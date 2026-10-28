extends SceneTree
## Run with --headless --path . --script res://scripts/test/beta_0_1_smoke.gd
var failures: Array[String] = []
var checks: int = 0
var game: Node
var match_state: Node
var player: CharacterBody3D

func _initialize() -> void:
	run.call_deferred()

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
		push_error("BETA CHECK: " + message)

func settle(frames: int = 3) -> void:
	for _index in range(frames): await physics_frame
	await process_frame

func run() -> void:
	game = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await settle()
	match_state = game.get_node("match_controller")
	player = game.get_node("Player")
	var environment = game.get_node("mega_abarrotera")
	check(match_state.state_name() == "READY", "startup is READY")
	check(match_state.lives == 3 and player.hp == 100.0, "three lives and full health")
	check(not player.combat_enabled, "READY cannot fire")
	var export_config := ConfigFile.new()
	check(export_config.load("res://export_presets.cfg") == OK, "Windows export preset parses")
	check(export_config.get_value("preset.0", "platform") == "Windows Desktop", "Windows Desktop export platform")
	for marker in environment.get_node("respawn_points").get_children():
		check(match_state.respawns._clear_geometry(marker.global_position), "respawn clearance: " + marker.name)
	for pickup in environment.get_node("health_pickups").get_children():
		check(match_state.respawns._clear_geometry(pickup.global_position + Vector3.UP * 0.05), "pickup access: " + pickup.name)
	for marker in environment.spawn_markers:
		check(match_state.respawns._clear_geometry(marker.global_position), "spawn clearance: " + marker.name)
	player.global_position = Vector3(0, 0.05, -1)
	await settle()
	check(match_state.state_name() == "PLAYING", "entrance starts match")
	check(match_state.director.running, "director starts")
	match_state.director.running = false # Deterministic assertions; combat uses the real enemy below.
	match_state._add_score(1000)
	check(match_state.total_score == 1000 and match_state.spendable_credits == 1000, "score earns matching credits")
	var station = environment.get_node("healing_station")
	player.global_position = station.global_position + Vector3(0, 0.05, 2)
	await settle()
	check(station.is_available(player), "station distance and line of sight")
	check(match_state.purchase_service(station) == "SALUD COMPLETA", "full health rejects purchase")
	check(match_state.spendable_credits == 1000, "full health costs nothing")
	player.take_damage(70)
	var purchase_key := InputEventKey.new()
	purchase_key.physical_keycode = KEY_E
	purchase_key.pressed = true
	station._unhandled_input(purchase_key)
	check(player.hp == 80 and match_state.spendable_credits == 500, "purchase heals 50 and charges 500")
	check(match_state.total_score == 1000, "purchase preserves total score")
	match_state.purchase_service(station)
	check(player.hp == 100 and match_state.spendable_credits == 0, "purchase caps HP at max")
	player.take_damage(10)
	check(match_state.purchase_service(station).contains("SUFICIENTES"), "insufficient credits feedback")
	check(player.hp == 90 and match_state.spendable_credits == 0, "failed purchase changes nothing")
	var pickup = environment.get_node("health_pickups/salud_cajas_oeste")
	player.heal(100)
	pickup._on_body_entered(player)
	check(not pickup.used, "full health does not consume pickup")
	player.take_damage(15)
	pickup._on_body_entered(player)
	check(player.hp == 100 and pickup.used, "pickup heals and caps at max")
	var before: float = match_state.remaining
	match_state.pause()
	var position_before := player.global_position
	await settle()
	check(paused and match_state.remaining == before, "pause freezes timer")
	check(player.global_position == position_before, "pause freezes player physics")
	match_state.resume()
	check(not paused and match_state.state_name() == "PLAYING", "resume restores same match")
	var rig = player.camera_rig
	rig.third_person = true
	rig._apply_mode()
	check(rig.third_camera.current and player.mango.visible, "TPS presentation")
	rig.third_person = false
	rig._apply_mode()
	check(rig.first_camera.current and not player.mango.visible, "FPS excludes body")
	var enemy_definition = match_state.director.enemy_definitions[0]
	match_state.director.running = true
	match_state.director._spawn(enemy_definition, Vector3(-44, 0.05, -3))
	var enemy = match_state.director.living.values()[0]
	enemy.take_damage(75)
	check(match_state.kills == 1 and match_state.total_score >= 1100, "real enemy death awards kill and score")
	match_state.director.running = false
	var saved_score: int = match_state.total_score
	var saved_kills: int = match_state.kills
	var saved_phase: int = match_state.objectives.phase
	before = match_state.remaining
	player.take_damage(1000)
	check(match_state.lives == 2 and match_state.respawning, "first death consumes one life")
	check(not player.combat_enabled and not player.movement_enabled, "life loss disables input and combat")
	match_state._physics_process(1.0)
	check(player.hp == 100 and not match_state.respawning, "respawn restores health without reload")
	check(not player.mango.reactions.dead and player.get_node("mango_slingshot").first_visual.visible, "respawn restores upright Mango and FPS weapon")
	check(match_state.total_score == saved_score and match_state.kills == saved_kills, "respawn preserves score and kills")
	check(match_state.remaining <= before and match_state.remaining > before - 2, "respawn preserves continuing timer")
	check(match_state.objectives.phase == saved_phase, "respawn preserves Hot Zone")
	check(player.invulnerability_left > 2.0, "respawn protection starts")
	player.take_damage(1000)
	check(player.hp == 100 and match_state.lives == 2, "invulnerability blocks damage")
	player.invulnerability_left = 0
	player.take_damage(1000)
	match_state._physics_process(1.0)
	check(match_state.lives == 1 and player.hp == 100, "second death respawns on final life")
	player.invulnerability_left = 0
	player.take_damage(1000)
	check(match_state.lives == 0 and match_state.state_name() == "DEFEAT", "final life causes defeat")
	check(paused and not match_state.director.running, "defeat freezes gameplay and director")
	match_state._finish(true)
	check(match_state.state_name() == "DEFEAT", "terminal result cannot change")
	check(match_state.summary.text.contains("VIDAS RESTANTES 0"), "results expose lives")
	match_state.restart()
	await settle(5)
	game = current_scene
	match_state = game.get_node("match_controller")
	player = game.get_node("Player")
	check(match_state.state_name() == "READY" and match_state.lives == 3, "restart creates fresh match")
	check(match_state.total_score == 0 and match_state.spendable_credits == 0 and match_state.kills == 0, "restart clears all counters")
	check(match_state.remaining == 600 and get_nodes_in_group("enemies").is_empty(), "restart resets clock and removes old enemies")
	match_state._on_entrance(player)
	match_state.remaining = 0.01
	match_state._physics_process(0.1)
	check(match_state.state_name() == "VICTORY" and match_state.elapsed == 600, "00:00 victory at exactly ten minutes")
	check(not player.combat_enabled and not match_state.director.running and paused, "victory disables combat and spawns")
	check(match_state.summary.text.contains("10:00"), "victory reports ten minutes")
	match_state._on_player_died()
	check(match_state.state_name() == "VICTORY", "late death cannot replace victory")
	print("BETA_SMOKE: %d checks, %d failures" % [checks, failures.size()])
	for failure in failures: print("FAILED: ", failure)
	paused = false
	if failures.is_empty(): match_state.exit_button.pressed.emit()
	else: quit(1)
