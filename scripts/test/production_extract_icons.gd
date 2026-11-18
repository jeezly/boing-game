extends SceneTree
## Opt-in derivative extraction from approved sheets; runtime never loads design boards.
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute("res://assets/ui")
	var image := Image.load_from_file("res://docs/references/production2/hud/weapon_selector_master.png")
	var regions := [Rect2i(788, 37, 91, 92), Rect2i(893, 44, 87, 88), Rect2i(986, 41, 86, 93), Rect2i(1080, 42, 85, 91), Rect2i(1174, 40, 75, 94)]
	for i in range(5): image.get_region(regions[i]).save_png("res://assets/ui/weapon_%d.png" % i)
	var mango := Image.load_from_file("res://docs/references/mango/mango_sheet_final.jpg")
	print("MANGO_IMAGE_SIZE ", mango.get_size())
	mango.get_region(Rect2i(1018, 1125, 245, 210)).save_png("res://assets/ui/mango_portrait.png")
	quit()
