extends Node3D
## Authored counter occupies the former first-aid footprint; E opens a safe modal.
const P = preload("res://scripts/game/production/prop_factory.gd")
const B = preload("res://scripts/components/visual_mesh_builder.gd")
var match_state: Node
var player: CharacterBody3D
var prompt_visible: bool = false
func _ready() -> void:
	P.box(self, Vector3(0, 0.55, 0), Vector3(2.7, 1.1, 1.1), "874926")
	P.box(self, Vector3(0, 1.15, 0), Vector3(3, 0.13, 1.3), "c99555")
	for x in [-1.4, 1.4]: P.box(self, Vector3(x, 1.7, -0.35), Vector3(0.13, 3.4, 0.13), "734322")
	P.box(self, Vector3(0, 3.15, -0.35), Vector3(3.3, 0.75, 0.16), "dba45a")
	P.label(self, "TACOS\nDON PLOMAZO", Vector3(0, 3.15, -0.23), 86, Color("e45127"))
	P.box(self, Vector3(-0.77, 2.19, -0.53), Vector3(1.25, 1.10, 0.08), "252921")
	P.box(self, Vector3(0.77, 2.19, -0.53), Vector3(1.25, 1.10, 0.08), "252921")
	P.label(self, "ARMAS\nCHANCLA  $500\nMOLCAJETE  $600\nCUETE  $700", Vector3(-0.77, 2.19, -0.47), 24)
	P.label(self, "ESPECIALIDADES\nABUELA  $1000\nINFERNAL  $1200\nKOMODO  $1500", Vector3(0.77, 2.19, -0.47), 24, Color("ffd45a"))
	for i in range(9):
		var x := -1.24 + i * 0.31
		P.box(self, Vector3(x, 2.67, -0.15), Vector3(0.23, 0.23, 0.012), ["df3652", "efb83b", "529852", "8254a0"][i % 4])
		B.oval(self, "bulb", Vector3(x, 2.98, 0.1), Vector3.ONE * 0.085, P.mat("ffe9a0"))
	for x in [-1.22, 1.20]:
		B.rod(self, "salsa", Vector3(x, 1.21, 0.20), Vector3(x, 1.43, 0.20), 0.05, P.mat("b92a1d" if x < 0 else "44872a"))
	# Wood counter slats, trim, hanging cut-paper and taco service props.
	for i in range(12):
		P.box(self, Vector3(-1.24 + i * 0.225, 0.55, 0.562), Vector3(0.205, 0.98, 0.035), "9a5b30" if i % 2 == 0 else "a96a38")
	P.box(self, Vector3(0, 0.14, 0.59), Vector3(2.8, 0.12, 0.07), "56321d")
	P.box(self, Vector3(0, 1.03, 0.59), Vector3(2.8, 0.09, 0.07), "56321d")
	for i in range(9):
		var x := -1.24 + i * 0.31
		for j in range(3):
			B.oval(self, "paper_cut", Vector3(x + (j - 1) * 0.06, 2.66, -0.137), Vector3(0.025, 0.08, 0.005), P.mat("e7bc6d"))
	for i in range(3):
		B.oval(self, "taco", Vector3(-0.7 + i * 0.18, 1.26, 0.26), Vector3(0.16, 0.08, 0.12), P.mat("edbd50"))
		B.oval(self, "filling", Vector3(-0.7 + i * 0.18, 1.29, 0.26), Vector3(0.11, 0.04, 0.07), P.mat("5f7e2d"))
	P.label(self, "¿QUÉ LE DAMOS, JOVEN?", Vector3(0, 0.68, 0.60), 30)
	# Friendly taquero with apron, moustache and cap behind the counter.
	B.oval(self, "vendor_shirt", Vector3(0, 1.4, -0.28), Vector3(0.65, 0.65, 0.4), P.mat("fff0ca"))
	P.box(self, Vector3(0, 1.39, -0.04), Vector3(0.37, 0.41, 0.035), "ba3027")
	B.oval(self, "vendor_head", Vector3(0, 1.87, -0.22), Vector3(0.43, 0.44, 0.38), P.mat("ca8a4e"))
	for x in [-0.085, 0.085]:
		B.oval(self, "eye", Vector3(x, 1.92, -0.033), Vector3(0.04, 0.045, 0.02), P.mat("2b2118"))
		B.oval(self, "moustache", Vector3(x * 0.7, 1.80, 0.005), Vector3(0.16, 0.07, 0.045), P.mat("302117"))
	B.oval(self, "nose", Vector3(0, 1.84, 0.015), Vector3(0.12, 0.1, 0.1), P.mat("de9c5e"))
	B.oval(self, "cap", Vector3(0, 2.08, -0.21), Vector3(0.46, 0.18, 0.40), P.mat("ffdc90"))
	P.label(self, "PLOMAZO", Vector3(0, 2.08, 0.015), 14, Color("673a23"))
	var body := StaticBody3D.new()
	body.name = "body"
	body.add_to_group("navigation_obstacle")
	body.collision_layer = 1
	body.collision_mask = 7
	add_child(body)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.7, 1.15, 1.1)
	shape.shape = box
	shape.position.y = 0.575
	body.add_child(shape)
	_bind.call_deferred()
func _bind() -> void:
	match_state = get_tree().get_first_node_in_group("match_controller")
	player = get_tree().get_first_node_in_group("player")
func is_available(customer: CharacterBody3D) -> bool:
	if customer.hp <= 0 or not customer.combat_enabled or customer.global_position.distance_to(global_position) > 3.3: return false
	var ray := PhysicsRayQueryParameters3D.create(customer.global_position + Vector3.UP * 1.4, global_position + Vector3.UP * 1.5, 1, [get_node("body").get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()
func _physics_process(_delta: float) -> void:
	if not is_instance_valid(match_state): return
	var available: bool = match_state.state_name() == "PLAYING" and is_available(player)
	if available != prompt_visible:
		prompt_visible = available
		match_state.interaction_changed.emit("[E] TACOS DON PLOMAZO · ARMAS Y MEJORAS" if available else "")
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo() and prompt_visible:
		get_tree().current_scene.get_node("HUD").open_modal("shop")
		get_viewport().set_input_as_handled()
