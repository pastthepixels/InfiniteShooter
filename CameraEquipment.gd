extends Spatial

onready var initial_warp_amount = $LensDistortion.material.get_shader_param("distort")
onready var initial_dispersion_amount = $LensDistortion.material.get_shader_param("dispersion")
var _animate_warp_dispersion = false
onready var _animate_warp_amount = 0
onready var _animate_dispersion_amount = 0

onready var orig_window_size = OS.window_size

# Since the playback speed of SkyAnimations is changed with a Tween, we want to store what the playback speed should be in another variable
# Probably a hacky way to do things, but also just works (tm)
var _sky_playback_speed = 1

export(Array, PanoramaSky) var skies


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # Hides the cursor
	VisualServer.canvas_item_set_z_index($FrameCounter.get_canvas_item(), 10)

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
		Saving.current_settings["skyanimations_speed"],
		0,
		3,
		Tween.TRANS_QUAD
	)
	$Tween.start()

func reset_sky_animation_speed():
	var settings = Saving.load_settings()
	$Tween.stop_all()

func resume_sky():
	$Tween.interpolate_property(
		$SkyAnimations,
		"playback_speed",
		0,
		Saving.current_settings["skyanimations_speed"],
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
func _process(_delta):
	$FrameCounter.text = "%s FPS" % Engine.get_frames_per_second()
	# Lerping distortion/dispersion
	if _animate_warp_dispersion == true and get_tree().paused == false and $LensDistortion.visible:
		set_distortion(
			lerp($LensDistortion.material.get_shader_param("distort"), _animate_warp_amount, 0.04),
			lerp($LensDistortion.material.get_shader_param("dispersion"), _animate_dispersion_amount, 0.04)
		)
		if $LensDistortion.material.get_shader_param("distort") == _animate_warp_amount and\
			$LensDistortion.material.get_shader_param("dispersion") == _animate_dispersion_amount:
			_animate_warp_dispersion = false
