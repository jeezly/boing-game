@tool
extends Node3D
## Reusable seven-point paper star; cached static surfaces, no gameplay collision.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const Batch = preload("res://scripts/components/visual_batcher.gd")

func _ready() -> void:
	var colors: Array[String] = ["eab531", "dc4b6e", "369e9d", "77a746", "ae6bb7"]
	B.rod(self, "hanging_rope", Vector3(0, 0.6, 0), Vector3(0, 9.4, 0), 0.012, Build.mat("78633e"))
	B.oval(self, "paper_core", Vector3.ZERO, Vector3(1.25, 1.25, 0.8), Build.mat("dc4b6e"))
	for index in range(7):
		var angle := TAU * index / 7.0
		var axis := Vector3(sin(angle), cos(angle), 0)
		var cone := CylinderMesh.new()
		cone.top_radius = 0.015
		cone.bottom_radius = 0.31
		cone.height = 0.95
		cone.radial_segments = 12
		var point := B.mesh_part(self, "star_point", axis * 0.95, Vector3.ONE, cone, Build.mat(colors[index % colors.size()]))
		point.rotation.z = -angle
		var ribbon := Build.box(self, axis * 1.5 + Vector3.DOWN * 0.28, Vector3(0.08, 0.65, 0.015), Build.mat(colors[(index + 2) % colors.size()]), "paper_tail")
		ribbon.rotation.z = 0.12 * sin(angle)
	for band in range(5):
		var points: Array[Vector3] = []
		var y := -0.48 + band * 0.22
		var radius := sqrt(maxf(0.0, 1.0 - y * y / 0.40)) * 0.63
		for index in range(24):
			var angle := TAU * index / 24.0
			points.append(Vector3(cos(angle) * radius, y, sin(angle) * radius * 0.67))
		Build.products(self, points, colors[band], Vector3(0.12, 0.15, 0.045))
	Batch.merge_children(self, "beta_star_pinata")
