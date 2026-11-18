extends MeshInstance3D
## Four low-poly puffs per second, each alive for less than one second.
var age: float = 0.0
static var shared_mesh: SphereMesh
static func spawn(parent: Node, at: Vector3) -> void:
	if shared_mesh == null:
		shared_mesh = SphereMesh.new()
		shared_mesh.radius = 0.07
		shared_mesh.height = 0.14
		shared_mesh.radial_segments = 8
		shared_mesh.rings = 4
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("ffe4b6")
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		shared_mesh.material = mat
	var puff = load("res://scripts/game/production/spicy_puff.gd").new()
	puff.mesh = shared_mesh
	puff.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(puff)
	puff.global_position = at
func _process(delta: float) -> void:
	age += delta
	position.y += delta*0.55
	scale = Vector3.ONE * maxf(0.0,1.0-age/0.7)
	if age >= 0.7: queue_free()
