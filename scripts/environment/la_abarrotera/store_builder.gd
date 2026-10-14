extends RefCounted
## Shared native-mesh construction. Small decorations deliberately have no collision.
static var material_cache: Dictionary = {}

static func mat(hex: String, glow: float = 0.0) -> StandardMaterial3D:
	var key := hex + ":" + str(glow)
	if material_cache.has(key): return material_cache[key]
	var result := StandardMaterial3D.new()
	result.albedo_color = Color(hex)
	result.roughness = 0.8
	if glow > 0.0:
		result.emission_enabled = true
		result.emission = Color(hex)
		result.emission_energy_multiplier = glow
	material_cache[key] = result
	return result

static func box(parent: Node3D, at: Vector3, size: Vector3, material: Material, part_name: String = "detail") -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh
	part.material_override = material
	parent.add_child(part)
	part.position = at
	return part

static func solid(parent: Node3D, at: Vector3, size: Vector3, material: Material, part_name: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = part_name
	body.collision_layer = 1
	body.collision_mask = 7
	parent.add_child(body)
	body.position = at
	box(body, Vector3.ZERO, size, material, "mesh")
	var collider := CollisionShape3D.new()
	collider.name = "collision_shape"
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	return body

static func label(parent: Node3D, text: String, at: Vector3, size: int = 64, color: Color = Color.WHITE) -> Label3D:
	var sign := Label3D.new()
	sign.name = "sign"
	sign.text = text
	sign.font_size = size
	sign.pixel_size = 0.008
	sign.modulate = color
	sign.outline_modulate = Color("23312e")
	sign.outline_size = 8
	parent.add_child(sign)
	sign.position = at
	return sign

static func products(parent: Node3D, positions: Array[Vector3], color: String, size: Vector3) -> void:
	if positions.is_empty():
		return
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat(color)
	var batch := MultiMesh.new()
	batch.transform_format = MultiMesh.TRANSFORM_3D
	batch.mesh = mesh
	batch.instance_count = positions.size()
	for index in range(positions.size()):
		batch.set_instance_transform(index, Transform3D(Basis.IDENTITY, positions[index]))
	var display := MultiMeshInstance3D.new()
	display.name = "product_batch"
	display.multimesh = batch
	parent.add_child(display)
