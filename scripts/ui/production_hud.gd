extends CanvasLayer
## One responsive combat presentation; all authoritative state remains on gameplay nodes.
const T = preload("res://scripts/ui/production_theme.gd")
@export var camera_rig_path: NodePath
var match_state: Node
var player: CharacterBody3D
var arsenal: Node
var powers: Node
var screen: Control
var hp_bar: ProgressBar
var hp_text: Label
var lives: Label
var timer: Label
var objective: Label
var score: Label
var credits: Label
var kills: Label
var weapon_text: Label
var ammo_text: Label
var status: Label
var prompt: Label
var effects: Label
var power_icons: Array[TextureRect] = []
var portrait: TextureRect
var slots: Array[Button] = []
var modal: Control
var modal_kind: String = ""
var detail: VBoxContainer
var purchase_button: Button
var selected_detail: int = 1
var upgrade_detail: bool = false
var notice_left: float = 0
var pulse: float = 0
var heal_left: float = 0
var flash_left: float = 0
var previous_hp: float = 100
var previous_credits: int = 0
var final_announced: bool = false
var feedback_label: Label
var credit_left: float = 0
var hit_left: float = 0
var crosshair: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	screen = Control.new()
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	screen.theme = T.theme()
	_build()
	_bind.call_deferred()

func _build() -> void:
	var margin := MarginContainer.new()
	screen.add_child(margin)
	margin.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	for edge in ["left", "right", "top"]: margin.add_theme_constant_override("margin_" + edge, 14)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top := HBoxContainer.new()
	margin.add_child(top)
	top.add_theme_constant_override("separation", 18)
	var identity := PanelContainer.new()
	top.add_child(identity)
	identity.custom_minimum_size.x = 270
	var id_row := HBoxContainer.new()
	identity.add_child(id_row)
	portrait = TextureRect.new()
	portrait.texture = load("res://assets/ui/mango_portrait.png")
	portrait.custom_minimum_size = Vector2(70, 84)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	id_row.add_child(portrait)
	var vital := VBoxContainer.new()
	id_row.add_child(vital)
	vital.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	T.text(vital, "MANGO", 22).add_theme_color_override("font_color", T.GOLD)
	hp_text = T.text(vital, "HP 100 / 100", 17)
	hp_bar = ProgressBar.new()
	vital.add_child(hp_bar)
	hp_bar.custom_minimum_size = Vector2(150, 15)
	hp_bar.show_percentage = false
	hp_bar.value = 100
	lives = T.text(vital, "♥ ♥ ♥", 21)
	lives.add_theme_color_override("font_color", Color("ff6652"))
	var center := VBoxContainer.new()
	top.add_child(center)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var timer_plate := PanelContainer.new()
	center.add_child(timer_plate)
	timer_plate.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	timer_plate.custom_minimum_size.x = 210
	timer_plate.add_theme_stylebox_override("panel", T.style(Color("2b3925"), T.GOLD, 2))
	timer = T.text(timer_plate, "10:00", 48)
	timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer.add_theme_color_override("font_color", Color("9bdb71"))
	objective = T.text(center, "ENTRA A LA ABARROTERA", 16)
	objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.custom_minimum_size.y = 42
	var totals := VBoxContainer.new()
	top.add_child(totals)
	totals.custom_minimum_size.x = 190
	score = T.text(totals, "PUNTOS 0", 23)
	kills = T.text(totals, "BAJAS 0", 20)
	credits = T.text(totals, "CRÉDITOS $0", 24)
	feedback_label = T.text(totals, "", 18)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	feedback_label.add_theme_color_override("font_color", Color("a5df6b"))
	for l in [score, kills, credits]: l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score.add_theme_color_override("font_color", T.GOLD)
	credits.add_theme_color_override("font_color", Color("9bdb71"))
	var quick := HBoxContainer.new()
	screen.add_child(quick)
	quick.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	quick.offset_left = 16
	quick.offset_right = 366
	quick.offset_top = -105
	quick.offset_bottom = -16
	quick.add_theme_constant_override("separation", 5)
	for i in range(5):
		var b := Button.new()
		quick.add_child(b)
		b.custom_minimum_size = Vector2(66, 80)
		b.icon = T.icon(i)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 39)
		b.text = str(i + 1)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slots.append(b)
	var weapon_panel := PanelContainer.new()
	screen.add_child(weapon_panel)
	weapon_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	weapon_panel.offset_left = -286
	weapon_panel.offset_top = -105
	weapon_panel.offset_right = -16
	weapon_panel.offset_bottom = -16
	var weapon_layout := VBoxContainer.new()
	weapon_panel.add_child(weapon_layout)
	weapon_text = T.text(weapon_layout, "RESORTERA DE MANGO", 17)
	weapon_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ammo_text = T.text(weapon_layout, "∞", 32)
	ammo_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var melee_hint := VBoxContainer.new()
	screen.add_child(melee_hint)
	melee_hint.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	melee_hint.offset_left = -120
	melee_hint.offset_right = 120
	melee_hint.offset_top = -68
	melee_hint.offset_bottom = -15
	T.text(melee_hint, "CLIC DERECHO - MANOTAZO", 14).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var toast := PanelContainer.new()
	toast.name = "toast"
	screen.add_child(toast)
	toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	toast.offset_left = -300
	toast.offset_right = 300
	toast.offset_top = 148
	toast.offset_bottom = 190
	toast.add_theme_stylebox_override("panel", T.style(Color("33271f"), T.GOLD, 2))
	toast.modulate.a = 0
	status = T.text(toast, "", 22)
	
	
	
	
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt = T.text(screen, "", 19)
	prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	prompt.offset_left = -360
	prompt.offset_right = 360
	prompt.offset_top = -152
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effects = T.text(screen, "", 15)
	effects.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	effects.position = Vector2(45, 132)
	for i in range(6):
		var power_icon := TextureRect.new()
		screen.add_child(power_icon)
		power_icon.position = Vector2(19, 132 + i * 22)
		power_icon.size = Vector2(22, 22)
		power_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		power_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		power_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		power_icons.append(power_icon)
	crosshair = T.text(screen, "+", 25)
	crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	crosshair.position -= Vector2(8, 17)

