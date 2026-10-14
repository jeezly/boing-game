extends Node3D
## Gameplay geometry lives in saved scenes. This script indexes zones, spawns and collision.
signal entrance_crossed(body: Node3D)
const Navigation = preload("res://scripts/environment/mega_abarrotera/planar_navigation.gd")
var navigation := Navigation.new()
var zones: Dictionary = {}
var spawn_markers: Array[Marker3D] = []
@onready var entrance: Area3D = $fachada_y_acceso/entrance_trigger
@onready var objectives: Node3D = $objective_markers

func _ready() -> void:
	add_to_group("store")
	for child in get_children():
		if child.has_method("contains_point"): zones[child.zone_id] = child
	for group in $spawn_points.get_children():
		for marker in group.get_children():
			if marker is Marker3D: spawn_markers.append(marker)
	var rectangles: Array[Rect2] = []
	_collect_obstacles(self, rectangles)
	navigation.rebuild(Rect2(-75, -95, 150, 110), rectangles)
	entrance.body_entered.connect(_on_entrance)
	set_objective(&"entrance", "ENTRA A LA ABARROTERA")

func _collect_obstacles(node: Node, result: Array[Rect2]) -> void:
	if node is StaticBody3D and node.is_in_group("navigation_obstacle"):
		for child in node.get_children():
			if not child is CollisionShape3D or not child.shape is BoxShape3D: continue
			var half: Vector3 = child.shape.size * 0.5
			var minimum := Vector2(INF, INF)
			var maximum := Vector2(-INF, -INF)
			for x in [-1.0, 1.0]:
				for y in [-1.0, 1.0]:
					for z in [-1.0, 1.0]:
						var corner: Vector3 = child.to_global(Vector3(x, y, z) * half)
						minimum = minimum.min(Vector2(corner.x, corner.z))
						maximum = maximum.max(Vector2(corner.x, corner.z))
			result.append(Rect2(minimum, maximum - minimum))
	for child in node.get_children(): _collect_obstacles(child, result)

func _on_entrance(body: Node3D) -> void:
	if body.is_in_group("player"): entrance_crossed.emit(body)

func get_navigation_path(from: Vector3, to: Vector3) -> PackedVector3Array:
	return navigation.path(from, to)

func is_walkable(point: Vector3) -> bool:
	return navigation.is_walkable(point)

func contains_zone(zone: StringName, point: Vector3) -> bool:
	return zones.has(zone) and zones[zone].contains_point(point)

func set_objective(zone: StringName, text: String) -> void:
	for marker in objectives.get_children():
		marker.visible = marker.name == String(zone)
		if marker.visible:
			var label := marker.get_node("beacon/label") as Label3D
			label.text = {&"entrance": "ENTRADA", &"cajas": "CAJAS", &"pasillos": "PASILLOS", &"refrigeradores": "FRÍOS", &"frutas": "FRUTAS", &"bodega": "BODEGA", &"patio": "PATIO"}.get(zone, text)
