extends CharacterBody3D

const CameraController = preload("res://scripts/characters/mango/camera_controller.gd")

signal health_changed(hp: float, maximum: float)
signal died
signal damaged(amount: float)
signal respawned
signal protection_changed(active: bool)

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 22.0
@export var deceleration: float = 26.0
@export var jump_velocity: float = 5.5
@export var max_hp: float = 100.0

@onready var camera_rig: CameraController = $CameraRig
@onready var mango = $mango_visual
var hp: float = 100.0
var combat_enabled: bool = true
var movement_enabled: bool = true
var invulnerability_left: float = 0.0
var gravity: float = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func _ready() -> void:
	add_to_group("player")
	hp = max_hp

func take_damage(amount: float) -> void:
	if hp <= 0.0 or not combat_enabled or invulnerability_left > 0.0 or get_tree().paused: return
	var previous_hp := hp
	hp = clampf(hp - maxf(amount, 0.0), 0.0, max_hp)
	if hp < previous_hp:
		mango.on_hit()
		damaged.emit(previous_hp - hp)
	health_changed.emit(hp, max_hp)
	if hp <= 0.0:
		mango.on_death()
		velocity = Vector3.ZERO
		died.emit()

func heal(amount: float) -> void:
	if hp <= 0.0: return
	hp = minf(max_hp, hp + maxf(amount, 0.0))
	health_changed.emit(hp, max_hp)

func _physics_process(delta: float) -> void:
	if invulnerability_left > 0.0:
		invulnerability_left = maxf(0.0, invulnerability_left - delta)
		if invulnerability_left <= 0.0: protection_changed.emit(false)
	if hp <= 0.0 or not movement_enabled: return
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

func respawn_at(point: Vector3) -> void:
	global_position = point
	velocity = Vector3.ZERO
	hp = max_hp
	invulnerability_left = 2.75
	mango.reset_after_life_loss()
	camera_rig.pitch_pivot.rotation.x = 0.0
	health_changed.emit(hp, max_hp)
	protection_changed.emit(true)
	respawned.emit()
