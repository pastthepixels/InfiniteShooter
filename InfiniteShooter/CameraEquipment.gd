extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor

func _process(_delta):
	if OS.window_fullscreen == true:
		pass#$LensDistortion.material.set_shader_param("distort", -0.001)
	elif $LensDistortion.material.get_shader_param("distort") == 0:
		pass#$LensDistortion.material.set_shader_param("distort", initial_warp_amount)
