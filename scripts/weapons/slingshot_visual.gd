@tool
extends Node3D
## One prop with shared anchor geometry; FPS/TPS only change presentation.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
@export var third_person_pose: bool = false
var pouch: Node3D
var bands: Array[MeshInstance3D] = []
var recoil: float = 0.0
var drawing: bool = false
var draw_amount: float = 0.0
var fps_hands: Node3D
var damage_time: float = 0.0
var readiness: float = 1.0
@onready var loaded_ammo: Node3D = $pouch/loaded_ammo
@onready var pulling_glove: Node3D = $fps_hands/pulling_glove

func _ready() -> void:
	var wood := B.material(Color("a26735"))
	var grain := B.material(Color("744523"))
	var green := B.material(Color("64862c"))
	var leather := B.material(Color("70452b"))
	var stitch := B.material(Color("d1a363"))
	var metal := B.material(Color("ac9051"), 0.4)
	B.oval($frame, "rounded_handle", Vector3(0, -0.075, 0), Vector3(0.095, 0.31, 0.09), wood)
	B.oval($frame, "fork_joint", Vector3(0, 0.07, 0), Vector3(0.12, 0.15, 0.10), wood)
	for side in [-1.0, 1.0]:
		var points: Array[Vector3] = []
		for index in range(9):
			var t := index / 8.0
			points.append(Vector3(side * (0.18 * sin(t * PI * 0.5)), 0.065 + 0.26 * t, 0))
		B.swept_tube($frame, "wood_fork", points, 0.036, wood)
		B.tube($frame, "fork_grain", [Vector3(0, 0.065, -0.043), Vector3(side * 0.10, 0.12, -0.037), Vector3(side * 0.16, 0.21, -0.036), Vector3(side * 0.18, 0.32, -0.036)], 0.0025, grain)
		for index in range(3):
			B.rod($frame, "tip_wrap", Vector3(side * 0.178, 0.259 + index * 0.020, 0), Vector3(side * 0.18, 0.277 + index * 0.020, 0), 0.044, green)
		bands.append(B.rod($elastic, "elastic_band", Vector3(side * 0.18, 0.29, 0.023), Vector3(side * 0.044, 0.24, 0.12), 0.011, green))
	for index in range(3):
		B.rod($frame, "handle_binding", Vector3(0, -0.005 + index * 0.02, 0), Vector3(0, 0.012 + index * 0.02, 0), 0.052, green)
	B.rounded_box($frame, "leather_emblem", Vector3(0, 0.093, -0.051), Vector3(0.085, 0.11, 0.022), 0.010, leather)
	var badge := B.oval($frame, "leaf_badge", Vector3(0, 0.098, -0.068), Vector3(0.030, 0.063, 0.012), green)
	badge.rotation.z = -0.4
	for side in [-1.0, 1.0]:
		B.oval($frame, "emblem_rivet", Vector3(side * 0.026, 0.13, -0.069), Vector3.ONE * 0.009, metal)
	pouch = $pouch
	B.rounded_box(pouch, "leather_cradle", Vector3(0, -0.01, 0.005), Vector3(0.125, 0.065, 0.10), 0.025, leather)
	for side in [-1.0, 1.0]:
		B.rounded_box(pouch, "band_tab", Vector3(side * 0.047, 0, -0.007), Vector3(0.027, 0.050, 0.045), 0.012, leather)
		B.oval(pouch, "tab_rivet", Vector3(side * 0.047, 0, -0.033), Vector3.ONE * 0.013, metal)
		B.rod(pouch, "pouch_stitch", Vector3(side * 0.047, -0.027, -0.032), Vector3(side * 0.015, -0.027, -0.032), 0.003, stitch)
	fps_hands = $fps_hands
	var glove := B.material(Color("ffcf62"))
	B.rounded_box(fps_hands, "holding_glove", Vector3(0.016, -0.105, 0.028), Vector3(0.108, 0.137, 0.066), 0.023, glove)
	B.oval(fps_hands, "holding_thumb", Vector3(-0.034, -0.071, -0.003), Vector3(0.048, 0.077, 0.048), glove)
	B.rounded_box(fps_hands, "wrist", Vector3(0.020, -0.215, 0.042), Vector3(0.076, 0.122, 0.058), 0.019, glove)
	for index in range(3):
		B.oval(fps_hands, "gripping_finger", Vector3(0.007, -0.07 - index * 0.036, -0.034), Vector3(0.10, 0.040, 0.061), glove)
	B.oval(pulling_glove, "pulling_palm", Vector3(-0.064, 0.015, 0.025), Vector3(0.12, 0.13, 0.11), glove)
	B.oval(pulling_glove, "pulling_thumb", Vector3(-0.026, -0.026, -0.009), Vector3(0.060, 0.067, 0.070), glove)
	fps_hands.visible = not third_person_pose
	_update_bands(0.0)

func kick() -> void:
	recoil = 1.0

func update_presentation(delta: float, aiming: bool) -> void:
	drawing = aiming
	_update_bands(delta)

func set_readiness(remaining: float, interval: float) -> void:
	# Hide ammo for the first 70% of the existing cooldown, then seat it smoothly.
	readiness = clampf((0.30 - remaining / maxf(interval, 0.01)) / 0.30, 0.0, 1.0)
	loaded_ammo.visible = readiness > 0.0
	loaded_ammo.scale = Vector3.ONE * maxf(0.01, smoothstep(0.0, 1.0, readiness))

func damage_reaction() -> void:
	damage_time = 0.20

func get_draw_point() -> Vector3:
	return pouch.global_position

func _update_bands(delta: float) -> void:
	recoil = move_toward(recoil, 0.0, delta * 6.0)
	damage_time = maxf(0.0, damage_time - delta)
	if not third_person_pose:
		rotation = Vector3(-sin(recoil * PI) * 0.045, 0, sin(damage_time / 0.20 * PI) * 0.075)
	draw_amount = lerpf(draw_amount, 1.0 if drawing else 0.0, 1.0 - exp(-18.0 * delta))
	var draw := draw_amount
	pouch.position = Vector3(-0.18 * draw, 0.17, 0.12 + draw * 0.12 - sin(recoil * PI) * 0.14)
	# Both modes resolve endpoints every frame, including recoil.
	for index in range(bands.size()):
		var side := -1.0 if index == 0 else 1.0
		B.segment(bands[index], Vector3(side * 0.18, 0.29, 0.023), pouch.position + Vector3(side * 0.044, 0, -0.012))
		bands[index].scale.x = 1.7
	pulling_glove.position = fps_hands.to_local(pouch.global_position)
	# Keep the detached pulling-palm proxy out of both camera presentations.
	pulling_glove.hide()
	$projectile_socket.position = pouch.position + loaded_ammo.position
	$muzzle.position = $projectile_socket.position
