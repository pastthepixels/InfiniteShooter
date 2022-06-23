extends RigidBody

export(float) var speed

signal opened

func _on_Laser_hit():
	# Let the player/game know something important just happened
	$CoinSound.play()
	emit_signal("opened")
	# Disable physics
	$CollisionShape.disabled = true
	collision_layer = 0
	collision_mask = 0
	# Hide the crate, stop rotating, and explode
	set_physics_process(false)
	$CoinCrate.hide()
	$AnimationPlayer.play("RESET")
	$Explosion.explode()

func _physics_process(delta):
	translation.z += delta * speed


func _on_VisibilityNotifier_screen_exited():
	if translation.z > 0: # Ensuring the [coin] left the BOTTOM of the screen
		queue_free()
