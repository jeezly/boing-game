extends SceneTree
## Opt-in rendered final-minute stress sample; no analytics or production references.
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	Engine.max_fps = 60
	root.size = Vector2i(1280, 720)
	var game: Node3D = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for _index in range(5): await physics_frame
	var player = game.get_node("Player")
	var match_state = game.get_node("match_controller")
	var environment = game.get_node("mega_abarrotera")
	player.global_position = Vector3(-41, 0.05, -70)
	player.invulnerability_left = 1000
	player.camera_rig.rotation.y = 0.45
	player.camera_rig.third_person = true
	player.camera_rig._apply_mode()
	match_state._on_entrance(player)
	match_state.remaining = 60
	match_state.objectives.advance(59)
	match_state.director.set_elapsed(540)
	var markers: Array = environment.spawn_markers.duplicate()
	markers.sort_custom(func(a: Marker3D, b: Marker3D): return a.global_position.distance_squared_to(player.global_position) < b.global_position.distance_squared_to(player.global_position))
	for marker in markers:
		if match_state.director.living.size() >= 22: break
		if marker.global_position.distance_to(player.global_position) < 9: continue
		if not match_state.respawns._clear_geometry(marker.global_position): continue
		match_state.director._spawn(match_state.director.enemy_definitions[1 if match_state.director.living.size() in [2, 7, 12] else 0], marker.global_position)
	for _index in range(60): await process_frame
	var samples: Array[float] = []
	var began := Time.get_ticks_usec()
	var previous := began
	var peak_enemies: int = 0
	var peak_projectiles: int = 0
	var process_sum: float = 0
	var physics_sum: float = 0
	var peak_draw_calls: int = 0
	var peak_effects: int = 0
	var effect_clock: float = 0
	player.get_node("arsenal").owned[4] = true
	player.get_node("arsenal").equip(4)
	while Time.get_ticks_usec() - began < 20000000:
		await process_frame
		var now := Time.get_ticks_usec()
		samples.append(float(now - previous) / 1000.0)
		process_sum += Performance.get_monitor(Performance.TIME_PROCESS) * 1000
		physics_sum += Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000
		peak_draw_calls = maxi(peak_draw_calls, int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		effect_clock += float(now - previous) / 1000000.0
		if effect_clock > 1.8:
			effect_clock = 0
			player.get_node("arsenal").ammo[4] = 3
			player.get_node("arsenal").fire()
		peak_effects = maxi(peak_effects, get_nodes_in_group("combat_effects").size())
		previous = now
		peak_enemies = maxi(peak_enemies, match_state.director.living.size())
		peak_projectiles = maxi(peak_projectiles, get_nodes_in_group("projectiles").size())
	samples.sort()
	var mean: float = samples.reduce(func(a: float, b: float): return a + b, 0.0) / samples.size()
	var p95: float = samples[mini(samples.size() - 1, floori(samples.size() * 0.95))]
	var report := "PRODUCTION_HORDE: %d frames / 20 s; mean %.2f ms (%.1f FPS); p95 %.2f ms; peak %d enemies / %d projectiles" % [samples.size(), mean, 1000.0 / mean, p95, peak_enemies, peak_projectiles]
	report += "; peak %d effects; mean process %.2f ms / physics %.2f ms; peak %d draw calls" % [peak_effects, process_sum / samples.size(), physics_sum / samples.size(), peak_draw_calls]
	print(report)
	var file := FileAccess.open("res://.godot/production_horde_metrics.txt", FileAccess.WRITE)
	file.store_line(report)
	DirAccess.make_dir_recursive_absolute("res://.godot/production_v2_review")
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/production_v2_review/25_horde.png")
	quit()
