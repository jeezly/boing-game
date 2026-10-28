@tool
extends Node3D
## Painted market panel mounted directly on the existing produce wall.
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Batch = preload("res://scripts/components/visual_batcher.gd")

func _ready() -> void:
	Build.box(self, Vector3.ZERO, Vector3(22, 4.5, 0.06), Build.mat("e5ca91"), "painted_plaster")
	for y in [-2.05, 2.05]:
		Build.box(self, Vector3(0, y, 0.045), Vector3(21.7, 0.18, 0.03), Build.mat("b95332"), "painted_border")
	var title := Build.label(self, "FRUTAS Y GRANEL", Vector3(0, 0.65, 0.05), 54, Color("a03c2d"))
	title.pixel_size = 0.008
	title.outline_size = 0
	var subtitle := Build.label(self, "DE NUESTRA TIERRA · A SU MESA", Vector3(0, -0.35, 0.05), 36, Color("476c37"))
	subtitle.pixel_size = 0.006
	subtitle.outline_size = 0
	for side in [-1.0, 1.0]:
		for index in range(3):
			var at := Vector3(side * (7.1 + index * 0.95), -0.10 + (index % 2) * 0.4, 0.065)
			B.oval(self, "painted_fruit", at, Vector3(1.3, 1.5, 0.035), Build.mat(["d4a326", "a64230", "71964b"][index]))
			var leaf := B.oval(self, "painted_leaf", at + Vector3(0.25, 0.80, 0.01), Vector3(0.25, 0.65, 0.018), Build.mat("4e793b"))
			leaf.rotation.z = -0.6
	var blue_tiles: Array[Vector3] = []
	var cream_tiles: Array[Vector3] = []
	for index in range(44):
		var at := Vector3(-10.75 + index * 0.5, -1.7, 0.055)
		if index % 2 == 0: blue_tiles.append(at)
		else: cream_tiles.append(at)
	Build.products(self, blue_tiles, "32677e", Vector3(0.47, 0.37, 0.025))
	Build.products(self, cream_tiles, "f6e1b2", Vector3(0.47, 0.37, 0.025))
	Batch.merge_children(self, "beta_market_mural")
