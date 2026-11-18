extends Node
## Authoritative per-match inventory; presentation is a subscriber.
signal changed
signal feedback(event: StringName, detail: String)
const Definition = preload("res://scripts/weapons/weapon_definition.gd")
var definitions: Array[Resource] = []
var owned: Dictionary = {0: true}
var upgraded: Dictionary = {}
var ammo: Dictionary = {}
var selected: int = 0
var cooldown: float = 0.0
@onready var player = get_parent()
var first_visual: Node3D
var third_visual: Node3D

func _ready() -> void:
	set_physics_process(false)
	await player.ready
	set_physics_process(true)
	for key in ["resortera", "chancla", "molcajete", "nopal", "cuete"]:
		definitions.append(load("res://resources/weapons/" + key + ".tres"))
	first_visual = Node3D.new()
	player.camera_rig.first_camera.add_child(first_visual)
	first_visual.position = Vector3(0.31, -0.34, -0.75)
	third_visual = Node3D.new()
	player.mango.weapon_socket.add_child(third_visual)
	_refresh_visual()

func current() -> Resource:
	return definitions[selected]

func title(slot: int) -> String:
	return definitions[slot].pro_name if upgraded.has(slot) else definitions[slot].display_name

func equip(slot: int) -> bool:
	if not owned.has(slot) or slot < 0 or slot >= definitions.size(): return false
	selected = slot
	cooldown = maxf(cooldown, 0.22)
	_refresh_visual()
	changed.emit()
	feedback.emit(&"weapon_equipped", title(slot))
	return true

func cycle(step: int) -> void:
	for offset in range(1, 6):
		var slot := posmod(selected + step * offset, 5)
		if owned.has(slot):
			equip(slot)
			return

func purchase(slot: int, pro: bool, match_state: Node) -> String:
	if slot <= 0 or slot >= definitions.size() or not definitions[slot].available: return "NO DISPONIBLE"
	var hud = player.get_tree().current_scene.get_node("HUD")
	var shop = match_state.environment.get_node("healing_station")
	if hud.modal_kind != "shop" or not shop.is_available(player): return "NO DISPONIBLE"
	if match_state.resume_state != match_state.State.PLAYING or not get_tree().paused or match_state.respawning: return "NO DISPONIBLE"
	if pro and not owned.has(slot): return "REQUIERE ARMA BASE"
	if pro and upgraded.has(slot): return "PRO ADQUIRIDA"
	if not pro and owned.has(slot):
		equip(slot)
		return "EQUIPADO"
	var price: int = definitions[slot].upgrade_price if pro else definitions[slot].price
	if match_state.spendable_credits < price: return "SIN CRÉDITOS"
	match_state.spendable_credits -= price
	match_state.credits_changed.emit(match_state.spendable_credits)
	owned[slot] = true
	if pro: upgraded[slot] = true
	else: ammo[slot] = definitions[slot].max_ammo
	equip(slot)
	feedback.emit(&"purchase", title(slot))
	return "PRO ADQUIRIDA" if pro else "COMPRADO"

func refill() -> bool:
	var gained := false
	for slot in owned:
		var maximum: int = definitions[slot].max_ammo
		if maximum > 0 and int(ammo.get(slot, 0)) < maximum:
			ammo[slot] = mini(maximum, int(ammo.get(slot, 0)) + ceili(maximum * 0.5))
			gained = true
	if gained: changed.emit()
	return gained

func damage_value() -> float:
	return (current().pro_damage if upgraded.has(selected) else current().damage) * player.get_node("power_state").damage_multiplier()

func _refresh_visual() -> void:
	for root in [first_visual, third_visual]:
		for child in root.get_children():
			root.remove_child(child)
			child.queue_free()
		if selected != 0: load("res://scripts/game/production/prop_factory.gd").weapon(root, selected, upgraded.has(selected))
	first_visual.scale = Vector3.ONE * 0.7
	third_visual.scale = Vector3.ONE * 0.7
	_update_visibility()

func _update_visibility() -> void:
	var sling = player.get_node("mango_slingshot")
	sling.first_visual.visible = selected == 0 and not player.camera_rig.third_person and player.hp > 0
	sling.third_visual.visible = selected == 0 and player.camera_rig.third_person
	first_visual.visible = selected != 0 and not player.camera_rig.third_person and player.hp > 0
	third_visual.visible = selected != 0 and player.camera_rig.third_person and player.hp > 0

func _physics_process(delta: float) -> void:
	_update_visibility()
	cooldown = maxf(0.0, cooldown - delta)
	first_visual.position.y = move_toward(first_visual.position.y, -0.34, delta * 1.5)
	if selected == 0 or not player.combat_enabled or player.hp <= 0: return
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire") and cooldown <= 0: fire()

func fire() -> bool:
	if selected == 0 or cooldown > 0 or not player.combat_enabled or player.hp <= 0 or get_tree().paused: return false
	if current().max_ammo > 0 and not player.get_node("power_state").active(&"happy") and int(ammo.get(selected, 0)) <= 0:
		feedback.emit(&"empty", "SIN MUNICIÓN")
		cooldown = 0.3
		return false
	var camera: Camera3D = player.camera_rig.get_active_camera()
	var origin: Vector3 = player.global_position + Vector3.UP * 1.25
	var aim: Vector3 = player.get_node("mango_slingshot")._get_aim_point()
	var shot = load("res://scripts/projectiles/arsenal_projectile.gd").new()
	shot.slot = selected
	shot.pro = upgraded.has(selected)
	shot.source = player
	shot.damage = damage_value()
	shot.speed = current().speed * (1.25 if shot.pro and selected == 1 else 1.0)
	shot.reach = current().reach * (1.4 if shot.pro else 1.0)
	shot.radius = current().radius * (1.4 if shot.pro else 1.0)
	player.get_tree().current_scene.add_child(shot)
	shot.global_position = origin
	shot.velocity = (aim - origin).normalized() * shot.speed
	if selected == 2:
		var offset: Vector3 = aim - origin
		if offset.length() > current().reach: offset = offset.normalized() * current().reach
		var flight_time := clampf(Vector2(offset.x, offset.z).length() / shot.speed, 0.3, 2.2)
		shot.velocity = offset / flight_time + Vector3.UP * 4.9 * flight_time
	if current().max_ammo > 0 and not player.get_node("power_state").active(&"happy"): ammo[selected] -= 1
	cooldown = current().cooldown * (0.82 if upgraded.has(selected) else 1.0) / player.get_node("power_state").cadence_multiplier()
	first_visual.position.y -= 0.10
	player.mango.on_fired()
	changed.emit()
	feedback.emit(&"weapon_fired", title(selected))
	return true
