extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")
onready var initial_dispersion_amount = $LensDistortion.material.get_shader_param("dispersion")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor

func set_distortion(distort, dispersion):
	$LensDistortion.material.set_shader_param("distort", distort)
	$LensDistortion.material.set_shader_param("dispersion", dispersion)

