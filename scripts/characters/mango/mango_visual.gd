@tool
extends Node3D
## Editor-visible presentation; gameplay owns movement and camera yaw.
const Builder = preload("res://scripts/components/visual_mesh_builder.gd")
const Appearance = preload("res://scripts/characters/mango/mango_appearance.gd")
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
@onready var weapon_socket: Node3D = $presentation/weapon_socket
var clock: float = 0.0
var firing_time: float = 0.0
var arm_parts: Dictionary = {}
var visual_aim: Vector2 = Vector2.ZERO
const Reactions = preload("res://scripts/components/character_reactions.gd")
var reactions := Reactions.new()
var move_speed: float = 0.0
var on_ground: bool = true
@onready var presentation: Node3D = $presentation

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	Appearance.build($presentation/body, $presentation/face, $presentation/helmet)
	var yellow := Builder.material(Color("ffbd39"))
	var glove := Builder.material(Color("ffcf62"))
	left_leg = $presentation/limbs/left_leg
	right_leg = $presentation/limbs/right_leg
	for leg in [left_leg, right_leg]:
		Builder.rod(leg, "shin", Vector3(0, 0.025, 0), Vector3(0, -0.25, 0), 0.055, yellow)
		Builder.oval(leg, "ankle_join", Vector3(0, -0.20, 0), Vector3(0.12, 0.14, 0.12), yellow)
		Appearance.build_boot(leg)
	left_arm = $presentation/limbs/left_arm
	right_arm = $presentation/limbs/right_arm
	for arm in [left_arm, right_arm]:
		arm_parts[arm] = {
			"upper": Builder.rod(arm, "upper_arm", Vector3.ZERO, Vector3(0, -0.23, -0.03), 0.053, yellow),
			"fore": Builder.rod(arm, "forearm", Vector3(0, -0.23, -0.03), Vector3(0, -0.39, -0.14), 0.056, yellow),
			"elbow": Builder.oval(arm, "elbow_join", Vector3(0, -0.23, -0.03), Vector3.ONE * 0.113, yellow),
			"hand": Builder.oval(arm, "glove", Vector3(0, -0.40, -0.15), Vector3(0.17, 0.19, 0.17), glove),
			"thumb": Builder.oval(arm, "thumb", Vector3(-0.07, -0.36, -0.17), Vector3(0.075, 0.11, 0.09), glove),
			"cuff": Builder.oval(arm, "glove_cuff", Vector3(0, -0.35, -0.13), Vector3(0.145, 0.065, 0.145), glove),
		}
		Builder.oval(arm, "shoulder_join", Vector3.ZERO, Vector3.ONE * 0.125, yellow)
		var fingers: Array[MeshInstance3D] = []
		for index in range(3):
			fingers.append(Builder.oval(arm, "glove_finger", Vector3(0.012, -0.37 - index * 0.038, -0.21), Vector3(0.13, 0.045, 0.073), glove))
		arm_parts[arm]["fingers"] = fingers
	_pose_arm(right_arm, Vector3(0.56, 1.02, -0.33), weapon_socket.position + Vector3(0, -0.10, 0), 1.0, true)

	reactions.bind(presentation)

func present(_delta: float, speed: float, grounded: bool, _pitch: float, _aiming: bool) -> void:
	move_speed = speed
	on_ground = grounded

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or get_tree().paused: return
	var speed := 0.0 if reactions.dead else move_speed
	var grounded := on_ground
	clock += delta * (5.0 + speed * 1.3)
	firing_time = maxf(0.0, firing_time - delta)
	var stride := minf(speed / 8.0, 1.0) * 0.55
	left_leg.rotation.x = sin(clock) * stride if grounded else -0.35
	right_leg.rotation.x = -sin(clock) * stride if grounded else 0.35
	var bob := sin(clock * 0.5) * 0.008 + absf(sin(clock)) * stride * 0.055 if grounded else 0.0
	reactions.update(delta, presentation, bob, sin(clock) * stride * 0.025)
	$presentation/body.scale.y = 1.0 + sin(clock * 0.5) * 0.006 if not reactions.dead else 1.0

func pose_slingshot(delta: float, target: Vector3, draw_point: Vector3, aiming: bool) -> void:
	var blend := 1.0 - exp(-14.0 * delta)
	var aim := aiming or firing_time > 0.0
	var local_pouch := weapon_socket.to_local(draw_point)
	var local_direction := (presentation.to_local(target) - weapon_socket.position).normalized()
	var desired := Vector2(
		clampf(atan2(local_direction.y, Vector2(local_direction.x, local_direction.z).length()), deg_to_rad(-20.0), deg_to_rad(20.0)),
		clampf(atan2(-local_direction.x, -local_direction.z), deg_to_rad(-12.0), deg_to_rad(12.0))
	)
	visual_aim = visual_aim.lerp(desired if aim else Vector2.ZERO, blend)
	weapon_socket.rotation = Vector3(visual_aim.x, visual_aim.y, 0)
	var reaction := sin(clampf(firing_time / 0.16, 0.0, 1.0) * PI) * 0.025
	weapon_socket.position = weapon_socket.position.lerp(Vector3(0.48, 1.02 if aim else 0.86, -0.88 + reaction), blend)
	var grip := weapon_socket.position + weapon_socket.basis * Vector3(0, -0.10, 0)
	var pull_hand := weapon_socket.position + weapon_socket.basis * local_pouch
	_pose_arm(right_arm, Vector3(0.57, 1.06, -0.34), grip, blend, true)
	if aim:
		_pose_arm(left_arm, Vector3(-0.32, 1.16, -0.47), pull_hand, blend, true)
	else:
		_pose_arm(left_arm, left_arm.position + Vector3(0, -0.23, -0.03), left_arm.position + Vector3(0, -0.40, -0.15 - sin(clock) * 0.06), blend)

func _pose_arm(arm: Node3D, elbow: Vector3, hand: Vector3, blend: float, hold_grip: bool = false) -> void:
	var parts: Dictionary = arm_parts[arm]
	var glove: MeshInstance3D = parts["hand"]
	var upper: MeshInstance3D = parts["upper"]
	var fore: MeshInstance3D = parts["fore"]
	var local_elbow := (upper.position * 2.0).lerp(elbow - arm.position, blend)
	var local_hand := hand - arm.position if hold_grip else glove.position.lerp(hand - arm.position, blend)
	Builder.segment(upper, Vector3.ZERO, local_elbow)
	Builder.segment(fore, local_elbow, local_hand)
	glove.position = local_hand
	parts["elbow"].position = local_elbow
	parts["thumb"].position = local_hand + Vector3(-0.067, 0.03, -0.025)
	parts["cuff"].position = local_hand + (local_elbow - local_hand).normalized() * 0.066
	var fingers: Array[MeshInstance3D] = parts["fingers"]
	for index in range(fingers.size()):
		fingers[index].position = local_hand + Vector3(0.012, 0.045 - index * 0.038, -0.060)

func on_fired() -> void:
	firing_time = 0.3
	reactions.fire()

func on_hit() -> void:
	reactions.hit()

func on_death() -> void:
	reactions.die(-1.0)

func reset_after_life_loss() -> void:
	reactions.reset(presentation)
	move_speed = 0.0
	firing_time = 0.0
	left_leg.rotation = Vector3.ZERO
	right_leg.rotation = Vector3.ZERO
