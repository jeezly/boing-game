extends RefCounted
## Reference proportions and surface details, separate from locomotion posing.
const B = preload("res://scripts/components/visual_mesh_builder.gd")

const Boot = preload("res://scripts/characters/mango/mango_boot.gd")
const Shapes = preload("res://scripts/components/presentation_shapes.gd")

static func build(body: Node3D, face: Node3D, helmet: Node3D) -> void:
	var gold := B.material(Color("ffbc36"))
	var orange := B.material(Color("f79527"))
	var leather := B.material(Color("493329"), 0.88)
	var seam := B.material(Color("b1804f"))
	var dark := B.material(Color("2a211b"))
	var cream := B.material(Color("fff0cf"), 0.5)
	var brass := B.material(Color("9b9079"), 0.4)
	var glass := B.material(Color("6b8076"), 0.18)
	glass.metallic = 0.25
	# A single surface avoids the old intersecting 'face egg' seam.
	var shader := Shader.new()
	shader.code = "shader_type spatial; varying vec3 local_position; void vertex(){local_position=VERTEX;} void fragment(){float warmth=smoothstep(-0.5,0.5,local_position.y); vec3 orange=vec3(0.95,0.34,0.035); vec3 yellow=vec3(1.0,0.67,0.09); float face=(1.0-smoothstep(-0.3,0.05,local_position.z)); ALBEDO=mix(orange,yellow,clamp(warmth*0.72+face*0.22,0.0,1.0)); ROUGHNESS=0.72;}"
	var skin := ShaderMaterial.new()
	skin.shader = shader
	B.mesh_part(body, "mango_skin", Vector3(0, 1.05, 0), Vector3.ONE, fruit_mesh(), skin)
	for side in [-1.0, 1.0]:
		B.oval(face, "eye_white", Vector3(side * 0.155, 1.37, -0.339), Vector3(0.215, 0.24, 0.105), cream)
		B.oval(face, "iris", Vector3(side * 0.155 + 0.012, 1.37, -0.39), Vector3(0.10, 0.135, 0.028), B.material(Color("68371a"), 0.4))
		B.oval(face, "pupil", Vector3(side * 0.155 + 0.012, 1.37, -0.405), Vector3(0.059, 0.092, 0.019), dark)
		B.oval(face, "catchlight", Vector3(side * 0.155 - 0.007, 1.398, -0.419), Vector3(0.024, 0.028, 0.014), cream)
		B.tube(face, "brow", [Vector3(side * 0.065, 1.50, -0.351), Vector3(side * 0.145, 1.535, -0.345), Vector3(side * 0.245, 1.512, -0.312)], 0.025, dark)
	B.oval(face, "nose", Vector3(0, 1.245, -0.414), Vector3(0.285, 0.205, 0.24), orange)
	B.tube(face, "smile", [Vector3(-0.145, 1.105, -0.338), Vector3(-0.06, 1.065, -0.357), Vector3(0.04, 1.068, -0.357), Vector3(0.14, 1.115, -0.338)], 0.014, dark)
	B.oval(face, "lower_lip", Vector3(0, 1.038, -0.354), Vector3(0.23, 0.055, 0.065), gold)
	B.oval(face, "chin", Vector3(0, 0.945, -0.356), Vector3(0.20, 0.15, 0.10), gold)
	# Open cap surface follows the crown, with no exposed hemisphere cut plane.
	B.mesh_part(helmet, "leather_crown", Vector3.ZERO, Vector3.ONE, cap_mesh(), leather)
	for side in [-1.0, 1.0]:
		B.oval(helmet, "ear_flap", Vector3(side * 0.36, 1.34, 0.025), Vector3(0.17, 0.52, 0.52), leather)
		B.tube(helmet, "flap_piping", [Vector3(side * 0.37, 1.49, -0.225), Vector3(side * 0.397, 1.34, -0.22), Vector3(side * 0.399, 1.13, -0.17), Vector3(side * 0.37, 1.08, -0.1)], 0.009, seam)
		B.tube(helmet, "chin_strap", [Vector3(side * 0.398, 1.13, -0.08), Vector3(side * 0.39, 0.91, -0.15)], 0.013, leather)
		B.rounded_box(helmet, "strap_buckle", Vector3(side * 0.39, 0.96, -0.16), Vector3(0.045, 0.055, 0.025), 0.006, brass)
		B.tube(helmet, "goggle_strap", [Vector3(side * 0.27, 1.69, -0.28), Vector3(side * 0.40, 1.63, 0), Vector3(side * 0.33, 1.58, 0.26), Vector3(0, 1.56, 0.34)], 0.027, leather)
		B.oval(helmet, "goggle_leather_rim", Vector3(side * 0.195, 1.68, -0.26), Vector3(0.32, 0.235, 0.125), leather)
		B.oval(helmet, "goggle_metal_rim", Vector3(side * 0.195, 1.68, -0.30), Vector3(0.285, 0.20, 0.08), brass)
		B.oval(helmet, "goggle_lens", Vector3(side * 0.195, 1.68, -0.342), Vector3(0.235, 0.152, 0.028), glass)
		B.oval(helmet, "lens_reflection", Vector3(side * 0.195 - 0.035, 1.708, -0.357), Vector3(0.026, 0.075, 0.008), B.material(Color("b5c6b5"), 0.25))
	B.rod(helmet, "goggle_bridge", Vector3(-0.062, 1.68, -0.3), Vector3(0.062, 1.68, -0.3), 0.018, leather)
	for side in [-1.0, 1.0]:
		var points: Array[Vector3] = []
		for index in range(17):
			var theta := float(index) / 16.0 * PI
			points.append(Vector3(side * 0.038, 1.405 + sin(theta) * 0.407, -cos(theta) * 0.345))
		B.tube(helmet, "crown_seam", points, 0.005, seam)

