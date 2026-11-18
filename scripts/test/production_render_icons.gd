extends SceneTree
## Render PRO icons from the actual authored weapon models, without sheet annotations.
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(192, 192)
	viewport.transparent_bg = true
	viewport.own_world_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var camera := Camera3D.new()
	viewport.add_child(camera)
	camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 0.85
	camera.position = Vector3(0.65, 0.85, 0.9)
	camera.look_at(Vector3(0, 0.05, 0))
	var light := DirectionalLight3D.new()
	viewport.add_child(light)
	light.rotation_degrees = Vector3(-40, -30, 0)
	light.light_energy = 1.0
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	world.environment.ambient_light_color = Color("ffe8c9")
	world.environment.ambient_light_energy = 0.7
	viewport.add_child(world)
	for slot in [1, 2, 4]:
		var prop := Node3D.new()
		viewport.add_child(prop)
		load("res://scripts/game/production/prop_factory.gd").weapon(prop, slot, true)
		if slot == 4: prop.position.y = -0.06
		for i in range(3): await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://assets/ui/weapon_pro_%d.png" % slot)
		prop.queue_free()
		await process_frame
	for kind in [&"candle", &"ice", &"chile", &"happy"]:
		var prop := Node3D.new()
		viewport.add_child(prop)
		load("res://scripts/game/production/prop_factory.gd").pickup(prop, kind)
		for i in range(3): await process_frame
		await RenderingServer.frame_post_draw
		viewport.get_texture().get_image().save_png("res://assets/ui/power_" + kind + ".png")
		prop.queue_free()
		await process_frame
	print("PRO AND POWER ICONS RENDERED")
	quit()
