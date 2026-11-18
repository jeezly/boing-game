extends Node
## Per-instance overlay preserves all underlying enemy materials and reactions.
var left: float = 0.0
var meshes: Array[MeshInstance3D] = []
var overlay: StandardMaterial3D
func flash(visual: Node3D) -> void:
	if overlay == null:
		overlay = StandardMaterial3D.new()
		overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		overlay.albedo_color = Color(1.0, 0.04, 0.02, 0.65)
		for mesh in visual.find_children("*", "MeshInstance3D", true, false): meshes.append(mesh)
	for mesh in meshes:
		if is_instance_valid(mesh): mesh.material_overlay = overlay
	left = 0.16
func _process(delta: float) -> void:
	if left <= 0: return
	left = maxf(0, left - delta)
	for mesh in meshes:
		# Runs after the base reaction animation; its restore must not erase a fresh hit.
		if is_instance_valid(mesh): mesh.material_overlay = overlay if left > 0 else null
