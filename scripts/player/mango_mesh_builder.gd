extends RefCounted
## Small shared primitive builder; all geometry is native Godot and untextured.

static func material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.85
	return result

static func oval(parent: Node3D, part_name: String, at: Vector3, size: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 24
	mesh.rings = 12
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
	mesh.height = start.distance_to(end)
	mesh.radial_segments = 12
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.material_override = mat
	parent.add_child(part)
	part.position = (start + end) * 0.5
	var axis := (end - start).normalized()
	var side := Vector3.RIGHT if absf(axis.dot(Vector3.RIGHT)) < 0.95 else Vector3.FORWARD
	var z_axis := side.cross(axis).normalized()
	part.basis = Basis(axis.cross(z_axis), axis, z_axis)
	return part
