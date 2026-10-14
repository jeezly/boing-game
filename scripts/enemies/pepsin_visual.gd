extends Node3D
## Articulated, reference-led duende with a pale face and two drooping jester lobes.

const Build = preload("res://scripts/player/mango_mesh_builder.gd")
const BlasterScene = preload("res://scenes/weapons/soda_blaster_visual.tscn")
const Blaster = preload("res://scripts/weapons/soda_blaster_visual.gd")
var legs: Array[Node3D] = []
var arms: Array[Node3D] = []
var weapon_mount: Node3D
var blaster: Blaster
var meshes: Array[MeshInstance3D] = []
var original_materials: Array[Material] = []
var flash_material: StandardMaterial3D
var hit_time: float = 0.0
var phase: float = 0.0

func _ready() -> void:
	var blue := Build.material(Color("1475d8"))
	var navy := Build.material(Color("183978"))
	var red := Build.material(Color("e32d4e"))
	var white := Build.material(Color("f4f0e8"))
	var silver := Build.material(Color("b7c8cf"))
	var pink := Build.material(Color("e9b8b9"))
	var dark := Build.material(Color("182b39"))
	var lens := Build.material(Color("41c3fa"))
	lens.roughness = 0.2
	flash_material = Build.material(Color("fff4b4"))
	flash_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	Build.oval(self, "blue_jacket", Vector3(0, 0.70, 0), Vector3(0.60, 0.60, 0.42), blue)
	Build.oval(self, "white_chest_panel", Vector3(0, 0.68, -0.20), Vector3(0.43, 0.22, 0.055), white)
	Build.rod(self, "red_hem", Vector3(-0.24, 0.47, -0.14), Vector3(0.24, 0.47, -0.14), 0.04, red)
	Build.rod(self, "zipper", Vector3(0, 0.48, -0.225), Vector3(0, 0.91, -0.225), 0.014, silver)
	Build.oval(self, "face", Vector3(0, 1.11, -0.015), Vector3(0.62, 0.49, 0.49), white)
	Build.oval(self, "cap_base", Vector3(0, 1.37, 0.04), Vector3(0.71, 0.27, 0.53), navy)
	Build.rod(self, "red_collar", Vector3(-0.22, 0.93, 0), Vector3(0.22, 0.93, 0), 0.07, red)
	for side in [-1.0, 1.0]:
		var cap_mat: Material = blue if side < 0.0 else red
		var lobe := Build.oval(self, "jester_lobe", Vector3(side * 0.26, 1.55, 0.08), Vector3(0.39, 0.48, 0.39), cap_mat)
		lobe.rotation.z = side * 0.50
		var droop := Build.oval(self, "cap_droop", Vector3(side * 0.47, 1.39, 0.07), Vector3(0.19, 0.45, 0.21), cap_mat)
		droop.rotation.z = side * -0.2
		Build.oval(self, "silver_bell", Vector3(side * 0.50, 1.12, 0.06), Vector3(0.16, 0.16, 0.16), silver)
		for index in range(3):
			Build.oval(self, "cap_bubble", Vector3(side * (0.22 + index * 0.065), 1.65 - index * 0.08, -0.10), Vector3(0.06, 0.06, 0.025), white)
		var ear := MeshInstance3D.new()
		ear.name = "pointed_ear"
		var cone := CylinderMesh.new()
		cone.top_radius = 0.0
		cone.bottom_radius = 0.13
		cone.height = 0.36
		cone.radial_segments = 8
		ear.mesh = cone
		ear.material_override = pink
		add_child(ear)
		ear.position = Vector3(side * 0.38, 1.11, -0.01)
		ear.rotation.z = side * -1.05
		Build.oval(self, "eye_white", Vector3(side * 0.135, 1.13, -0.247), Vector3(0.20, 0.22, 0.075), white)
		Build.oval(self, "pupil", Vector3(side * 0.135, 1.13, -0.285), Vector3(0.10, 0.12, 0.04), dark)
		Build.oval(self, "eye_glint", Vector3(side * 0.135 - 0.018, 1.16, -0.309), Vector3(0.025, 0.027, 0.012), white)
		var brow := Build.oval(self, "mischievous_brow", Vector3(side * 0.14, 1.28, -0.25), Vector3(0.22, 0.045, 0.065), navy)
		brow.rotation.z = side * 0.22
		Build.oval(self, "goggle_frame", Vector3(side * 0.16, 1.40, -0.23), Vector3(0.35, 0.23, 0.095), silver)
		Build.oval(self, "goggle_glass", Vector3(side * 0.16, 1.40, -0.285), Vector3(0.28, 0.17, 0.035), lens)
		var leg := _pivot("leg", Vector3(side * 0.16, 0.47, 0))
		legs.append(leg)
		Build.rod(leg, "blue_shin", Vector3.ZERO, Vector3(0, -0.24, 0), 0.065, navy)
		Build.rod(leg, "red_sock", Vector3(0, -0.12, 0), Vector3(0, -0.18, 0), 0.08, red)
		Build.oval(leg, "sport_boot", Vector3(0, -0.33, -0.065), Vector3(0.30, 0.27, 0.40), blue)
		Build.oval(leg, "red_toe", Vector3(0, -0.31, -0.19), Vector3(0.29, 0.18, 0.16), red)
		Build.oval(leg, "boot_sole", Vector3(0, -0.43, -0.065), Vector3(0.32, 0.065, 0.43), navy)
		Build.rod(leg, "white_stripe", Vector3(-0.13, -0.26, -0.11), Vector3(0.13, -0.26, -0.11), 0.024, white)
		var arm := _pivot("arm", Vector3(side * 0.31, 0.86, 0))
		arms.append(arm)
		Build.rod(arm, "sleeve", Vector3.ZERO, Vector3(0, -0.13, -0.15), 0.085, blue)
		Build.rod(arm, "red_cuff", Vector3(0, -0.13, -0.15), Vector3(0, -0.15, -0.20), 0.09, red)
		Build.oval(arm, "white_glove", Vector3(0, -0.13, -0.26), Vector3(0.18, 0.18, 0.18), white)
	Build.oval(self, "button_nose", Vector3(0, 1.06, -0.27), Vector3(0.11, 0.08, 0.10), pink)
	var grin := Build.oval(self, "cheeky_grin", Vector3(0.025, 0.985, -0.23), Vector3(0.23, 0.06, 0.05), dark)
	grin.rotation.z = -0.13
	Build.oval(self, "grin_teeth", Vector3(0.03, 1.001, -0.258), Vector3(0.17, 0.02, 0.014), white)
	weapon_mount = _pivot("weapon_mount", Vector3(0.31, 0.78, -0.27))
	blaster = BlasterScene.instantiate() as Blaster
	weapon_mount.add_child(blaster)
	_collect_meshes(self)

