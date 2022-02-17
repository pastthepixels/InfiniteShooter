extends Spatial

export var auto_explode = false

export var auto_delete = false

export var static_position = false

export var no_sound = false

export var speed_scale = 1

export var particles = true

export(float, 0, 1) var opacity = 1

onready var original_transform = get_global_transform()

signal exploded

func _ready():
	$ExplosionAnimation.opacity = opacity
	$ExplosionAnimation.frames.set_animation_speed("default", 50*speed_scale) # Default is 50 FPS
	if auto_explode == true:
		explode()
	if static_position == true:
		# 1. Create a new node with the current node's position
		var new_node = duplicate()
		new_node.static_position = false
		new_node.translation = global_transform.origin
		# 2. Add that node to the GameSpace node and then remove this node as it is obsolete
		var new_parent = get_node("/root/Game/GameSpace")
		new_parent.add_child(new_node)
		queue_free()

func explode():
	if $ExplosionAnimation.playing == false and $ExplosionSound.playing == false:
		# Starts the animation and shows the node
		show()
		$ExplosionAnimation.playing = true
		if particles == true: $Particles.emitting = true

		# Vibrates the first controller and shakes the screen
		if no_sound == false:
			Input.start_joy_vibration(0, 0.5, 0.7, .2)
			CameraEquipment.get_node("ShakeCamera").add_trauma(.4)
		
		# Plays an explosion sound at a random pitch
		$ExplosionSound.pitch_scale = rand_range(0.8, 1.2)
		if no_sound == false: $ExplosionSound.play()

func _on_ExplosionAnimation_animation_finished():
	# Waits for animations/sounds to finish
	$ExplosionAnimation.hide()
	if $ExplosionSound.playing == true: yield($ExplosionSound, "finished")
	if $Particles.emitting == true:
		yield($Particles, "finished")
	emit_signal("exploded")
	if auto_delete == true: queue_free()
