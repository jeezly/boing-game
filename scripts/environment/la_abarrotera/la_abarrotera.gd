extends Node3D
## Reference-led, roofless-for-readability store with six zones and two flank routes.

const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const Fruit = preload("res://scripts/components/visual_mesh_builder.gd")
const FixtureScene = preload("res://scenes/environment/la_abarrotera/store_fixture.tscn")
const Navigation = preload("res://scripts/environment/la_abarrotera/store_navigation.gd")
var navigation := Navigation.new()
var footprints: Dictionary = {}
var bodega_gates: Array[StaticBody3D] = []
var build_parent: Node3D

func _ready() -> void:
	add_to_group("store")
	build_parent = _zone("architecture")
	_shell()
	build_parent = _zone("shopping_floor")
	_shopping_floor()
	build_parent = _zone("bodega_and_patio")
	_storage_and_patio()
	build_parent = _zone("lighting_and_dressing")
	_dressing()
	_rebuild_navigation()

func _zone(zone_name: String) -> Node3D:
	var node := Node3D.new()
	node.name = zone_name
	add_child(node)
	return node

func _block(at: Vector3, size: Vector3, color: String, part_name: String, navigable_obstacle: bool = true) -> StaticBody3D:
	var body := Build.solid(build_parent, at, size, Build.mat(color), part_name)
	if navigable_obstacle:
		footprints[body] = Rect2(Vector2(at.x - size.x * 0.5, at.z - size.z * 0.5), Vector2(size.x, size.z))
	return body

func _fixture(kind: String, at: Vector3, length: float = 8.0, text: String = "ABARROTES") -> void:
	var fixture = FixtureScene.instantiate()
	fixture.name = kind
	fixture.kind = kind
	fixture.length = length
	fixture.sign_text = text
	build_parent.add_child(fixture)
	fixture.position = at
	var size: Vector2 = fixture.footprint_size
	footprints[fixture] = Rect2(Vector2(at.x, at.z) - size * 0.5, size)

func _shell() -> void:
	_block(Vector3(0, -0.2, -12), Vector3(34, 0.4, 68), "e4d1aa", "continuous_floor", false)
	# Side boundaries include the sidewalk and rear service pocket.
	for side in [-1.0, 1.0]:
		_block(Vector3(side * 16.5, 2.2, -6), Vector3(0.5, 4.4, 36), "efdbb9", "shop_wall")
		_block(Vector3(side * 16.5, 2.2, -30), Vector3(0.5, 4.4, 12), "a1aaa2", "bodega_wall")
		_block(Vector3(side * 16.5, 1.4, -41), Vector3(0.5, 2.8, 10), "c7aa7e", "patio_wall")
		_block(Vector3(side * 16.5, 0.8, 17), Vector3(0.5, 1.6, 10), "b39169", "approach_boundary")
		_block(Vector3(side * 10, 1.9, 12), Vector3(12, 3.8, 0.5), "eee0bb", "storefront")
		Build.box(build_parent, Vector3(side * 10, 0.35, 12.3), Vector3(12, 0.7, 0.08), Build.mat("bd3f35"), "painted_base")
		Build.box(build_parent, Vector3(side * 10, 1.8, 12.3), Vector3(9.8, 1.9, 0.05), Build.mat("316773"), "store_window")
		for x in range(5, 16, 2):
			Build.box(build_parent, Vector3(side * x, 1.8, 12.34), Vector3(0.08, 1.95, 0.08), Build.mat("ebc470"), "window_mullion")
	_block(Vector3(0, 4.1, 12), Vector3(33, 0.75, 0.5), "f3e5c6", "facade_header", false)
	Build.label(build_parent, "LA ABARROTERA", Vector3(0, 4.15, 12.30), 108, Color("e64a39"))
	Build.label(build_parent, "FRUTAS  /  ABARROTES  /  SABOR DEL BARRIO", Vector3(0, 3.55, 13.8), 32, Color("fff2cf"))
	Build.box(build_parent, Vector3(0, 3.43, 13), Vector3(32, 0.14, 2.3), Build.mat("d7473b"), "red_awning")
	for x in range(-15, 16):
		Build.box(build_parent, Vector3(x, 3.25, 14.1), Vector3(0.92, 0.30, 0.09), Build.mat("d7473b"), "awning_scallop")
	_block(Vector3(0, 0.9, 21.6), Vector3(33, 1.8, 0.3), "a88c69", "street_boundary")
	for side in [-1.0, 1.0]:
		_block(Vector3(side * 5.0, 0.48, 14), Vector3(0.3, 0.96, 0.3), "e9b73d", "bollard")
	# Back partitions have two broad store-to-bodega passages and one patio doorway.
	_block(Vector3(0, 2.1, -24), Vector3(15, 4.2, 0.4), "c7b594", "bodega_partition")
	for side in [-1.0, 1.0]:
		_block(Vector3(side * 14.5, 2.1, -24), Vector3(4, 4.2, 0.4), "c7b594", "partition_edge")
		var gate := _block(Vector3(side * 10, 1.7, -24), Vector3(5, 3.4, 0.3), "4b7575", "bodega_shutter")
		bodega_gates.append(gate)
		for y in range(1, 7):
			Build.box(gate, Vector3(0, -1.5 + y * 0.4, 0.17), Vector3(4.8, 0.04, 0.025), Build.mat("8eaaa4"))
		Build.label(build_parent, "BODEGA / ACCESO DE SERVICIO", Vector3(side * 10, 3.75, -23.74), 24)
	for side in [-1.0, 1.0]:
		_block(Vector3(side * 10.8, 2.1, -36), Vector3(11.4, 4.2, 0.4), "8b9895", "rear_partition")
	_block(Vector3(0, 1.4, -45.8), Vector3(33, 2.8, 0.4), "b99b76", "rear_boundary")
	Build.label(build_parent, "AQUI TAMBIEN SE MUEVE MEXICO", Vector3(0, 2.0, -45.55), 47, Color("c84435"))