static func build_boot(leg: Node3D) -> void:
	Boot.build(leg)

static func fruit_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var rings := 40
	var sides := 64
	for row in range(rings + 1):
		var theta := PI * float(row) / rings
		var y := cos(theta)
		var taper := 1.0 - 0.14 * y
		for col in range(sides + 1):
			var phi := TAU * float(col) / sides
			vertices.append(Vector3(sin(theta) * cos(phi) * 0.445 * taper + 0.035 * y, y * 0.615, sin(theta) * sin(phi) * 0.355 * taper))
			var normal := Vector3(sin(theta) * cos(phi) / 0.445, y / 0.615, sin(theta) * sin(phi) / 0.355).normalized()
			normals.append(normal)
	for row in range(rings):
		for col in range(sides):
			var a := row * (sides + 1) + col
			indices.append_array(PackedInt32Array([a, a + sides + 1, a + 1, a + 1, a + sides + 1, a + sides + 2]))
	return surface(vertices, normals, indices)

static func cap_mesh() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for row in range(21):
		for col in range(65):
			var phi := TAU * col / 64.0
			var front := maxf(0.0, -sin(phi))
			var theta := (1.63 - 0.32 * front) * row / 20.0
			var n := Vector3(sin(theta) * cos(phi), cos(theta), sin(theta) * sin(phi))
			vertices.append(Vector3(n.x * 0.425, 1.405 + n.y * 0.405, n.z * 0.345))
			normals.append(Vector3(n.x / 0.425, n.y / 0.405, n.z / 0.345).normalized())
	for row in range(20):
		for col in range(64):
			var a := row * 65 + col
			indices.append_array(PackedInt32Array([a, a + 65, a + 1, a + 1, a + 65, a + 66]))
	return surface(vertices, normals, indices)

static func surface(vertices: PackedVector3Array, normals: PackedVector3Array, indices: PackedInt32Array) -> ArrayMesh:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
