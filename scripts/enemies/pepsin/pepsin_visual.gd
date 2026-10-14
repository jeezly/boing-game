@tool
extends Node3D
## Scene groups own art; procedural posing never moves the enemy collision body.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Appearance = preload("res://scripts/enemies/pepsin/pepsin_appearance.gd")
const Batcher = preload("res://scripts/components/visual_batcher.gd")
const Reactions = preload("res://scripts/components/character_reactions.gd")
var reactions := Reactions.new()
var phase: float = 0.0
var move_speed: float = 0.0
var aiming: bool = false
var aim_target := Vector3.ZERO
var arm_parts: Dictionary = {}
@onready var presentation: Node3D = $presentation
@onready var weapon_mount: Node3D = $presentation/weapon_mount
@onready var blaster = $presentation/weapon_mount/blaster
@onready var left_leg: Node3D = $presentation/limbs/left_leg
@onready var right_leg: Node3D = $presentation/limbs/right_leg

func _ready() -> void:
	var lobes: Array[Node3D] = [$presentation/cap/left_lobe, $presentation/cap/right_lobe]
	Appearance.build($presentation/torso, $presentation/face, $presentation/cap, lobes)
	Appearance.boot(left_leg)
	Appearance.boot(right_leg)
	var blue := B.material(Color("0867d9"))
	var red := B.material(Color("e82d4b"))
	var white := B.material(Color("f8f1e7"))
	for arm in [$presentation/limbs/left_arm, $presentation/limbs/right_arm]:
		arm_parts[arm] = {
			"upper": B.rod(arm, "puffy_sleeve", Vector3.ZERO, Vector3(0, -0.14, -0.10), 0.078, blue),
			"fore": B.rod(arm, "fore_sleeve", Vector3(0, -0.14, -0.10), Vector3(0, -0.18, -0.23), 0.073, blue),
			"elbow": B.oval(arm, "elbow_join", Vector3(0, -0.14, -0.10), Vector3.ONE * 0.16, blue),
			"cuff": B.oval(arm, "red_cuff", Vector3(0, -0.18, -0.20), Vector3.ONE * 0.16, red),
			"hand": B.oval(arm, "white_glove", Vector3(0, -0.18, -0.26), Vector3(0.16, 0.18, 0.16), white),
			"thumb": B.oval(arm, "thumb", Vector3(-0.06, -0.16, -0.29), Vector3(0.067, 0.10, 0.08), white),
		}
		B.oval(arm, "shoulder_join", Vector3.ZERO, Vector3.ONE * 0.18, blue)
		var fingers: Array[MeshInstance3D] = []
		for index in range(3):
			fingers.append(B.oval(arm, "finger", Vector3.ZERO, Vector3(0.12, 0.04, 0.06), white))
		arm_parts[arm]["fingers"] = fingers
	aim_target = to_global(Vector3(0, 1, -8))
	_pose_weapon(0.0)
	# Merge only immutable art; preserve all authored poses/markers and editor detail.
	Batcher.merge_children($presentation/torso, "pepsin_torso")
	Batcher.merge_children($presentation/face, "pepsin_face")
	Batcher.merge_children($presentation/cap, "pepsin_cap")
	Batcher.merge_children($presentation/cap/left_lobe, "pepsin_left_cap")
	Batcher.merge_children($presentation/cap/right_lobe, "pepsin_right_cap")
	Batcher.merge_children(left_leg, "pepsin_boot")
	Batcher.merge_children(right_leg, "pepsin_boot")
	reactions.bind(presentation)

func present(_delta: float, speed: float, target: Vector3, winding_up: bool) -> void:
	move_speed = speed
	aim_target = target
	aiming = winding_up

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	phase += delta * (3.8 + move_speed * 2.4)
	var stride := minf(move_speed * 0.14, 0.48) if not reactions.dead else 0.0
	left_leg.rotation.x = sin(phase) * stride
	right_leg.rotation.x = -left_leg.rotation.x
	var bob := sin(phase * 0.5) * 0.009 + absf(sin(phase)) * stride * 0.05
	reactions.update(delta, presentation, bob, sin(phase) * stride * 0.045)
	if reactions.dead: return
	$presentation/torso.scale.y = 1.0 + sin(phase * 0.5) * 0.012
	$presentation/cap/left_lobe.rotation.z = sin(phase) * (0.012 + stride * 0.04)
	$presentation/cap/right_lobe.rotation.z = -sin(phase + 0.4) * (0.012 + stride * 0.04)
	_pose_weapon(delta)

func _pose_weapon(delta: float) -> void:
	var blend := 1.0 if delta <= 0.0 else 1.0 - exp(-14.0 * delta)
	var local_target := presentation.to_local(aim_target)
	var direction := local_target - weapon_mount.position
	var pitch := clampf(atan2(direction.y, Vector2(direction.x, direction.z).length()), -0.35, 0.35)
	weapon_mount.rotation.x = lerpf(weapon_mount.rotation.x, pitch, blend)
	weapon_mount.position.y = lerpf(weapon_mount.position.y, 0.85 if aiming else 0.81, blend)
	blaster.set_anticipation(aiming)
	_pose_arm($presentation/limbs/right_arm, Vector3(0.39, 0.74, -0.11), presentation.to_local(blaster.get_node("grip_socket").global_position))
	_pose_arm($presentation/limbs/left_arm, Vector3(-0.29, 0.72, -0.25), presentation.to_local(blaster.get_node("support_socket").global_position))

func _pose_arm(arm: Node3D, elbow: Vector3, hand: Vector3) -> void:
	var parts: Dictionary = arm_parts[arm]
	var local_elbow := elbow - arm.position
	var local_hand := hand - arm.position
	B.segment(parts["upper"], Vector3.ZERO, local_elbow)
	B.segment(parts["fore"], local_elbow, local_hand)
	parts["elbow"].position = local_elbow
	parts["hand"].position = local_hand
	parts["thumb"].position = local_hand + Vector3(-0.055, 0.025, -0.01)
	parts["cuff"].position = local_hand + (local_elbow - local_hand).normalized() * 0.085
	var fingers: Array[MeshInstance3D] = parts["fingers"]
	for index in range(fingers.size()):
		fingers[index].position = local_hand + Vector3(0.005, 0.036 - index * 0.032, -0.055)

func hit_flash() -> void:
	reactions.hit()
	aiming = false
	blaster.set_anticipation(false)

func play_death(sign_direction: float) -> void:
	reactions.die(sign_direction)
	blaster.set_anticipation(false)

func muzzle_position() -> Vector3:
	return blaster.get_node("barrel/projectile_socket").global_position

func fire_reaction() -> void:
	reactions.fire()
	blaster.kick()