func _bind() -> void:
	match_state = get_tree().get_first_node_in_group("match_controller")
	player = match_state.player
	arsenal = player.get_node("arsenal")
	powers = player.get_node("power_state")
	player.health_changed.connect(_health)
	player.damaged.connect(func(_amount): flash_left = 0.35; notify("¡AGUAS!", Color("ff7758")))
	player.protection_changed.connect(func(active):
		if active: notify("PROTECCIÓN DE REAPARICIÓN", T.GOLD))
	match_state.lives_changed.connect(func(value): credit_left = 0; feedback_label.text = ""; lives.text = "♥ ".repeat(value); notify("VIDA PERDIDA · QUEDAN %d" % value, Color("ff7758")))
	match_state.time_changed.connect(func(value):
		timer.text = match_state.format_time(value)
		if value <= 60 and not final_announced:
			final_announced = true
			notify("¡ÚLTIMO MINUTO!", Color("ff6a38"))
			arsenal.feedback.emit(&"final_minute", ""))
	match_state.credits_changed.connect(_credits)
	match_state.notice.connect(func(value): notify(value, T.GOLD))
	match_state.interaction_changed.connect(func(value): prompt.text = value)
	match_state.objectives.objective_changed.connect(func(_zone, value, _phase): objective.text = value; notify("¡CAMBIO DE ZONA CALIENTE!", T.GOLD))
	match_state.state_changed.connect(func(value): screen.visible = value in ["READY", "PLAYING"])
	powers.changed.connect(_inventory)
	arsenal.changed.connect(_inventory)
	arsenal.feedback.connect(_feedback)
	powers.feedback.connect(_feedback)
	match_state.panel.theme = T.theme()
	match_state.panel.add_theme_stylebox_override("panel", T.style(Color("663a25"), T.GOLD, 3))
	match_state.get_node("match_ui/screen/panel/layout/version").text = "BOING · COMBAT / UI"
	_inventory()

