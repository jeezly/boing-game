extends Control
signal selected(slot: int)
signal confirmed(slot: int)
var arsenal: Node
var hover: int = 0
const T = preload("res://scripts/ui/production_theme.gd")
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var offset: Vector2 = event.position - size * 0.5
		hover = posmod(roundi((offset.angle() + PI * 0.5) / TAU * 5), 5)
		selected.emit(hover)
		queue_redraw()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT: confirmed.emit(hover)
func _draw() -> void:
	var center := size * 0.5
	for slot in range(5):
		var points := PackedVector2Array()
		var a := -PI * 0.5 + TAU * slot / 5
		for i in range(17):
			var angle := a - TAU / 10 + TAU / 5 * i / 16
			points.append(center + Vector2.from_angle(angle) * 171)
		for i in range(16, -1, -1):
			var angle := a - TAU / 10 + TAU / 5 * i / 16
			points.append(center + Vector2.from_angle(angle) * 64)
		draw_colored_polygon(points, T.CREAM if slot == hover else Color("82512e"))
		points.append(points[0])
		draw_polyline(points, T.GOLD if slot == hover else T.INK, 4, true)
		var point := center + Vector2.from_angle(a) * 118
		draw_texture_rect(T.icon(slot, arsenal.upgraded.has(slot)), Rect2(point - Vector2(28, 30), Vector2(56, 60)), false, Color.WHITE if arsenal.owned.has(slot) else Color("776859"))
	draw_circle(center, 55, T.INK)
	draw_circle(center, 51, T.WOOD)
	draw_string(ThemeDB.fallback_font, center + Vector2(-32, 6), "MANGO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, T.GOLD)
