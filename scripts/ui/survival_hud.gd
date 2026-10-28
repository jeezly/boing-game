extends Control
## Signal-driven functional overlay; existing health/weapon HUD stays independent.
@onready var timer: Label = $objective_panel/layout/timer
@onready var score: Label = $score_panel/layout/score
@onready var kills: Label = $score_panel/layout/kills
@onready var credits: Label = $score_panel/layout/credits
@onready var objective: Label = $objective_panel/layout/objective
@onready var status: Label = $status
@onready var lives: Label = $"../Screen/health_panel/layout/lives"
@onready var protection: Label = $"../Screen/health_panel/layout/protection"
@onready var interaction: Label = $interaction
var notice_left: float = 0.0

func bind_match(match_controller: Node) -> void:
	var match_state = match_controller
	show()
	match_state.time_changed.connect(_on_time)
	match_state.score_changed.connect(_on_score)
	match_state.credits_changed.connect(func(value: int): credits.text = "CRÉDITOS %d" % value)
	match_state.lives_changed.connect(func(value: int): lives.text = "VIDAS ×%d" % value)
	match_state.notice.connect(_on_notice)
	match_state.interaction_changed.connect(func(text: String): interaction.text = text)
	match_state.player.protection_changed.connect(func(active: bool): protection.visible = active)
	match_state.kills_changed.connect(_on_kills)
	match_state.state_changed.connect(_on_state)
	match_state.objectives.objective_changed.connect(_on_objective)
	_on_time(ceili(match_state.remaining))
	_on_score(match_state.total_score)
	credits.text = "CRÉDITOS %d" % match_state.spendable_credits
	lives.text = "VIDAS ×%d" % match_state.lives
	_on_kills(match_state.kills)
	_on_state(match_state.state_name())
	objective.text = match_state.objectives.objective_text()

func _on_time(seconds: int) -> void:
	timer.text = "%02d:%02d" % [seconds / 60, seconds % 60]

func _on_score(value: int) -> void:
	score.text = "PUNTOS %d" % value

func _on_kills(value: int) -> void:
	kills.text = "BAJAS %d" % value

func _on_objective(_zone: StringName, text: String, _phase: int) -> void:
	objective.text = text

func _on_state(value: String) -> void:
	visible = value == "READY" or value == "PLAYING"
	get_node("../Screen").visible = visible

func _on_notice(text: String) -> void:
	status.text = text
	notice_left = 3.0
	status.show()

func _process(delta: float) -> void:
	if notice_left > 0.0:
		notice_left = maxf(0.0, notice_left - delta)
		if notice_left <= 0.0: status.hide()
