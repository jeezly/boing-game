@tool
extends Node3D
## Art-directed finishes tied to existing architecture. No additional movement collision.
const B = preload("res://scripts/components/visual_mesh_builder.gd")
const Build = preload("res://scripts/environment/la_abarrotera/store_builder.gd")
const Batch = preload("res://scripts/components/visual_batcher.gd")
func _ready() -> void:
	_checkout_finish()
	_architectural_finish()
	_loading_finish()
	Batch.merge_children(self,"professional_store_finishes")
func board(text: String, at: Vector3, size: Vector2, color: String, yaw: float = 0.0) -> void:
	var holder := Node3D.new()
	holder.name = "sign_" + str(get_child_count())
	add_child(holder)
	holder.position = at
	holder.rotation.y = yaw
	Build.box(holder,Vector3.ZERO,Vector3(size.x+0.12,size.y+0.12,0.09),Build.mat("d9ad64"),"frame")
	Build.box(holder,Vector3(0,0,0.055),Vector3(size.x,size.y,0.025),Build.mat(color),"enamel")
	var label := Build.label(holder,text,Vector3(0,0,0.08),48,Color("fff0cf"))
	label.pixel_size = minf(size.x / maxf(text.length()*28,1),0.011)
	label.outline_size = 0
	label.double_sided = false
	Batch.merge_children(holder,"finish_sign_"+text)
func _checkout_finish() -> void:
	for x in [-32.0,-20.0,-8.0,8.0,20.0,32.0]:
		# Protective kick plates, belt rollers, bagging hooks and scanner bezels.
		Build.box(self,Vector3(x,0.14,-8),Vector3(4.22,0.20,6.02),Build.mat("24463f"),"checkout_kickplate")
		for side in [-1,1]:
			Build.box(self,Vector3(x+side*2.08,0.62,-8),Vector3(0.06,0.74,5.8),Build.mat("af4438"),"counter_recess")
		for z in [-9.65,-6.35]:
			B.rod(self,"belt_roller",Vector3(x-1.2,1.155,z),Vector3(x+1.2,1.155,z),0.06,Build.mat("a6b1ac"))
		Build.box(self,Vector3(x+0.8,1.18,-6.7),Vector3(0.62,0.04,0.48),Build.mat("283c3b"),"scanner_frame")
		Build.box(self,Vector3(x+0.8,1.207,-6.7),Vector3(0.43,0.012,0.31),Build.mat("68bcb2",0.2),"scanner_glass")
		Build.box(self,Vector3(x+0.8,1.218,-6.7),Vector3(0.38,0.01,0.018),Build.mat("f36e54",0.4),"scanner_line")
		for side in [-1,1]:
			Build.box(self,Vector3(x+1.6,1.21,-5.6+side*0.24),Vector3(0.40,0.035,0.035),Build.mat("8d9a94"),"bag_rack")
		Build.box(self,Vector3(x+1.6,0.97,-5.6),Vector3(0.30,0.40,0.40),Build.mat("dfcba1"),"paper_bag")
	board("GRACIAS POR COMPRAR LOCAL",Vector3(0,8.2,-0.64),Vector2(18,1.3),"9e3d32",PI)
	board("PAGO EN EFECTIVO  /  TARJETA",Vector3(-45,4.0,-0.67),Vector2(10,0.9),"315f56",PI)
func _architectural_finish() -> void:
	# Pilasters and wainscot follow the shell instead of filling the fighting space.
	for side in [-1,1]:
		for z in [-15.0,-37.0,-59.0,-81.0]:
			Build.box(self,Vector3(side*74.3,3.4,z),Vector3(0.45,6.8,0.75),Build.mat("d1c2a0"),"wall_pilaster")
			Build.box(self,Vector3(side*74.1,0.34,z),Vector3(0.66,0.68,0.96),Build.mat("315c50"),"pilaster_plinth")
		for y in [0.18,2.25,6.8]:
			Build.box(self,Vector3(side*74.3,y,-47),Vector3(0.12,0.12,92),Build.mat("b87039" if y>2 else "316655"),"wall_trim")
	# Clerestory panels break the vast rear wall into a designed industrial rhythm.
	for x in [-60.0,-40.0,-20.0,0.0,20.0,40.0,60.0]:
		Build.box(self,Vector3(x,10.8,-94.3),Vector3(12.1,2.15,0.16),Build.mat("325d59"),"clerestory_frame")
		Build.box(self,Vector3(x,10.8,-94.18),Vector3(11.8,1.9,0.04),Build.mat("9cc5c2",0.12),"clerestory_glazing")
		for offset in [-4.0,-2.0,0.0,2.0,4.0]:
			Build.box(self,Vector3(x+offset,10.8,-94.13),Vector3(0.065,1.95,0.05),Build.mat("3c6660"),"window_mullion")
	for z in [-18.0,-42.0,-62.0]:
		for x in [-48.0,-24.0,0.0,24.0,48.0]:
			# Visible twin fluorescent tubes and end sockets on the existing truss grid.
			Build.box(self,Vector3(x,12.6,z),Vector3(4.8,0.16,0.70),Build.mat("3e5855"),"luminaire_housing")
			for side in [-1,1]:
				B.rod(self,"fluorescent_tube",Vector3(x-2.2,12.48,z+side*0.2),Vector3(x+2.2,12.48,z+side*0.2),0.055,Build.mat("fff2d7",0.7))
			for offset in [-2.0,2.0]: B.rod(self,"lamp_hanger",Vector3(x+offset,12.7,z),Vector3(x+offset,14.5,z),0.018,Build.mat("495b54"))
	board("EL SABOR DE NUESTRO BARRIO",Vector3(50,6.3,-94.0),Vector2(23,1.7),"9c4c2c")
	board("RETORNABLES  /  BIEN FRIOS",Vector3(-74,5.2,-40),Vector2(16,1.3),"286d85",PI*0.5)
	board("MAYOREO  /  MENUDEO",Vector3(0,6.5,-94.0),Vector2(18,1.4),"305f53")
func _loading_finish() -> void:
	# Stair stringers and handrails respect the two existing ramps, top at y=2.8.
	for x in [-16.0,16.0]:
		for side in [-1,1]:
			var edge: float = x+side*1.92
			B.rod(self,"ramp_handrail",Vector3(edge,1.05,-72.6),Vector3(edge,3.75,-83.5),0.045,Build.mat("e1a736"))
			B.rod(self,"ramp_lower_rail",Vector3(edge,0.50,-72.6),Vector3(edge,3.20,-83.5),0.032,Build.mat("e1a736"))
			for i in range(5):
				var z := -72.6-i*2.72
				var y := i*0.675
				B.rod(self,"ramp_baluster",Vector3(edge,y+0.05,z),Vector3(edge,y+1.05,z),0.033,Build.mat("d29a32"))
	board("RUTA ALTA  /  ACCESO A BODEGA",Vector3(0,4.7,-83.0),Vector2(14,0.85),"315e52")
	for x in [-16.0,16.0]:
		Build.box(self,Vector3(x,2.62,-84.9),Vector3(4.0,0.30,0.12),Build.mat("dda639"),"landing_safety_nosing")
