extends RefCounted
## Small native surface builders for straps, rounded soles, ears and cap lobes.
const B = preload("res://scripts/components/visual_mesh_builder.gd")

static func ring(parent: Node3D, name: String, at: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius * 0.77
	mesh.outer_radius = radius
	mesh.rings = 24
	mesh.ring_segments = 8
	var part := B.mesh_part(parent, name, at, Vector3.ONE, mesh, mat)
	part.rotation.x = PI * 0.5
	return part

static func sole(parent: Node3D, name: String, at: Vector3, size: Vector3, mat: Material) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.5
	mesh.bottom_radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 40
	B.mesh_part(parent, name, at, size, mesh, mat)

static func ribbon(parent: Node3D, name: String, points: Array[Vector3], width: float, mat: Material) -> void:
	for index in range(points.size() - 1):
		var start := points[index]
		var end := points[index + 1]
		var axis := (end - start).normalized()
		var outward := ((start + end) * 0.5 - Vector3(0, 1.05, 0)).normalized()
		var side := axis.cross(outward).normalized()
		if side.length_squared() < 0.5: side = Vector3.RIGHT
		var part := B.rounded_box(parent, name + "_%02d" % index, (start + end) * 0.5, Vector3(width, start.distance_to(end) + 0.014, 0.016), 0.007, mat)
		part.basis = Basis(side, axis, side.cross(axis).normalized())

static func horn(parent: Node3D, name: String, points: Array[Vector3], radii: Array[float], mat: Material) -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var sides := 32
	for row in range(points.size()):
		var tangent := (points[mini(row + 1, points.size() - 1)] - points[maxi(row - 1, 0)]).normalized()
		var u := Vector3.FORWARD.cross(tangent).normalized()
		var v := tangent.cross(u)
		for col in range(sides + 1):
			var angle := TAU * col / sides
			var normal := u * cos(angle) + v * sin(angle)
			vertices.append(points[row] + normal * radii[row])
			normals.append(normal)
	for row in range(points.size() - 1):
		for col in range(sides):
			var a := row * (sides + 1) + col
			indices.append_array(PackedInt32Array([a, a + sides + 1, a + 1, a + 1, a + sides + 1, a + sides + 2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	B.mesh_part(parent, name, Vector3.ZERO, Vector3.ONE, mesh, mat)

static func panel(parent: Node3D, name: String, outline: Array[Vector2], at: Vector3, mat: Material, curvature: float = 0.0) -> MeshInstance3D:
	var vertices := PackedVector3Array([Vector3(0, 0, -0.012)])
	var normals := PackedVector3Array([Vector3.FORWARD])
	var indices := PackedInt32Array()
	for point in outline:
		vertices.append(Vector3(point.x, point.y, point.x * point.x * curvature))
		normals.append(Vector3.FORWARD)
	for index in range(outline.size()):
		indices.append_array(PackedInt32Array([0, (index + 1) % outline.size() + 1, index + 1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return B.mesh_part(parent, name, at, Vector3.ONE, mesh, mat)
