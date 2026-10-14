extends RefCounted
## Expanded fixture footprints on a bounded grid; no navigation bake or external dependency.
const CLEARANCE: float = 0.62
const CELL: float = 1.5
var grid := AStarGrid2D.new()
var bounds: Rect2
var obstacles: Array[Rect2] = []
var cached_paths: Dictionary = {}

func rebuild(world_bounds: Rect2, rectangles: Array[Rect2]) -> void:
	bounds = world_bounds
	obstacles = rectangles
	cached_paths.clear()
	grid.region = Rect2i(Vector2i.ZERO, Vector2i(floori(bounds.size.x / CELL), floori(bounds.size.y / CELL)))
	grid.cell_size = Vector2.ONE * CELL
	grid.offset = bounds.position + Vector2.ONE * CELL * 0.5
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	grid.update()
	for x in range(grid.region.size.x):
		for z in range(grid.region.size.y):
			var point := grid.offset + Vector2(x, z) * CELL
			for rectangle in obstacles:
				if rectangle.grow(CLEARANCE).has_point(point):
					grid.set_point_solid(Vector2i(x, z))
					break

func _cell(point: Vector3) -> Vector2i:
	var relative := (Vector2(point.x, point.z) - bounds.position) / CELL
	return Vector2i(clampi(floori(relative.x), 0, grid.region.size.x - 1), clampi(floori(relative.y), 0, grid.region.size.y - 1))

func _nearest(point: Vector3) -> Vector2i:
	var cell := _cell(point)
	if not grid.is_point_solid(cell): return cell
	for radius in range(1, 9):
		var best := Vector2i(-1, -1)
		var distance := INF
		for x in range(-radius, radius + 1):
			for z in range(-radius, radius + 1):
				if absi(x) != radius and absi(z) != radius: continue
				var candidate := cell + Vector2i(x, z)
				if not grid.is_in_boundsv(candidate) or grid.is_point_solid(candidate): continue
				var d := Vector2(candidate - cell).length_squared()
				if d < distance:
					best = candidate
					distance = d
		if best.x >= 0: return best
	return Vector2i(-1, -1)

func is_walkable(point: Vector3) -> bool:
	if not bounds.has_point(Vector2(point.x, point.z)): return false
	for obstacle in obstacles:
		if obstacle.grow(CLEARANCE).has_point(Vector2(point.x, point.z)): return false
	return not grid.is_point_solid(_cell(point))

func path(from: Vector3, to: Vector3) -> PackedVector3Array:
	var empty := PackedVector3Array()
	var start := _nearest(from)
	var end := _nearest(to)
	if start.x < 0 or end.x < 0: return empty
	var key := Vector4i(start.x, start.y, end.x, end.y)
	if cached_paths.has(key): return cached_paths[key]
	var result := PackedVector3Array()
	for id in grid.get_id_path(start, end):
		var point := grid.offset + Vector2(id) * CELL
		result.append(Vector3(point.x, 0, point.y))
	if cached_paths.size() >= 256: cached_paths.clear()
	cached_paths[key] = result
	return result
