@tool
extends Node3D
## Small non-colliding details sit on existing fixtures, never in movement lanes.
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Batch = preload("res://scripts/components/visual_batcher.gd")
@export_enum("checkout", "produce", "sacks", "fridge", "shelf") var kind: String = "checkout"

func _ready() -> void:
	match kind:
		"checkout": _checkout()
		"produce": _produce()
		"sacks": _sacks()
		"fridge": _fridge()
		"shelf": _shelf()
	Batch.merge_children(self, "beta_fixture_" + kind + (String(get_parent().name) if kind == "shelf" else ""))

func sign_board(text: String, at: Vector3, size: Vector2, color: String = "28584e", yaw: float = 0.0) -> void:
	var holder := Node3D.new()
	holder.name = "physical_offer"
	add_child(holder)
	holder.position = at
	holder.rotation.y = yaw
	Build.box(holder, Vector3.ZERO, Vector3(size.x, size.y, 0.035), Build.mat(color), "painted_board")
	var text_label := Build.label(holder, text, Vector3(0, 0, 0.025), 28, Color("fff0c6"))
	text_label.pixel_size = 0.0032
	text_label.outline_size = 0
	text_label.visibility_range_end = 32.0
	text_label.no_depth_test = false

func _checkout() -> void:
	for color in range(3):
		var wrappers: Array[Vector3] = []
		for row in range(3):
			for col in range(4): wrappers.append(Vector3(-1.65 + col * 0.28, 1.25 + row * 0.09, 1.2 + color * 0.30))
		Build.products(self, wrappers, ["e5b438", "cc4f50", "538c9b"][color], Vector3(0.22, 0.075, 0.20))
	var keys: Array[Vector3] = []
	for row in range(3):
		for col in range(4): keys.append(Vector3(0.84 + col * 0.12, 1.66, 1.61 + row * 0.10))
	Build.products(self, keys, "eee1c8", Vector3(0.075, 0.025, 0.065))
	Build.box(self, Vector3(1.10, 1.68, 1.95), Vector3(0.17, 0.015, 0.30), Build.mat("f2e8d5"), "receipt")
	sign_board("DULCES LA ESQUINA\nHOY: 3 POR $10", Vector3(-1.2, 1.60, 2.85), Vector2(1.6, 0.45), "a64335")
	Build.box(self, Vector3(-1.2, 1.35, 2.82), Vector3(0.045, 0.40, 0.045), Build.mat("795632"), "offer_stand")

func _produce() -> void:
	sign_board("FRESCO DEL MERCADO\nLLEVE LO DE TEMPORADA", Vector3(0, 1.65, 2.56), Vector2(2.5, 0.55), "795632")
	Build.box(self, Vector3(0, 1.35, 2.53), Vector3(0.055, 0.80, 0.055), Build.mat("795632"), "offer_stake")
	# Slats and corner hardware make the existing bins read as market huacales.
	for y in [0.24, 0.52, 0.80]:
		Build.box(self, Vector3(0, y, 2.53), Vector3(3.95, 0.16, 0.07), Build.mat("b88a4e"), "crate_slat")
	for x in [-1.85, 1.85]:
		Build.box(self, Vector3(x, 0.55, 2.58), Vector3(0.09, 0.85, 0.045), Build.mat("6e583a"), "crate_corner")

func _sacks() -> void:
	for x in [-0.53, 0.53]:
		Build.box(self, Vector3(x, 0.60, 1.01), Vector3(0.33, 0.28, 0.02), Build.mat("87633e"), "sack_stamp")
		B.rod(self, "sack_stitch", Vector3(x, 0.20, 0.995), Vector3(x, 0.85, 0.94), 0.008, Build.mat("c9b185"))

func _fridge() -> void:
	for z in range(-7, 8, 2):
		for y in [0.34, 1.10, 1.86, 2.62, 3.38]:
			Build.box(self, Vector3(1.245, y, z), Vector3(0.022, 0.035, 1.78), Build.mat("bdd8d2"), "door_rail")
		Build.box(self, Vector3(1.25, 2.0, z - 0.90), Vector3(0.04, 3.35, 0.045), Build.mat("42646a"), "door_frame")
	sign_board("RETORNABLES\nLA BURBUJITA", Vector3(1.30, 3.70, 0), Vector2(2.3, 0.48), "245871", PI * 0.5)

func _shelf() -> void:
	var fixture_name := String(get_parent().name)
	if fixture_name.begins_with("industrial_"):
		# Labels, strapping and box seams instead of retail offers in the bodega.
		for z in [-6.0, -2.0, 2.0, 6.0]:
			Build.box(self, Vector3(1.18, 1.2, z), Vector3(0.02, 0.28, 0.38), Build.mat("eee0ba"), "cargo_label")
		return
	var index := clampi(int(fixture_name.split("_")[1]) - 1, 0, 7) if fixture_name.begins_with("aisle_") else 0
	var brands: Array[String] = ["CRUJIMANGO\nBOTANAS DE BARRIO", "BRILLA BONITO\nLIMPIEZA DEL HOGAR", "LA COSECHITA\nENLATADOS", "CASA CONTENTA\nTODO PARA EL HOGAR", "MAÑANITAS\nCEREALES", "LA BURBUJITA\nBEBIDAS", "DULCES LA ESQUINA\nUN GUSTITO MÁS", "EL COSTALITO\nABARROTES"]
	var colors: Array[String] = ["ad4930", "337a85", "558253", "94734d", "b57d28", "326b99", "ab4e78", "7b753d"]
	sign_board(brands[index], Vector3(0, 3.15, 8.06), Vector2(2.6, 0.65), colors[index])
	sign_board("OFERTA DEL DÍA\nBUEN PRECIO, BUENA GENTE", Vector3(0, 1.65, 8.06), Vector2(2.4, 0.60), "a54532")
