extends Node3D
## One reusable module for stocked shelves, fridge banks, produce bins and pallets.

const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const Fruit = preload("res://scripts/components/visual_mesh_builder.gd")
@export_enum("shelf", "fridge", "produce", "pallet", "checkout", "sacks") var kind: String = "shelf"
@export var length: float = 8.0
@export var sign_text: String = "ABARROTES"
var footprint_size: Vector2

func _ready() -> void:
	match kind:
		"shelf": _shelf()
		"fridge": _fridge()
		"produce": _produce()
		"pallet": _pallet()
		"checkout": _checkout()
		"sacks": _sacks()

func _collision(size: Vector3) -> void:
	footprint_size = Vector2(size.x, size.z)
	var body := StaticBody3D.new()
	body.name = "solid"
	body.collision_layer = 1
	add_child(body)
	var collider := CollisionShape3D.new()
	collider.name = "collision_shape"
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	collider.position.y = size.y * 0.5

func _shelf() -> void:
	_collision(Vector3(1.5, 1.95, length))
	var teal := Build.mat("247a79")
	var cream := Build.mat("efe2c3")
	var red := Build.mat("c93c3f")
	Build.box(self, Vector3(0, 0.95, 0), Vector3(0.16, 1.9, length), teal, "back_panel")
	for z in [-length * 0.5, length * 0.5]:
		Build.box(self, Vector3(0, 0.97, z), Vector3(1.5, 1.94, 0.12), teal, "end_cap")
		var sign := Build.label(self, sign_text, Vector3(0, 1.64, z + signf(z) * 0.075), 23)
		if z < 0.0: sign.rotation.y = PI
	for row in range(4):
		var y := 0.2 + row * 0.47
		Build.box(self, Vector3(0, y, 0), Vector3(1.5, 0.09, length), cream, "shelf_board")
		for side in [-1.0, 1.0]:
			Build.box(self, Vector3(side * 0.74, y + 0.035, 0), Vector3(0.04, 0.09, length), red, "price_rail")
	var colors := ["efbd48", "df6043", "55a378", "3382b0", "eee5cd"]
	for color_index in range(colors.size()):
		var points: Array[Vector3] = []
		for row in range(4):
			for column in range(int(length / 0.35)):
				if (row + column) % colors.size() != color_index: continue
				for side in [-1.0, 1.0]:
					points.append(Vector3(side * 0.44, 0.4 + row * 0.47, -length * 0.5 + 0.23 + column * 0.35))
		Build.products(self, points, colors[color_index], Vector3(0.31, 0.31, 0.25))

func _fridge() -> void:
	_collision(Vector3(1.4, 2.6, length))
	var metal := Build.mat("294951")
	var pale := Build.mat("b4e0e4", 0.18)
	Build.box(self, Vector3(0, 1.3, 0), Vector3(1.35, 2.6, length), metal, "fridge_case")
	for index in range(int(length / 1.3)):
		var z := -length * 0.5 + 0.7 + index * 1.3
		Build.box(self, Vector3(0.70, 1.35, z), Vector3(0.03, 2.1, 1.13), pale, "lit_door")
		Build.box(self, Vector3(0.75, 1.2, z + 0.42), Vector3(0.08, 0.65, 0.06), metal, "door_handle")
		for row in range(4):
			var points: Array[Vector3] = []
			for bottle in range(4):
				points.append(Vector3(0.74, 0.55 + row * 0.47, z - 0.4 + bottle * 0.24))
			Build.products(self, points, "3c9cce" if row % 2 == 0 else "5aae72", Vector3(0.055, 0.29, 0.15))
	var sign := Build.label(self, "REFRESCOS / BIEN FRIOS", Vector3(0.76, 2.4, 0), 25)
	sign.rotation.y = PI / 2.0

func _produce() -> void:
	_collision(Vector3(2.0, 0.95, 3.0))
	var wood := Build.mat("a07343")
	Build.box(self, Vector3(0, 0.48, 0), Vector3(2, 0.95, 3), wood, "produce_crate")
	for edge in [-1.0, 1.0]:
		Build.box(self, Vector3(edge * 0.98, 1.03, 0), Vector3(0.08, 0.2, 3), wood)
	for index in range(12):
		var fruit_mat := Build.mat("eba537" if index % 2 == 0 else "719849")
		Fruit.oval(self, "fruit", Vector3(-0.65 + (index % 3) * 0.65, 1.05, -1.05 + int(index / 3.0) * 0.68), Vector3(0.40, 0.35, 0.45), fruit_mat)
	Build.label(self, sign_text, Vector3(0, 0.65, 1.53), 27, Color("fff2b8"))

func _pallet() -> void:
	_collision(Vector3(2.5, 1.5, 2.5))
	var wood := Build.mat("775d41")
	var card := Build.mat("c49c63")
	for index in range(5):
		Build.box(self, Vector3(-1.05 + index * 0.52, 0.12, 0), Vector3(0.40, 0.24, 2.5), wood, "pallet_slat")
	for level in range(2):
		for x in [-0.62, 0.62]:
			for z in [-0.62, 0.62]:
				Build.box(self, Vector3(x, 0.53 + level * 0.62, z), Vector3(1.08, 0.59, 1.08), card, "stock_box")
				Build.box(self, Vector3(x, 0.83 + level * 0.62, z), Vector3(0.09, 0.012, 1.08), wood, "packing_tape")
	Build.label(self, "COSECHA\nDEL BARRIO", Vector3(0, 0.9, 1.26), 20)

func _checkout() -> void:
	_collision(Vector3(3.8, 1.08, 2.0))
	Build.box(self, Vector3(0, 0.48, 0), Vector3(3.8, 0.96, 2), Build.mat("d55341"), "checkout_base")
	Build.box(self, Vector3(0, 1.02, 0), Vector3(3.9, 0.12, 2.1), Build.mat("e1c792"), "counter_top")
	Build.box(self, Vector3(-0.45, 1.10, 0), Vector3(1.7, 0.025, 1.4), Build.mat("2c4141"), "belt")
	Build.box(self, Vector3(1.10, 1.28, 0), Vector3(0.6, 0.36, 0.5), Build.mat("374859"), "register")
	Build.box(self, Vector3(1.10, 1.39, 0.27), Vector3(0.43, 0.18, 0.018), Build.mat("74d9a5", 0.3), "register_screen")
	Build.label(self, "CAJA / GRACIAS", Vector3(0, 0.6, 1.02), 26)

func _sacks() -> void:
	_collision(Vector3(2.0, 1.1, 2.0))
	var fabric := Build.mat("dacbab")
	for index in range(4):
		var x := -0.46 + (index % 2) * 0.92
		var z := -0.46 + int(index / 2.0) * 0.92
		Fruit.oval(self, "grain_sack", Vector3(x, 0.49, z), Vector3(0.83, 0.96, 0.82), fabric)
		Fruit.oval(self, "sack_tie", Vector3(x, 1.0, z), Vector3(0.16, 0.17, 0.16), Build.mat("886e42"))
	Build.label(self, "MAIZ DEL BARRIO", Vector3(0, 0.60, 1.03), 23, Color("426b4d"))
