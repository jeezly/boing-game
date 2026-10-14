extends CharacterBody3D
## Waiting -> approach/strafe -> telegraphed shot -> reposition -> hit/death.

signal defeated(enemy: CharacterBody3D)
const BubbleScene = preload("res://scenes/projectiles/soda_bubble.tscn")
const Player = preload("res://scripts/player/player_controller.gd")
const Store = preload("res://scripts/environment/la_abarrotera.gd")
const Visual = preload("res://scripts/enemies/pepsin_visual.gd")
@export var max_hp: float = 75.0
@export var move_speed: float = 3.2
@export var attack_damage: float = 10.0
@export var attack_interval: float = 1.8
@export var projectile_speed: float = 10.0
@export var attack_range: float = 12.0
@onready var visual: Visual = $visual
@onready var tell: MeshInstance3D = $attack_tell
var hp: float = 75.0
var target: Player
var store: Store
var active: bool = false
var dead: bool = false
var windup: float = -1.0
var cooldown: float = 1.0
var repath: float = 0.0
var route := PackedVector3Array()
var route_index: int = 0
var strafe_sign: float = 1.0
var hit_stun: float = 0.0
var locked_shot: Vector3
var gravity: float = 9.8

func _ready() -> void:
	add_to_group("enemies")
	hp = max_hp
	tell.hide()
	gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity"))

func activate(player: Player, environment: Store, index: int) -> void:
	target = player
	store = environment
	strafe_sign = -1.0 if index % 2 == 0 else 1.0
	cooldown = 0.6 + index * 0.35
	active = true

func take_damage(amount: float) -> void:
	if dead: return
	hp = maxf(0.0, hp - maxf(amount, 0.0))
	visual.hit_flash()
	hit_stun = 0.14
	windup = -1.0
	tell.hide()
	print("Pepsin: %d / %d HP" % [int(hp), int(max_hp)])
	if hp <= 0.0:
		dead = true
		active = false
		collision_layer = 0
		collision_mask = 0
		defeated.emit(self)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(visual, "rotation:z", 1.3 * strafe_sign, 0.22)
		tween.tween_property(visual, "scale", Vector3.ONE * 0.04, 0.45)
		tween.chain().tween_callback(queue_free)

func _physics_process(delta: float) -> void:
	if dead or not active or not is_instance_valid(target): return
	if target.hp <= 0.0: return
	cooldown = maxf(0.0, cooldown - delta)
	hit_stun = maxf(0.0, hit_stun - delta)
	var target_point := target.global_position + Vector3.UP * 1.0
	var flat := target.global_position - global_position
	flat.y = 0.0
	if flat.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-flat.x, -flat.z), 1.0 - exp(-12.0 * delta))
	var distance := flat.length()
	var clear := _line_of_sight(target_point)
	if windup >= 0.0:
		windup -= delta
		if windup <= 0.0:
			if clear and hit_stun <= 0.0: _shoot()
			windup = -1.0
			tell.hide()
			cooldown = attack_interval
			strafe_sign *= -1.0
	elif cooldown <= 0.0 and clear and distance <= attack_range and hit_stun <= 0.0:
		locked_shot = target_point
		windup = 0.48
		tell.show()
	var desired := Vector3.ZERO
	if windup < 0.0 and hit_stun <= 0.0:
		repath -= delta
		if repath <= 0.0:
			repath = 0.45
			var goal := target.global_position
			if clear and distance < 9.0:
				var away := -flat.normalized()
				goal += away * 6.0 + Vector3(away.z, 0, -away.x) * strafe_sign * 3.0
			route = store.get_navigation_path(global_position, goal)
			route_index = 0
			# Don't repeatedly walk back to the current cell's center on every replan.
			if route.size() > 1 and global_position.distance_to(route[0]) < 0.85:
				route_index = 1
		while route_index < route.size() and Vector2(route[route_index].x - global_position.x, route[route_index].z - global_position.z).length() < 0.28:
			route_index += 1
		if route_index < route.size():
			desired = route[route_index] - global_position
			desired.y = 0.0
			desired = desired.normalized() * move_speed
	velocity.x = move_toward(velocity.x, desired.x, delta * 18.0)
	velocity.z = move_toward(velocity.z, desired.z, delta * 18.0)
	if not is_on_floor(): velocity.y -= gravity * delta
	else: velocity.y = 0.0
	move_and_slide()
	visual.present(delta, Vector2(velocity.x, velocity.z).length(), target_point, windup >= 0.0)
	tell.scale = Vector3.ONE * (1.0 + 0.25 * sin(Time.get_ticks_msec() * 0.02))

func _line_of_sight(point: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(visual.muzzle_position(), point, 3, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and hit["collider"] == target

func _shoot() -> void:
	var origin: Vector3 = visual.muzzle_position()
	# Don't let a long bottle barrel shoot from the far side of a nearby shelf.
	var safety := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.85, origin, 1)
	if not get_world_3d().direct_space_state.intersect_ray(safety).is_empty(): return
	var bubble = BubbleScene.instantiate()
	get_tree().current_scene.add_child(bubble)
	bubble.global_position = origin
	var direction := (locked_shot - origin).normalized()
	bubble.launch(direction, projectile_speed, attack_damage, self)
	if direction.length_squared() > 0.01: bubble.look_at(origin + direction, Vector3.UP)
	visual.fire_reaction()
