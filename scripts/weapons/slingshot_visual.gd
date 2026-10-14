extends Node3D

const Builder = preload("res://scripts/player/mango_mesh_builder.gd")
var pouch: MeshInstance3D
var bands: Array[MeshInstance3D] = []
var recoil: float = 0.0
var third_person_pose: bool = false
var drawing: bool = false
var draw_amount: float = 0.0

func _ready() -> void:
	var wood := Builder.material(Color("965728"))
	var green := Builder.material(Color("668d2d"))
	var leather := Builder.material(Color("633c25"))
	var orange := Builder.material(Color("ffaa29"))
	Builder.rod(self, "handle", Vector3(0, -0.19, 0), Vector3(0, 0.09, 0), 0.045, wood)
	for side in [-1.0, 1.0]:
		Builder.rod(self, "fork_lower", Vector3(0, 0.04, 0), Vector3(side * 0.13, 0.17, 0), 0.04, wood)
		Builder.rod(self, "fork_tip", Vector3(side * 0.13, 0.17, 0), Vector3(side * 0.18, 0.32, 0), 0.035, wood)
		for index in range(3):
			Builder.rod(self, "green_wrap", Vector3(side * 0.175, 0.26 + index * 0.025, -0.005), Vector3(side * 0.175, 0.275 + index * 0.025, -0.005), 0.047, green)
		bands.append(Builder.rod(self, "elastic", Vector3(side * 0.18, 0.29, 0), Vector3(0, 0.24, 0.12), 0.014, green))
	pouch = Builder.oval(self, "pouch", Vector3(0, 0.24, 0.12), Vector3(0.12, 0.07, 0.07), leather)
	Builder.oval(self, "mango_badge", Vector3(0, 0.07, -0.046), Vector3(0.07, 0.09, 0.018), orange)
	var leaf := Builder.oval(self, "leaf_badge", Vector3(0.01, 0.09, -0.059), Vector3(0.025, 0.05, 0.01), green)
	leaf.rotation.z = -0.5

func kick() -> void:
	recoil = 1.0

func _process(delta: float) -> void:
	if third_person_pose:
		return
	_update_bands(delta)

func update_third_person(delta: float, aiming: bool) -> void:
	drawing = aiming
	_update_bands(delta)

func get_draw_point() -> Vector3:
	return pouch.global_position

func _update_bands(delta: float) -> void:
	recoil = move_toward(recoil, 0.0, delta * 6.0)
	if not third_person_pose:
		pouch.position.z = 0.12 - sin(recoil * PI) * 0.1
		for band in bands:
			band.scale.z = 1.0 - sin(recoil * PI) * 0.35
		return
	draw_amount = lerpf(draw_amount, 1.0 if drawing else 0.0, 1.0 - exp(-18.0 * delta))
	pouch.position = Vector3(-0.18 * draw_amount, 0.24, 0.12 + draw_amount * 0.12 - sin(recoil * PI) * 0.10)
	# Rebuild only transforms: fork anchors stay fixed, both bands meet the pouch.
	for index in range(bands.size()):
		var start := Vector3(-0.18 if index == 0 else 0.18, 0.29, 0)
		var end := pouch.position
		var axis := (end - start).normalized()
		var z_axis := Vector3.UP.cross(axis).normalized()
		var band := bands[index]
		var cylinder := band.mesh as CylinderMesh
		band.position = (start + end) * 0.5
		band.basis = Basis(axis.cross(z_axis), axis, z_axis)
		band.scale.y = start.distance_to(end) / cylinder.height
	$projectile_socket.position = pouch.position + Vector3(0, 0, -0.07)
