extends Node3D
## Articulated fruit model, facing local -Z. Presentation stays outside movement logic.

const Builder = preload("res://scripts/player/mango_mesh_builder.gd")
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var weapon_socket: Node3D
var clock: float = 0.0
var firing_time: float = 0.0
var arm_parts: Dictionary = {}
var visual_aim: Vector2 = Vector2.ZERO

func _ready() -> void:
	var orange := Builder.material(Color("f69b24"))
	var yellow := Builder.material(Color("ffbf39"))
	var leather := Builder.material(Color("493025"))
	var tan := Builder.material(Color("bd792d"))
	var sole := Builder.material(Color("674126"))
	var cream := Builder.material(Color("fff0ce"))
	var dark := Builder.material(Color("241b16"))
	var metal := Builder.material(Color("82796a"))
	var glass := Builder.material(Color("526c67"))
	var green := Builder.material(Color("58872b"))
	Builder.oval(self, "fruit_body", Vector3(0, 1.03, 0), Vector3(0.91, 1.24, 0.72), orange)
	Builder.oval(self, "golden_face", Vector3(0, 1.18, -0.20), Vector3(0.75, 0.91, 0.43), yellow)
	# Upper hemisphere leaves the face exposed, with separate leather ear flaps.
	var cap := SphereMesh.new()
	cap.radius = 0.48
	cap.height = 0.96
	cap.is_hemisphere = true
	var helmet := MeshInstance3D.new()
	helmet.name = "pilot_helmet"
	helmet.mesh = cap
	helmet.material_override = leather
	add_child(helmet)
	helmet.position = Vector3(0, 1.39, 0)
	helmet.scale = Vector3(1.0, 0.66, 0.86)
	for side in [-1.0, 1.0]:
		Builder.oval(self, "ear_flap", Vector3(side * 0.39, 1.32, 0.01), Vector3(0.16, 0.53, 0.53), leather)
		Builder.rod(self, "chin_strap", Vector3(side * 0.40, 1.12, -0.12), Vector3(side * 0.39, 0.85, -0.18), 0.018, leather)
		Builder.oval(self, "eye_white", Vector3(side * 0.17, 1.36, -0.384), Vector3(0.22, 0.25, 0.08), cream)
		Builder.oval(self, "eye_iris", Vector3(side * 0.17 + 0.018, 1.36, -0.426), Vector3(0.105, 0.14, 0.035), sole)
		Builder.oval(self, "eye_pupil", Vector3(side * 0.17 + 0.018, 1.36, -0.445), Vector3(0.060, 0.095, 0.02), dark)
		Builder.oval(self, "eye_glint", Vector3(side * 0.17, 1.39, -0.459), Vector3(0.022, 0.028, 0.01), cream)
		var brow := Builder.oval(self, "expressive_brow", Vector3(side * 0.18, 1.51, -0.39), Vector3(0.24, 0.065, 0.08), dark)
		brow.rotation.z = side * -0.22
		Builder.oval(self, "goggle_frame", Vector3(side * 0.21, 1.68, -0.28), Vector3(0.32, 0.22, 0.12), metal)
		Builder.oval(self, "goggle_lens", Vector3(side * 0.21, 1.68, -0.345), Vector3(0.25, 0.16, 0.035), glass)
	Builder.rod(self, "goggle_bridge", Vector3(-0.08, 1.68, -0.30), Vector3(0.08, 1.68, -0.30), 0.025, leather)
	Builder.rod(self, "helmet_seam", Vector3(0, 1.73, -0.15), Vector3(0, 1.72, 0.21), 0.012, tan)
	Builder.oval(self, "nose", Vector3(0, 1.23, -0.46), Vector3(0.29, 0.21, 0.24), orange)
	var smile := Builder.oval(self, "smile", Vector3(0.015, 1.06, -0.406), Vector3(0.32, 0.095, 0.04), dark)
	smile.rotation.z = -0.12
	Builder.oval(self, "smile_teeth", Vector3(0.02, 1.079, -0.43), Vector3(0.25, 0.035, 0.018), cream)
	Builder.oval(self, "chin", Vector3(0, 0.94, -0.37), Vector3(0.22, 0.18, 0.12), yellow)
	Builder.oval(self, "leather_backpack", Vector3(0, 1.10, 0.38), Vector3(0.51, 0.58, 0.23), leather)
	Builder.oval(self, "backpack_patch", Vector3(0, 1.12, 0.51), Vector3(0.25, 0.26, 0.025), tan)
	var leaf := Builder.oval(self, "leaf_badge", Vector3(0, 1.12, 0.535), Vector3(0.10, 0.18, 0.025), green)
	leaf.rotation.z = -0.4
	left_leg = _limb("left_leg", Vector3(-0.22, 0.49, 0))
	right_leg = _limb("right_leg", Vector3(0.22, 0.49, 0))
	for leg in [left_leg, right_leg]:
		Builder.rod(leg, "shin", Vector3.ZERO, Vector3(0, -0.25, 0), 0.06, yellow)
		Builder.oval(leg, "boot", Vector3(0, -0.32, -0.07), Vector3(0.30, 0.29, 0.43), tan)
		Builder.oval(leg, "boot_cuff", Vector3(0, -0.21, 0), Vector3(0.25, 0.11, 0.25), leather)
		Builder.oval(leg, "boot_sole", Vector3(0, -0.425, -0.08), Vector3(0.32, 0.08, 0.45), sole)
		for index in range(3):
			Builder.rod(leg, "lace", Vector3(-0.08, -0.25 - index * 0.035, -0.17), Vector3(0.08, -0.27 - index * 0.035, -0.17), 0.009, cream)
	left_arm = _limb("left_arm", Vector3(-0.43, 1.25, 0))
	right_arm = _limb("right_arm", Vector3(0.43, 1.25, 0))
	for arm in [left_arm, right_arm]:
		arm_parts[arm] = {
			"upper": Builder.rod(arm, "upper_arm", Vector3.ZERO, Vector3(0, -0.23, -0.03), 0.055, yellow),
			"fore": Builder.rod(arm, "forearm", Vector3(0, -0.23, -0.03), Vector3(0, -0.39, -0.14), 0.06, yellow),
			"hand": Builder.oval(arm, "glove", Vector3(0, -0.40, -0.15), Vector3(0.19, 0.21, 0.19), yellow),
			"thumb": Builder.oval(arm, "thumb", Vector3(-0.08, -0.36, -0.17), Vector3(0.08, 0.12, 0.10), yellow),
		}
	# Independent socket avoids inheriting shoulder rotations and crossing the torso.
	weapon_socket = _limb("weapon_socket", Vector3(0.48, 0.86, -0.70))

