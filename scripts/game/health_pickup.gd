extends Area3D
const Build = preload("res://scripts/environment/store_builder.gd")
@export var healing: float = 30.0
var clock: float = 0.0
var used: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	Build.box($visual, Vector3.ZERO, Vector3(0.6, 0.48, 0.45), Build.mat("fff1ce"), "supply_box")
	Build.box($visual, Vector3(0, 0, 0.235), Vector3(0.12, 0.33, 0.018), Build.mat("47ac76"), "health_cross")
	Build.box($visual, Vector3(0, 0, 0.245), Vector3(0.34, 0.12, 0.018), Build.mat("47ac76"))
	Build.label(self, "+30 SALUD", Vector3(0, 1.08, 0), 24, Color("a6e5b4"))

func _process(delta: float) -> void:
	clock += delta
	$visual.position.y = 0.62 + sin(clock * 2.5) * 0.08
	$visual.rotation.y += delta * 0.5

func _on_body_entered(body: Node3D) -> void:
	if used or not body.is_in_group("player"): return
	if float(body.get("hp")) <= 0.0 or float(body.get("hp")) >= float(body.get("max_hp")): return
	used = true
	body.call("heal", healing)
	queue_free()

func _physics_process(_delta: float) -> void:
	# Also collect while already overlapping, after damage creates room for healing.
	for body in get_overlapping_bodies():
		_on_body_entered(body)
		if used: break
