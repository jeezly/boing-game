@tool
extends Node3D
## Saved fixture children remain editable; repeated immutable meshes merge at runtime.
const Batch = preload("res://scripts/components/visual_batcher.gd")
func _ready() -> void:
 if not Engine.is_editor_hint():
  Batch.merge_children(self, scene_file_path)
