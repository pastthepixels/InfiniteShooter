extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")
onready var initial_dispersion_amount = $LensDistortion.material.get_shader_param("dispersion")

export(Array, PanoramaSky) var skies
var _old_sky_num = 0


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor

func set_distortion(distort, dispersion):
	$LensDistortion.material.set_shader_param("distort", distort)
	$LensDistortion.material.set_shader_param("dispersion", dispersion)

func set_sky(sky_idx):
	$WorldEnvironment.environment.background_sky = skies[sky_idx]

func set_rand_sky():
	set_sky(generate_rand_sky_num())

func generate_rand_sky_num():
	var new_sky_num = rand_range(0, len(skies))
	if _old_sky_num == new_sky_num:
		return generate_rand_sky_num()
	_old_sky_num = new_sky_num
	return new_sky_num

