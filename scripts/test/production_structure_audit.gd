extends SceneTree
## Runtime NodePath, signal, collision and production-boundary audit.
var checks: int = 0
var failures: Array[String] = []
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message); push_error(message)
func inspect(node: Node) -> void:
	for property in node.get_property_list():
		if property.type == TYPE_NODE_PATH:
			var path: NodePath = node.get(property.name)
			if not path.is_empty(): check(node.has_node(path), str(node.get_path()) + " resolves " + str(path))
	for entry in node.get_signal_list():
		for connection in node.get_signal_connection_list(entry.name):
			check(connection.callable.is_valid(), "valid signal " + str(entry.name))
	var script: Script = node.get_script()
	if script != null: check(not script.resource_path.begins_with("res://scripts/test/"), "no production test scripts")
	for child in node.get_children(): inspect(child)
func run() -> void:
	var game: Node3D = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for i in range(5): await physics_frame
	inspect(game)
	var p = game.get_node("Player")
	var m = game.get_node("match_controller")
	check(p.collision_layer == 2 and p.collision_mask == 5, "Mango layers")
	check(game.get_node("mega_abarrotera/healing_station/body").is_in_group("navigation_obstacle"), "shop navigation obstacle")
	m._on_entrance(p)
	m.director.running = false
	m.director._spawn(m.director.enemy_definitions[1], Vector3(0, 0.05, -20))
	var polar = m.director.enemy_root.get_child(-1)
	check(polar.collision_layer == 4 and polar.collision_mask == 7, "Polar collision convention")
	inspect(polar)
	var keys := {}
	for action in ["move_forward", "move_backward", "move_left", "move_right", "jump", "sprint", "toggle_camera", "interact", "weapon_1", "weapon_2", "weapon_3", "weapon_4", "weapon_5", "weapon_previous", "weapon_next", "weapon_wheel", "melee", "ui_cancel", "fire"]:
		for event in InputMap.action_get_events(action):
			var key := ""
			if event is InputEventKey: key = "key_" + str(event.physical_keycode)
			if event is InputEventMouseButton: key = "mouse_" + str(event.button_index)
			check(not keys.has(key), "unique production input " + key)
			keys[key] = action
	print("PRODUCTION_STRUCTURE: %d checks, %d failures" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
