extends Spatial

# Declare member variables here.
var exploding = false
signal exploded


func explode():
	if exploding == true:
		return
	show()
	exploding = true
	$ExplosionAnimation.playing = true
	Input.start_joy_vibration(0, 0.5, 0.7, .2)  # Vibrates a controller if you have one

	# Plays an explosion sound at a varying pitch
	$ExplosionSound.pitch_scale = rand_range(0.8, 1.2)
	$ExplosionSound.play()


func hide_explosion():  # Once the explosion is done, hide it
	hide()


func end_explosion():  # Ends the explosion once we are done waiting for the audio (which is longer than the explosion itself)
	emit_signal("exploded")
	queue_free()
