extends Area

# How much damage the laser does
var damage = 0

# Whether or not it is from the player
var from_player = true

# Needs to be here for making the node still run while the laser explodes
var freeze = false

# A variable for... the "sender" of a laser
var sender

# Following the player
onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()] if len(get_tree().get_nodes_in_group("players")) > 0 else null

export var follow_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if from_player == false:  # By default the player laser is visible where the enemy laser model is not. If this laser is from an enemy, swap this.
		$PlayerLaser.hide()
		$EnemyLaser.show()
	
	if follow_player == true:
		$FollowTimer.start()
	
	$LaserSound.pitch_scale = rand_range(0.9, 1.1)
	$LaserSound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if freeze == true:
		return

	if from_player == true:
		translation.z -= .4  # If the laser is from the player, move it up

	else:
		if follow_player == true and is_instance_valid(followed_player) and followed_player.health > 0:
			$EnemyLaser/Laser.look_at(followed_player.translation, Vector3(0, 1, 0))
			translation.z += .1 if translation.z < followed_player.translation.z else -.1
			translation.x += .1 if translation.x < followed_player.translation.x else -.1
		else:
			translation.z += .4  # otherwise, it's from an enemy ship, so move it down.


# Called when the laser collides with objects
func on_collision(area):
	if area.get_parent().is_in_group("enemies") and area.name != "ShipDetection" and area.get_parent() != sender:  # If the area this is colliding with is an enemy (and it is from the player)
		area.get_parent().health -= damage  # subtract health from the enemy
		if area.get_parent().health <= 0: area.get_parent().killed_from_player = true
		remove_laser(true)  # and remove the laser

	if area.is_in_group("players") and area != sender:  # If the area this is colliding with is the PLAYER (and it is from the enemy)
		if area.godmode == false: area.set_health(area.health - damage)  # send it to BRAZIL
		Input.start_joy_vibration(0, 0.6, 1, .1)  # vibrate any controllers a bit
		remove_laser(true)  # and remove the laser


func remove_laser(hit_ship):
	if freeze == true:  # The variable "freze" is a good indicator of whether this function was called or not. This function cannot be called twice!
		return

	freeze = true
	$PlayerLaser.hide()
	$EnemyLaser.hide()
	if hit_ship == false:
		$Particles.emitting = true
		# Also we're setting the color of the explosion bits (for some reason we have to do it NOW of ALL TIMES)
		var material = $Particles.draw_pass_1.surface_get_material(0)
		material.albedo_color = ($EnemyLaser if from_player == false else $PlayerLaser).get_child(0).get_active_material(0).albedo_color
		$Particles.draw_pass_1.surface_set_material(0, material)
	$CollisionShape.queue_free()
	if hit_ship == true:
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(.3)  # Shakes the screen a little bit
		$HitSound.pitch_scale = rand_range(0.9, 1.1) # and plays a sound
		$HitSound.play()
	
	if $HitSound.playing == true: yield($HitSound, "finished")
	if $LaserSound.playing == true: yield($LaserSound, "finished")
	if $Particles.emitting == true: yield(Utils.timeout(.5), "timeout")
	queue_free()


func _on_VisibilityNotifier_screen_exited():
	remove_laser(false)


func _on_FollowTimer_timeout():
	remove_laser(false)
