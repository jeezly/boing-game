extends RefCounted
## Approved soda-goblin proportions and markings; no combat state.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const S = preload("res://scripts/components/presentation_shapes.gd")

static func build(torso: Node3D, face: Node3D, cap: Node3D, lobes: Array[Node3D]) -> void:
	var blue := B.material(Color("0867d9"), 0.65)
	var navy := B.material(Color("173775"))
	var red := B.material(Color("e82d4b"), 0.62)
	var white := B.material(Color("f8f1e7"), 0.70)
	var pink := B.material(Color("e2afb0"))
	var silver := B.material(Color("c6d3dc"), 0.25)
	silver.metallic = 0.65
	var dark := B.material(Color("152334"), 0.35)
	var lens := B.material(Color("0785ee"), 0.16)
	lens.metallic = 0.3
	B.oval(torso, "puffy_jacket", Vector3(0, 0.70, 0), Vector3(0.64, 0.60, 0.45), blue)
	B.oval(torso, "navy_waist", Vector3(0, 0.46, 0), Vector3(0.53, 0.16, 0.36), navy)
	B.oval(torso, "red_hem", Vector3(0, 0.48, -0.012), Vector3(0.59, 0.077, 0.42), red)
	B.tube(torso, "white_chest_wave", [Vector3(-0.245, 0.64, -0.145), Vector3(-0.14, 0.68, -0.206), Vector3(0, 0.72, -0.222), Vector3(0.13, 0.68, -0.211), Vector3(0.24, 0.66, -0.15)], 0.017, white)
	B.tube(torso, "zipper", [Vector3(0, 0.50, -0.182), Vector3(0, 0.63, -0.224), Vector3(0, 0.74, -0.226), Vector3(0, 0.87, -0.188)], 0.010, silver)
	for index in range(10):
		var y := 0.52 + index * 0.033
		var z := -0.225 * sqrt(maxf(0.0, 1.0 - pow((y - 0.70) / 0.30, 2))) - 0.008
		B.rod(torso, "zipper_teeth", Vector3(-0.012, y, z), Vector3(0.012, y, z), 0.004, white)
	B.oval(torso, "red_collar", Vector3(0, 0.94, 0.025), Vector3(0.49, 0.13, 0.38), red)
	for side in [-1.0, 1.0]:
		B.tube(torso, "hood_drawstring", [Vector3(side * 0.09, 0.90, -0.17), Vector3(side * 0.105, 0.78, -0.23)], 0.009, white)
		B.oval(torso, "drawstring_tip", Vector3(side * 0.105, 0.776, -0.23), Vector3(0.024, 0.040, 0.020), silver)
		S.ring(torso, "jacket_bubble", Vector3(side * 0.16, 0.76, -0.199), 0.039, white)
		S.ring(torso, "small_bubble", Vector3(side * 0.22, 0.58, -0.146), 0.018, white)
	B.oval(face, "pale_face", Vector3(0, 1.115, -0.014), Vector3(0.64, 0.50, 0.49), white)
	for side in [-1.0, 1.0]:
		B.oval(face, "rounded_cheek", Vector3(side * 0.20, 1.04, -0.184), Vector3(0.20, 0.17, 0.14), white)
		B.oval(face, "cheek_blush", Vector3(side * 0.215, 1.055, -0.252), Vector3(0.079, 0.046, 0.014), B.material(Color("eec7bd")))
		var ear_outline: Array[Vector2] = [Vector2(-0.03, -0.055), Vector2(-0.035, 0.07), Vector2(0.035, 0.095), Vector2(0.28, 0.16), Vector2(0.19, 0.025), Vector2(0.08, -0.065)]
		for index in range(ear_outline.size()): ear_outline[index].x *= side
		if side < 0.0: ear_outline.reverse()
		var ear_mat := B.material(Color("f0d8d0"))
		ear_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		var ear := S.panel(face, "swept_ear", ear_outline, Vector3(side * 0.275, 1.105, -0.06), ear_mat)
		ear.scale.z = 2.0
		var inner := S.panel(face, "inner_ear", ear_outline, Vector3(side * 0.292, 1.113, -0.084), pink)
		inner.scale = Vector3(0.76, 0.64, 1.0)
		B.oval(face, "eye_white", Vector3(side * 0.132, 1.15, -0.242), Vector3(0.22, 0.235, 0.091), white)
		B.oval(face, "iris", Vector3(side * 0.132 - side * 0.007, 1.14, -0.288), Vector3(0.108, 0.128, 0.032), B.material(Color("493a31"), 0.30))
		B.oval(face, "pupil", Vector3(side * 0.132 - side * 0.007, 1.14, -0.305), Vector3(0.071, 0.093, 0.017), dark)
		B.oval(face, "catchlight", Vector3(side * 0.132 - 0.021, 1.168, -0.317), Vector3(0.027, 0.031, 0.012), white)
		B.tube(face, "sly_brow", [Vector3(side * 0.055, 1.252, -0.254), Vector3(side * 0.13, 1.29, -0.248), Vector3(side * 0.22, 1.306, -0.207)], 0.022, navy)
	B.oval(face, "button_nose", Vector3(0, 1.062, -0.278), Vector3(0.12, 0.086, 0.09), pink)
	B.tube(face, "smirk", [Vector3(-0.11, 1.006, -0.224), Vector3(-0.045, 0.974, -0.237), Vector3(0.040, 0.98, -0.238), Vector3(0.128, 1.025, -0.222)], 0.012, dark)
	B.oval(face, "tooth", Vector3(0.035, 0.993, -0.249), Vector3(0.073, 0.018, 0.014), white)
	B.oval(cap, "cap_base", Vector3(0, 1.36, 0.03), Vector3(0.66, 0.23, 0.51), navy)
	for index in range(2):
		var side := -1.0 if index == 0 else 1.0
		var mat: Material = blue if index == 0 else red
		var lobe := lobes[index]
		var path: Array[Vector3] = []
		var radii: Array[float] = []
		# Cubic curve makes one joined, tapering cap lobe with a drooping bell.
		var p0 := Vector3(side * 0.105, 1.39, 0.075)
		var p1 := Vector3(side * 0.14, 1.98, 0.09)
		var p2 := Vector3(side * 0.53, 1.89, 0.07)
		var p3 := Vector3(side * 0.50, 1.19, 0.04)
		for sample in range(25):
			var t := sample / 24.0
			var q := 1.0 - t
			path.append(p0 * q * q * q + p1 * 3.0 * q * q * t + p2 * 3.0 * q * t * t + p3 * t * t * t)
			radii.append(lerpf(0.185, 0.012, smoothstep(0.10, 1.0, t)))
		S.horn(lobe, "curved_jester_lobe", path, radii, mat)
		B.rod(lobe, "bell_link", p3, p3 + Vector3(0, -0.022, 0), 0.014, silver)
		B.oval(lobe, "silver_bell", p3 + Vector3(0, -0.06, 0), Vector3.ONE * 0.13, silver)
		B.oval(lobe, "bell_slot", p3 + Vector3(0, -0.06, -0.066), Vector3(0.014, 0.048, 0.012), dark)
		for mark in range(3):
			S.ring(lobe, "cap_bubble", Vector3(side * (0.20 + mark * 0.07), 1.68 - mark * 0.095, -0.10), 0.026 + mark * 0.005, white)
	# Single wraparound visor with a lifted nose bridge, nested rim and red seal.
	var outline: Array[Vector2] = [Vector2(-0.30,-0.04), Vector2(-0.30,0.055), Vector2(-0.25,0.095), Vector2(0.25,0.095), Vector2(0.30,0.055), Vector2(0.30,-0.045), Vector2(0.26,-0.095), Vector2(0.14,-0.095), Vector2(0.06,-0.07), Vector2(0,-0.025), Vector2(-0.06,-0.07), Vector2(-0.14,-0.095), Vector2(-0.26,-0.095)]
	B.oval(cap, "goggle_foam_backing", Vector3(0, 1.385, -0.23), Vector3(0.64, 0.205, 0.16), navy)
	var gasket := S.panel(cap, "red_goggle_seal", outline, Vector3(0, 1.385, -0.285), red, 0.75)
	gasket.scale = Vector3(1.10, 1.18, 1)
	var rim := S.panel(cap, "silver_visor_rim", outline, Vector3(0, 1.385, -0.298), silver, 0.75)
	rim.scale = Vector3(1.055, 1.08, 1)
	S.panel(cap, "blue_wraparound_lens", outline, Vector3(0, 1.385, -0.312), lens, 0.75)
	for x in [-0.20, -0.15, 0.16]:
		B.oval(cap, "visor_reflection", Vector3(x, 1.405, -0.313 + x * x * 0.75), Vector3(0.024, 0.10, 0.006), B.material(Color("78d8fc"), 0.20))
	for side in [-1.0, 1.0]:
		B.tube(cap, "silver_goggle_strap", [Vector3(side * 0.30, 1.385, -0.215), Vector3(side * 0.337, 1.365, 0.07), Vector3(side * 0.25, 1.35, 0.245), Vector3(0, 1.35, 0.282)], 0.024, silver)
	B.oval(cap, "forehead_medallion", Vector3(0, 1.505, -0.198), Vector3(0.097, 0.076, 0.024), silver)

