extends SceneTree
## Reproducible art/gameplay review. Captures are local artifacts, not production dependencies.
var game: Node3D
var p: CharacterBody3D
var m: Node
var hud: CanvasLayer
var camera: Camera3D
const OUTPUT = "res://.godot/professional_polish_review/"
func _initialize() -> void: run.call_deferred()
func frames(count: int = 5) -> void:
	for i in range(count): await process_frame
func capture(key: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT+key+".png")
func view(key: String, at: Vector3, target: Vector3) -> void:
	hud.hide()
	camera.current = true
	camera.global_position = at
	camera.look_at(target)
	await frames()
	await capture(key)
func run() -> void:
	Engine.max_fps = 60
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	game = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames(10)
	p = game.get_node("Player")
	p.camera_rig.set_process_unhandled_input(false)
	p.camera_rig.rotation = Vector3.ZERO
	p.camera_rig.pitch_pivot.rotation = Vector3.ZERO
	m = game.get_node("match_controller")
	hud = game.get_node("HUD")
	p.global_position = Vector3(0,0.05,-20)
	m._on_entrance(p)
	m.director.running = false
	p.set_physics_process(false)
	p.get_node("mango_slingshot").set_physics_process(false)
	p.get_node("arsenal").set_physics_process(false)
	p.get_node("mango_slingshot").first_visual.hide()
	p.get_node("arsenal").first_visual.hide()
	camera = Camera3D.new()
	game.add_child(camera)
	await view("01_checkout",Vector3(-22,3.2,-2),Vector3(-22,3,-20))
	await view("02_drinks",Vector3(21.8,1.7,-26),Vector3(18.8,1.4,-29))
	await view("03_coolers",Vector3(-60,2.2,-20),Vector3(-68,2,-32))
	await view("04_market",Vector3(53,3.4,-64),Vector3(49,2.5,-80))
	await view("05_corn",Vector3(67,2.2,-69),Vector3(64,1.35,-73))
	await view("06_grain",Vector3(60,1.7,-63),Vector3(59,0.9,-66))
	await view("07_bodega",Vector3(19,5,-67),Vector3(0,4,-82))
	await view("08_ceiling",Vector3(0,5,-14),Vector3(0,12,-45))
	await view("09_broom",Vector3(-70,1.3,-10),Vector3(-73.4,0.9,-13))
	await view("10_patio",Vector3(-30,4,-68),Vector3(-57,4,-81))
	game.get_node("mega_abarrotera").set_objective(&"pasillos", "PASILLOS")
	await view("11_hot_zone_far",Vector3(0,3,-16),Vector3(0,7,-43))
	await view("12_hot_zone_floor",Vector3(5,3,-41),Vector3(0,1,-43))
	# Player-facing views and power states, including transparent TPS Mango.
	p.camera_rig.third_person = false
	p.camera_rig._apply_mode()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	p.get_node("mango_slingshot").first_visual.show()
	hud.show()
	await frames()
	await capture("13_fps")
	p.get_node("melee_attack").strike()
	await frames(4)
	await capture("14_fps_melee")
	p.camera_rig.third_person = true
	p.camera_rig._apply_mode()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	p.get_node("mango_slingshot").first_visual.hide()
	await frames(20)
	await capture("15_tps")
	var powers = p.get_node("power_state")
	for kind in [&"ice",&"chile",&"candle",&"happy"]:
		powers.clear()
		powers.collect(kind)
		await frames(10)
		await capture("16_power_"+kind)
		camera.current = true
		camera.global_position = Vector3(1.5,1.4,-23)
		camera.look_at(p.global_position+Vector3.UP*1.1)
		await frames(5)
		await capture("19_mango_front_"+kind)
		p.camera_rig.third_camera.current = true
	powers.clear()
	# Freeze hit confirmation at the first rendered damaged frame.
	for index in [0,1]:
		m.director._spawn(m.director.enemy_definitions[index],Vector3(0,0.05,-25))
		var enemy: CharacterBody3D = m.director.enemy_root.get_child(-1)
		enemy.set_physics_process(false)
		enemy.rotation.y = PI
		enemy.take_damage(10)
		hud.hide()
		camera.current = true
		camera.global_position = Vector3(1.6,1.4,-21.8)
		camera.look_at(Vector3(0,1,-25))
		await capture("17_hit_"+str(index))
		enemy.queue_free()
		await frames()
	# All pickup silhouettes plus one real healing burst.
	var display := Node3D.new()
	p.mango.hide()
	game.add_child(display)
	var kinds := [&"health",&"ammo",&"ice",&"chile",&"candle",&"happy"]
	for i in range(kinds.size()):
		var prop := Node3D.new()
		display.add_child(prop)
		prop.position = Vector3((i-2.5)*0.9,0.7,-20)
		load("res://scripts/game/production/prop_factory.gd").pickup(prop,kinds[i])
	load("res://scripts/game/production/pickup_burst.gd").spawn(game,Vector3(-2.25,0.8,-20),Color("ff4564"),true)
	await view("18_pickups_healing",Vector3(0,2.1,-15.8),Vector3(0,0.7,-20))
	print("PROFESSIONAL_VISUAL_REVIEW: 27 captures completed")
	quit()
