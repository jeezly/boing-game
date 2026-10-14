extends CanvasLayer

const CameraController = preload("res://scripts/player/camera_controller.gd")

@export var camera_rig_path: NodePath
@onready var mode_label: Label = $Screen/ModeLabel

func _ready() -> void:
	var camera_rig: CameraController = get_node(camera_rig_path) as CameraController
	camera_rig.camera_mode_changed.connect(_update_mode)
	_update_mode(camera_rig.get_mode_name())

func _update_mode(mode_name: String) -> void:
	mode_label.text = mode_name
