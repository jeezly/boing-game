extends Node
## The only authority for match state, time and results.
signal state_changed(state_name: String)
signal time_changed(remaining: int)
signal score_changed(score: int)
signal kills_changed(kills: int)
signal match_finished(victory: bool, score: int, kills: int, survived: float)
enum State { READY, PLAYING, VICTORY, DEFEAT, PAUSED }
const DURATION: float = 600.0
@export var player_path: NodePath = NodePath("../Player")
@export var environment_path: NodePath = NodePath("../mega_abarrotera")
@export var hud_path: NodePath = NodePath("../HUD/survival_status")
@onready var player = get_node(player_path)
@onready var environment = get_node(environment_path)
@onready var objectives = $objective_director
@onready var director = $survival_director
@onready var panel: Control = $match_ui/screen/panel
@onready var heading: Label = $match_ui/screen/panel/layout/heading
@onready var summary: Label = $match_ui/screen/panel/layout/summary
@onready var resume_button: Button = $match_ui/screen/panel/layout/resume
@onready var restart_button: Button = $match_ui/screen/panel/layout/restart
@onready var exit_button: Button = $match_ui/screen/panel/layout/exit
var state: State = State.READY
var resume_state: State = State.READY
var remaining: float = DURATION
var elapsed: float = 0.0
var score: int = 0
var kills: int = 0
var displayed_second: int = 600
var restarting: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("match_controller")
	get_tree().paused = false
	player.combat_enabled = false
	player.movement_enabled = true
	player.died.connect(_on_player_died)
	environment.entrance_crossed.connect(_on_entrance)
	director.enemy_defeated.connect(_on_enemy_defeated)
	objectives.phase_bonus_awarded.connect(_add_score)
	resume_button.pressed.connect(resume)
	restart_button.pressed.connect(restart)
	exit_button.pressed.connect(exit_match)
	panel.hide()
	_bind_hud.call_deferred()

func _bind_hud() -> void:
	var hud = get_node(hud_path)
	hud.bind_match(self)

func _on_entrance(body: Node3D) -> void:
	if state != State.READY or body != player or player.hp <= 0.0: return
	_set_state(State.PLAYING)
	player.combat_enabled = true
	objectives.begin()
	director.start()
	time_changed.emit(600)

func _physics_process(delta: float) -> void:
	if state == State.READY and not get_tree().paused and not restarting:
		# Recover safely if pause/input timing delayed an entrance body_entered event.
		if environment.entrance.get_overlapping_bodies().has(player): _on_entrance(player)
		return
	if state != State.PLAYING or get_tree().paused or restarting: return
	# Death wins a same-frame boundary race; location and kills never finish the match.
	if player.hp <= 0.0:
		_finish(false)
		return
	var step := minf(delta, remaining)
	remaining = maxf(0.0, remaining - step)
	elapsed = DURATION - remaining
	objectives.advance(remaining)
	director.set_elapsed(elapsed)
	var second := ceili(remaining)
	if second != displayed_second:
		displayed_second = second
		time_changed.emit(second)
	if remaining <= 0.0:
		objectives.finish()
		_finish(true)

func _on_enemy_defeated(points: int) -> void:
	if state != State.PLAYING or player.hp <= 0.0: return
	kills += 1
	kills_changed.emit(kills)
	_add_score(points + (50 if objectives.player_inside() else 0))

func _add_score(points: int) -> void:
	if state != State.PLAYING or points <= 0: return
	score += points
	score_changed.emit(score)

func _on_player_died() -> void:
	if state == State.READY or state == State.PLAYING or state == State.PAUSED: _finish(false)

func _finish(victory: bool) -> void:
	if state == State.VICTORY or state == State.DEFEAT or restarting: return
	director.stop()
	objectives.stop()
	player.combat_enabled = false
	player.movement_enabled = false
	for projectile in get_tree().get_nodes_in_group("projectiles"): projectile.queue_free()
	_set_state(State.VICTORY if victory else State.DEFEAT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	heading.text = "VICTORIA" if victory else "DERROTA"
	summary.text = "PUNTOS %d\nBAJAS %d\nTIEMPO SOBREVIVIDO: %s" % [score, kills, format_time(floori(elapsed))]
	resume_button.hide()
	restart_button.text = "REINICIAR" if victory else "REINTENTAR"
	panel.show()
	restart_button.grab_focus()
	match_finished.emit(victory, score, kills, elapsed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if state == State.READY or state == State.PLAYING: pause()
		elif state == State.PAUSED: resume()
		get_viewport().set_input_as_handled()
	elif event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_R:
		if state == State.VICTORY or state == State.DEFEAT:
			restart()
			get_viewport().set_input_as_handled()

func pause() -> void:
	if state != State.READY and state != State.PLAYING: return
	resume_state = state
	_set_state(State.PAUSED)
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	heading.text = "PAUSA"
	summary.text = "PUNTOS %d\nBAJAS %d\nTIEMPO RESTANTE: %s" % [score, kills, format_time(ceili(remaining))]
	resume_button.show()
	restart_button.text = "REINICIAR"
	panel.show()
	resume_button.grab_focus()

func resume() -> void:
	if state != State.PAUSED or restarting: return
	panel.hide()
	_set_state(resume_state)
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func restart() -> void:
	if restarting: return
	restarting = true
	director.stop()
	objectives.stop()
	player.combat_enabled = false
	player.movement_enabled = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene.call_deferred()

func exit_match() -> void:
	if OS.has_feature("web"):
		restart() # Browser builds safely return to READY instead of trying to close a tab.
	else:
		get_tree().paused = false
		get_tree().quit()

func _set_state(next: State) -> void:
	state = next
	state_changed.emit(State.keys()[state])

func state_name() -> String:
	return State.keys()[state]

static func format_time(seconds: int) -> String:
	return "%02d:%02d" % [maxi(0, seconds) / 60, maxi(0, seconds) % 60]
