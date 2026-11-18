@tool
extends Node3D
## Each saved canopy exposes its painted caption without duplicating the fixture.
@export var caption: String = "DEL CAMPO A TU MESA":
 set(value):
  caption = value
  if is_node_ready(): _apply_caption()
func _ready() -> void:
 _apply_caption()
 if not Engine.is_editor_hint():
  preload("res://scripts/components/visual_batcher.gd").merge_children(self, scene_file_path)
func _apply_caption() -> void:
 var lettering := get_node_or_null("market_card/lettering") as Label3D
 if lettering != null: lettering.text = caption
