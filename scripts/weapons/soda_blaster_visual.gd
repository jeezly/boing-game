@tool
extends Node3D
## Existing soda weapon: coherent chamber, nozzle, hardware and anchored grip.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Batcher = preload("res://scripts/components/visual_batcher.gd")
const S = preload("res://scripts/components/presentation_shapes.gd")
var kick_amount: float = 0.0
var flash_time: float = 0.0
var anticipating: bool = false
@onready var barrel: Node3D = $barrel
@onready var emission: Node3D = $barrel/emission

func _ready() -> void:
	var blue := B.material(Color("087be5"), 0.22)
	blue.metallic = 0.12
	var navy := B.material(Color("173775"))
	var red := B.material(Color("e82d4b"), 0.45)
	var silver := B.material(Color("bcced9"), 0.23)
	silver.metallic = 0.70
	var white := B.material(Color("bdefff"), 0.30)
	B.rod(barrel, "soda_chamber", Vector3(0, 0, 0.015), Vector3(0, 0, -0.31), 0.135, blue)
	B.oval(barrel, "bottle_shoulder", Vector3(0, 0, -0.30), Vector3(0.265, 0.265, 0.13), blue)
	B.rod(barrel, "rear_collar", Vector3(0, 0, 0.015), Vector3(0, 0, 0.055), 0.153, silver)
	B.rod(barrel, "front_collar", Vector3(0, 0, -0.30), Vector3(0, 0, -0.335), 0.148, silver)
	B.rod(barrel, "red_nozzle", Vector3(0, 0, -0.346), Vector3(0, 0, -0.455), 0.105, red)
	B.rod(barrel, "nozzle_seal", Vector3(0, 0, -0.334), Vector3(0, 0, -0.355), 0.112, silver)
	for index in range(6):
		var angle := index * TAU / 6.0
		B.oval(barrel, "nozzle_port", Vector3(sin(angle) * 0.058, cos(angle) * 0.058, -0.457), Vector3(0.033, 0.033, 0.008), navy)
	B.oval(barrel, "center_port", Vector3(0, 0, -0.458), Vector3(0.029, 0.029, 0.008), navy)
	for index in range(10):
		var angle := index * TAU / 10.0
		B.rod(barrel, "cap_rib", Vector3(sin(angle) * 0.106, cos(angle) * 0.106, -0.36), Vector3(sin(angle) * 0.106, cos(angle) * 0.106, -0.439), 0.006, red)
	B.rod(barrel, "rear_canister", Vector3(0, 0, 0.05), Vector3(0, 0, 0.16), 0.12, navy)
	B.rod(barrel, "rear_red_band", Vector3(0, 0, 0.09), Vector3(0, 0, 0.125), 0.125, red)
	for side in [-1.0, 1.0]:
		for index in range(3):
			var ring := S.ring(barrel, "bubble_mark", Vector3(side * 0.137, 0.015, -0.07 - index * 0.087), 0.026 + index * 0.006, white)
			ring.rotation = Vector3(0, PI * 0.5, 0)
		B.tube($hardware, "silver_rail", [Vector3(side * 0.12, -0.04, 0.03), Vector3(side * 0.12, -0.16, -0.02), Vector3(side * 0.12, -0.15, -0.28), Vector3(side * 0.12, -0.05, -0.30)], 0.012, silver)
		B.oval(barrel, "collar_rivet", Vector3(side * 0.15, 0, -0.319), Vector3.ONE * 0.022, silver)
	B.rod($hardware, "grip", Vector3(0, -0.055, 0.025), Vector3(0, -0.25, 0.08), 0.052, navy)
	for index in range(3):
		B.rod($hardware, "red_grip_wrap", Vector3(0, -0.11 - index * 0.045, 0.041 + index * 0.013), Vector3(0, -0.133 - index * 0.045, 0.048 + index * 0.013), 0.057, red)
	B.tube($hardware, "trigger_guard", [Vector3(0, -0.08, 0.008), Vector3(0, -0.09, -0.077), Vector3(0, -0.165, -0.083), Vector3(0, -0.19, 0.055)], 0.010, silver)
	B.rod($hardware, "trigger", Vector3(0, -0.092, -0.025), Vector3(0, -0.13, -0.04), 0.009, red)
	B.rod($hardware, "support_grip", Vector3(-0.085, -0.11, -0.18), Vector3(0.085, -0.11, -0.18), 0.038, navy)
	var glow := B.material(Color("85e3ff"), 0.2)
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for index in range(3):
		var bubble := B.oval(emission, "emission_bubble", Vector3((index - 1) * 0.024, index * 0.011, -index * 0.025), Vector3.ONE * (0.034 - index * 0.005), glow)
		bubble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	emission.hide()
	Batcher.merge_children(barrel, "pepsin_blaster_barrel")
	Batcher.merge_children($hardware, "pepsin_blaster_hardware")

func set_anticipation(value: bool) -> void:
	anticipating = value

func kick() -> void:
	kick_amount = 0.048
	flash_time = 0.10
	emission.show()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	kick_amount = move_toward(kick_amount, 0.0, delta * 0.35)
	flash_time = maxf(0.0, flash_time - delta)
	# Only the sliding chamber recoils; hands remain attached to stationary grips.
	barrel.position.z = kick_amount
	barrel.rotation.z = sin(Time.get_ticks_msec() * 0.035) * 0.006 if anticipating else 0.0
	emission.visible = flash_time > 0.0
	emission.scale = Vector3.ONE * (1.0 + (0.10 - flash_time) * 7.0)
