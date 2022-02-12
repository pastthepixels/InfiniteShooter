extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor
