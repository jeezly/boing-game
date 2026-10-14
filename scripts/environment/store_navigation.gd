extends RefCounted
## Equivalent planar navigation: obstacle-expanded AStarGrid2D, no bake required.
## Cells are blocked using the same footprints as physical store fixtures.

const CLEARANCE: float = 0.62
var grid := AStarGrid2D.new()
var obstacles: Array[Rect2] = []

func rebuild(rectangles: Array[Rect2]) -> void:
	obstacles = rectangles
	grid.region = Rect2i(-17, -46, 34, 68)
	grid.cell_size = Vector2.ONE
	grid.offset = Vector2(0.5, 0.5)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.update()
	for x in range(-17, 17):
		for z in range(-46, 22):
			var point := Vector2(x + 0.5, z + 0.5)
			for rect in obstacles:
				if rect.grow(CLEARANCE).has_point(point):
					grid.set_point_solid(Vector2i(x, z))
					break

func _nearest(point: Vector3) -> Vector2i:
	var cell := Vector2i(floori(point.x), floori(point.z))
	cell.x = clampi(cell.x, -17, 16)
	cell.y = clampi(cell.y, -46, 21)
	if not grid.is_point_solid(cell): return cell
	for radius in range(1, 6):
		for x in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				var candidate := cell + Vector2i(x, z)
				if grid.is_in_boundsv(candidate) and not grid.is_point_solid(candidate): return candidate
	return cell

func path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var result := PackedVector3Array()
	var start := _nearest(from)
	var end := _nearest(to)
	if grid.is_point_solid(start) or grid.is_point_solid(end): return result
	var ids := grid.get_id_path(start, end)
	for id in ids:
		result.append(Vector3(id.x + 0.5, 0.0, id.y + 0.5))
	return result