func _credits(value: int) -> void:
	if value > previous_credits:
		feedback_label.text = "+$%d" % (value - previous_credits)
		credit_left = 1.8
	else:
		feedback_label.text = ""
		credit_left = 0
	previous_credits = value

func _health(hp: float, maximum: float) -> void:
	if hp - previous_hp >= 1: heal_left = 0.6; notify("+%d HP · ¡CON CARIÑO!" % roundi(hp - previous_hp), Color("9de077"))
	previous_hp = hp
	hp_text.text = ("¡PELIGRO! " if hp <= 25 else "HP ") + "%d / %d" % [ceili(hp), maximum]
	hp_bar.max_value = maximum
	hp_bar.add_theme_stylebox_override("fill", T.style(Color("d6323b") if hp <= 25 else Color("85b932"), T.GOLD, 1))


func notify(value: String, color: Color = T.GOLD) -> void:
	status.text = value
	status.add_theme_color_override("font_color", color)
	status.get_parent().modulate.a = 1
	notice_left = 2.4

func _feedback(event: StringName, value: String) -> void:
	if event == &"hit": hit_left = 0.16; return
	if event == &"weapon_fired": return
	if event == &"pickup": value = load("res://scripts/game/production/pickup.gd").NAMES.get(StringName(value), value)
	if event != &"polar_attack": notify(value, T.GOLD)

func _inventory() -> void:
	if arsenal == null or arsenal.definitions.is_empty(): return
	for i in range(5):
		var owned: bool = arsenal.owned.has(i)
		slots[i].icon = T.icon(i, arsenal.upgraded.has(i))
		slots[i].modulate = Color.WHITE if owned else Color("776859")
		slots[i].text = str(i + 1) + (" PRO" if arsenal.upgraded.has(i) else (" 🔒" if not owned else ""))
		slots[i].add_theme_stylebox_override("normal", T.style(Color("563720"), T.GOLD if arsenal.selected == i else T.INK, 3))
		if owned and arsenal.definitions[i].max_ammo > 0 and int(arsenal.ammo.get(i, 0)) == 0: slots[i].modulate = Color("ff7161")
	weapon_text.text = arsenal.title(arsenal.selected).to_upper()
	ammo_text.text = "∞" if arsenal.current().max_ammo < 0 or powers.active(&"happy") else "%d / %d" % [arsenal.ammo.get(arsenal.selected, 0), arsenal.current().max_ammo]

func _process(delta: float) -> void:
	if not is_instance_valid(match_state): return
	if get_tree().paused: return
	hp_bar.value = move_toward(hp_bar.value, player.hp, delta * 220)
	hit_left = maxf(0, hit_left - delta)
	crosshair.modulate = T.GOLD if hit_left > 0 else Color.WHITE
	pulse += delta
	flash_left = maxf(0, flash_left - delta)
	heal_left = maxf(0, heal_left - delta)
	portrait.modulate = Color(0.65, 1, 0.55) if heal_left > 0 else (Color(1, 0.5, 0.4) if flash_left > 0 else Color.WHITE)
	if notice_left > 0:
		notice_left = maxf(0, notice_left - delta)
		status.get_parent().modulate.a = minf(1, notice_left * 3)
	score.text = "PUNTOS %s" % match_state.total_score
	kills.text = "BAJAS %d" % match_state.kills
	credits.text = "CRÉDITOS $%d" % match_state.spendable_credits
	credit_left = maxf(0, credit_left - delta)
	feedback_label.modulate.a = minf(1, credit_left * 3)
	if player.hp <= 25: hp_text.modulate.a = 0.8 + sin(pulse * 5) * 0.2
	else: hp_text.modulate.a = 1
	if match_state.remaining <= 60:
		timer.add_theme_color_override("font_color", Color("ff653a"))
		timer.modulate.a = 0.85 + sin(pulse * 6) * 0.15
	var descriptions: Array[String] = []
	var icon_keys: Array[String] = []
	if player.invulnerability_left > 0: descriptions.append("REAPARICIÓN %.1fs" % player.invulnerability_left)
	if player.invulnerability_left > 0: icon_keys.append("")
	var names = load("res://scripts/game/production/pickup.gd").NAMES
	for key in powers.effects:
		descriptions.append("%s  %.1fs" % [names[key], powers.effects[key]])
		icon_keys.append(String(key))
	for i in range(power_icons.size()):
		power_icons[i].visible = i < icon_keys.size() and icon_keys[i] != ""
		if power_icons[i].visible: power_icons[i].texture = load("res://assets/ui/power_" + icon_keys[i] + ".png")
	effects.text = "\n".join(descriptions)

