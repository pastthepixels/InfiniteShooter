extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")
onready var initial_dispersion_amount = $LensDistortion.material.get_shader_param("dispersion")
var _animate_warp_dispersion = false
onready var _animate_warp_amount = 0
onready var _animate_dispersion_amount = 0

export(Array, PanoramaSky) var skies


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor

#
# distortion stuff
#
func set_distortion(distort, dispersion):
	if $LensDistortion.visible:
		$LensDistortion.material.set_shader_param("distort", distort)
		$LensDistortion.material.set_shader_param("dispersion", dispersion)

func set_animated_distortion(distort, dispersion):
	_animate_warp_dispersion = true
	_animate_warp_amount = distort
	_animate_dispersion_amount = dispersion

#
# sky stuff
#
func slow_sky():
	$Tween.interpolate_property(
		$SkyAnimations,
		"playback_speed",
		1,
		0,
		3,
		Tween.TRANS_QUAD
	)
	$Tween.start()

func reset_sky_animation_speed():
	$Tween.stop_all()
	$SkyAnimations.playback_speed = 1

func resume_sky():
	$Tween.interpolate_property(
		$SkyAnimations,
		"playback_speed",
		0,
		1,
		3,
		Tween.TRANS_QUAD
	)
	$Tween.start()
	
func set_sky(sky_idx):
	$WorldEnvironment.environment.background_sky = skies[sky_idx]

func set_rand_sky():
	set_sky(generate_rand_sky_num())

func generate_rand_sky_num():
	var new_sky_num = rand_range(0, len(skies))
	if $WorldEnvironment.environment.background_sky == skies[new_sky_num]:
		return generate_rand_sky_num()
	else:
		return new_sky_num

#
# _process()
#
func _process(delta):
	# Lerping distortion/dispersion
	if _animate_warp_dispersion == true and get_tree().paused == false and $LensDistortion.visible:
		set_distortion(
			lerp($LensDistortion.material.get_shader_param("distort"), _animate_warp_amount, 0.04),
			lerp($LensDistortion.material.get_shader_param("dispersion"), _animate_dispersion_amount, 0.04)
		)
		if $LensDistortion.material.get_shader_param("distort") == _animate_warp_amount and\
			$LensDistortion.material.get_shader_param("dispersion") == _animate_dispersion_amount:
			_animate_warp_dispersion = false
		
	# Moving stuff when keys are pressed
	var key_pressed = false
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("ui_right"): 
		key_pressed = true
		$ShakeCamera.additional_offset.x = lerp($ShakeCamera.additional_offset.x, 3, 0.4)

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("ui_left"): 
		key_pressed = true
		$ShakeCamera.additional_offset.x = lerp($ShakeCamera.additional_offset.x, -3, 0.4)

	if Input.is_action_pressed("move_down") or Input.is_action_pressed("ui_up"):
		key_pressed = true
		$ShakeCamera.additional_offset.y = lerp($ShakeCamera.additional_offset.y, 3, 0.4)

	if Input.is_action_pressed("move_up") or Input.is_action_pressed("ui_down"):
		key_pressed = true
		$ShakeCamera.additional_offset.y = lerp($ShakeCamera.additional_offset.y, -3, 0.4)

	if key_pressed == false:
		$ShakeCamera.additional_offset = lerp($ShakeCamera.additional_offset, Vector2(), 0.4)
