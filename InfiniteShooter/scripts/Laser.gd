extends Area

# How much damage the laser does
var damage = 0

# Whether or not it is from the player
var from_player = true

# Needs to be here for making the node still run while the laser explodes
var freeze = false

# Folowwing the player
onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()]

export var follow_player = true

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
		if follow_player == true and followed_player != null:
			$EnemyLaser/Laser.look_at(followed_player.translation, Vector3(0, 1, 0))
			translation.z += .05 if translation.z < followed_player.translation.z else -.05
			translation.x += .05 if translation.x < followed_player.translation.x else -.05
		else:
			translation.z += .4  # otherwise, it's from an enemy ship, so move it down.


# Called when the laser collides with objects
func on_collision(area):
	if area.get_parent().is_in_group("enemies") and area.name != "ShipDetection" and from_player == true:  # If the area this is colliding with is an enemy (and it is from the player)
		area.get_parent().health -= damage  # subtract health from the enemy
		if area.get_parent().health <= 0: area.get_parent().killed_from_player = true
		remove_laser(true)  # and remove the laser

	if area.is_in_group("players") and from_player == false:  # If the area this is colliding with is the PLAYER (and it is from the enemy)
		if area.godmode == false: area.set_health(area.health - damage)  # send it to BRAZIL
		Input.start_joy_vibration(0, 0.6, 1, .1)  # vibrate any controllers a bit
		remove_laser(true)  # and remove the laser


func remove_laser(hit_ship):
	if freeze == true:  # The variable "freze" is a good indicator of whether this function was called or not. This function cannot be called twice!
		return

	freeze = true
	hide()
	$CollisionShape.queue_free()
	if hit_ship == true:
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(.3)  # Shakes the screen a little bit
		$HitSound.pitch_scale = rand_range(0.9, 1.1) # and plays a sound
		$HitSound.play()
		yield($HitSound, "finished")
	

	yield($LaserSound, "finished")
	queue_free()


func _on_VisibilityNotifier_screen_exited():
	remove_laser(false)


func _on_FollowTimer_timeout():
	remove_laser(false)
