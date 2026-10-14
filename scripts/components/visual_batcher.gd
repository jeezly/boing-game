extends RefCounted
## Cache/merge immutable visual pieces. Art transforms/materials are preserved.
## Animated limbs, markers and emission nodes are never merged into their parents.
static var cache: Dictionary = {}

static func merge_children(root: Node3D, cache_key: String) -> void:
	if Engine.is_editor_hint(): return
	var sources: Array[MeshInstance3D] = []
	for child in root.get_children():
		if child is MeshInstance3D: sources.append(child)
	if sources.is_empty(): return
	var combined: ArrayMesh
	if cache.has(cache_key):
		combined = cache[cache_key]
	else:
		combined = ArrayMesh.new()
		var groups: Dictionary = {}
		for source in sources:
			for surface in range(source.mesh.get_surface_count()):
				var material := source.material_override
				if material == null: material = source.mesh.surface_get_material(surface)
				if not groups.has(material): groups[material] = []
				groups[material].append([source, surface])
		for material in groups:
			var tool := SurfaceTool.new()
			tool.begin(Mesh.PRIMITIVE_TRIANGLES)
			for entry in groups[material]:
				var source: MeshInstance3D = entry[0]
				tool.append_from(source.mesh, entry[1], source.transform)
			tool.set_material(material)
			tool.commit(combined)
		cache[cache_key] = combined
	for source in sources: source.free()
	var mesh := MeshInstance3D.new()
	mesh.name = "cached_static_visual"
	mesh.mesh = combined
	root.add_child(mesh)
