extends CharacterBody3D
## Swept body collision prevents fast pellets tunneling through thin targets.

@export var max_lifetime: float = 4.0
@export var impact_scene: PackedScene
var damage: float = 25.0
var shooter: CollisionObject3D
var age: float = 0.0
var launched: bool = false

func launch(direction: Vector3, speed: float, hit_damage: float, source: CollisionObject3D) -> void:
	shooter = source
	damage = hit_damage
	add_collision_exception_with(source)
	velocity = direction.normalized() * speed
	launched = true

func _physics_process(delta: float) -> void:
	if not launched:
		return
	age += delta
	if age >= max_lifetime:
		queue_free()
		return
	var hit := move_and_collide(velocity * delta)
	if hit != null:
		var target := hit.get_collider()
		if target != shooter and is_instance_valid(target) and target.has_method("take_damage"):
			target.call("take_damage", damage)
		if impact_scene != null:
			var impact := impact_scene.instantiate() as Node3D
			get_tree().current_scene.add_child(impact)
			impact.global_position = hit.get_position()
		queue_free()
