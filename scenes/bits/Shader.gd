extends ColorRect

onready var original_material = get_material()

var active = true

export(CanvasItemMaterial) var blank_material = CanvasItemMaterial.new()

func enable():
	active = true
	set_material(original_material)
	show()

func disable():
	active = false
	set_material(blank_material)
	hide()
