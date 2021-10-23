extends Spatial

signal exploded


func explode():
	if $ExplosionAnimation.playing == false and $ExplosionSound.playing == false:
		# Starts the animation and shows the node
		show()
		$ExplosionAnimation.playing = true

		# Vibrates the first controller and shakes the screen
		Input.start_joy_vibration(0, 0.5, 0.7, .2)
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(.2)
		
		# Plays an explosion sound at a random pitch
		$ExplosionSound.pitch_scale = rand_range(0.8, 1.2)
		$ExplosionSound.play()


func _on_ExplosionAnimation_animation_finished():
	hide()
	emit_signal_on_finish()


func _on_ExplosionSound_finished():
	emit_signal_on_finish()

func emit_signal_on_finish(): # Emits the "exploded" signal when both the animation and sound are finished
	if $ExplosionAnimation.playing == false and $ExplosionSound.playing == false:  emit_signal("exploded")
