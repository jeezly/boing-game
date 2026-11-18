extends SceneTree
## Academic evidence: production scenes and APIs, staged reproducible states.
const OUT = "res://docs/evidence/proyecto_parcial_2/"
var game
var p
var m
var hud
var cam
func _initialize(): run.call_deferred()
func frames(n=5):
	for i in range(n): await process_frame
func shot(name):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
	print("EVIDENCE ",name)
func capture(name,n=5):
	await frames(n)
	await shot(name)
func clear_enemies():
	for e in get_nodes_in_group("enemies"): e.queue_free()
	await frames(3)
func mode(tps):
	p.camera_rig.third_person=tps
	p.camera_rig._apply_mode()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
func spawn_enemy(index,at):
	m.director._spawn(m.director.enemy_definitions[index],at)
	return m.director.enemy_root.get_child(-1)
func run():
	Engine.max_fps=60
	root.size=Vector2i(1280,720)
	root.content_scale_size=Vector2i(1280,720)
	root.content_scale_mode=Window.CONTENT_SCALE_MODE_VIEWPORT
	game=load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene=game
	await frames(12)
	p=game.get_node("Player")
	m=game.get_node("match_controller")
	hud=game.get_node("HUD")
	p.camera_rig.set_process_unhandled_input(false)
	p.camera_rig.rotation=Vector3.ZERO
	p.camera_rig.pitch_pivot.rotation=Vector3.ZERO
	p.global_position=Vector3(0,0.05,-20)
	m._on_entrance(p)
	m.director.running=false
	p.set_physics_process(false)
	m.set_physics_process(false)
	await clear_enemies()
	mode(true)
	await capture("01_gameplay_general",20)
	m.remaining=509
	m.elapsed=91
	m.time_changed.emit(509)
	m.objectives.advance(509)
	p.global_position=Vector3(0,0.05,-33)
	await capture("02_evento_zona_caliente",15)
	p.global_position=Vector3(0,0.05,-20)
	mode(false)
	var e=spawn_enemy(0,Vector3(0,0.05,-27))
	e.cooldown=0.0
	await frames(34)
	await shot("03a_comportamiento_pepsin")
	await clear_enemies()
	e=spawn_enemy(1,Vector3(0,0.05,-21.65))
	e.cooldown=0.0
	await frames(18)
	await shot("03b_comportamiento_polar")
	await clear_enemies()
	# Earn credits through actual enemy-defeat callbacks.
	m.director.running=true
	m.director.set_physics_process(false)
	for i in range(12):
		e=spawn_enemy(0,Vector3(0,0.05,-27))
		e.take_damage(1000)
	m.director.running=false
	await frames(3)
	await clear_enemies()
	p.global_position=Vector3(3,0.05,-2)
	hud.open_modal("shop")
	hud._detail(1,false)
	await capture("04a_transaccion_tienda")
	hud.purchase_button.pressed.emit()
	hud.close_modal()
	hud.open_modal("shop")
	hud._detail(1,false)
	await capture("04b_transaccion_compra")
	hud.close_modal()
	p.global_position=Vector3(0,0.05,-20)
	mode(false)
	var a=p.get_node("arsenal")
	a.equip(0)
	await frames(5)
	p.get_node("mango_slingshot")._fire()
	await capture("05a_accion_disparo",3)
	m._clear_projectiles()
	await frames(3)
	e=spawn_enemy(0,Vector3(0,0.05,-21.8))
	e.set_physics_process(false)
	e.rotation.y=PI
	await frames(5)
	var melee=p.get_node("melee_attack")
	print("MELEE_SUCCESS ",melee.strike()," enemy hp ",e.hp)
	melee._physics_process(0.06)
	await shot("05b_accion_melee")
	await shot("06_colisiones")
	await clear_enemies()
	mode(true)
	await capture("07_puntaje_creditos_bajas",15)
	p.take_damage(1000)
	m._physics_process(0.9)
	await capture("08_vidas_respawn",8)
	p.invulnerability_left=0
	p.protection_changed.emit(false)
	p.global_position=Vector3(9,0.05,-17)
	mode(true)
	await capture("09_objetos_especiales",12)
	p.global_position=Vector3(11,0.05,-20)
	await frames(10)
	await capture("09b_powerup_activo",6)
	# Actual terminal-state transition after time reaches zero.
	p.get_node("power_state").clear()
	m.remaining=0.01
	m._physics_process(0.1)
	await capture("10_resultado_victoria")
	paused=false
	game.queue_free()
	await frames(5)
	game=load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene=game
	await frames(12)
	m=game.get_node("match_controller")
	p=game.get_node("Player")
	p.camera_rig.set_process_unhandled_input(false)
	m._on_entrance(p)
	m.director.running=false
	m.lives=1
	p.take_damage(1000)
	await capture("10b_resultado_derrota")
	paused=false
	print("ACADEMIC_EVIDENCE_COMPLETE")
	quit()
