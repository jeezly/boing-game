extends Node3D
## Short, pooled-by-lifetime graphic burst. No lights or physics bodies.
var clock: float = 0.0
var pieces: Array[Node3D] = []
static func spawn(parent: Node, at: Vector3, tint: Color, healing: bool = false) -> void:
	var burst = load("res://scripts/game/production/pickup_burst.gd").new()
	parent.add_child(burst)
	burst.global_position = at
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = tint
	material.emission_enabled = true
	material.emission = tint
	for i in range(8):
		var piece := Node3D.new()
		burst.add_child(piece)
		var angle := TAU * i / 8.0
		piece.position = Vector3(cos(angle), 0, sin(angle)) * 0.35
		burst.pieces.append(piece)
		for size in ([Vector3(0.06, 0.22, 0.04), Vector3(0.22, 0.06, 0.04)] if healing else [Vector3(0.06, 0.15, 0.06)]):
			var mesh := MeshInstance3D.new()
			var box := BoxMesh.new()
			box.size = size
			mesh.mesh = box
			mesh.material_override = material
			mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			piece.add_child(mesh)
		piece.rotation.y = -angle
func _process(delta: float) -> void:
	clock += delta
	for piece in pieces:
		piece.position += Vector3(piece.position.x * 0.7, 0.8, piece.position.z * 0.7) * delta
		piece.scale = Vector3.ONE * maxf(0.0, 1.0 - clock / 0.85)
	if clock >= 0.85: queue_free()
