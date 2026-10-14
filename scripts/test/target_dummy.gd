extends StaticBody3D

@export var max_hp: float = 100.0
@export var respawn_seconds: float = 2.0
@onready var mesh: MeshInstance3D = $Mesh
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var respawn_timer: Timer = $RespawnTimer
var hp: float = 100.0
var dead: bool = false

func _ready() -> void:
	hp = max_hp
	respawn_timer.timeout.connect(_respawn)

func take_damage(amount: float) -> void:
	if dead:
		return
	hp = maxf(0.0, hp - amount)
	print("Target hit: %d HP remaining" % int(hp))
	if hp <= 0.0:
		dead = true
		mesh.hide()
		collision.set_deferred("disabled", true)
		respawn_timer.start(respawn_seconds)

func _respawn() -> void:
	hp = max_hp
	dead = false
	mesh.show()
	collision.set_deferred("disabled", false)
	print("Target respawned: %d HP" % int(hp))
