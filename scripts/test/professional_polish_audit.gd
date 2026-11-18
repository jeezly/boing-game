extends SceneTree
## Integration contracts for the resumed pass. Tests real project nodes and collisions.
var checks: int = 0
var failures: Array[String] = []
var game: Node3D
var p: CharacterBody3D
var m: Node
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message); push_error(message)
func frames(count: int = 3) -> void:
	for i in range(count): await physics_frame
func spawn_enemy(index: int, at: Vector3) -> CharacterBody3D:
	m.director._spawn(m.director.enemy_definitions[index],at)
	var enemy: CharacterBody3D = m.director.enemy_root.get_child(-1)
	enemy.set_physics_process(false)
	return enemy
func run() -> void:
	game = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(5)
	p = game.get_node("Player")
	m = game.get_node("match_controller")
	m._on_entrance(p)
	m.director.running = false
	for pickup in game.get_node("mega_abarrotera").get_children():
		if String(pickup.name).begins_with("pickup_"):
			check(m.respawns._clear_geometry(pickup.global_position + Vector3.UP*0.05),"accessible production pickup " + pickup.name)
	p.global_position = Vector3(0,0.05,-20)
	p.camera_rig.rotation = Vector3.ZERO
	p.camera_rig.pitch_pivot.rotation = Vector3.ZERO
	p.set_physics_process(false)
	var powers = p.get_node("power_state")
	var arsenal = p.get_node("arsenal")
	var melee = p.get_node("melee_attack")
	check(InputMap.action_get_events("melee")[0].button_index == MOUSE_BUTTON_RIGHT,"right click maps to melee")
	check(not InputMap.has_action("special"),"removed special action")
	check(not powers.collect(&"love") and not powers.collect(&"amor"),"removed effects rejected")
	for kind in [&"ice",&"chile",&"candle",&"happy"]:
		powers.clear()
		check(powers.collect(kind) and powers.effects[kind] == 30.0,"30 second effect " + kind)
		powers._physics_process(12.0)
		powers.collect(kind)
		check(powers.effects[kind] == 30.0,"refresh without accumulation " + kind)
		m.pause()
		await frames(4)
		check(powers.effects[kind] == 30.0,"pause freezes " + kind)
		m.resume()
		powers._physics_process(30.1)
		check(not powers.active(kind),"expiration " + kind)
	powers.collect(&"ice")
	p.take_damage(40)
	check(p.hp == 80,"ice halves damage")
	powers.collect(&"candle")
	check(powers.detection_range() == 3.5,"ghost limited detection")
	powers._physics_process(0)
	check(powers.surfaces[0].mesh.get_active_material(powers.surfaces[0].surface) == powers.surfaces[0].material,"power materials are actually bound for rendering")
	check(powers.surfaces[0].material.albedo_color.a < 0.5 and powers.skin_material.get_shader_parameter("ghost_alpha") < 0.5,"Compatibility ghost material alpha visible")
	for index in [0,1]:
		var enemy := spawn_enemy(index,p.global_position+Vector3(0,0,-8))
		enemy.cooldown = 0
		enemy._physics_process(0.1)
		check(enemy.windup < 0,"ghost prevents distant attack " + str(index))
		enemy.queue_free()
	await frames()
	powers.clear()
	powers._physics_process(0)
	check(powers.surfaces[0].material.albedo_color.a == 1 and powers.skin_material.get_shader_parameter("ghost_alpha") == 1.0,"ghost expiration restores opacity")
	for slot in [2,4]: arsenal.owned[slot] = true; arsenal.ammo[slot] = 0
	var pickup = game.get_node("mega_abarrotera/pickup_ammo")
	pickup.collect(p)
	check(pickup.used and not pickup.visible and arsenal.ammo[2] == 2 and arsenal.ammo[4] == 2,"world huacal refills all owned limited weapons")
	pickup._physics_process(25.1)
	check(not pickup.used and pickup.visible,"ammo world respawn")
	arsenal.refill()
	pickup.collect(p)
	check(not pickup.used,"full reserve leaves huacal intact")
	powers.collect(&"happy")
	for slot in [2,4]:
		arsenal.equip(slot)
		arsenal.ammo[slot] = 0
		arsenal.cooldown = 0
		check(arsenal.fire() and arsenal.ammo[slot] == 0,"tequila zero-reserve weapon " + str(slot))
	var hp: float = p.hp
	p.take_damage(999)
	check(p.hp == hp,"tequila immunity")
	p.camera_rig._process(0.5)
	check(absf(p.camera_rig.first_camera.rotation.z) > 0.001 and absf(p.camera_rig.first_camera.rotation.z) < 0.03,"bounded camera sway")
	powers._physics_process(30.1)
	arsenal.cooldown = 0
	check(not arsenal.fire(),"zero reserve becomes empty again after tequila")
	p.take_damage(10)
	check(p.hp < hp,"immunity expires")
	for node in get_nodes_in_group("projectiles"): node.queue_free()
	await frames()
	for index in [0,1]:
		var victim := spawn_enemy(index,p.global_position+Vector3(0,0,-1.5))
		var previous: float = victim.hp
		melee.cooldown = 0
		check(melee.strike() and victim.hp == previous-32,"melee hits enemy " + str(index))
		check(not melee.strike() and victim.hp == previous-32,"melee cooldown prevents duplicate hits")
		var hit = victim.get_node("hit_tint")
		check(hit.meshes.size() > 0 and hit.meshes[0].material_overlay != null,"enemy red hit overlay " + str(index))
		hit._process(0.2)
		check(hit.meshes[0].material_overlay == null,"enemy flash clears " + str(index))
		victim.queue_free()
	await frames()
	var wall := StaticBody3D.new()
	wall.collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3,3,0.2)
	shape.shape = box
	wall.add_child(shape)
	game.add_child(wall)
	wall.global_position = p.global_position + Vector3(0,1,-0.7)
	var blocked := spawn_enemy(0,p.global_position+Vector3(0,0,-1.5))
	await frames()
	melee.cooldown = 0
	melee.strike()
	check(blocked.hp == blocked.max_hp,"melee cannot hit through wall")
	m.pause()
	melee.cooldown = 0
	check(not melee.strike(),"melee forbidden in pause")
	m.resume()
	var beacon = game.get_node("mega_abarrotera/objective_markers/cajas/beacon")
	check(beacon.get_node("beam").mesh.height >= 10,"tall hot-zone column")
	check(beacon.get_node("ring").mesh.outer_radius > 2.5,"large hot-zone floor ring")
	check(arsenal.definitions[1].reach == 21 and arsenal.definitions[1].pro_damage > 50,"Chancla range and upgrade tuning")
	print("PROFESSIONAL_POLISH: %d checks, %d failures" % [checks,failures.size()])
	quit(0 if failures.is_empty() else 1)
