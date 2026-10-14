extends Node3D
## Fictional soda bottle launcher: blue chamber, silver collars, red nozzle.
const Build = preload("res://scripts/player/mango_mesh_builder.gd")
var kick_amount: float = 0.0

func _ready() -> void:
	var blue := Build.material(Color("127ce2"))
	var navy := Build.material(Color("183d85"))
	var red := Build.material(Color("e23752"))
	var silver := Build.material(Color("b3c9d0"))
	var white := Build.material(Color("eefaff"))
	Build.oval(self, "bottle_chamber", Vector3(0, 0, -0.12), Vector3(0.28, 0.28, 0.48), blue)
	Build.rod(self, "rear_collar", Vector3(0, 0, 0.06), Vector3(0, 0, 0.10), 0.16, silver)
	Build.rod(self, "front_collar", Vector3(0, 0, -0.31), Vector3(0, 0, -0.35), 0.13, silver)
	Build.rod(self, "red_nozzle", Vector3(0, 0, -0.36), Vector3(0, 0, -0.43), 0.11, red)
	for index in range(5):
		var angle := index * TAU / 5.0
		Build.oval(self, "nozzle_hole", Vector3(sin(angle) * 0.065, cos(angle) * 0.065, -0.47), Vector3(0.035, 0.035, 0.016), navy)
	Build.rod(self, "grip", Vector3(0, -0.03, 0), Vector3(0, -0.25, 0.05), 0.06, navy)
	Build.rod(self, "grip_wrap", Vector3(0, -0.12, 0.02), Vector3(0, -0.18, 0.04), 0.07, red)
	for side in [-1.0, 1.0]:
		for index in range(3):
			Build.oval(self, "bubble_decal", Vector3(side * 0.138, 0.04 - index * 0.045, -0.20 + index * 0.08), Vector3(0.015, 0.055, 0.055), white)

func kick() -> void:
	kick_amount = 0.08

func _process(delta: float) -> void:
	kick_amount = move_toward(kick_amount, 0.0, delta * 0.5)
	position.z = kick_amount
