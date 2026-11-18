extends Node
## Stable future sound entry point. Connect cue_requested to licensed audio playback.
signal cue_requested(cue: StringName, position: Vector3)
var low_health: bool = false
func _ready() -> void:
	_bind.call_deferred()
func _bind() -> void:
	var m = get_tree().get_first_node_in_group("match_controller")
	var player = m.player
	player.get_node("arsenal").feedback.connect(func(cue, _detail): cue_requested.emit(cue, player.global_position))
	player.get_node("power_state").feedback.connect(func(cue, _detail): cue_requested.emit(cue, player.global_position))
	player.damaged.connect(func(_amount): cue_requested.emit(&"damage", player.global_position))
	player.health_changed.connect(func(hp, _maximum):
		if hp <= 25 and not low_health: cue_requested.emit(&"low_health", player.global_position)
		low_health = hp <= 25)
	m.lives_changed.connect(func(_lives): cue_requested.emit(&"life_lost", player.global_position))
