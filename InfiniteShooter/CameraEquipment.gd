extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")
onready var initial_dispersion_amount = $LensDistortion.material.get_shader_param("dispersion")

export(Array, PanoramaSky) var skies
var _old_sky_num = 0


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor

#
# distortion stuff
#
func set_distortion(distort, dispersion):
	$LensDistortion.material.set_shader_param("distort", distort)
	$LensDistortion.material.set_shader_param("dispersion", dispersion)

#
# sky stuff
#
func set_sky(sky_idx):
	_old_sky_num = sky_idx
	$WorldEnvironment.environment.background_sky = skies[sky_idx]

func set_rand_sky():
	set_sky(generate_rand_sky_num())

func generate_rand_sky_num():
	var new_sky_num = rand_range(0, len(skies))
	if _old_sky_num == new_sky_num:
		return generate_rand_sky_num()
	_old_sky_num = new_sky_num
	return new_sky_num

#
# _process()
#
func _process(delta):
	if Input.is_action_pressed("move_right"): 
		$ShakeCamera.additional_offset.x = lerp($ShakeCamera.additional_offset.x, 3, 0.4)

	if Input.is_action_pressed("move_left"): 
		$ShakeCamera.additional_offset.x = lerp($ShakeCamera.additional_offset.x, -3, 0.4)

	if Input.is_action_pressed("move_down"):
		$ShakeCamera.additional_offset.y = lerp($ShakeCamera.additional_offset.y, 3, 0.4)

	if Input.is_action_pressed("move_up"):
		$ShakeCamera.additional_offset.y = lerp($ShakeCamera.additional_offset.y, -3, 0.4)

	if Input.is_action_pressed("move_right") == false and\
		Input.is_action_pressed("move_left") == false and\
		Input.is_action_pressed("move_down") == false and\
		Input.is_action_pressed("move_up") == false:
		$ShakeCamera.additional_offset = lerp($ShakeCamera.additional_offset, Vector2(), 0.4)
