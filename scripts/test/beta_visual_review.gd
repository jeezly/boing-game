extends SceneTree
## Opt-in screenshot review; never referenced by production gameplay.
var game: Node3D
var match_state: Node
var player: CharacterBody3D
var review_camera: Camera3D

func _initialize() -> void:
	run.call_deferred()

func capture(file_name: String) -> void:
	for _index in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/beta_review/" + file_name + ".png")

func overview(file_name: String, point: Vector3, target: Vector3) -> void:
	player.get_node("mango_slingshot").first_visual.hide()
	review_camera.global_position = point
	review_camera.look_at(target)
	review_camera.current = true
	game.get_node("HUD").hide()
	await capture(file_name)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://.godot/beta_review")
	root.size = Vector2i(1280, 720)
	game = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame
	match_state = game.get_node("match_controller")
	player = game.get_node("Player")
	await capture("01_ready")
	player.global_position = Vector3(0, 0.05, -6)
	match_state._on_entrance(player)
	match_state.director.running = false
	await capture("02_fps")
	player.camera_rig.third_person = true
	player.camera_rig._apply_mode()
	await capture("03_tps")
	player.global_position = Vector3(3, 0.05, -2)
	player.take_damage(40)
	match_state._add_score(1500)
	await capture("04_station")
	match_state.pause()
	match_state.settings.show()
	await capture("05_pause_settings")
	root.size = Vector2i(960, 640)
	await capture("05b_pause_960")
	root.size = Vector2i(1280, 720)
	match_state.resume()
	review_camera = Camera3D.new()
	game.add_child(review_camera)
	review_camera.fov = 70
	await overview("06_checkout", Vector3(-22, 3.2, -2), Vector3(-22, 2, -20))
	await overview("07_aisle", Vector3(-32, 2.5, -17), Vector3(-32, 2.8, -45))
	await overview("08_coolers", Vector3(-60, 2.4, -20), Vector3(-68, 2, -40))
	await overview("09_produce", Vector3(53, 3.4, -64), Vector3(49, 1.6, -80))
	await overview("10_bodega", Vector3(19, 5, -67), Vector3(0, 2, -82))
	await overview("11_patio", Vector3(-30, 4, -68), Vector3(-57, 2, -81))
	await overview("12_facade", Vector3(0, 5, 14), Vector3(0, 5, -1))
	await overview("16_pinata", Vector3(0, 6.0, -29), Vector3(0, 6.6, -35))
	await overview("17_water_jugs", Vector3(-60, 1.7, 14), Vector3(-61, 0.8, 10))
	game.get_node("HUD").show()
	match_state.remaining = 0.01
	match_state._physics_process(0.1)
	await capture("13_victory")
	match_state.restart()
	for _index in range(5): await physics_frame
	await process_frame
	game = current_scene
	match_state = game.get_node("match_controller")
	player = game.get_node("Player")
	match_state._on_entrance(player)
	match_state.lives = 1
	player.take_damage(1000)
	await capture("15_defeat")
	print("BETA_VISUAL: saved 17 review images to .godot/beta_review")
	paused = false
	quit()
