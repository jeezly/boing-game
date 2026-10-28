@tool
extends Node3D
## Only repeated non-colliding goods are generated; shelves/collision stay authored.
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
@export_enum("shelf", "fridge") var style: String = "shelf"
static var mesh_cache: Dictionary = {}
const PALETTES: Array = [
	["e6b735", "c5412e", "f07132", "4c842b", "f2cf65"], # botanas
	["49afb3", "e6dced", "3173b8", "9cbb53", "f2ecdc"], # limpieza
	["c64732", "689351", "d9bd67", "e1d4a8", "7d9b91"], # enlatados
	["77aaa5", "b87b53", "dfceb0", "779c57", "cf6947"], # hogar
	["edb443", "d97735", "794d2c", "eddbb2", "bb4439"], # cereales
	["387cb4", "b63e36", "e6a836", "5b9562", "dad8c2"], # bebidas
	["dc668f", "a67aca", "e8ba3d", "53acaa", "d65a3d"], # dulces
	["e5d6af", "a95030", "658644", "ba9e67", "dc9b42"], # abarrotes
	["9c7954", "c39b6c", "a88964", "c0a17c", "806344"] # bodega
]

func _ready() -> void:
	var fixture_name := String(get_parent().name)
	var category := 5 if style == "fridge" else 7
	if fixture_name.begins_with("aisle_"): category = clampi(int(fixture_name.split("_")[1]) - 1, 0, 7)
	elif fixture_name.begins_with("industrial_"): category = 8
	var colors: Array = PALETTES[category]
	var round_goods := category == 1 or category == 2 or category == 5
	var size := Vector3(0.38, 0.48, 0.32)
	if category == 4: size = Vector3(0.44, 0.57, 0.34)
	elif category == 6: size = Vector3(0.32, 0.36, 0.29)
	elif category == 8: size = Vector3(0.62, 0.53, 0.43)
	var labels: Array[Vector3] = []
	var caps: Array[Vector3] = []
	for color_index in range(colors.size()):
		var points: Array[Vector3] = []
		for row in range(4):
			for column in range(30):
				if (row + column) % colors.size() != color_index: continue
				var z := -7.5 + column * 0.51
				var sides: Array = [1.0] if style == "fridge" else [-1.0, 1.0]
				for side in sides:
					var point := Vector3(side * (1.06 if style == "fridge" else 0.86), 0.55 + row * 0.76, z)
					points.append(point)
					labels.append(point + Vector3(side * (0.14 if round_goods else size.x * 0.51), 0, 0))
					if round_goods and category != 2: caps.append(point + Vector3.UP * 0.26)
		if round_goods:
			var key: String = str(category) + str(color_index) + style
			if not mesh_cache.has(key):
				var cylinder := CylinderMesh.new()
				cylinder.top_radius = 0.09 if category != 2 else 0.16
				cylinder.bottom_radius = 0.13 if category != 2 else 0.16
				cylinder.height = 0.43
				cylinder.radial_segments = 8
				cylinder.material = Build.mat(colors[color_index])
				mesh_cache[key] = cylinder
			batch(points, mesh_cache[key])
		else:
			Build.products(self, points, colors[color_index], size)
	Build.products(self, labels, "f4e5bd", Vector3(0.018, 0.13, 0.19))
	Build.products(self, caps, "e8e2d1", Vector3(0.12, 0.09, 0.12))

func batch(points: Array[Vector3], mesh: Mesh) -> void:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = points.size()
	for index in range(points.size()): multi.set_instance_transform(index, Transform3D(Basis.IDENTITY, points[index]))
	var display := MultiMeshInstance3D.new()
	display.multimesh = multi
	display.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(display)
