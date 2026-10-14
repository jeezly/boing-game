extends Node3D
## Authored zone rectangle, independent of triggers/kill counts.
@export var zone_id: StringName
@export var bounds := Vector2(20, 20)

func contains_point(point: Vector3) -> bool:
	var local := to_local(point)
	return absf(local.x) <= bounds.x * 0.5 and absf(local.z) <= bounds.y * 0.5 and local.y >= -1.0 and local.y <= 18.0
