extends RefCounted
## Shared native geometry helpers. Presentation only; no gameplay state.

static func material(color: Color, roughness: float = 0.85) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = roughness
	return result

static func oval(parent: Node3D, part_name: String, at: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 24
	mesh.rings = 12
	return mesh_part(parent, part_name, at, size, mesh, mat)

static func mesh_part(parent: Node3D, part_name: String, at: Vector3, size: Vector3, mesh: Mesh, mat: Material) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.material_override = mat
	parent.add_child(part)
	part.position = at
	part.scale = size
	return part

static func rod(parent: Node3D, part_name: String, start: Vector3, end: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = maxf(start.distance_to(end), 0.0001)
	mesh.radial_segments = 12
	var part := mesh_part(parent, part_name, Vector3.ZERO, Vector3.ONE, mesh, mat)
	segment(part, start, end)
	return part

static func segment(part: MeshInstance3D, start: Vector3, end: Vector3) -> void:
	var axis := (end - start).normalized()
	if axis.length_squared() < 0.5:
		return
	var side := Vector3.RIGHT if absf(axis.dot(Vector3.RIGHT)) < 0.95 else Vector3.FORWARD
	var z_axis := side.cross(axis).normalized()
	part.position = (start + end) * 0.5
	part.basis = Basis(axis.cross(z_axis), axis, z_axis)
	part.scale.y = start.distance_to(end) / (part.mesh as CylinderMesh).height

static func tube(parent: Node3D, part_name: String, points: Array[Vector3], radius: float, mat: Material) -> void:
	for index in range(points.size() - 1):
		rod(parent, part_name + "_%02d" % index, points[index], points[index + 1], radius, mat)
	for index in range(points.size()):
		oval(parent, part_name + "_join_%02d" % index, points[index], Vector3.ONE * radius * 2.0, mat)

static func rounded_box(parent: Node3D, part_name: String, at: Vector3, size: Vector3, radius: float, mat: Material) -> MeshInstance3D:
	# Project subdivided cube faces onto a rounded box, with smooth analytic normals.
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var half := size * 0.5
	var inner := half - Vector3.ONE * radius
	var steps := 12
	for face in range(6):
		var normal: Vector3 = [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.BACK, Vector3.FORWARD][face]
		var u := Vector3.UP if absf(normal.x) > 0.5 else Vector3.RIGHT
		var v := normal.cross(u)
		var offset := vertices.size()
		for row in range(steps + 1):
			for col in range(steps + 1):
				var unit := normal + u * (2.0 * col / steps - 1.0) + v * (2.0 * row / steps - 1.0)
				var cube := unit * half
				var core := cube.clamp(-inner, inner)
				var direction := (cube - core).normalized()
				vertices.append(core + direction * radius)
				normals.append(direction)
		for row in range(steps):
			for col in range(steps):
				var a := offset + row * (steps + 1) + col
				# Godot front faces use clockwise winding.
				indices.append_array(PackedInt32Array([a, a + steps + 1, a + 1, a + 1, a + steps + 1, a + steps + 2]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh_part(parent, part_name, at, Vector3.ONE, mesh, mat)

static func swept_tube(parent: Node3D, part_name: String, points: Array[Vector3], radius: float, mat: Material) -> MeshInstance3D:
	# Continuous wood surface; fork bends have no exposed cylinder end caps.
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var sides := 20
	for row in range(points.size()):
		var tangent := (points[mini(row + 1, points.size() - 1)] - points[maxi(row - 1, 0)]).normalized()
		var reference := Vector3.FORWARD
		var u := reference.cross(tangent).normalized()
		var v := tangent.cross(u)
		for col in range(sides + 1):
			var angle := TAU * col / sides
			var normal := u * cos(angle) + v * sin(angle)
			vertices.append(points[row] + normal * radius)
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
	var part := mesh_part(parent, part_name, Vector3.ZERO, Vector3.ONE, mesh, mat)
	for tip in [points[0], points[-1]]:
		oval(parent, part_name + "_end", tip, Vector3.ONE * radius * 2.0, mat)
	return part
