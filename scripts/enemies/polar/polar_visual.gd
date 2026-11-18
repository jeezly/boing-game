extends Node3D
## Polar's lean winter silhouette, expressive face and articulated clawed paws.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const P = preload("res://scripts/game/production/prop_factory.gd")
var arms: Array[Node3D] = []
var legs: Array[Node3D] = []
var clock: float = 0
var hit_left: float = 0
var dead: bool = false
var torso: Node3D
func _ready() -> void:
	var fur := P.mat("fff1da")
	var red := P.surface("bd222d", 1)
	var dark := P.mat("302c2a")
	var pink := P.mat("d58f82")
	torso = Node3D.new()
	add_child(torso)
	B.oval(torso, "sweater", Vector3(0, 1.06, 0), Vector3(0.61, 0.68, 0.37), red)
	for y in [0.79, 1.31]:
		var ring = preload("res://scripts/components/presentation_shapes.gd").ring(torso, "ribbed_hem", Vector3(0, y, 0), 0.28 if y < 1 else 0.24, red)
		ring.rotation.x = 0
		for i in range(24):
			var a := TAU * i / 24
			B.rod(torso, "knit", Vector3(cos(a) * 0.255, y - 0.045, sin(a) * 0.17), Vector3(cos(a) * 0.255, y + 0.045, sin(a) * 0.17), 0.009, P.mat("e34846"))
	# The white knitted snowflake band wraps front and back.
	for side in [-1, 1]:
		for x in [-0.18, 0.0, 0.18]:
			for a in [0.0, PI / 3, PI * 2 / 3]:
				var center := Vector3(x, 1.09, side * 0.181)
				var axis := Vector3(cos(a), sin(a), 0) * 0.07
				B.rod(torso, "snowflake", center - axis, center + axis, 0.012, fur)
	B.oval(torso, "neck", Vector3(0, 1.39, -0.025), Vector3(0.35, 0.36, 0.31), fur)
	B.oval(torso, "head", Vector3(0, 1.59, -0.07), Vector3(0.43, 0.45, 0.40), fur)
	B.oval(torso, "muzzle", Vector3(0, 1.51, -0.28), Vector3(0.30, 0.18, 0.28), fur)
	B.oval(torso, "nose", Vector3(0, 1.55, -0.42), Vector3(0.17, 0.09, 0.09), dark)
	P.box(torso, Vector3(0, 1.47, -0.37), Vector3(0.17, 0.018, 0.022), "52392e")
	for side in [-1, 1]:
		B.oval(torso, "ear", Vector3(side * 0.19, 1.78, -0.04), Vector3(0.14, 0.17, 0.09), fur)
		B.oval(torso, "inner_ear", Vector3(side * 0.19, 1.78, -0.09), Vector3(0.085, 0.11, 0.025), pink)
		B.oval(torso, "eye_white", Vector3(side * 0.105, 1.64, -0.244), Vector3(0.12, 0.10, 0.045), P.mat("ffffff"))
		B.oval(torso, "eye", Vector3(side * 0.09, 1.64, -0.269), Vector3(0.046, 0.065, 0.025), dark)
		B.rod(torso, "brow", Vector3(side * 0.045, 1.69, -0.27), Vector3(side * 0.17, 1.75, -0.25), 0.025, dark)
		var arm := Node3D.new()
		torso.add_child(arm)
		arm.position = Vector3(side * 0.31, 1.25, -0.045)
		arms.append(arm)
		B.rod(arm, "sleeve", Vector3.ZERO, Vector3(side * 0.12, -0.36, -0.06), 0.10, red)
		B.oval(arm, "cuff", Vector3(side * 0.12, -0.36, -0.06), Vector3(0.23, 0.12, 0.22), red)
		B.oval(arm, "palm", Vector3(side * 0.14, -0.51, -0.09), Vector3(0.30, 0.30, 0.20), fur)
		for finger in range(4):
			var start := Vector3(side * 0.14 + (finger - 1.5) * 0.055, -0.57, -0.12)
			B.rod(arm, "finger", start, start + Vector3(0, -0.12, -0.03), 0.031, fur)
			B.rod(arm, "claw", start + Vector3(0, -0.12, -0.03), start + Vector3(0, -0.17, -0.09), 0.019, dark)
		B.oval(arm, "thumb", Vector3(side * 0.29, -0.5, -0.12), Vector3(0.09, 0.15, 0.08), fur)
		var leg := Node3D.new()
		add_child(leg)
		leg.position = Vector3(side * 0.16, 0.79, 0)
		legs.append(leg)
		B.rod(leg, "shin", Vector3.ZERO, Vector3(side * 0.085, -0.60, 0.04), 0.075, fur)
		B.oval(leg, "foot", Vector3(side * 0.085, -0.68, -0.08), Vector3(0.23, 0.18, 0.36), fur)
		for finger in range(3):
			B.rod(leg, "toe_claw", Vector3(side * 0.085 + (finger - 1) * 0.06, -0.69, -0.21), Vector3(side * 0.085 + (finger - 1) * 0.06, -0.72, -0.28), 0.017, dark)
	# Lower jaw and visible ivory canines make the attack silhouette readable.
	B.oval(torso, "jaw", Vector3(0, 1.43, -0.29), Vector3(0.25, 0.10, 0.20), fur)
	for side in [-1, 1]:
		B.rod(torso, "canine", Vector3(side * 0.09, 1.48, -0.36), Vector3(side * 0.08, 1.42, -0.37), 0.015, P.mat("fffbdc"))
	B.oval(self, "tail", Vector3(0, 0.76, 0.20), Vector3.ONE * 0.13, fur)

func present(delta: float, speed: float, anticipation: float, striking: bool) -> void:
	clock += delta
	hit_left = maxf(0, hit_left - delta)
	if dead:
		rotation.z = lerp_angle(rotation.z, 1.35, delta * 6)
		position.y = move_toward(position.y, -0.12, delta)
		return
	torso.position.y = sin(clock * 8) * minf(speed * 0.006, 0.025)
	torso.rotation.z = sin(hit_left * 40) * hit_left * 0.4
	for i in range(2):
		legs[i].rotation.x = sin(clock * 8 + i * PI) * minf(speed * 0.10, 0.42)
		# Positive X carries the downward rest vector forward (-Z), then overhead.
		# Keep the arc below PI so interpolation cannot take the backward shortcut.
		var pose := 2.65 if anticipation > 0 else (0.55 if striking else sin(clock * 8 + i * PI) * speed * 0.06)
		var response := 30.0 if striking else 12.0
		arms[i].rotation.x = lerpf(arms[i].rotation.x, pose, 1.0 - exp(-delta * response))
		arms[i].rotation.z = lerpf(arms[i].rotation.z, (-0.12 if i == 0 else 0.12) if anticipation > 0 else 0.0, 1.0 - exp(-delta * 12.0))
	# Lean back under raised paws, then put body weight into the downstroke.
	torso.rotation.x = lerpf(torso.rotation.x, 0.12 if anticipation > 0 else (-0.22 if striking else 0.0), 1.0 - exp(-delta * 18.0))

