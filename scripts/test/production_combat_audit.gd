extends SceneTree
## Production behavior integration, independent from the rendered review fixture.
var failures: Array[String] = []
var checks: int = 0
var game: Node3D
var m: Node
var p: CharacterBody3D
var a: Node
var powers: Node
var hud: CanvasLayer
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures.append(message); push_error(message)
func frames(count: int = 3) -> void:
	for i in range(count): await physics_frame
	await process_frame
func enemy(slot: int, at: Vector3) -> CharacterBody3D:
	m.director._spawn(m.director.enemy_definitions[slot], at)
	return m.director.enemy_root.get_child(-1)
func clear_enemies() -> void:
	for e in get_nodes_in_group("enemies"): e.queue_free()
func run() -> void:
	game = load("res://scenes/game/main.tscn").instantiate()
	root.add_child(game)
	current_scene = game
	await frames()
	m = game.get_node("match_controller")
	p = game.get_node("Player")
	a = p.get_node("arsenal")
	powers = p.get_node("power_state")
	hud = game.get_node("HUD")
	check(a.owned.size() == 1 and a.selected == 0, "starter inventory")
	check(a.current().max_ammo == -1, "Resortera infinite")
	check(not a.equip(1) and not a.equip(3), "unowned and Nopal locked")
	m._on_entrance(p)
	m.director.running = false
	m._add_score(10000)
	p.global_position = Vector3(3, 0.05, -2)
	await frames()
	hud.open_modal("shop")
	check(paused and m.state_name() == "PAUSED", "shop pause safety")
	var clock: float = m.remaining
	var position_before := p.global_position
	await frames(6)
	check(m.remaining == clock and p.global_position == position_before, "shop freezes gameplay")
	p.take_damage(50)
	check(p.hp == 100, "shop cannot damage player")
	check(a.purchase(1, true, m) == "REQUIERE ARMA BASE", "PRO requires base")
	check(m.spendable_credits == 10000, "rejected upgrade costs nothing")
	for slot in [1, 2, 4]:
		var previous: int = m.spendable_credits
		check(a.purchase(slot, false, m) == "COMPRADO", "buy base %d" % slot)
		check(a.owned.has(slot) and a.selected == slot, "ownership/equip %d" % slot)
		check(m.spendable_credits == previous - a.definitions[slot].price, "base exact price %d" % slot)
		check(a.ammo[slot] == a.definitions[slot].max_ammo, "starting ammo %d" % slot)
		previous = m.spendable_credits
		check(a.purchase(slot, true, m) == "PRO ADQUIRIDA", "buy PRO %d" % slot)
		check(a.upgraded.has(slot), "PRO recorded %d" % slot)
		check(m.spendable_credits == previous - a.definitions[slot].upgrade_price, "upgrade exact price %d" % slot)
		check(a.purchase(slot, true, m) == "PRO ADQUIRIDA", "duplicate upgrade stable %d" % slot)
		check(m.spendable_credits == previous - a.definitions[slot].upgrade_price, "duplicate spends nothing %d" % slot)
	check(m.total_score == 10000, "all spending preserves score")
	check(hud.feedback_label.text == "", "purchases never display net earnings as rewards")
	check(a.purchase(3, false, m) == "NO DISPONIBLE", "Nopal unavailable")
	a.upgraded.erase(1)
	m.spendable_credits = 0
	check(a.purchase(1, true, m) == "SIN CRÉDITOS", "insufficient credits")
	hud.close_modal()
	check(not paused and m.state_name() == "PLAYING", "shop resumes cleanly")
	check(a.purchase(1, true, m) == "NO DISPONIBLE", "purchase outside shop rejected")
	for slot in [0, 1, 2, 4]: check(a.equip(slot), "equip owned %d" % slot)
	a.equip(4)
	a.cycle(1)
	check(a.selected == 0, "cycle wraps and skips locked")
	a.cycle(-1)
	check(a.selected == 4, "previous wraps")
	hud.open_modal("wheel")
	check(paused and hud.modal_kind == "wheel", "wheel safe pause")
	hud.close_modal()
	check(not paused and (DisplayServer.get_name() == "headless" or Input.mouse_mode == Input.MOUSE_MODE_CAPTURED), "wheel restores mouse (actual capture verified by rendered run)")
	p.global_position = Vector3(0, 0.05, -20)
	p.camera_rig.rotation = Vector3.ZERO
	p.camera_rig.pitch_pivot.rotation = Vector3.ZERO
	await frames()
	a.equip(2)
	a.cooldown = 0
	var ammo_before: int = a.ammo[2]
	check(a.fire() and a.ammo[2] == ammo_before - 1, "limited ammo consumption")
	a.ammo[2] = 0
	a.cooldown = 0
	check(not a.fire() and a.ammo[2] == 0, "empty weapon cannot fire")
	a.ammo[4] = 0
	check(a.refill() and a.ammo[2] == 2 and a.ammo[4] == 2, "refill half rounded up")
	check(a.refill() and a.ammo[2] == 4 and a.ammo[4] == 3, "refill caps max")
	check(not a.refill(), "full ammo not wasted")
	a.equip(0)
	check(a.current().max_ammo == -1, "Resortera stays infinite after refill")
	m._clear_projectiles()
	await frames()
	a.equip(1)
	a.cooldown = 0
	check(a.fire(), "Chancla launches")
	var chancla = get_nodes_in_group("projectiles").back()
	var instance: WeakRef = weakref(chancla)
	await frames(160)
	check(instance.get_ref() == null, "Chancla guaranteed return and cleanup")
	clear_enemies()
	await frames()
	var pass_target := enemy(0, p.global_position + Vector3(0, 0, -4))
	pass_target.set_physics_process(false)
	a.equip(1)
	a.cooldown = 0
	check(a.fire(), "pass-test Chancla launches")
	await frames(150)
	check(is_instance_valid(pass_target) and pass_target.hp == 5, "Chancla hits exactly once per outward/return pass")
	clear_enemies()
	await frames()
	for weapon_slot in [2, 4]:
		var victim := enemy(1, p.global_position + Vector3(0, 0, -7))
		victim.set_physics_process(false)
		a.equip(weapon_slot)
		a.cooldown = 0
		a.ammo[weapon_slot] = a.current().max_ammo
		check(a.fire(), "real explosive launches %d" % weapon_slot)
		await frames(100)
		check(not is_instance_valid(victim) or victim.hp < victim.max_hp, "real trajectory explosion hits %d" % weapon_slot)
		clear_enemies()
		await frames()
	clear_enemies()
	await frames()
	for slot in [2, 4]:
		var e := enemy(0, Vector3(0, 0.05, -25))
		e.set_physics_process(false)
		var shot = load("res://scripts/projectiles/arsenal_projectile.gd").new()
		shot.slot = slot
		shot.source = p
		shot.damage = 120
		shot.radius = 4
		game.add_child(shot)
		shot.global_position = e.global_position + Vector3.UP * 0.7
		shot.explode()
		check(e.dead, "area explosion damages enemy %d" % slot)
		await frames()
	p.hp = 100
	check(not powers.collect(&"health"), "full HP does not waste kit")
	p.take_damage(40)
	check(powers.collect(&"health") and p.hp == 90, "kit heals 30")
	p.heal(100)
	powers.collect(&"candle")
	p.take_damage(50)
	check(p.hp == 50 and powers.detection_range() == 3.5, "Veladora concealment without invulnerability")
	p.heal(100)
	check(p.invulnerability_left == 0, "Veladora separate from respawn")
	powers._physics_process(30.1)
	check(not powers.active(&"candle"), "Veladora expires")
	powers.collect(&"ice")
	p.take_damage(30)
	check(p.hp == 85, "Hielo 50 percent reduction")
	powers._physics_process(30.1)
	check(not powers.active(&"ice"), "Hielo expires")
	powers.collect(&"chile")
	check(is_equal_approx(powers.damage_multiplier(), 1.5) and is_equal_approx(powers.cadence_multiplier(), 1.3), "Chile damage/cadence")
	powers._physics_process(30.1)
	check(is_equal_approx(powers.damage_multiplier(), 1), "Chile expiration")
	powers.collect(&"happy")
	check(is_equal_approx(powers.cadence_multiplier(), 1.6) and is_equal_approx(powers.damage_multiplier(), 1.35), "Tequila attack multipliers")
	p.hp = 80
	p.take_damage(100)
	check(p.hp == 80, "Tequila invulnerable")
	a.equip(4)
	a.ammo[4] = 0
	a.cooldown = 0
	check(a.fire() and a.ammo[4] == 0, "Tequila fires with zero ammo without spending reserve")
	var left: float = powers.effects[&"happy"]
	m.pause()
	await frames(6)
	check(powers.effects[&"happy"] == left, "pause freezes buffs")
	m.resume()
	powers.clear()
	clear_enemies()
	await frames()
	p.hp = 100
	var polar := enemy(1, p.global_position + Vector3(0, 0, -1.3))
	polar.rotation.y = PI
	polar.set_physics_process(false)
	polar.sequence = 1
	polar._strike()
	check(p.hp == 70, "Polar claw 30 damage")
	polar.cooldown = 1.5
	polar.windup = -1
	polar.recovery = 0
	polar._physics_process(0.1)
	check(polar.windup < 0 and polar.cooldown > 1, "Polar attack cooldown")
	polar.sequence = 3
	polar._strike()
	check(p.hp == 55, "Polar combo 15 per strike")
	p.global_position += Vector3.RIGHT * 10
	var hp_before: float = p.hp
	polar._strike()
	check(p.hp == hp_before, "Polar attack range revalidated")
	polar.cooldown = 1
	polar.recovery = 0
	polar.windup = -1
	polar._physics_process(0.1)
	check(polar.velocity.length() > 0, "Polar routes toward player")
	m.director.running = true
	var score_before: int = m.total_score
	var credit_before: int = m.spendable_credits
	polar.take_damage(1000)
	var expected := 350 if m.objectives.player_inside() else 300
	check(polar.dead and m.total_score == score_before + expected and m.spendable_credits == credit_before + expected, "Polar reward 300 plus existing zone bonus")
	m.director.running = false
	m.director.elapsed = 0
	check(not m.director._eligible(m.director.enemy_definitions[1]), "early game excludes Polar")
	m.director.elapsed = 300
	check(m.director._eligible(m.director.enemy_definitions[1]), "mid game permits Polar")
	for i in range(4): enemy(1, Vector3(10 + i * 2, 0, -30))
	check(not m.director._eligible(m.director.enemy_definitions[1]), "Polar active cap")
	check(m.director._budget() == 16, "mixed spawn budget accounting")
	enemy(0, Vector3(-10, 0, -30))
	check(m.director._budget() == 17, "Pepsin costs one")
	for action in ["weapon_1", "weapon_2", "weapon_3", "weapon_4", "weapon_5", "weapon_previous", "weapon_next", "weapon_wheel", "melee"]:
		check(InputMap.has_action(action), "input action " + action)
	check(InputMap.action_get_events("interact")[0].physical_keycode == KEY_E, "E remains interact")
	print("PRODUCTION_COMBAT: %d checks, %d failures" % [checks, failures.size()])
	for failure in failures: print("FAILED: ", failure)
	paused = false
	quit(0 if failures.is_empty() else 1)
