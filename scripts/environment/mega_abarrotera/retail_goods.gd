@tool
extends RefCounted
## Shared product silhouettes, print and reusable profiles for shelf MultiMeshes.
static var cache: Dictionary = {}
static func material(category: int, color: String, bottle: bool) -> Material:
	var key := str(category) + color + str(bottle)
	if cache.has(key): return cache[key]
	var mat := ShaderMaterial.new()
	mat.shader = load("res://resources/environment/retail_packaging.gdshader")
	mat.set_shader_parameter("brand_color", Color(color))
	mat.set_shader_parameter("kind", 1 if bottle else (2 if category in [3,4,8] else 0))
	mat.set_shader_parameter("label_art", load("res://assets/environment/package_%d.png" % category))
	cache[key] = mat
	return mat
static func profile(points: Array[Vector2], mat: Material, segments: int = 16) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row in range(points.size() - 1):
		for col in range(segments):
			for corner in [Vector2i(0,0),Vector2i(1,0),Vector2i(1,1),Vector2i(0,0),Vector2i(1,1),Vector2i(0,1)]:
				var p := points[row + corner.y]
				var u := float(col + corner.x) / segments
				var angle := TAU * u
				tool.set_uv(Vector2(u, p.y / points[-1].y))
				tool.add_vertex(Vector3(cos(angle) * p.x, p.y, sin(angle) * p.x))
	tool.generate_normals()
	tool.set_material(mat)
	return tool.commit()
static func mesh(category: int, color: String, variant: int) -> Mesh:
	var key := "mesh" + str(category) + color + str(variant)
	if cache.has(key): return cache[key]
	var result: Mesh
	if category in [1, 5]:
		# Full shoulder, narrow neck, rolled lip and actual closure; stable flat base.
		result = profile([Vector2(0.02,0),Vector2(0.12,0.025),Vector2(0.125,0.36),Vector2(0.115,0.43),Vector2(0.045,0.51),Vector2(0.045,0.61),Vector2(0.055,0.62),Vector2(0.055,0.66),Vector2(0.005,0.66)],material(category,color,true))
	elif category == 2 or (category == 6 and variant == 1):
		result = profile([Vector2(0.01,0),Vector2(0.15,0.015),Vector2(0.155,0.035),Vector2(0.145,0.055),Vector2(0.145,0.39),Vector2(0.155,0.41),Vector2(0.15,0.43),Vector2(0.01,0.43)],material(category,color,true))
	elif category in [0,6,7]:
		# Sealed pillow bag instead of a rectangular block.
		var bag := SphereMesh.new()
		bag.radius = 0.5
		bag.height = 1.0
		bag.radial_segments = 12
		bag.rings = 6
		# Squeezed top and bottom, pillow center, full print on each broad face.
		var arrays := bag.get_mesh_arrays()
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var uvs: PackedVector2Array = arrays[Mesh.ARRAY_TEX_UV]
		for i in range(vertices.size()):
			vertices[i] = Vector3(vertices[i].x * 0.45, vertices[i].y * 0.55 + 0.28, vertices[i].z * 0.22)
			uvs[i] = Vector2(vertices[i].x / 0.45 + 0.5, 1.0 - vertices[i].y / 0.56)
			normals[i] = Vector3(normals[i].x / 0.45, normals[i].y / 0.55, normals[i].z / 0.22).normalized()
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		var pillow := ArrayMesh.new()
		pillow.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		pillow.surface_set_material(0, material(category,color,false))
		result = pillow
	else:
		var box := BoxMesh.new()
		box.size = Vector3(0.38,0.56,0.31) if category != 8 else Vector3(0.60,0.51,0.43)
		box.material = material(category,color,false)
		result = box
	cache[key] = result
	return result
static func batch(parent: Node3D, mesh: Mesh, transforms: Array[Transform3D], part_name: String) -> void:
	if transforms.is_empty(): return
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in range(transforms.size()): multi.set_instance_transform(i, transforms[i])
	var display := MultiMeshInstance3D.new()
	display.name = part_name
	display.multimesh = multi
	display.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(display)
