@tool
extends Node3D
## Only repeated non-colliding goods are generated; shelves/collision stay authored.
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
@export_enum("shelf", "fridge") var style: String = "shelf"

func _ready() -> void:
	var colors := ["eab741", "d95a43", "58a675", "2789c0", "f1e7c8"]
	for color_index in range(colors.size()):
		var points: Array[Vector3] = []
		for row in range(4):
			for column in range(30):
				if (row + column) % colors.size() != color_index: continue
				var z := -7.5 + column * 0.51
				if style == "fridge":
					points.append(Vector3(1.035, 0.55 + row * 0.76, z))
				else:
					for side in [-1.0, 1.0]:
						points.append(Vector3(side * 0.82, 0.58 + row * 0.76, z))
		Build.products(self, points, colors[color_index], Vector3(0.36 if style == "shelf" else 0.035, 0.48, 0.30))
