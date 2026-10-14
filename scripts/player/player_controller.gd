extends CharacterBody3D

const CameraController = preload("res://scripts/player/camera_controller.gd")

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 22.0
@export var deceleration: float = 26.0
@export var jump_velocity: float = 5.5

@onready var camera_rig: CameraController = $CameraRig
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _physics_process(delta: float) -> void:
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
