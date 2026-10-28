extends Node3D

signal camera_mode_changed(mode_name: String)

@export var mouse_sensitivity: float = 0.0025
@onready var pitch_pivot: Node3D = $PitchPivot
@onready var first_camera: Camera3D = $PitchPivot/FirstPersonCamera
@onready var spring_arm: SpringArm3D = $PitchPivot/ThirdPersonArm
@onready var third_camera: Camera3D = $PitchPivot/ThirdPersonArm/ThirdPersonCamera
@onready var mango: Node3D = $"../mango_visual"
var third_person: bool = false

func _ready() -> void:
	spring_arm.add_excluded_object((get_parent() as CollisionObject3D).get_rid())
	_apply_mode()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not get_parent().movement_enabled or get_tree().paused: return
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_camera"):
		third_person = not third_person
		_apply_mode()
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		mango.rotation.y = rotation.y
		pitch_pivot.rotation.x = clampf(pitch_pivot.rotation.x - event.relative.y * mouse_sensitivity, deg_to_rad(-70.0), deg_to_rad(70.0))

func _apply_mode() -> void:
	first_camera.current = not third_person
	third_camera.current = third_person
	mango.visible = third_person
	camera_mode_changed.emit(get_mode_name())

func get_mode_name() -> String:
	return "THIRD PERSON" if third_person else "FIRST PERSON"

func get_active_camera() -> Camera3D:
	return third_camera if third_person else first_camera