func _input(event: InputEvent) -> void:
	if not is_instance_valid(match_state) or event.is_echo(): return
	if event.is_action_pressed("weapon_wheel") and (modal_kind == "wheel" or match_state.state_name() == "PLAYING"):
		if modal_kind == "wheel": close_modal()
		elif modal_kind == "" and match_state.state_name() == "PLAYING": open_modal("wheel")
		get_viewport().set_input_as_handled()
		return

func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(match_state) or event.is_echo(): return
	if get_tree().paused or not player.combat_enabled: return
	for i in range(5):
		if event.is_action_pressed("weapon_%d" % (i + 1)): arsenal.equip(i)
	if event.is_action_pressed("weapon_previous"): arsenal.cycle(-1)
	if event.is_action_pressed("weapon_next"): arsenal.cycle(1)

func open_modal(kind: String) -> void:
	if modal_kind != "" or match_state.state_name() != "PLAYING" or match_state.respawning: return
	modal_kind = kind
	match_state.pause()
	match_state.panel.hide()
	modal = Control.new()
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modal.theme = T.theme()
	var shade := ColorRect.new()
	modal.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.07, 0.045, 0.025, 0.83)
	var panel := PanelContainer.new()
	modal.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -440
	panel.offset_right = 440
	panel.offset_top = -280
	panel.offset_bottom = 280
	var layout := VBoxContainer.new()
	panel.add_child(layout)
	T.text(layout, "TACOS DON PLOMAZO" if kind == "shop" else "ELIGE TU SABOR", 32).add_theme_color_override("font_color", T.GOLD)
	T.text(layout, "AQUÍ LAS ARMAS SÍ PICAN · $%d CRÉDITOS" % match_state.spendable_credits if kind == "shop" else "1–5 · ELIGE Y EQUIPA · TAB PARA VOLVER", 16)
	var body := HBoxContainer.new()
	layout.add_child(body)
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var choices := VBoxContainer.new()
	body.add_child(choices)
	choices.custom_minimum_size.x = 445
	if kind == "shop":
		var tabs := HBoxContainer.new()
		choices.add_child(tabs)
		for category in ["ARMAS", "MEJORAS", "ITEMS"]:
			var tab := Button.new()
			tabs.add_child(tab)
			tab.text = category
			tab.pressed.connect(_shop_list.bind(choices, category))
		_shop_list(choices, "ARMAS")
	else:
		var wheel = load("res://scripts/ui/weapon_wheel.gd").new()
		wheel.custom_minimum_size = Vector2(430, 360)
		choices.add_child(wheel)
		wheel.arsenal = arsenal
		wheel.selected.connect(func(slot): selected_detail = slot; _detail(slot, false))
		wheel.confirmed.connect(func(slot):
			if arsenal.equip(slot): close_modal())
	detail = VBoxContainer.new()
	body.add_child(detail)
	detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail.custom_minimum_size.x = 330
	_detail(arsenal.selected if kind == "wheel" else 1, false)
	var close := Button.new()
	layout.add_child(close)
	close.text = "VOLVER AL DESMADRE  [ESC]"
	close.pressed.connect(close_modal)

