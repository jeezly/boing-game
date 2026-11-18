extends Node3D
## Swept query for fast throws; a boomerang tracks one hit per target per pass.
const Props = preload("res://scripts/game/production/prop_factory.gd")
var slot: int = 1
var pro: bool = false
var source: CharacterBody3D
var damage: float = 35
var speed: float = 15
var radius: float = 0.6
var velocity: Vector3
var reach: float = 18.0
var travelled: float = 0.0
var age: float = 0
var returning: bool = false
var hit_ids: Dictionary = {}
var visual: Node3D
var trail_clock: float = 0

func _ready() -> void:
	add_to_group("projectiles")
	visual = Node3D.new()
	add_child(visual)
	Props.weapon(visual, slot, pro)
	visual.scale = Vector3.ONE * (1.15 if pro else 1.0)

func _physics_process(delta: float) -> void:
	age += delta
	if not is_instance_valid(source) or source.hp <= 0 or age > 6:
		queue_free()
		return
	if slot == 1:
		visual.rotation.y += delta * 20
		if travelled >= reach and not returning: _return()
		if returning:
			var home := source.global_position + Vector3.UP * 1.2
			velocity = (home - global_position).normalized() * speed * 1.3
			if global_position.distance_to(home) < 0.65:
				queue_free()
				return
		# Segment distance avoids skipping targets between physics frames.
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.dead or hit_ids.has(enemy.get_instance_id()): continue
			var point: Vector3 = enemy.global_position + Vector3.UP * 0.9
			var capsule_radius: float = 0.32
			var axis_low := point - Vector3.UP * 0.5
			var axis_high := point + Vector3.UP * 0.5
			for child in enemy.get_children():
				if child is CollisionShape3D and child.shape is CapsuleShape3D:
					capsule_radius = child.shape.radius
					var half: float = child.shape.height * 0.5 - capsule_radius
					axis_low = child.global_position - Vector3.UP * half
					axis_high = child.global_position + Vector3.UP * half
			var closest := Geometry3D.get_closest_points_between_segments(global_position, global_position + velocity * delta, axis_low, axis_high)
			var sight := PhysicsRayQueryParameters3D.create(global_position, closest[1], 1)
			if closest[0].distance_to(closest[1]) <= radius * (1.2 if pro else 1.0) + capsule_radius and get_world_3d().direct_space_state.intersect_ray(sight).is_empty():
				enemy.take_damage(damage)
				source.get_node("arsenal").feedback.emit(&"hit", "")
				hit_ids[enemy.get_instance_id()] = true
	else:
		if slot == 2: velocity.y -= 9.8 * delta
		visual.rotate_y(delta * 3 if slot == 2 else 0)
	var next := global_position + velocity * delta
	var query := PhysicsRayQueryParameters3D.create(global_position, next, 1 if slot == 1 else 5, [source.get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		if slot == 1:
			if not returning: _return()
			# Returning chancla is guaranteed to recover even behind geometry.
		else:
			global_position = hit.position
			explode()
			return
	travelled += global_position.distance_to(next)
	global_position = next
	trail_clock -= delta
	if trail_clock <= 0 and (slot == 4 or pro):
		trail_clock = 0.09
		var puff = load("res://scripts/game/production/combat_effect.gd").new()
		puff.tint = Color("ed62cc") if slot == 1 else Color("e7b16b")
		puff.size = 0.07
		get_tree().current_scene.add_child(puff)
		puff.global_position = global_position

func _return() -> void:
	returning = true
	hit_ids.clear()

func explode() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.dead: continue
		var distance: float = global_position.distance_to(enemy.global_position + Vector3.UP * 0.7)
		if distance > radius: continue
		var query := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.05, enemy.global_position + Vector3.UP * 0.7, 1)
		if get_world_3d().direct_space_state.intersect_ray(query).is_empty():
			enemy.take_damage(damage * lerpf(1.0, 0.3, distance / radius))
			source.get_node("arsenal").feedback.emit(&"hit", "")
	var effect = load("res://scripts/game/production/combat_effect.gd").new()
	effect.size = radius
	effect.tint = Color("ed6c23") if slot == 4 or pro else Color("97b430")
	effect.hazard = slot == 2 and pro
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position + Vector3.UP * 0.1
	queue_free()