func _pivot(part_name: String, at: Vector3) -> Node3D:
	var node := Node3D.new()
	node.name = part_name
	add_child(node)
	node.position = at
	return node

func _collect_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			meshes.append(child)
			original_materials.append(child.material_override)
		_collect_meshes(child)

func hit_flash() -> void:
	hit_time = 0.13
	for mesh in meshes: mesh.material_override = flash_material

func present(delta: float, speed: float, target: Vector3, winding_up: bool) -> void:
	phase += delta * (5.0 + speed * 2.8)
	if hit_time > 0.0:
		hit_time = maxf(0.0, hit_time - delta)
		if hit_time == 0.0:
			for index in range(meshes.size()): meshes[index].material_override = original_materials[index]
	legs[0].rotation.x = sin(phase) * minf(speed * 0.12, 0.50)
	legs[1].rotation.x = -legs[0].rotation.x
	position.y = absf(sin(phase)) * minf(speed * 0.012, 0.035)
	var direction := to_local(target) - weapon_mount.position
	weapon_mount.rotation.x = clampf(atan2(direction.y, Vector2(direction.x, direction.z).length()), -0.35, 0.35)
	arms[1].rotation.x = weapon_mount.rotation.x
	arms[0].rotation.x = -0.25 if winding_up else sin(phase) * 0.12
	if winding_up: blaster.scale = Vector3.ONE * 1.05
	else: blaster.scale = Vector3.ONE

func muzzle_position() -> Vector3:
	var socket := blaster.get_node("projectile_socket") as Marker3D
	return socket.global_position

func fire_reaction() -> void:
	blaster.kick()
