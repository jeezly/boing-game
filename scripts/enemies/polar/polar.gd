extends CharacterBody3D
signal defeated(enemy: CharacterBody3D)
@export var max_hp: float = 220
@export var move_speed: float = 4.2
@export var attack_damage: float = 30
@export var combo_damage: float = 15
@export var attack_interval: float = 1.5
@export var reach: float = 1.9
var hp: float = 220
var dead: bool = false
var active: bool = false
var combat_enabled: bool = true
var target: CharacterBody3D
var store: Node3D
var cooldown: float = 0.7
var windup: float = -1
var recovery: float = 0
var combo_left: int = 0
var sequence: int = 0
var repath: float = 0
var route := PackedVector3Array()
var route_index: int = 0
var visual: Node3D
func _ready() -> void:
	add_to_group("enemies")
	var feedback = load("res://scripts/components/hit_tint.gd").new()
	feedback.name = "hit_tint"
	add_child(feedback)
	collision_layer = 4
	collision_mask = 7
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.34
	capsule.height = 1.8
	shape.shape = capsule
	shape.position.y = 0.9
	add_child(shape)
	visual = load("res://scripts/enemies/polar/polar_visual.gd").new()
	add_child(visual)
	hp = max_hp
func activate(player: CharacterBody3D, environment: Node3D, index: int) -> void:
	target = player
	store = environment
	cooldown = 0.7 + index * 0.1
	active = true
func deactivate() -> void:
	active = false
	combat_enabled = false
	velocity = Vector3.ZERO
func take_damage(amount: float) -> void:
	if dead or not combat_enabled or get_tree().paused: return
	get_node("hit_tint").flash(visual)
	hp = maxf(0, hp - maxf(0, amount))
	visual.hit_left = 0.22
	if hp <= 0:
		dead = true
		active = false
		visual.dead = true
		collision_layer = 0
		collision_mask = 0
		defeated.emit(self)
		get_tree().create_timer(0.9, false).timeout.connect(queue_free)
func _physics_process(delta: float) -> void:
	visual.present(delta, Vector2(velocity.x, velocity.z).length(), windup, recovery > 0.3)
	if dead or not active or not is_instance_valid(target) or target.hp <= 0: return
	cooldown = maxf(0, cooldown - delta)
	recovery = maxf(0, recovery - delta)
	if global_position.distance_to(target.global_position) > target.get_node("power_state").detection_range():
		windup = -1.0
		velocity.x = move_toward(velocity.x, 0.0, delta * 20.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 20.0)
		velocity.y = velocity.y - 9.8 * delta if not is_on_floor() else 0.0
		move_and_slide()
		combo_left = 0
		return
	var flat := target.global_position - global_position
	flat.y = 0
	if flat.length_squared() > 0.01 and windup < 0:
		rotation.y = lerp_angle(rotation.y, atan2(-flat.x, -flat.z), delta * 10)
	if windup >= 0:
		windup -= delta
		if windup <= 0:
			_strike()
			windup = -1
			recovery = 0.5
	elif recovery <= 0 and cooldown <= 0 and flat.length() < reach:
		sequence += 1
		combo_left = 3 if sequence % 3 == 0 else 1
		windup = 0.65
		cooldown = attack_interval + 0.65
		target.get_node("arsenal").feedback.emit(&"polar_attack", "¡GARRAS!")
	elif recovery <= 0 and combo_left > 0:
		if flat.length() < reach:
			windup = 0.32
		else: combo_left = 0
	var desired := Vector3.ZERO
	if windup < 0 and recovery <= 0 and flat.length() > 1.4:
		repath -= delta
		if repath <= 0:
			repath = 0.5
			route = store.get_navigation_path(global_position, target.global_position)
			route_index = 1 if route.size() > 1 else 0
		while route_index < route.size() and global_position.distance_to(route[route_index]) < 0.4: route_index += 1
		if route_index < route.size():
			desired = route[route_index] - global_position
			desired.y = 0
			desired = desired.normalized() * move_speed
	velocity.x = move_toward(velocity.x, desired.x, delta * 20)
	velocity.z = move_toward(velocity.z, desired.z, delta * 20)
	velocity.y = velocity.y - 9.8 * delta if not is_on_floor() else 0.0
	move_and_slide()
func _strike() -> void:
	var offset := target.global_position - global_position
	var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP, target.global_position + Vector3.UP, 1)
	if offset.length() < reach and (-global_basis.z).dot(offset.normalized()) > 0.35 and get_world_3d().direct_space_state.intersect_ray(query).is_empty():
		target.take_damage(combo_damage if sequence % 3 == 0 else attack_damage)
	combo_left = maxi(0, combo_left - 1)
	if combo_left == 0: cooldown = attack_interval + 0.5
