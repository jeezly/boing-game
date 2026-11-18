@tool
extends Node3D
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
func _ready() -> void:
	# Head touches the floor; continuous handle meets its socket at the head.
	Build.box(self,Vector3(0,0.15,0),Vector3(0.46,0.10,0.17),Build.mat("684a30"),"broom_binding")
	for i in range(15):
		B.rod(self,"natural_bristle",Vector3(-0.22+i*0.031,0.15,0),Vector3(-0.24+i*0.034,0.025,0.015),0.016,Build.mat("c6ab56"))
	B.rod(self,"wood_handle",Vector3(0,0.18,0),Vector3(0.20,1.85,0),0.022,Build.mat("ae7b44"))
	B.rod(self,"grip",Vector3(0.18,1.65,0),Vector3(0.20,1.86,0),0.028,Build.mat("3f6653"))
	preload("res://scripts/components/visual_batcher.gd").merge_children(self,"maintenance_broom")
