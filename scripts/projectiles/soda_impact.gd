extends Node3D
const Build = preload("res://scripts/components/visual_mesh_builder.gd")
var age: float = 0.0
var bubbles: Array[MeshInstance3D] = []

func _ready() -> void:
	var mat := Build.material(Color("9cecff"))
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for index in range(6):
		bubbles.append(Build.oval(self, "fizz", Vector3.ZERO, Vector3.ONE * 0.08, mat))

func _process(delta: float) -> void:
	age += delta
	for index in range(bubbles.size()):
		var angle := index * TAU / 6.0
		bubbles[index].position = Vector3(cos(angle), sin(angle), cos(angle * 2.0)) * age * 1.5
		bubbles[index].scale = Vector3.ONE * maxf(0.005, 0.10 * (1.0 - age / 0.3))
	if age >= 0.3: queue_free()
