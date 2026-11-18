extends RefCounted
## Authored native cartoon props; no per-decoration collision or lights.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const S = preload("res://scripts/components/presentation_shapes.gd")
static func mat(hex: String) -> StandardMaterial3D:
	return B.material(Color(hex))
static func surface(hex: String, kind: int) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = load("res://resources/production/market_surfaces.gdshader")
	result.set_shader_parameter("base_color", Color(hex))
	result.set_shader_parameter("surface_kind", kind)
	return result
static func box(p: Node3D, at: Vector3, size: Vector3, color: String) -> void:
	B.rounded_box(p, "part", at, size, minf(0.025, minf(size.x, minf(size.y, size.z)) * 0.2), surface(color, 0) if color in ["874926", "c99555", "734322", "dba45a", "9a5b30", "a96a38", "56321d", "c99150", "b17a3a"] else mat(color))
static func label(p: Node3D, text: String, at: Vector3, size: int = 36, color: Color = Color("fff0c4")) -> Label3D:
	var l := Label3D.new()
	p.add_child(l)
	l.position = at
	l.text = text
	l.font_size = size
	l.pixel_size = 0.003
	l.modulate = color
	l.outline_size = 5
	return l
static func flower(p: Node3D, at: Vector3, color: String, radius: float = 0.035) -> void:
	for i in range(5):
		var a := TAU * i / 5
		B.oval(p, "petal", at + Vector3(cos(a), 0, sin(a)) * radius, Vector3(radius, 0.012, radius) * 1.25, mat(color))
	B.oval(p, "center", at + Vector3.UP * 0.01, Vector3(radius, 0.018, radius) * 0.7, mat("ffd24c"))
static func weapon(p: Node3D, slot: int, pro: bool) -> void:
	match slot:
		1:
			S.sole(p, "sole", Vector3.ZERO, Vector3(0.27, 0.055, 0.58), mat("49301f"))
			S.sole(p, "footbed", Vector3(0, 0.034, 0), Vector3(0.25, 0.035, 0.55), mat("54246e" if pro else "cf2338"))
			B.tube(p, "strap", [Vector3(-0.12, 0.05, 0.02), Vector3(0, 0.14, -0.13), Vector3(0.12, 0.05, 0.02)], 0.028, mat("8d30a4" if pro else "ed3549"))
			for i in range(8):
				flower(p, Vector3(sin(i * 2.4) * 0.065, 0.06, -0.21 + i * 0.06), ["ff449c", "36b3cb", "ffd04a"][i % 3] if pro else "ffd2bf", 0.023)
			p.rotation.x = 0.8
		2:
			var stone := surface("24252b" if pro else "555c49", 2)
			var bowl := SphereMesh.new()
			bowl.radius = 0.22
			bowl.height = 0.32
			B.mesh_part(p, "bowl", Vector3.ZERO, Vector3.ONE, bowl, stone)
			var ring := S.ring(p, "rim", Vector3(0, 0.10, 0), 0.24, stone)
			ring.rotation.x = 0
			for i in range(3):
				var a := TAU * i / 3
				B.rod(p, "leg", Vector3(cos(a) * 0.12, -0.07, sin(a) * 0.12), Vector3(cos(a) * 0.16, -0.23, sin(a) * 0.16), 0.05, stone)
			for i in range(9):
				var a := i * 2.4
				var at := Vector3(cos(a) * 0.12, 0.12, sin(a) * 0.12)
				B.oval(p, "habanero", at, Vector3(0.12, 0.12, 0.09), mat(["e82d19", "ff9c16", "a92844"][i % 3] if pro else "95b92a"))
				B.rod(p, "stem", at, at + Vector3(0.02, 0.12, 0), 0.014, mat("286232"))
			if pro: label(p, "☠", Vector3(0, -0.01, 0.21), 48, Color("ffb847"))
		4:
			var body := CylinderMesh.new()
			body.top_radius = 0.095 if not pro else 0.14
			body.bottom_radius = body.top_radius
			body.height = 0.4
			B.mesh_part(p, "firework", Vector3(0, 0.12, 0), Vector3.ONE, body, mat("242831" if pro else "f6bd41"))
			for y in [-0.03, 0.12, 0.27]:
				var r := S.ring(p, "band", Vector3(0, y, 0), 0.15 if pro else 0.10, mat("777a81" if pro else "28773b"))
				r.rotation.x = 0
			var cone := CylinderMesh.new()
			cone.top_radius = 0
			cone.bottom_radius = 0.16 if pro else 0.13
			cone.height = 0.24
			B.mesh_part(p, "nose", Vector3(0, 0.43, 0), Vector3.ONE, cone, mat("353a42" if pro else "d93227"))
			B.rod(p, "stick", Vector3(0.05, -0.43, 0), Vector3(0.05, 0.05, 0), 0.023, mat("9c6834"))
			if pro:
				for side in [-1, 1]:
					box(p, Vector3(side * 0.2, -0.10, 0), Vector3(0.17, 0.25, 0.035), "656972")
					for y in range(4):
						B.oval(p, "rivet", Vector3(side * 0.085, y * 0.08, 0.105), Vector3.ONE * 0.026, mat("babdc2"))
			p.rotation.x = -0.45
