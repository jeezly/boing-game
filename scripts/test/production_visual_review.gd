extends SceneTree
## Opt-in rendered review of production combat states and authored props.
var game: Node3D
var m: Node
var p: CharacterBody3D
var hud: CanvasLayer
var camera: Camera3D
func _initialize() -> void: run.call_deferred()
func capture(key: String) -> void:
	for i in range(5): await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://.godot/production_v2_review/" + key + ".png")
func view(key: String, at: Vector3, target: Vector3) -> void:
	hud.hide()
	p.get_node("mango_slingshot").first_visual.hide()
	p.get_node("arsenal").first_visual.hide()
	camera.global_position = at
	camera.look_at(target)
	camera.current = true
	await capture(key)
func run() -> void:
	Engine.max_fps = 60
	DirAccess.make_dir_recursive_absolute("res://.godot/production_v2_review")
	root.size = Vector2i(1280, 720)
	game = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	for i in range(5): await physics_frame
	m = game.get_node("match_controller")
	p = game.get_node("Player")
	hud = game.get_node("HUD")
	p.global_position = Vector3(0, 0.05, -20)
	m._on_entrance(p)
	m.director.running = false
	await capture("01_fps")
	p.camera_rig.third_person = true
	p.camera_rig._apply_mode()
	await capture("02_tps")
	p.take_damage(25)
	await capture("03_damage")
	p.take_damage(55)
	await capture("04_low_health")
	p.heal(50)
	await capture("05_healing")
	m.remaining = 59
	m.time_changed.emit(59)
	await capture("06_final_minute")
	hud.open_modal("wheel")
	await capture("07_radial")
	hud.close_modal()
	p.global_position = Vector3(3, 0.05, -2)
	m._add_score(10000)
	hud.open_modal("shop")
	await capture("08_shop")
	var a = p.get_node("arsenal")
	a.purchase(1, false, m)
	hud._detail(1, false)
	await capture("09_purchase")
	a.purchase(1, true, m)
	hud._detail(1, true)
	await capture("10_pro")
	a.purchase(2, false, m)
	a.purchase(4, false, m)
	a.purchase(2, true, m)
	a.purchase(4, true, m)
	hud.close_modal()
	p.camera_rig.third_person = false
	p.camera_rig._apply_mode()
	for slot in [1, 2, 4]:
		a.equip(slot)
		await capture("11_equipped_%d" % slot)
	p.get_node("power_state").charge(100)
	p.get_node("power_state").collect(&"happy")
	await capture("12_tequila")
	for kind in [&"candle", &"ice", &"chile", &"happy"]:
		p.get_node("power_state").collect(kind)
		await capture("12_power_" + kind)
	p.get_node("power_state").clear()
	p.take_damage(1000)
	await capture("12_life_lost")
	for i in range(55): await physics_frame
	await capture("12_respawn_protection")
	p.global_position = Vector3(0, 0.05, -20)
	for resolution in [Vector2i(1280, 720), Vector2i(1152, 648), Vector2i(960, 640)]:
		root.size = resolution
		await capture("13_hud_%d" % resolution.x)
		m.pause()
		m.settings.show()
		await capture("14_pause_%d" % resolution.x)
		m.resume()
	root.size = Vector2i(960, 640)
	p.global_position = Vector3(3, 0.05, -2)
	hud.open_modal("shop")
	await capture("14_shop_960")
	hud.close_modal()
	hud.open_modal("wheel")
	await capture("14_wheel_960")
	hud.close_modal()
	root.size = Vector2i(1280, 720)
	camera = Camera3D.new()
	game.add_child(camera)
	await view("15_shop_exterior", Vector3(3, 2, 0), Vector3(3, 1.8, -4))
	var lineup := Node3D.new()
	game.add_child(lineup)
	lineup.position = Vector3(0, 0, -13)
	var kinds := [&"health", &"candle", &"ice", &"ammo", &"chile", &"happy"]
	for i in range(7):
		var prop := Node3D.new()
		lineup.add_child(prop)
		prop.position = Vector3((i - 3) * 0.85, 0.8, 0)
		load("res://scripts/game/production/prop_factory.gd").pickup(prop, kinds[i])
		await view("16_pickup_" + kinds[i], prop.global_position + Vector3(0, 0.4, 1.2), prop.global_position)
	await view("17_pickups", Vector3(0, 2.0, -9), Vector3(0, 0.8, -13))
	m.director._spawn(m.director.enemy_definitions[1], Vector3(0, 0.05, -17))
	var polar = m.director.enemy_root.get_child(-1)
	polar.set_physics_process(false)
	polar.rotation.y = PI
	await view("18_polar_front", Vector3(0, 1.2, -14), Vector3(0, 1, -17))
	await view("19_polar_side", Vector3(3, 1.2, -17), Vector3(0, 1, -17))
	await view("20_polar_back", Vector3(0, 1.2, -20), Vector3(0, 1, -17))
	polar.visual.present(0.5, 0, 0.65, false)
	await view("21_polar_attack", Vector3(1.5, 1.3, -14), Vector3(0, 1, -17))
	p.global_position = Vector3(0, 0.05, -13)
	p.camera_rig.third_person = true
	p.camera_rig._apply_mode()
	polar.set_physics_process(true)
	m.director._spawn(m.director.enemy_definitions[0], Vector3(2, 0.05, -18))
	hud.show()
	await capture("22_mixed_combat")
	m.remaining = 0.01
	m._physics_process(0.1)
	await capture("23_victory")
	m.restart()
	for i in range(5): await physics_frame
	game = current_scene
	m = game.get_node("match_controller")
	p = game.get_node("Player")
	m._on_entrance(p)
	m.lives = 1
	p.take_damage(1000)
	await capture("24_defeat")
	print("PRODUCTION_VISUAL_REVIEW COMPLETE")
	paused = false
	quit()
