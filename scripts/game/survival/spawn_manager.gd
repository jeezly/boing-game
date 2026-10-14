extends Node
## Strict camera visibility + floor/route/spacing checks; no visible fallback pop-in.
@export var environment_path: NodePath
@export var player_path: NodePath
@export var camera_rig_path: NodePath
@export var minimum_distance: float = 14.0
@export var maximum_distance: float = 65.0
@onready var environment = get_node(environment_path)
@onready var player: CharacterBody3D = get_node(player_path)
@onready var camera_rig = get_node(camera_rig_path)
var last_used: Dictionary = {}
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func choose(zone: StringName, neighbors: Array[StringName], living: Array, elapsed: float) -> Marker3D:
	var candidates: Array[Marker3D] = []
	var weights: Array[float] = []
	var total: float = 0.0
	for marker in environment.spawn_markers:
		if elapsed - float(last_used.get(marker.get_instance_id(), -100.0)) < 6.0: continue
		var point: Vector3 = marker.global_position
		var distance := point.distance_to(player.global_position)
		if distance < minimum_distance or distance > maximum_distance: continue
		if not environment.is_walkable(point): continue
		var occupied := false
		for enemy in living:
			if is_instance_valid(enemy) and enemy.global_position.distance_to(point) < 2.4:
				occupied = true
				break
		if occupied or _visible(point): continue
		var floor_query := PhysicsRayQueryParameters3D.create(point + Vector3.UP * 2.0, point - Vector3.UP * 2.0, 1)
		var floor_hit := player.get_world_3d().direct_space_state.intersect_ray(floor_query)
		if floor_hit.is_empty() or floor_hit["normal"].y < 0.7 or absf(floor_hit["position"].y - point.y) > 0.30: continue
		if environment.get_navigation_path(point, player.global_position).is_empty(): continue
		var marker_zone := StringName(marker.get_parent().name)
		var bias := 3.0 if marker_zone == zone else (1.6 if neighbors.has(marker_zone) else 0.6)
		var weight := bias / maxf(16.0, distance)
		candidates.append(marker)
		weights.append(weight)
		total += weight
	if candidates.is_empty(): return null
	var roll := rng.randf() * total
	for index in range(candidates.size()):
		roll -= weights[index]
		if roll <= 0.0:
			last_used[candidates[index].get_instance_id()] = elapsed
			return candidates[index]
	var last: Marker3D = candidates[candidates.size() - 1]
	last_used[last.get_instance_id()] = elapsed
	return last

func _visible(point: Vector3) -> bool:
	var camera: Camera3D = camera_rig.get_active_camera()
	var center := point + Vector3.UP
	# Reject a visible head/body sample; hiding only the feet is insufficient.
	for offset in [Vector3.ZERO, Vector3.UP * 0.90, Vector3.RIGHT * 0.55, Vector3.LEFT * 0.55]:
		var sample: Vector3 = center + offset
		if not camera.is_position_in_frustum(sample): continue
		var query := PhysicsRayQueryParameters3D.create(camera.global_position, sample, 1)
		if player.get_world_3d().direct_space_state.intersect_ray(query).is_empty(): return true
	return false
