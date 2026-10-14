@tool
extends RefCounted
## Visual-only transient state. Never modifies collision, HP, aim rays or movement.
var hit_left: float = 0.0
var fire_left: float = 0.0
var dead: bool = false
var death_age: float = 0.0
var fall_sign: float = 1.0
var meshes: Array[MeshInstance3D] = []
var overlays: Array[Material] = []
var flash: StandardMaterial3D

func bind(root: Node3D) -> void:
	flash = StandardMaterial3D.new()
	flash.albedo_color = Color(1.0, 0.78, 0.48, 0.38)
	flash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_collect(root)

func _collect(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
			overlays.append(child.material_overlay)
		_collect(child)

func hit() -> void:
	if dead: return
	hit_left = 0.18
	for mesh in meshes:
		mesh.material_overlay = flash

func fire() -> void:
	if not dead: fire_left = 0.18

func die(direction: float = 1.0) -> void:
	if dead: return
	dead = true
	death_age = 0.0
	fall_sign = direction
	fire_left = 0.0

func update(delta: float, pivot: Node3D, bob: float, sway: float) -> void:
	hit_left = maxf(0.0, hit_left - delta)
	fire_left = maxf(0.0, fire_left - delta)
	if hit_left <= 0.07:
		for index in range(meshes.size()):
			meshes[index].material_overlay = overlays[index]
	if dead:
		death_age += delta
		var t := smoothstep(0.0, 0.55, death_age)
		pivot.rotation = Vector3(-0.20 * t, 0, fall_sign * 1.10 * t)
		pivot.position = Vector3(0, -0.04 * t, 0.08 * t)
		pivot.scale = Vector3(1.0, 1.0 - 0.24 * t, 1.0)
		return
	var hurt := sin(hit_left / 0.18 * PI)
	var shot := sin(fire_left / 0.18 * PI)
	pivot.position = Vector3(0, bob, hurt * 0.075 + shot * 0.018)
	pivot.rotation = Vector3(-hurt * 0.10 + shot * 0.035, 0, sway + hurt * 0.08)
	pivot.scale = Vector3(1.0 + hurt * 0.022, 1.0 - hurt * 0.035, 1.0)
