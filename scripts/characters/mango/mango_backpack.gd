@tool
extends Node3D
## Local +Z is Mango's back.
const B = preload("res://scripts/components/visual_mesh_builder.gd")

const Shapes = preload("res://scripts/components/presentation_shapes.gd")

func _ready() -> void:
	var leather := B.material(Color("583a28"))
	var edge := B.material(Color("9d6b3d"))
	var thread := B.material(Color("d3a868"))
	var brass := B.material(Color("b6944d"), 0.4)
	var green := B.material(Color("58812d"))
	B.rounded_box(self, "pack_body", Vector3(0, 1.075, 0.40), Vector3(0.53, 0.57, 0.27), 0.07, leather)
	B.rounded_box(self, "flap_border", Vector3(0, 1.20, 0.546), Vector3(0.44, 0.32, 0.047), 0.022, edge)
	B.rounded_box(self, "leather_flap", Vector3(0, 1.205, 0.565), Vector3(0.405, 0.28, 0.025), 0.012, leather)
	B.rounded_box(self, "closure_strap", Vector3(0, 0.98, 0.558), Vector3(0.06, 0.26, 0.027), 0.012, edge)
	B.rounded_box(self, "buckle_frame", Vector3(0, 0.96, 0.579), Vector3(0.081, 0.075, 0.018), 0.008, brass)
	B.rounded_box(self, "buckle_center", Vector3(0, 0.96, 0.590), Vector3(0.049, 0.044, 0.009), 0.004, leather)
	B.rod(self, "buckle_pin", Vector3(0, 0.94, 0.600), Vector3(0, 0.98, 0.600), 0.004, brass)
	B.oval(self, "badge_backing", Vector3(0, 1.21, 0.586), Vector3(0.20, 0.20, 0.021), B.material(Color("e7b742")))
	var leaf := B.oval(self, "leaf_badge", Vector3(0, 1.21, 0.600), Vector3(0.084, 0.15, 0.015), green)
	leaf.rotation.z = -0.45
	B.rod(self, "leaf_vein", Vector3(-0.025, 1.15, 0.611), Vector3(0.027, 1.26, 0.611), 0.004, thread)
	for side in [-1.0, 1.0]:
		var points: Array[Vector3] = [Vector3(side * 0.19, 1.34, 0.37), Vector3(side * 0.28, 1.47, 0.16), Vector3(side * 0.30, 1.47, -0.075), Vector3(side * 0.31, 1.31, -0.255), Vector3(side * 0.37, 1.12, -0.23), Vector3(side * 0.38, 0.96, 0.04), Vector3(side * 0.21, 0.86, 0.37)]
		Shapes.ribbon(self, "shoulder_strap", points, 0.065, leather)
		B.tube(self, "strap_stitch", [Vector3(side * 0.307, 1.43, -0.12), Vector3(side * 0.323, 1.30, -0.264), Vector3(side * 0.382, 1.13, -0.238)], 0.004, thread)
		B.rounded_box(self, "side_pocket", Vector3(side * 0.263, 1.05, 0.408), Vector3(0.08, 0.28, 0.18), 0.035, edge)
	for index in range(11):
		B.rod(self, "flap_stitch", Vector3(-0.17 + index * 0.034, 1.095, 0.584), Vector3(-0.155 + index * 0.034, 1.095, 0.584), 0.003, thread)
	B.tube(self, "carry_loop", [Vector3(-0.065, 1.35, 0.40), Vector3(-0.06, 1.40, 0.40), Vector3(0.06, 1.40, 0.40), Vector3(0.065, 1.35, 0.40)], 0.014, leather)
