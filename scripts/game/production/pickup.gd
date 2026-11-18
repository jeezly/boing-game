extends Area3D
signal collected(kind: StringName)
@export var kind: StringName = &"health"
var clock: float = 0
var used: bool = false
var visual: Node3D
const NAMES = {&"health": "BOTIQUÍN DE LA ABUELA", &"candle": "VELADORA", &"ice": "BOLSA DE HIELO", &"ammo": "HUACAL CON FRUTAS · MUNICIÓN", &"chile": "CHILE", &"happy": "YA SE ME CALENTÓ EL HOCICO"}
const COLORS = {&"health": Color("ff4564"), &"ammo": Color("b4ff52"), &"ice": Color("63dcff"), &"chile": Color("ff6335"), &"candle": Color("bca0ff"), &"happy": Color("ffc044")}
var respawn_left: float = 0.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.65
	shape.shape = sphere
	shape.position.y = 0.6
	add_child(shape)
	visual = Node3D.new()
	add_child(visual)
	load("res://scripts/game/production/prop_factory.gd").pickup(visual, kind)
	var title = load("res://scripts/game/production/prop_factory.gd").label(self, NAMES[kind], Vector3(0, 1.12, 0), 24)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	title.visibility_range_end = 13
	var halo := MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.36
	ring.outer_radius = 0.40
	ring.rings = 24
	ring.ring_segments = 6
	halo.mesh = ring
	var glow := StandardMaterial3D.new()
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow.albedo_color = COLORS[kind]
	glow.emission_enabled = true
	glow.emission = COLORS[kind]
	halo.material_override = glow
	halo.position.y = 0.08
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(halo)
	body_entered.connect(collect)
func _process(delta: float) -> void:
	clock += delta
	visual.position.y = 0.6 + sin(clock * 2.5) * 0.07
	visual.rotation.y += delta * 0.5
func collect(body: Node3D) -> void:
	if used or not body.is_in_group("player") or not body.has_node("power_state"): return
	if body.get_node("power_state").collect(kind):
		used = true
		collected.emit(kind)
		hide()
		respawn_left = 25.0 if kind == &"ammo" else 50.0
		load("res://scripts/game/production/pickup_burst.gd").spawn(get_tree().current_scene, global_position + Vector3.UP * 0.7, COLORS[kind], kind == &"health")
func _physics_process(_delta: float) -> void:
	if used:
		respawn_left -= _delta
		if respawn_left <= 0:
			used = false
			show()
		return
	for body in get_overlapping_bodies():
		collect(body)
		if used: break
