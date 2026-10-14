extends Area3D
## Temporary authored survival supply; no inventory or drop system.
signal collected(player: Node3D, restored_hp: float)
@export_range(1.0, 100.0) var healing: float = 30.0
@onready var visual: Node3D = $visual
var clock: float = 0.0
var used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	clock += delta
	visual.position.y = 0.62 + sin(clock * 2.5) * 0.08
	visual.rotation.y += delta * 0.5
	visual.scale = Vector3.ONE * (1.0 + sin(clock * 2.5) * 0.025)

func _on_body_entered(body: Node3D) -> void:
	if used or get_tree().paused or not body.is_in_group("player") or not body.has_method("heal"): return
	var previous: float = float(body.get("hp"))
	if previous <= 0.0 or previous >= float(body.get("max_hp")): return
	used = true
	body.call("heal", healing)
	var restored: float = float(body.get("hp")) - previous
	if restored <= 0.0:
		used = false
		return
	set_deferred("monitoring", false)
	visual.hide()
	collected.emit(body, restored)
	queue_free()

func _physics_process(_delta: float) -> void:
	# A full-health player may already overlap when damage makes room to heal.
	for body in get_overlapping_bodies():
		_on_body_entered(body)
		if used: break
