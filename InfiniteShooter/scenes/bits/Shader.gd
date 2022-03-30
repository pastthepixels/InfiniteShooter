extends ColorRect

onready var original_material = get_material()

export(CanvasItemMaterial) var blank_material = CanvasItemMaterial.new()

func enable():
	set_material(original_material)
	show()

func disable():
	set_material(blank_material)
	hide()
