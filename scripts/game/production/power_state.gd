extends Node
## Refresh to 30 seconds on repeat collection; different effects coexist.
signal changed
signal feedback(event: StringName, detail: String)
const DURATION: float = 30.0
var effects: Dictionary = {}
@onready var player = get_parent()
var clock: float = 0.0
var aura: MeshInstance3D
var aura_material: StandardMaterial3D
var surfaces: Array[Dictionary] = []
var geometry: Array[GeometryInstance3D] = []
var smoke_clock: float = 0.0
var skin_material: ShaderMaterial

func _ready() -> void:
	aura = MeshInstance3D.new()
	aura.name = "power_aura"
	var ring := TorusMesh.new()
	ring.inner_radius = 0.49
	ring.outer_radius = 0.55
	ring.rings = 32
	ring.ring_segments = 6
	aura.mesh = ring
	aura_material = StandardMaterial3D.new()
	aura_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	aura_material.emission_enabled = true
	aura.material_override = aura_material
	aura.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	player.add_child.call_deferred(aura)
	aura.position.y = 0.12
	aura.visible = false
	_bind_surfaces.call_deferred()

func _bind_surfaces() -> void:
	for mesh in player.get_node("mango_visual").find_children("*", "GeometryInstance3D", true, false): geometry.append(mesh)
	for mesh in player.get_node("mango_visual").find_children("*", "MeshInstance3D", true, false):
		for index in range(mesh.mesh.get_surface_count()):
			var original: Material = mesh.get_active_material(index)
			if original is StandardMaterial3D:
				var material := original.duplicate() as StandardMaterial3D
				if mesh.material_override != null: mesh.material_override = material
				else: mesh.set_surface_override_material(index, material)
				surfaces.append({"material": material, "mesh": mesh, "surface": index, "color": material.albedo_color, "name": String(mesh.name), "transparency": material.transparency})
			elif original is ShaderMaterial and String(mesh.name) == "mango_skin":
				skin_material = original.duplicate() as ShaderMaterial
				if mesh.material_override != null: mesh.material_override = skin_material
				else: mesh.set_surface_override_material(index,skin_material)

func _physics_process(delta: float) -> void:
	clock += delta
	smoke_clock -= delta
	if active(&"chile") and player.hp > 0 and smoke_clock <= 0:
		smoke_clock = 0.45
		for side in [-1,1]:
			var at: Vector3 = player.global_position + player.mango.global_basis * Vector3(side*0.37,1.43,0)
			load("res://scripts/game/production/spicy_puff.gd").spawn(get_tree().current_scene,at)
	if player.hp <= 0 and not effects.is_empty(): clear()
	for key in effects.keys():
		effects[key] = maxf(0.0, float(effects[key]) - delta)
		if effects[key] <= 0:
			effects.erase(key)
			feedback.emit(&"expired", load("res://scripts/game/production/pickup.gd").NAMES.get(key, String(key)) + " - FIN")
			changed.emit()
	if is_instance_valid(aura):
		aura.visible = player.hp > 0 and not effects.is_empty()
		var tint := Color("ff982f") if active(&"happy") else (Color("ff573c") if active(&"chile") else (Color("74cfff") if active(&"ice") else Color("b6a7ff")))
		aura_material.albedo_color = tint
		aura_material.emission = tint
		aura.scale = Vector3.ONE * (1.0 + sin(clock * 5) * 0.05)
	for entry in surfaces:
		var color: Color = entry.color
		if active(&"ice"): color = color.lerp(Color("74cfff"), 0.23)
		if active(&"chile") and ("face" in entry.name or "cheek" in entry.name or "body" in entry.name or "skin" in entry.name): color = color.lerp(Color("ff5335"), 0.28)
		if active(&"candle"): color.a *= 0.42
		entry.material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if active(&"candle") else entry.transparency
		entry.material.albedo_color = color
	if skin_material != null:
		skin_material.set_shader_parameter("ghost_alpha",0.42 if active(&"candle") else 1.0)
		skin_material.set_shader_parameter("power_tint",Color("ff5335") if active(&"chile") else Color("74cfff"))
		skin_material.set_shader_parameter("power_mix",0.30 if active(&"chile") else (0.23 if active(&"ice") else 0.0))

func active(key: StringName) -> bool:
	return float(effects.get(key, 0)) > 0

func collect(kind: StringName) -> bool:
	if player.hp <= 0 or not player.combat_enabled or get_tree().paused: return false
	match kind:
		&"health":
			if player.hp >= player.max_hp: return false
			player.heal(30)
		&"ammo":
			if not player.get_node("arsenal").refill(): return false
		&"candle", &"ice", &"chile", &"happy": effects[kind] = DURATION
		_: return false
	feedback.emit(&"pickup", String(kind))
	changed.emit()
	return true

func damage_multiplier() -> float:
	return (1.5 if active(&"chile") else 1.0) * (1.35 if active(&"happy") else 1.0)

func cadence_multiplier() -> float:
	return (1.3 if active(&"chile") else 1.0) * (1.6 if active(&"happy") else 1.0)

func movement_multiplier() -> float:
	return 1.0

func resistance() -> float:
	return 0.5 if active(&"ice") else 1.0

func detection_range() -> float:
	return 3.5 if active(&"candle") else 1000.0

func clear() -> void:
	effects.clear()
	changed.emit()
