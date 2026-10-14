extends CanvasLayer

const CameraController = preload("res://scripts/player/camera_controller.gd")

@export var camera_rig_path: NodePath
@onready var mode_label: Label = $Screen/ModeLabel
@onready var health_bar: ProgressBar = $Screen/health_bar
@onready var health_label: Label = $Screen/health_label
@onready var weapon_label: Label = $Screen/weapon_label

func _ready() -> void:
	var camera_rig: CameraController = get_node(camera_rig_path) as CameraController
	camera_rig.camera_mode_changed.connect(_update_mode)
	_update_mode(camera_rig.get_mode_name())
	var player = camera_rig.get_parent()
	player.health_changed.connect(_update_health)
	_update_health(player.hp, player.max_hp)
	var weapon = player.get_node("mango_slingshot")
	weapon_label.text = weapon.weapon_name + "\n" + weapon.get_ammo_text()

func _update_health(hp: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = hp
	health_label.text = "HP %d / %d" % [int(hp), int(maximum)]

func _update_mode(mode_name: String) -> void:
	mode_label.text = mode_name
