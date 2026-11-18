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
	var goods = preload("res://scripts/environment/mega_abarrotera/retail_goods.gd")
	var fixture_name := String(get_parent().name)
	var category := 5 if style == "fridge" else 7
	if fixture_name.begins_with("aisle_"): category = clampi(int(fixture_name.split("_")[1]) - 1, 0, 7)
	elif fixture_name.begins_with("industrial_"): category = 8
	if category == 8:
		_warehouse(goods)
		return
	for brand in range(3):
		var transforms: Array[Transform3D] = []
		var caps: Array[Vector3] = []
		for row in range(4):
			for col in range(30):
				if (col / 5 + row / 2) % 3 != brand: continue
				if (col + row*3) % 17 == 11: continue
				for side in ([1.0] if style == "fridge" else [-1.0,1.0]):
					var bottom := Vector3(side * (1.06 if style == "fridge" else 0.86), 0.31 + row * 0.76, -7.5 + col * 0.51)
					var angle: float = side * PI * 0.5 + sin(col * 7 + row) * 0.035
					var origin := bottom + (Vector3.UP * 0.28 if category in [3,4,8] else Vector3.ZERO)
					var shape_scale := Vector3.ONE * (0.94 + 0.06 * sin(col * 1.8 + row))
					transforms.append(Transform3D(Basis(Vector3.UP,angle).scaled(shape_scale),origin))
					if category in [1,5]: caps.append(bottom + Vector3.UP * 0.645)
		goods.batch(self, goods.mesh(category, PALETTES[category][brand], brand % 2), transforms, "stock_brand_%d" % brand)
		Build.products(self,caps,["d83230","efe1b8","2a7759"][brand],Vector3(0.115,0.045,0.115))

func _warehouse(goods) -> void:
	var carton := BoxMesh.new()
	carton.size = Vector3(0.64,0.50,0.86)
	carton.material = goods.material(8,"ac8254",false)
	var straps: Array[Vector3] = []
	for shipment in range(3):
		var transforms: Array[Transform3D] = []
		for row in range(4):
			for col in range(15):
				if col / 5 != shipment or (row+col)%13 == 7: continue
				for side in [-1,1]:
					var at := Vector3(side*0.86,0.56+row*0.76,-7.15+col*1.02)
					var scale_y := 0.85 if (row+col)%3 == 0 else 1.0
					transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1,scale_y,1)),at))
					straps.append(at+Vector3.UP*0.255*scale_y)
		goods.batch(self,carton,transforms,"warehouse_shipment_%d" % shipment)
	Build.products(self,straps,"ddc297",Vector3(0.65,0.018,0.10))
