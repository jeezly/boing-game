extends Control
## Signal-driven functional overlay; existing health/weapon HUD stays independent.
@onready var timer: Label = $timer
@onready var score: Label = $score
@onready var kills: Label = $kills
@onready var objective: Label = $objective
@onready var status: Label = $status

func bind_match(match_controller: Node) -> void:
	var match_state = match_controller
	show()
	match_state.time_changed.connect(_on_time)
	match_state.score_changed.connect(_on_score)
	match_state.kills_changed.connect(_on_kills)
	match_state.state_changed.connect(_on_state)
	match_state.objectives.objective_changed.connect(_on_objective)
	_on_time(ceili(match_state.remaining))
	_on_score(match_state.score)
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
	# Pause/results already have their own overlay; no gameplay debug footer.
	status.text = "PAUSA" if value == "PAUSED" else ""
	status.hide()
