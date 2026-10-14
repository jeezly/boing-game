extends Node

const CameraController = preload("res://scripts/characters/mango/camera_controller.gd")

@export var weapon_name: String = "debug_blaster"
@export var range_meters: float = 100.0
@export var shots_per_second: float = 4.0
@export var damage: float = 25.0
@onready var player: CharacterBody3D = get_parent() as CharacterBody3D
@onready var camera_rig: CameraController = $"../CameraRig"
var cooldown: float = 0.0

func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire") and cooldown <= 0.0:
		cooldown = 1.0 / shots_per_second
		_fire()

func _fire() -> void:
	var camera: Camera3D = camera_rig.get_active_camera()
	var center: Vector2 = camera.get_viewport().get_visible_rect().size * 0.5
	var origin: Vector3 = camera.project_ray_origin(center)
	var direction: Vector3 = camera.project_ray_normal(center)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + direction * range_meters)
	query.exclude = [player.get_rid()]
	query.collision_mask = 1
	var hit: Dictionary = player.get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var collider: Object = hit["collider"]
		if collider.has_method("take_damage"):
			collider.call("take_damage", damage)