func _limb(part_name: String, at: Vector3, parent: Node3D = null) -> Node3D:
	if parent == null:
		parent = self
	var part := Node3D.new()
	part.name = part_name
	parent.add_child(part)
	part.position = at
	return part

func present(delta: float, speed: float, grounded: bool, _pitch: float, _aiming: bool) -> void:
	clock += delta * (5.0 + speed * 1.3)
	firing_time = maxf(0.0, firing_time - delta)
	var stride := minf(speed / 8.0, 1.0) * 0.55
	left_leg.rotation.x = sin(clock) * stride if grounded else -0.35
	right_leg.rotation.x = -sin(clock) * stride if grounded else 0.35
	position.y = sin(clock * 0.5) * (0.015 + stride * 0.03) if grounded else 0.0
	# Weapon presentation owns arm posing so hands and elastic update together.
	# Camera pitch is intentionally not applied directly to the shoulders.

func pose_slingshot(delta: float, target: Vector3, draw_point: Vector3, aiming: bool) -> void:
	var blend := 1.0 - exp(-14.0 * delta)
	var aim := aiming or firing_time > 0.0
	var local_pouch := weapon_socket.to_local(draw_point)
	var local_direction := (to_local(target) - weapon_socket.position).normalized()
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
		_pose_arm(left_arm, Vector3(-0.32, 1.16, -0.47), pull_hand, blend)
	else:
		_pose_arm(left_arm, left_arm.position + Vector3(0, -0.23, -0.03), left_arm.position + Vector3(0, -0.40, -0.15 - sin(clock) * 0.06), blend)

func _pose_arm(arm: Node3D, elbow: Vector3, hand: Vector3, blend: float, hold_grip: bool = false) -> void:
	var parts: Dictionary = arm_parts[arm]
	var glove: MeshInstance3D = parts["hand"]
	var upper: MeshInstance3D = parts["upper"]
	var fore: MeshInstance3D = parts["fore"]
	var old_elbow := upper.position * 2.0
	var local_elbow := old_elbow.lerp(elbow - arm.position, blend)
	# Socket motion is already smoothed; keep the holding glove attached to its grip.
	var local_hand := hand - arm.position if hold_grip else glove.position.lerp(hand - arm.position, blend)
	_set_segment(upper, Vector3.ZERO, local_elbow)
	_set_segment(fore, local_elbow, local_hand)
	glove.position = local_hand
	var thumb: MeshInstance3D = parts["thumb"]
	thumb.position = local_hand + Vector3(-0.07, 0.04, -0.02)

func _set_segment(part: MeshInstance3D, start: Vector3, end: Vector3) -> void:
	var axis := (end - start).normalized()
	var side := Vector3.RIGHT if absf(axis.dot(Vector3.RIGHT)) < 0.95 else Vector3.FORWARD
	var z_axis := side.cross(axis).normalized()
	var cylinder := part.mesh as CylinderMesh
	part.position = (start + end) * 0.5
	part.basis = Basis(axis.cross(z_axis), axis, z_axis)
	part.scale.y = start.distance_to(end) / cylinder.height

func on_fired() -> void:
	firing_time = 0.3