func _shopping_floor() -> void:
	_fixture("checkout", Vector3(-6.5, 0, 8))
	_fixture("checkout", Vector3(6.5, 0, 8))
	for index in range(4):
		var x: float = [-10.0, -5.0, 5.0, 10.0][index]
		var category: String = ["ABARROTES", "LIMPIEZA", "BOTANAS", "BEBIDAS"][index]
		_fixture("shelf", Vector3(x, 0, -10), 10.0, category)
		var sign := Build.label(build_parent, category, Vector3(x, 3.0, -8), 34, Color("fff3ce"))
		Build.box(build_parent, Vector3(x, 3.0, -8.06), Vector3(3.3, 0.6, 0.06), Build.mat("236e83"))
		for offset in [-1.0, 1.0]:
			Build.box(build_parent, Vector3(x + offset, 3.7, -8), Vector3(0.025, 0.8, 0.025), Build.mat("6f685c"))
		# Sign faces front approach, kept well above jumping Mango.
		sign.no_depth_test = false
	_fixture("fridge", Vector3(-15, 0, -15), 14.0)
	for z in [-2.0, -7.0, -18.5]:
		_fixture("produce", Vector3(14.2, 0, z), 3.0, "FRUTA DE NUESTRA TIERRA")
	_fixture("pallet", Vector3(-11.5, 0, 1.5))
	_fixture("pallet", Vector3(10.5, 0, 1.5))
	_fixture("pallet", Vector3(2.7, 0, -20.5))
	_fixture("sacks", Vector3(14.2, 0, -12.5))
	Build.label(build_parent, "TODO PARA TU CASA", Vector3(0, 3.1, -23.74), 62, Color("b83e34"))

func _storage_and_patio() -> void:
	for x in [-13.5, -5.0, 5.0, 13.5]:
		_fixture("pallet", Vector3(x, 0, -27.5))
		_fixture("pallet", Vector3(x, 0, -33.0))
	for x in [-13.0, 13.0]:
		_fixture("pallet", Vector3(x, 0, -40.0))
	# Parked fictional delivery truck forms cover on the patio's left edge.
	_block(Vector3(-11, 1.6, -43), Vector3(5.2, 3.2, 3.0), "ddd9c5", "delivery_truck")
	Build.label(build_parent, "RUTA DEL SOL\nABASTO LOCAL", Vector3(-11, 1.7, -41.45), 26, Color("328581"))
	for x in [-12.7, -9.3]:
		Fruit.oval(build_parent, "truck_wheel", Vector3(x, 0.48, -41.46), Vector3(0.75, 0.75, 0.22), Build.mat("283836"))
	Build.label(build_parent, "PATIO DE CARGA", Vector3(0, 3.4, -35.72), 53, Color("fff1ca"))
	Build.box(build_parent, Vector3(0, 3.9, -38), Vector3(10, 0.16, 4.0), Build.mat("6b8c89"), "loading_canopy")
	for x in [-4.6, 4.6]:
		_block(Vector3(x, 1.9, -39.8), Vector3(0.15, 3.8, 0.15), "697975", "canopy_post")
	for index in range(5):
		Build.box(build_parent, Vector3(0, 0.015, -43 + index * 0.5), Vector3(5.0, 0.015, 0.18), Build.mat("dcaf38"), "loading_marking")
	Build.label(build_parent, "SALIDA / BARRIO SEGURO", Vector3(0, 1.1, -44.8), 36, Color("96d787"))