static func pickup(p: Node3D, kind: StringName) -> void:
	match kind:
		&"health":
			box(p, Vector3.ZERO, Vector3(0.48, 0.33, 0.31), "fff1d5")
			box(p, Vector3(0, 0.12, 0), Vector3(0.5, 0.05, 0.33), "d52c39")
			box(p, Vector3(0, -0.16, 0), Vector3(0.5, 0.06, 0.33), "d52c39")
			B.tube(p, "handle", [Vector3(-0.12, 0.16, 0), Vector3(-0.12, 0.27, 0), Vector3(0.12, 0.27, 0), Vector3(0.12, 0.16, 0)], 0.025, mat("d52c39"))
			box(p, Vector3(0, 0, 0.16), Vector3(0.06, 0.19, 0.02), "d52c39")
			box(p, Vector3(0, 0, 0.16), Vector3(0.19, 0.06, 0.025), "d52c39")
			flower(p, Vector3(0.17, 0.18, 0.06), "3594c6", 0.025)
		&"ammo":
			for y in [-0.13, 0.0, 0.13]:
				box(p, Vector3(0, y, 0.2), Vector3(0.49, 0.095, 0.035), "c99150")
				box(p, Vector3(0, y, -0.2), Vector3(0.49, 0.095, 0.035), "c99150")
				for x in [-0.23, 0.23]: box(p, Vector3(x, y, 0), Vector3(0.035, 0.095, 0.4), "b17a3a")
			for i in range(7):
				B.oval(p, "fruit", Vector3(sin(i * 3) * 0.14, 0.12, cos(i * 2) * 0.12), Vector3(0.17, 0.19, 0.16), mat(["f7b91c", "df3936", "75a83c"][i % 3]))
			label(p, "FRUTAS", Vector3(0, 0.01, 0.225), 23, Color("a93227"))
		&"ice":
			var plastic := mat("81bddb")
			plastic.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			plastic.albedo_color.a = 0.55
			var bag := SphereMesh.new()
			bag.radius = 0.5
			bag.height = 1
			bag.radial_segments = 9
			bag.rings = 5
			B.mesh_part(p, "crinkled_bag", Vector3.ZERO, Vector3(0.43, 0.42, 0.32), bag, plastic)
			for i in range(6):
				var cube := B.rounded_box(p, "ice_cube", Vector3(sin(i * 2.4) * 0.11, cos(i * 2.4) * 0.10, 0.025), Vector3(0.12, 0.11, 0.09), 0.015, mat("c5e9f5"))
				cube.rotation.z = i * 0.5
			B.rod(p, "tie", Vector3(-0.05, 0.18, 0), Vector3(0.05, 0.18, 0), 0.021, mat("275eb2"))
			var top := CylinderMesh.new()
			top.top_radius = 0.105
			top.bottom_radius = 0.025
			top.height = 0.15
			top.radial_segments = 7
			B.mesh_part(p, "ruffled_top", Vector3(0, 0.26, 0), Vector3(1, 1, 0.6), top, mat("b4dcec"))
			label(p, "HIELO", Vector3(0, -0.05, 0.17), 27, Color("2366b0"))
		_:
			var color := "f8c856" if kind == &"candle" else ("c33321" if kind == &"chile" else "d29a26")
			var body := CylinderMesh.new()
			body.top_radius = 0.13
			body.bottom_radius = 0.13
			body.height = 0.40
			B.mesh_part(p, "jar", Vector3.ZERO, Vector3.ONE, body, mat(color))
			box(p, Vector3(0, 0, 0.132), Vector3(0.19, 0.24, 0.015), "ffdf91")
			if kind == &"candle":
				B.oval(p, "flame", Vector3(0, 0.28, 0), Vector3(0.07, 0.16, 0.07), mat("ffec85"))
				label(p, "♥", Vector3(0, 0, 0.15), 44, Color("db4b31"))
			else:
				B.rod(p, "neck", Vector3(0, 0.19, 0), Vector3(0, 0.3, 0), 0.06, mat(color))
				box(p, Vector3(0, 0.31, 0), Vector3(0.15, 0.045, 0.15), "24683b")
				label(p, "CHILE" if kind == &"chile" else "TEQUILA", Vector3(0, 0, 0.15), 21, Color("642b1c"))
