extends Spatial

export var auto_explode = false

export var static_position = false

export var only_visuals = false

export var speed_scale = 1

export(float, 0, 1) var opacity = 1

onready var original_transform = get_global_transform()

signal exploded

func _ready():
	$ExplosionAnimation.opacity = opacity
	$ExplosionAnimation.frames.set_animation_speed("default", 50*speed_scale) # Default is 50 FPS
	if auto_explode == true:
		explode()

func _process(_delta):
	if static_position == true:
		translation = original_transform.origin - get_parent().translation
		

func explode():
	if $ExplosionAnimation.playing == false and $ExplosionSound.playing == false:
		# Starts the animation and shows the node
		show()
		$ExplosionAnimation.playing = true

		# Vibrates the first controller and shakes the screen
		if only_visuals == false:
			Input.start_joy_vibration(0, 0.5, 0.7, .2)
			CameraEquipment.get_node("ShakeCamera").add_trauma(.4)
		
		# Plays an explosion sound at a random pitch
		$ExplosionSound.pitch_scale = rand_range(0.8, 1.2)
		if only_visuals == false: $ExplosionSound.play()


func _on_ExplosionAnimation_animation_finished():
	hide()
	emit_signal_on_finish()


func _on_ExplosionSound_finished():
	emit_signal_on_finish()

func emit_signal_on_finish(): # Emits the "exploded" signal when both the animation and sound are finished
	if $ExplosionAnimation.playing == false and $ExplosionSound.playing == false:  emit_signal("exploded")
