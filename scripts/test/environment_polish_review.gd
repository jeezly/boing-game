extends SceneTree
## Opt-in rendered review of the environment finish; no production references.
var game: Node3D
var camera: Camera3D
func _initialize() -> void: run.call_deferred()
func view(key: String, at: Vector3, target: Vector3) -> void:
 root.content_scale_size = Vector2i(1280, 720)
 root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
 root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
 camera.global_position = at
 camera.look_at(target)
 for i in range(8): await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://.godot/environment_polish_review/" + key + ".png")
func run() -> void:
 Engine.max_fps = 60
 root.size = Vector2i(1280, 720)
 DirAccess.make_dir_recursive_absolute("res://.godot/environment_polish_review")
 game = load("res://scenes/game/main.tscn").instantiate()
 root.add_child(game)
 current_scene = game
 for i in range(5): await physics_frame
 var player = game.get_node("Player")
 game.get_node("match_controller").director.running = false
 player.set_physics_process(false)
 player.get_node("mango_slingshot").first_visual.hide()
 player.get_node("arsenal").first_visual.hide()
 game.get_node("HUD").hide()
 camera = Camera3D.new()
 game.add_child(camera)
 camera.current = true
 await view("01_facade", Vector3(0, 5.2, 14), Vector3(0, 6, 0))
 await view("02_checkout", Vector3(-22, 3.2, -2), Vector3(-22, 3, -20))
 await view("03_aisle", Vector3(-32, 2.5, -17), Vector3(-32, 3.2, -45))
 await view("04_coolers", Vector3(-60, 2.4, -20), Vector3(-68, 3, -40))
 await view("05_produce", Vector3(53, 3.4, -64), Vector3(49, 3, -80))
 await view("06_bodega", Vector3(19, 5, -67), Vector3(0, 4, -82))
 await view("07_patio", Vector3(-30, 4, -68), Vector3(-57, 4, -81))
 await view("08_ceiling", Vector3(0, 5, -14), Vector3(0, 12, -45))
 await view("09_entrance", Vector3(0, 1.7, 5), Vector3(0, 2, -16))
 var polar = load("res://scripts/enemies/polar/polar_visual.gd").new()
 game.add_child(polar)
 polar.position = Vector3(0, 0, -16)
 polar.rotation.y = PI
 for i in range(25): polar.present(1.0 / 60.0, 0, 0.6, false)
 await view("10_polar_raised", Vector3(2, 1.3, -12.5), Vector3(0, 1.2, -16))
 for i in range(5): polar.present(1.0 / 60.0, 0, -1, true)
 await view("11_polar_downstroke", Vector3(2, 1.3, -12.5), Vector3(0, 1.2, -16))
 await view("12_storefront_glazing", Vector3(48, 3.5, 13), Vector3(42, 3.2, 0))
 await view("13_soap_endcap", Vector3(-22, 2, -25), Vector3(-23.5, 1.4, -29))
 await view("14_checkout_exit", Vector3(0, 2, -20), Vector3(0, 5.5, -6))
 DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
 Engine.max_fps = 0
 camera.global_position = Vector3(-22, 3.2, -2)
 camera.look_at(Vector3(-22, 3, -35))
 for i in range(30): await process_frame
 var started := Time.get_ticks_usec()
 for i in range(90): await process_frame
 var elapsed := (Time.get_ticks_usec() - started) / 1000.0 / 90.0
 print("ENVIRONMENT_RENDER: %.2f ms/frame, %d draw calls (uncapped static checkout view)" % [elapsed, Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)])
 print("ENVIRONMENT_POLISH_REVIEW complete: 14 images")
 quit()
