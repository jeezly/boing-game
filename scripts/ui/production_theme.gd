extends RefCounted
const INK = Color("24160f")
const CREAM = Color("ffe6b6")
const GOLD = Color("ffc841")
const WOOD = Color("663a25")
static func style(color: Color, border: Color = INK, width: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.border_color = border
	s.set_border_width_all(width)
	s.set_corner_radius_all(12)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	s.shadow_color = Color(0, 0, 0, 0.45)
	s.shadow_size = 4
	s.shadow_offset = Vector2(0, 3)
	return s
static func theme() -> Theme:
	var t := Theme.new()
	t.default_font_size = 18
	var font := SystemFont.new()
	font.font_names = PackedStringArray(["Arial", "DejaVu Sans"])
	font.font_weight = 700
	t.default_font = font
	t.set_color("font_color", "Label", CREAM)
	t.set_color("font_outline_color", "Label", INK)
	t.set_constant("outline_size", "Label", 4)
	t.set_stylebox("panel", "PanelContainer", style(WOOD))
	for kind in ["normal", "hover", "pressed", "focus", "disabled"]:
		t.set_stylebox(kind, "Button", style(Color("8a5030") if kind == "normal" else (Color("3b3027") if kind == "disabled" else Color("ad7136")), GOLD if kind in ["hover", "focus"] else INK))
	t.set_color("font_color", "Button", CREAM)
	t.set_color("font_outline_color", "Button", INK)
	t.set_constant("outline_size", "Button", 3)
	t.set_stylebox("background", "ProgressBar", style(Color("35231b"), INK, 2))
	t.set_stylebox("fill", "ProgressBar", style(Color("81b635"), Color("cad64d"), 1))
	return t
static func text(parent: Node, value: String, size: int = 18) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_font_size_override("font_size", size)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l
static func icon(slot: int, pro: bool = false) -> Texture2D:
	if pro and slot in [1, 2, 4]: return load("res://assets/ui/weapon_pro_%d.png" % slot)
	return load("res://assets/ui/weapon_%d.png" % slot)
