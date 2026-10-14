extends RefCounted
## Rounded work-boot last and curved welt, independent of Mango's pose/other art.
const B = preload("res://scripts/components/visual_mesh_builder.gd")

static func build(leg: Node3D) -> void:
	var tan := B.material(Color("ce953f"))
	var rubber := B.material(Color("704528"))
	var welt := B.material(Color("d6b77b"))
	var collar := B.material(Color("372d27"))
	B.mesh_part(leg, "curved_outsole", Vector3.ZERO, Vector3.ONE, sole_mesh(-0.455, 0.058, 1.0), rubber)
	B.mesh_part(leg, "rounded_welt", Vector3.ZERO, Vector3.ONE, sole_mesh(-0.398, 0.017, 0.985), welt)
	var groove := B.material(Color("50351f"))
	for index in range(12):
		var angle := TAU * index / 12.0
		var x := sin(angle) * (0.140 - 0.018 * cos(angle))
		var z := -0.075 + cos(angle) * 0.208
		B.rod(leg, "sole_groove", Vector3(x, -0.435, z), Vector3(x, -0.415, z), 0.0023, groove)
	# Overlapping round lasts replace the square heel/shaft and thin box sole.
	B.oval(leg, "toe_and_vamp", Vector3(0, -0.320, -0.105), Vector3(0.276, 0.175, 0.350), tan)
	B.oval(leg, "heel_and_shaft", Vector3(0, -0.258, 0.013), Vector3(0.207, 0.240, 0.218), tan)
	B.oval(leg, "padded_collar", Vector3(0, -0.155, 0.012), Vector3(0.223, 0.068, 0.230), collar)
	var tongue := B.rounded_box(leg, "tongue", Vector3(0, -0.229, -0.159), Vector3(0.122, 0.190, 0.030), 0.014, tan)
	tongue.rotation.x = 0.74
	var heights: Array[float] = [-0.188, -0.219, -0.251, -0.278]
	var depths: Array[float] = [-0.129, -0.158, -0.193, -0.218]
	for index in range(heights.size()):
		var y := heights[index]
		var z := depths[index]
		for side in [-1.0, 1.0]:
			B.oval(leg, "eyelet", Vector3(side * 0.052, y, z), Vector3(0.014, 0.014, 0.009), welt)
		B.rod(leg, "lace_a", Vector3(-0.052, y, z - 0.006), Vector3(0.052, y - 0.016, z - 0.006), 0.004, welt)
		B.rod(leg, "lace_b", Vector3(0.052, y, z - 0.011), Vector3(-0.052, y - 0.016, z - 0.011), 0.004, welt)
	for side in [-1.0, 1.0]:
		B.tube(leg, "quarter_stitch", [Vector3(side * 0.083, -0.194, 0.056), Vector3(side * 0.101, -0.280, 0.054), Vector3(side * 0.111, -0.335, -0.092)], 0.0025, welt)
	B.tube(leg, "heel_seam", [Vector3(0, -0.193, 0.111), Vector3(0, -0.265, 0.124), Vector3(0, -0.353, 0.079)], 0.0025, welt)

static func sole_mesh(bottom: float, thickness: float, scale_xz: float) -> ArrayMesh:
	# A tapered oval plan with a raised arch and toe rocker, rather than a box
	# whose corner radius is limited by its thin vertical thickness.
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	const SIDES: int = 48
	for row in range(4):
		var t := float(row) / 3.0
		var inset := 0.98 if row == 0 or row == 3 else 1.0
		for col in range(SIDES + 1):
			var angle := TAU * col / SIDES
			var z := -0.075 + cos(angle) * 0.208 * scale_xz * inset
			var x := sin(angle) * (0.140 - 0.018 * cos(angle)) * scale_xz * inset
			var arch := 0.016 * exp(-pow((z + 0.010) / 0.060, 2.0)) * (1.0 - t)
			var rocker := 0.007 * (1.0 - smoothstep(-0.282, -0.215, z))
			vertices.append(Vector3(x, bottom + thickness * t + arch + rocker, z))
			var bevel_y := -0.5 if row == 0 else (0.5 if row == 3 else 0.0)
			normals.append(Vector3(sin(angle), bevel_y, cos(angle) * 0.7).normalized())
	for row in range(3):
		for col in range(SIDES):
			var a := row * (SIDES + 1) + col
			indices.append_array(PackedInt32Array([a, a + SIDES + 2, a + 1, a, a + SIDES + 1, a + SIDES + 2]))
	# Separate cap normals keep the welt crisp without exposing open surfaces.
	for top in [false, true]:
		var start := vertices.size()
		var row := 3 if top else 0
		var normal := Vector3.UP if top else Vector3.DOWN
		vertices.append(Vector3(0, bottom + (thickness if top else 0.016), -0.075))
		normals.append(normal)
		for col in range(SIDES):
			vertices.append(vertices[row * (SIDES + 1) + col])
			normals.append(normal)
		for col in range(SIDES):
			var a := start + 1 + col
			var b := start + 1 + (col + 1) % SIDES
			indices.append_array(PackedInt32Array([start, b, a] if top else [start, a, b]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
