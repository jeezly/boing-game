extends Node3D
## Bounded geometry effects, pausable lifetime and fixed-rate salsa damage.
var tint: Color = Color.ORANGE
var size: float = 1
var hazard: bool = false
var age: float = 0
var tick: float = 0
var mesh: MeshInstance3D
func _ready() -> void:
	add_to_group("combat_effects")
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh = MeshInstance3D.new()
	var ring := TorusMesh.new()
	ring.inner_radius = 0.8
	ring.outer_radius = 1
	ring.rings = 24
	ring.ring_segments = 6
	mesh.mesh = ring
	mesh.material_override = material
	add_child(mesh)
func _process(delta: float) -> void:
	age += delta
	if age > (4.0 if hazard else 0.4):
		queue_free()
		return
	var radius := size * (minf(1, age * 7) if hazard else age * 2.5)
	mesh.scale = Vector3(radius, 0.08, radius)
	if hazard:
		tick -= delta
		if tick <= 0:
			tick = 0.5
			for enemy in get_tree().get_nodes_in_group("enemies"):
				if not enemy.dead and enemy.global_position.distance_to(global_position) < size: enemy.take_damage(10)
