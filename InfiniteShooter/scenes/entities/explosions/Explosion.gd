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
		
		# Waits for animations/sounds to finish
		if $ExplosionSound.playing == true: yield($ExplosionSound, "finished")
		if $ExplosionAnimation.playing == true: yield($ExplosionAnimation, "animation_finished")
		emit_signal("exploded")
