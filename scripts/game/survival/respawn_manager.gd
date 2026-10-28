extends Node
## Small authored marker selector; physical clearance is checked at every life loss.
@export var player_path: NodePath
@export var environment_path: NodePath
@onready var player: CharacterBody3D = get_node(player_path)
@onready var environment = get_node(environment_path)
const SAFE_RADIUS: float = 9.0

func choose(zone: StringName) -> Vector3:
	var candidates: Array[Marker3D] = []
	var preferred: Vector3 = environment.zones[zone].global_position if environment.zones.has(zone) else player.global_position
	for marker in environment.get_node("respawn_points").get_children():
		if marker is Marker3D and _clear_geometry(marker.global_position): candidates.append(marker)
	candidates.sort_custom(func(a: Marker3D, b: Marker3D): return a.global_position.distance_squared_to(preferred) < b.global_position.distance_squared_to(preferred))
	for marker in candidates:
		if _enemy_distance(marker.global_position) >= SAFE_RADIUS: return marker.global_position
	# An occupied marker is recoverable: retire nearby pressure without awarding score.
	# This also prevents a saturated final-minute horde from denying every respawn.
	var fallback: Vector3 = candidates[0].global_position if not candidates.is_empty() else Vector3(0, 0.05, 6)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(fallback) < SAFE_RADIUS:
			enemy.deactivate()
			enemy.queue_free()
	return fallback

func _clear_geometry(point: Vector3) -> bool:
	var space := player.get_world_3d().direct_space_state
	var floor_query := PhysicsRayQueryParameters3D.create(point + Vector3.UP, point - Vector3.UP * 0.5, 1)
	var floor_hit := space.intersect_ray(floor_query)
	if floor_hit.is_empty() or floor_hit.normal.y < 0.7 or absf(floor_hit.position.y - point.y) > 0.15: return false
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 1.9
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform = Transform3D(Basis.IDENTITY, point + Vector3.UP * 0.98)
	query.collision_mask = 1
	return space.intersect_shape(query, 1).is_empty() and environment.is_walkable(point)

func _enemy_distance(point: Vector3) -> float:
	var nearest := INF
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.dead: nearest = minf(nearest, enemy.global_position.distance_to(point))
	return nearest
