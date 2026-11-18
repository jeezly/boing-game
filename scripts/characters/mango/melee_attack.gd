extends Node
## Camera-directed close shove. Damage is occlusion-tested from Mango, not the camera.
@export var reach: float = 2.35
@export var damage: float = 32.0
@export var interval: float = 0.55
var cooldown: float = 0.0
var motion: float = 0.0
var fist: Node3D
@onready var player = get_parent()
func _ready() -> void:
	await player.ready
	fist = Node3D.new()
	fist.name = "melee_glove"
	player.camera_rig.first_camera.add_child(fist)
	var builder = load("res://scripts/components/visual_mesh_builder.gd")
	var mat = builder.material(Color("ffcb58"))
	builder.oval(fist, "palm", Vector3.ZERO, Vector3(0.22, 0.20, 0.25), mat)
	builder.rod(fist, "forearm", Vector3(0.02,-0.22,0.40),Vector3(0,-0.02,0.08),0.070,mat)
	builder.oval(fist,"wrist_cuff",Vector3(0,-0.045,0.10),Vector3(0.16,0.08,0.16),mat)
	for i in range(3): builder.oval(fist, "knuckle", Vector3(-0.07 + i * 0.07, 0.035, -0.10), Vector3(0.07, 0.10, 0.10), mat)
	fist.hide()
func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	motion = maxf(0.0, motion - delta)
	if is_instance_valid(fist):
		fist.visible = motion > 0 and player.hp > 0 and not player.camera_rig.third_person
		fist.position = Vector3(-0.28 + sin(motion / 0.24 * PI) * 0.12, -0.25, -0.48 - sin(motion / 0.24 * PI) * 0.38)
	if motion > 0 and player.hp > 0:
		player.mango.pose_melee(1.0 - motion / 0.24)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("melee") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if strike(): get_viewport().set_input_as_handled()
func strike() -> bool:
	if cooldown > 0 or player.hp <= 0 or not player.combat_enabled or get_tree().paused: return false
	cooldown = interval
	motion = 0.24
	player.mango.on_fired()
	var origin: Vector3 = player.global_position + Vector3.UP * 1.0
	var forward: Vector3 = -player.camera_rig.get_active_camera().global_basis.z
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.dead: continue
		var point: Vector3 = enemy.global_position + Vector3.UP * 0.95
		var offset := point - origin
		if offset.length() > reach or offset.normalized().dot(forward) < 0.55: continue
		var ray := PhysicsRayQueryParameters3D.create(origin, point, 1, [player.get_rid()])
		if not player.get_world_3d().direct_space_state.intersect_ray(ray).is_empty(): continue
		enemy.take_damage(damage * player.get_node("power_state").damage_multiplier())
		enemy.velocity += offset.normalized() * 4.0
		player.get_node("arsenal").feedback.emit(&"hit", "")
		load("res://scripts/game/production/pickup_burst.gd").spawn(get_tree().current_scene, point, Color("ffd761"))
	return true