static func boot(leg: Node3D) -> void:
	var blue := B.material(Color("1268ce"))
	var red := B.material(Color("e63149"))
	var white := B.material(Color("f4f1e9"))
	var navy := B.material(Color("16346e"))
	B.rod(leg, "shin", Vector3(0, 0.02, 0), Vector3(0, -0.245, 0), 0.059, navy)
	B.rod(leg, "red_sock", Vector3(0, -0.10, 0), Vector3(0, -0.16, 0), 0.067, red)
	S.sole(leg, "rounded_outsole", Vector3(0, -0.422, -0.068), Vector3(0.32, 0.068, 0.43), navy)
	B.oval(leg, "sport_boot", Vector3(0, -0.326, -0.075), Vector3(0.31, 0.225, 0.415), blue)
	B.oval(leg, "ankle_upper", Vector3(0, -0.237, 0.015), Vector3(0.237, 0.23, 0.24), blue)
	B.oval(leg, "red_toe_cap", Vector3(0, -0.322, -0.193), Vector3(0.286, 0.168, 0.17), red)
	var collar := S.ring(leg, "ankle_collar", Vector3(0, -0.163, 0.015), 0.124, red)
	collar.rotation.x = 0
	for offset in [-0.19, -0.095]:
		B.tube(leg, "white_shoe_stripe", [Vector3(-0.14, -0.362, offset), Vector3(-0.12, -0.298, offset - 0.006), Vector3(0, -0.248, offset - 0.003), Vector3(0.12, -0.298, offset - 0.006), Vector3(0.14, -0.362, offset)], 0.014, white)
	for side in [-1.0, 1.0]:
		S.ring(leg, "ankle_badge", Vector3(side * 0.118, -0.24, 0.009), 0.033, white).rotation = Vector3(0, PI * 0.5, 0)
	B.rod(leg, "white_collar_band", Vector3(-0.10, -0.186, -0.08), Vector3(0.10, -0.186, -0.08), 0.016, white)
