extends Area

# How much damage the laser does
var damage = 0

# Whether or not it is from the player
var from_player = true

# Needs to be here for making the node still run while the laser explodes
var freeze = false

# A variable for... the "sender" of a laser
var sender

# To stop ships from hurting themselves as soon as they shoot lasers
var invincible = true

# Following the player
onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()] if len(get_tree().get_nodes_in_group("players")) > 0 else null

export var follow_player = false

export var follow_speed = 0.08

# Laser "modifiers"
export var modifier_fire = true

export var modifier_ice = false

export var modifier_corrosion = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_laser()
	
	if follow_player == true: $FollowTimer.start()
	
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
			$EnemyLaser.look_at(followed_player.translation, Vector3(0, 1, 0))
			if stepify(translation.z, follow_speed) != stepify(followed_player.translation.z, follow_speed): translation.z += follow_speed if stepify(translation.z, follow_speed) < stepify(followed_player.translation.z, follow_speed) else -follow_speed
			if stepify(translation.x, follow_speed) != stepify(followed_player.translation.x, follow_speed): translation.x += follow_speed if stepify(translation.x, follow_speed) < stepify(followed_player.translation.x, follow_speed) else -follow_speed
		else:
			translation.z += .4  # otherwise, it's from an enemy ship, so move it down.

# Called to set the laser's color/decoration
func set_laser():
	if from_player == false:
		# Hides the player laser
		$PlayerLaser.hide()
		# Sets the color of the particles
		$Particles.draw_pass_1.surface_set_material(0, $EnemyLaser.get_active_material(0))
	else:
		# HIdes the enemy laser
		$EnemyLaser.hide()

# Called when the laser collides with objects
func on_collision(area):
	if (area.get_parent().is_in_group("enemies") or area.get_parent().is_in_group("bosses")) and area.name != "ShipDetection" and (invincible and area.get_parent() == sender) == false:  # If the area this is colliding with is an enemy (and it is from the player)
		area.get_parent().health -= damage  # subtract health from the enemy
		# Laser modifiers
		if modifier_fire == true:
			area.get_node("../LaserEffects").bleed(.5, 3)
		# End laser modifiers
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
		set_laser()
		$Particles.emitting = true
	$CollisionShape.queue_free()
	if hit_ship == true:
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(.15)  # Shakes the screen a little bit
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


func _on_InvincibilityTimer_timeout():
	invincible = false