func _dressing() -> void:
	# Inset checker tiles create floor variation without collider seams.
	var tiles: Array[Vector3] = []
	for x in range(-15, 16, 2):
		for z in range(-23, 12, 2):
			if (x + z) % 4 == 0:
				tiles.append(Vector3(x, 0.006, z))
	Build.products(build_parent, tiles, "d6c39f", Vector3(1.92, 0.01, 1.92))
	Build.box(build_parent, Vector3(0, 0.006, -30), Vector3(32, 0.01, 12), Build.mat("98a59c"), "bodega_concrete")
	Build.box(build_parent, Vector3(0, 0.006, -41), Vector3(32, 0.01, 10), Build.mat("b7ad91"), "patio_concrete")
	Build.box(build_parent, Vector3(0, 0.01, 11), Vector3(6.0, 0.015, 1.5), Build.mat("c84e3f"), "welcome_mat")
	for z in [5.0, -6.0, -17.0, -29.0]:
		Build.box(build_parent, Vector3(0, 4.43, z), Vector3(33, 0.22, 0.32), Build.mat("e6dac0"), "ceiling_beam")
	for z in [-3.0, -14.0]:
		for index in range(12):
			var color: String = ["d84a47", "eab942", "339bb4", "ba4c82", "4b9f6b"][index % 5]
			var x := -14.3 + index * 2.6
			Build.box(build_parent, Vector3(x, 3.9 - absf(x) * 0.012, z), Vector3(1.1, 0.48, 0.025), Build.mat(color), "papel_picado")
			for hole in [-0.28, 0.0, 0.28]:
				Build.box(build_parent, Vector3(x + hole, 3.85 - absf(x) * 0.012, z + 0.016), Vector3(0.12, 0.12, 0.012), Build.mat("efe3c2"), "paper_cutout")
		Build.box(build_parent, Vector3(0, 4.12, z), Vector3(31, 0.025, 0.025), Build.mat("756858"), "decoration_cord")
	for x in [-9.0, 0.0, 9.0]:
		for z in [4.0, -9.0, -20.0, -30.0]:
			Build.box(build_parent, Vector3(x, 4.1, z), Vector3(2.2, 0.10, 0.55), Build.mat("fdf0cd", 0.7), "ceiling_lamp")
			Build.box(build_parent, Vector3(x, 4.27, z), Vector3(2.3, 0.22, 0.65), Build.mat("687c76"), "lamp_housing")
	# Restrained colored lights supplement global illumination in Compatibility.
	for z in [-9.0, -20.0]:
		var light := OmniLight3D.new()
		light.name = "fridge_cool_light"
		light.light_color = Color("83cde8")
		light.light_energy = 0.8
		light.omni_range = 9.0
		build_parent.add_child(light)
		light.position = Vector3(-13, 2.8, z)
	for side in [-1.0, 1.0]:
		var pot := Vector3(side * 12.5, 0.45, 15)
		Fruit.oval(build_parent, "terracotta_pot", pot, Vector3(1.1, 0.9, 1.1), Build.mat("b96240"))
		for index in range(5):
			var leaf := Fruit.oval(build_parent, "agave_leaf", pot + Vector3(sin(index * 1.25) * 0.25, 0.75, cos(index * 1.25) * 0.25), Vector3(0.17, 1.2, 0.2), Build.mat("4f9161"))
			leaf.rotation.z = sin(index * 1.25) * 0.6
	# Low display crates and water jugs stay along the perimeter, away from travel lanes.
	for index in range(5):
		Fruit.oval(build_parent, "water_jug", Vector3(14.5, 0.65, 5.0 + index * 0.6), Vector3(0.45, 1.1, 0.45), Build.mat("327bac"))
		Fruit.oval(build_parent, "jug_neck", Vector3(14.5, 1.22, 5.0 + index * 0.6), Vector3(0.18, 0.18, 0.18), Build.mat("1e4a7c"))
	Build.label(build_parent, "BUEN PRECIO\nBUENA GENTE", Vector3(-3.0, 1.0, 15.2), 33, Color("ffdd75"))
	Build.box(build_parent, Vector3(-3.0, 1.0, 15.15), Vector3(1.9, 1.4, 0.10), Build.mat("284b43"), "sidewalk_board")

func open_bodega() -> void:
	for gate in bodega_gates:
		footprints.erase(gate)
		gate.hide()
		gate.collision_layer = 0
		gate.collision_mask = 0
	_rebuild_navigation()

func _rebuild_navigation() -> void:
	var rectangles: Array[Rect2] = []
	for rect in footprints.values(): rectangles.append(rect)
	navigation.rebuild(rectangles)

func get_navigation_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	return navigation.path(from, to)