func _shop_list(choices: VBoxContainer, category: String) -> void:
	for child in choices.get_children():
		if child.name == "products": choices.remove_child(child); child.queue_free()
	var list := VBoxContainer.new()
	list.name = "products"
	choices.add_child(list)
	if category == "ITEMS": T.text(list, "Próximamente.\nBusca provisiones en la abarrotera.", 18); return
	for slot in [1, 2, 4]:
		var b := Button.new()
		list.add_child(b)
		var pro := category == "MEJORAS"
		b.text = "%s\n$%d" % [arsenal.definitions[slot].pro_name if pro else arsenal.definitions[slot].display_name, arsenal.definitions[slot].upgrade_price if pro else arsenal.definitions[slot].price]
		b.icon = T.icon(slot, pro)
		b.expand_icon = true
		b.add_theme_constant_override("icon_max_width", 53)
		b.custom_minimum_size.y = 83
		b.pressed.connect(_detail.bind(slot, pro))

func _detail(slot: int, pro: bool) -> void:
	if detail == null: return
	selected_detail = slot
	upgrade_detail = pro
	for child in detail.get_children(): detail.remove_child(child); child.queue_free()
	var d: Resource = arsenal.definitions[slot]
	var image := TextureRect.new()
	detail.add_child(image)
	image.texture = T.icon(slot, pro or arsenal.upgraded.has(slot))
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = Vector2(100, 90)
	var name_label := T.text(detail, d.pro_name if pro else arsenal.title(slot), 23)
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var desc := T.text(detail, d.description, 16)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	for stat in [["DAÑO", d.pro_damage if pro else d.damage, 180], ["ALCANCE", d.reach, 100], ["CADENCIA", 1.0 / d.cooldown, 3.0]]:
		var row := HBoxContainer.new()
		detail.add_child(row)
		T.text(row, stat[0], 14).custom_minimum_size.x = 90
		var bar := ProgressBar.new()
		row.add_child(bar)
		bar.custom_minimum_size = Vector2(130, 12)
		bar.max_value = stat[2]
		bar.value = stat[1]
		bar.show_percentage = false
	T.text(detail, "MUNICIÓN ∞" if d.max_ammo < 0 else "MUNICIÓN %d / %d" % [arsenal.ammo.get(slot, 0), d.max_ammo], 16)
	var state := "EQUIPADO" if arsenal.selected == slot else ("COMPRADO" if arsenal.owned.has(slot) else "DISPONIBLE")
	if arsenal.upgraded.has(slot): state += " · PRO ADQUIRIDA"
	elif arsenal.owned.has(slot) and slot != 0: state += " · MEJORABLE"
	T.text(detail, state, 15).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	purchase_button = Button.new()
	detail.add_child(purchase_button)
	if modal_kind == "shop":
		purchase_button.text = ("MEJORAR" if pro else "COMPRAR") + "  $%d" % (d.upgrade_price if pro else d.price)
		if arsenal.owned.has(slot) and not pro: purchase_button.text = "EQUIPAR"
		if pro and not arsenal.owned.has(slot): purchase_button.text = "REQUIERE ARMA BASE"; purchase_button.disabled = true
		elif pro and arsenal.upgraded.has(slot): purchase_button.text = "PRO ADQUIRIDA"; purchase_button.disabled = true
		elif not (arsenal.owned.has(slot) and not pro) and match_state.spendable_credits < (d.upgrade_price if pro else d.price): purchase_button.text = "SIN CRÉDITOS"; purchase_button.disabled = true
		purchase_button.pressed.connect(func():
			var result: String = arsenal.purchase(slot, pro, match_state)
			_detail(slot, pro)
			T.text(detail, "¡GRACIAS, JOVEN! · " + result, 15).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART)
	else:
		purchase_button.text = "EQUIPAR" if arsenal.owned.has(slot) else "SIN COMPRAR"
		purchase_button.disabled = not arsenal.owned.has(slot)
		purchase_button.pressed.connect(func(): arsenal.equip(slot); close_modal())

func close_modal() -> void:
	if modal_kind == "": return
	modal.queue_free()
	modal_kind = ""
	match_state.resume()
	player.get_node("mango_slingshot").cooldown = maxf(player.get_node("mango_slingshot").cooldown, 0.22)
	arsenal.cooldown = maxf(arsenal.cooldown, 0.22)
