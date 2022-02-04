extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("warp_amount")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor

func _process(_delta):
	if OS.window_fullscreen == true:
		$LensDistortion.material.set_shader_param("warp_amount", -0.001)
	elif $LensDistortion.material.get_shader_param("warp_amount") == 0:
		$LensDistortion.material.set_shader_param("warp_amount", initial_warp_amount)
