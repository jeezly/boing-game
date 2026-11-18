@tool
extends RefCounted
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const Batch = preload("res://scripts/components/visual_batcher.gd")
static var corn: ShaderMaterial
static var grain_mesh: SphereMesh
static func produce(root: Node3D) -> void:
	var table := root.get_parent()
	var column := int(String(table.name).split("_")[1]) if String(table.name).begins_with("produce_") else 0
	var rear := String(table.name).ends_with("_1")
	var kind := column + (3 if rear else 0)
	for child in table.get_children():
		if String(child.name).begins_with("produce_") and child is MeshInstance3D: child.hide()
	var names := ["MANGO ATAULFO", "LIMON CON SEMILLA", "ELOTE TIERNO", "JITOMATE SALADET", "SANDIA DULCE", "CHILE POBLANO"]
	var prices := ["$29 / KG", "$24 / KG", "$8 / PIEZA", "$19 / KG", "$15 / KG", "$32 / KG"]
	var display := Node3D.new()
	display.name = "fresh_" + str(kind)
	root.add_child(display)
	for x in [-1.9,0.0,1.9]:
		Build.box(display,Vector3(x,1.28,0),Vector3(0.07,0.30,4.88),Build.mat("735134"),"bin_divider")
	for z in [-2.45,0.0,2.45]:
		Build.box(display,Vector3(0,1.28,z),Vector3(3.85,0.30,0.07),Build.mat("ad7b45"),"crate_partition")
	var count_x := 5 if kind == 4 else 7
	var count_z := 6 if kind == 4 else 9
	for row in range(count_z):
		for col in range(count_x):
			var at := Vector3(-1.65 + col * 3.3 / (count_x-1),1.35,-2.12 + row * 4.2 / (count_z-1))
			at += Vector3(sin(row*17+col)*0.04,cos(col*4+row)*0.025,cos(row+col*3)*0.04)
			var color: String = ["ffbf30","8bb837","efc54e","dc4e35","3d8346","427b31"][kind]
			var size: Vector3 = [Vector3(0.38,0.34,0.57),Vector3(0.32,0.30,0.33),Vector3(0.24,0.24,0.72),Vector3(0.34,0.28,0.46),Vector3(0.58,0.53,0.72),Vector3(0.24,0.20,0.54)][kind]
			var fruit: MeshInstance3D
			if kind == 2:
				if corn == null:
					corn = ShaderMaterial.new()
					corn.shader = load("res://resources/environment/corn_kernels.gdshader")
				fruit = B.oval(display,"golden_cob",at,size,corn)
				for side in [-1,1]:
					var husk := B.oval(display,"folded_husk",at+Vector3(side*0.10,-0.04,0.15),Vector3(0.08,0.10,0.56),Build.mat("568748"))
					husk.rotation.y = side*0.3
			elif kind == 4:
				fruit = B.oval(display,"watermelon",at,size,Build.mat(color))
				for stripe in [-0.12,0.0,0.12]:
					B.oval(display,"melon_stripe",at+Vector3(stripe,0.20,0),Vector3(0.035,0.12,0.54),Build.mat("74a64a"))
			else:
				fruit = B.oval(display,"fresh_fruit",at,size,Build.mat(color))
			fruit.rotation.y = sin(row*4+col)*0.35
			B.rod(display,"fruit_stem",at+Vector3(0,0.12,0),at+Vector3(0.025,0.21,0.015),0.014,Build.mat("496333"))
			if kind in [0,3,5]: B.oval(display,"leaf",at+Vector3(0.06,0.18,0),Vector3(0.13,0.025,0.06),Build.mat("45814a"))
	Build.box(display,Vector3(0,1.5,2.58),Vector3(2.6,0.61,0.05),Build.mat("244c3c"),"chalk_price_card")
	var label := Build.label(display,names[kind]+"\n"+prices[kind],Vector3(0,1.5,2.62),30,Color("fff0cd"))
	label.pixel_size = 0.0034
	label.outline_size = 0
	label.visibility_range_end = 28
	Batch.merge_children(display,"fresh_goods_%d" % kind)
	if not Engine.is_editor_hint(): display.get_node("cached_static_visual").cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

static func grain(root: Node3D) -> void:
	# Two open sacks, rolled cloth lips, visible beans/maize and scoops.
	if grain_mesh == null:
		grain_mesh = SphereMesh.new()
		grain_mesh.radius = 0.5
		grain_mesh.height = 1.0
		grain_mesh.radial_segments = 8
		grain_mesh.rings = 4
	var detail := Node3D.new()
	detail.name = "open_grain"
	root.add_child(detail)
	for side in [-1,1]:
		var center := Vector3(side*0.53,1.10,0.53)
		var rim := TorusMesh.new()
		rim.inner_radius = 0.32
		rim.outer_radius = 0.43
		rim.rings = 24
		rim.ring_segments = 8
		B.mesh_part(detail,"rolled_jute_lip",center,Vector3(1,0.65,1),rim,Build.mat("cab087"))
		B.oval(detail,"grain_heap",center,Vector3(0.69,0.17,0.69),Build.mat("dfb453" if side == 1 else "79513e"))
		for i in range(75):
			var angle := i*2.39996
			var radius := sqrt(float(i)/75)*0.31
			var at := center+Vector3(cos(angle)*radius,0.07+0.035*(1-radius/0.31),sin(angle)*radius)
			var bean := B.mesh_part(detail,"maize" if side == 1 else "bean",at,Vector3(0.049,0.030,0.065),grain_mesh,Build.mat("f0c55f" if side == 1 else "aa7556"))
			bean.rotation.y = angle
		B.rod(detail,"scoop_handle",center+Vector3(0.1,0.09,0),center+Vector3(0.28,0.27,0.1),0.025,Build.mat("a8b5b1"))
		B.oval(detail,"scoop_bowl",center+Vector3(0.1,0.10,0),Vector3(0.18,0.035,0.23),Build.mat("b5c0ba"))
	Batch.merge_children(detail,"open_grain")
	if not Engine.is_editor_hint(): detail.get_node("cached_static_visual").cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
