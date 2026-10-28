extends SceneTree
## Opt-in real-physics, resource, navigation and boundary-race audit.
var checks: int = 0
var failures: Array[String] = []

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error("BETA AUDIT: " + message)

func frames(count: int) -> void:
	for _index in range(count): await physics_frame
	await process_frame

func audit_resources(folder: String) -> void:
	for file in DirAccess.get_files_at(folder):
		if file.get_extension() in ["tscn", "tres", "gd"]:
			check(load(folder.path_join(file)) != null, "resource loads: " + folder.path_join(file))
	for directory in DirAccess.get_directories_at(folder): audit_resources(folder.path_join(directory))

func new_match() -> Node3D:
	if is_instance_valid(current_scene):
		current_scene.free()
	paused = false
	var game: Node3D = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(3)
	return game

func run() -> void:
	audit_resources("res://scenes")
	audit_resources("res://scripts")
	audit_resources("res://resources")
	check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "GL Compatibility preserved")
	check(ProjectSettings.get_setting("physics/3d/physics_engine") == "Jolt Physics", "Jolt preserved")
	var e_key := InputEventKey.new()
	e_key.physical_keycode = KEY_E
	check(InputMap.event_is_action(e_key, "interact"), "E maps to interact")
	var game := await new_match()
	var player = game.get_node("Player")
	var match_state = game.get_node("match_controller")
	var environment = game.get_node("mega_abarrotera")
	match_state._on_entrance(player)
	match_state.director.running = false
	# Connected routes across every zone, with the saved fixture footprints.
	var origin := Vector3(0, 0.05, -2)
	for marker in environment.get_node("respawn_points").get_children():
		check(not environment.get_navigation_path(origin, marker.global_position).is_empty(), "connected ground route: " + marker.name)
	check(not match_state.respawns._clear_geometry(Vector3(-62, 0.05, -75.7)), "loading truck cab has solid collision")
	var chosen_count := 0
	var no_neighbors: Array[StringName] = []
	for yaw in range(6):
		player.camera_rig.rotation.y = yaw * PI / 3.0
		var marker: Marker3D = match_state.get_node("spawn_manager").choose(&"cajas", no_neighbors, [], 0.0)
		if marker == null: continue
		chosen_count += 1
		check(not match_state.get_node("spawn_manager")._visible(marker.global_position), "spawn selector rejects visible pop-in")
		check(marker.global_position.distance_to(player.global_position) >= 14, "spawn selector respects player distance")
	check(chosen_count > 0, "spawn selector finds eligible markers")
	player.camera_rig.rotation.y = 0
	# Movement, sprint and jump use actual Input actions and Jolt physics.
	player.global_position = Vector3(0, 0.05, -20)
	await frames(4)
	var start: Vector3 = player.global_position
	Input.action_press("move_forward")
	await frames(30)
	Input.action_release("move_forward")
	var walk_distance: float = start.z - player.global_position.z
	check(walk_distance > 1.5, "WASD moves Mango through physics")
	await frames(12)
	start = player.global_position
	Input.action_press("move_forward")
	Input.action_press("sprint")
	await frames(30)
	Input.action_release("move_forward")
	Input.action_release("sprint")
	check(start.z - player.global_position.z > walk_distance + 0.5, "sprint increases movement speed")
	await frames(12)
	Input.action_press("jump")
	await frames(10)
	Input.action_release("jump")
	check(player.global_position.y > 0.4, "jump leaves floor")
	await frames(70)
	# Walk straight into a shelf; the player must stop outside its solid footprint.
	player.global_position = Vector3(-2.8, 0.05, -24)
	player.velocity = Vector3.ZERO
	Input.action_press("move_left")
	await frames(50)
	Input.action_release("move_left")
	check(player.global_position.x > -3.4, "player cannot pass through shelf")
	player.global_position = Vector3(-16, 0.05, -70)
	player.velocity = Vector3.ZERO
	Input.action_press("move_forward")
	await frames(160)
	Input.action_release("move_forward")
	check(player.global_position.y > 2.0, "bodega ramp is physically climbable")
	# Test the real Resortera, swept mango projectiles, target collision and death signal.
	player.global_position = Vector3(0, 0.05, -20)
	player.velocity = Vector3.ZERO
	player.camera_rig.rotation = Vector3.ZERO
	player.camera_rig.pitch_pivot.rotation = Vector3.ZERO
	player.invulnerability_left = 0
	await frames(4)
	match_state.director.running = true
	match_state.director.spawn_left = 10000.0
	match_state.director._spawn(match_state.director.enemy_definitions[0], Vector3(0, 0.05, -28))
	var enemy = match_state.director.enemy_root.get_child(-1)
	enemy.set_physics_process(false)
	var weapon = player.get_node("mango_slingshot")
	for _shot in range(3):
		weapon._fire()
		await frames(30)
	check(enemy.dead and match_state.kills == 1, "three real mango projectile hits defeat Pepsín")
	# Real Pepsín soda projectile must damage Mango.
	match_state.director._spawn(match_state.director.enemy_definitions[0], Vector3(0, 0.05, -28))
	enemy = match_state.director.enemy_root.get_child(-1)
	enemy.set_physics_process(false)
	enemy.rotation.y = PI
	enemy.locked_shot = player.global_position + Vector3.UP
	enemy._shoot()
	await frames(65)
	check(player.hp < 100, "real soda projectile damages Mango")
	# Pause freezes every gameplay category, including presentations and supply animation.
	enemy.set_physics_process(true)
	enemy.locked_shot = player.global_position + Vector3.UP
	enemy._shoot()
	await frames(1)
	var projectile = get_nodes_in_group("projectiles").back()
	var projectile_at: Vector3 = projectile.global_position
	var enemy_at: Vector3 = enemy.global_position
	var pickup = environment.get_node("health_pickups/salud_frutas")
	var pickup_clock: float = pickup.clock
	var visual_clock: float = player.mango.clock
	match_state.pause()
	var clock: float = match_state.remaining
	await frames(10)
	check(projectile.global_position == projectile_at, "pause freezes projectiles")
	check(enemy.global_position == enemy_at, "pause freezes AI")
	check(pickup.clock == pickup_clock and player.mango.clock == visual_clock, "pause freezes pickup and Mango animation")
	check(match_state.remaining == clock, "pause freezes survival timer")
	match_state.sensitivity.value = 3.5
	match_state.volume.value = 40
	check(is_equal_approx(player.camera_rig.mouse_sensitivity, 0.0035), "sensitivity setting affects camera")
	check(is_equal_approx(AudioServer.get_bus_volume_linear(0), 0.4), "volume setting affects Master bus")
	match_state.resume()
	match_state.director.running = false
	# Unsafe preferred marker must select a clear authored fallback.
	var preferred: Vector3 = match_state.respawns.choose(&"cajas")
	match_state.director._spawn(match_state.director.enemy_definitions[0], preferred)
	var alternate: Vector3 = match_state.respawns.choose(&"cajas")
	check(alternate.distance_to(preferred) >= 9, "enemy occupancy rejects preferred respawn")
	for marker in environment.get_node("respawn_points").get_children():
		match_state.director._spawn(match_state.director.enemy_definitions[0], marker.global_position)
	var saturated: Vector3 = match_state.respawns.choose(&"cajas")
	var fallback_safe := true
	for actor in get_nodes_in_group("enemies"):
		if not actor.dead and actor.global_position.distance_to(saturated) < 9 and not actor.is_queued_for_deletion(): fallback_safe = false
	check(fallback_safe, "saturated respawn retires nearby pressure safely")
	# Phase timeline and spawn scaling are time driven, never location/kill gated.
	for pair in [[509.0, 1], [419.0, 2], [329.0, 3], [239.0, 4], [149.0, 5], [59.0, 6]]:
		match_state.objectives.advance(pair[0])
		check(match_state.objectives.phase == pair[1], "Hot Zone transition at " + str(pair[0]))
	check(match_state.director.CAPS[-1] == 22 and match_state.director.INTERVALS[-1] < match_state.director.INTERVALS[0], "final minute bounded pressure scales")
	# Final death at the boundary always defeats; an intermediate death restores first.
	game = await new_match()
	match_state = game.get_node("match_controller")
	player = game.get_node("Player")
	match_state._on_entrance(player)
	match_state.director.running = false
	match_state.remaining = 0.01
	match_state.lives = 1
	player.take_damage(1000)
	match_state._physics_process(1.0)
	check(match_state.state_name() == "DEFEAT", "final death wins timer boundary race")
	game = await new_match()
	match_state = game.get_node("match_controller")
	player = game.get_node("Player")
	match_state._on_entrance(player)
	match_state.director.running = false
	match_state.remaining = 0.01
	player.take_damage(1000)
	match_state._physics_process(0.1)
	check(match_state.respawning and match_state.state_name() == "PLAYING", "00:00 does not win while Mango is dead during life recovery")
	match_state.pause()
	var respawn_left: float = match_state.respawn_left
	await frames(4)
	check(match_state.respawn_left == respawn_left, "pause freezes life recovery")
	match_state.resume()
	match_state._physics_process(1.0)
	check(match_state.state_name() == "VICTORY" and player.hp > 0 and match_state.lives == 2, "pending victory resolves once remaining life is alive")
	print("BETA_GAMEPLAY_AUDIT: %d checks, %d failures" % [checks, failures.size()])
	for failure in failures: print("FAILED: ", failure)
	paused = false
	quit(0 if failures.is_empty() else 1)
