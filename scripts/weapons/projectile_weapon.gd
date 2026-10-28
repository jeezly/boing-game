extends Node
## Camera ray selects the aim point only; damage comes exclusively from the projectile.

@export var visual_scene: PackedScene = preload("res://scenes/weapons/mango_slingshot_visual.tscn")
@export var projectile_scene: PackedScene = preload("res://scenes/projectiles/mango_projectile.tscn")
@export var weapon_name: String = "Resortera de Mango"
@export var shots_per_second: float = 3.0
@export var damage: float = 25.0
@export var projectile_speed: float = 24.0
@export var aim_distance: float = 100.0
@onready var player: CharacterBody3D = get_parent()
@onready var camera_rig = $"../CameraRig"
@onready var mango = $"../mango_visual"
var first_visual: Node3D
var third_visual: Node3D
var cooldown: float = 0.0
var readiness_left: float = 0.0

func _ready() -> void:
	first_visual = visual_scene.instantiate()
	camera_rig.first_camera.add_child(first_visual)
	first_visual.position = Vector3(0.30, -0.34, -0.76)
	third_visual = mango.weapon_socket.get_node("slingshot")
	third_visual.third_person_pose = true
	player.damaged.connect(_on_player_damaged)
	player.died.connect(_on_player_died)
	player.respawned.connect(_on_player_respawned)
	camera_rig.camera_mode_changed.connect(_update_mode)
	_update_mode(camera_rig.get_mode_name())

func _update_mode(_mode: String) -> void:
	first_visual.visible = not camera_rig.third_person and float(player.get("hp")) > 0.0
	third_visual.visible = camera_rig.third_person

func _physics_process(delta: float) -> void:
	if float(player.get("hp")) <= 0.0 or not player.get("combat_enabled"): return
	cooldown = maxf(0.0, cooldown - delta)
	readiness_left = maxf(0.0, readiness_left - delta)
	var interval := 1.0 / maxf(shots_per_second, 0.1)
	first_visual.update_presentation(delta, Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire"))
	third_visual.update_presentation(delta, Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire") or mango.firing_time > 0.0)
	first_visual.set_readiness(readiness_left, interval)
	third_visual.set_readiness(readiness_left, interval)
	var aiming := Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire")
	if camera_rig.third_person:
		mango.pose_slingshot(delta, _get_aim_point(), third_visual.get_draw_point(), aiming)
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("fire") and cooldown <= 0.0:
		cooldown = 1.0 / maxf(shots_per_second, 0.1)
		_fire()

func _get_aim_point() -> Vector3:
	var camera: Camera3D = camera_rig.get_active_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var forward := camera.project_ray_normal(center)
	var aim_point := origin + forward * aim_distance
	var query := PhysicsRayQueryParameters3D.create(origin, aim_point, 5, [player.get_rid()])
	var result := player.get_world_3d().direct_space_state.intersect_ray(query)
	if not result.is_empty():
		aim_point = result["position"]
	return aim_point

func _fire() -> void:
	var aim_point := _get_aim_point()
	var camera: Camera3D = camera_rig.get_active_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var forward := camera.project_ray_normal(center)
	var visual: Node3D = third_visual if camera_rig.third_person else first_visual
	var muzzle: Marker3D = visual.get_node("projectile_socket")
	var spawn := muzzle.global_position
	# Resolve any wall between the player and muzzle before spawning outside it.
	var safety := PhysicsRayQueryParameters3D.create(player.global_position + Vector3.UP * 1.25, spawn, 1, [player.get_rid()])
	var obstruction := player.get_world_3d().direct_space_state.intersect_ray(safety)
	if not obstruction.is_empty():
		if camera_rig.third_person:
			# A blocked fork cannot launch through a wall or relocate the shot to Mango.
			return
		spawn = obstruction["position"] + obstruction["normal"] * 0.09
	var direction := (aim_point - spawn).normalized()
	if not camera_rig.third_person and direction.dot(forward) < 0.1:
		direction = forward
	var projectile = projectile_scene.instantiate()
	player.get_tree().current_scene.add_child(projectile)
	var ammo: Node3D = visual.get_node("pouch/loaded_ammo")
	projectile.global_transform = Transform3D(ammo.global_basis.orthonormalized(), spawn)
	projectile.launch(direction, projectile_speed, damage, player)
	readiness_left = cooldown
	# Synchronize both presentations so switching modes cannot show stale loaded ammo.
	first_visual.set_readiness(readiness_left, 1.0 / maxf(shots_per_second, 0.1))
	third_visual.set_readiness(readiness_left, 1.0 / maxf(shots_per_second, 0.1))
	first_visual.kick()
	third_visual.kick()
	mango.on_fired()

func _on_player_damaged(_amount: float) -> void:
	first_visual.damage_reaction()

func _on_player_died() -> void:
	first_visual.hide()

func _on_player_respawned() -> void:
	cooldown = 0.35
	readiness_left = 0.0
	_update_mode(camera_rig.get_mode_name())

func get_ammo_text() -> String:
	return "Ammo: infinite"
