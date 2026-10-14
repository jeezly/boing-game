extends CharacterBody3D

const CameraController = preload("res://scripts/player/camera_controller.gd")

signal health_changed(hp: float, maximum: float)
signal died

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 22.0
@export var deceleration: float = 26.0
@export var jump_velocity: float = 5.5
@export var max_hp: float = 100.0

@onready var camera_rig: CameraController = $CameraRig
@onready var mango = $mango_visual
var hp: float = 100.0
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
	add_to_group("player")
	hp = max_hp

func take_damage(amount: float) -> void:
	if hp <= 0.0: return
	hp = clampf(hp - maxf(amount, 0.0), 0.0, max_hp)
	health_changed.emit(hp, max_hp)
	if hp <= 0.0:
		velocity = Vector3.ZERO
		died.emit()

func heal(amount: float) -> void:
	if hp <= 0.0: return
	hp = minf(max_hp, hp + maxf(amount, 0.0))
	health_changed.emit(hp, max_hp)

func _physics_process(delta: float) -> void:
	if hp <= 0.0: return
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = camera_rig.basis * Vector3(input_vector.x, 0.0, input_vector.y)
	var speed: float = sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var rate: float = acceleration if input_vector.length_squared() > 0.0 else deceleration
	velocity.x = move_toward(velocity.x, direction.x * speed, rate * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, rate * delta)
	move_and_slide()
	var aiming := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire")
	mango.present(delta, Vector2(velocity.x, velocity.z).length(), is_on_floor(), camera_rig.pitch_pivot.rotation.x, aiming)
