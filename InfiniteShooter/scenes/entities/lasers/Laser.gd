extends Area

# How much damage the laser does
var damage = 0

# Laser speed

export var speed = 0.4

export var follow_speed = 0.05

# To stop ships from hurting themselves as soon as they shoot lasers
var invincible = true

# A variable for... the "sender" of a laser
var sender

# Following the player

onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()] if len(get_tree().get_nodes_in_group("players")) > 0 else null

export var follow_player = false

# Laser "modifiers"

var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none

# Materials and extra stuff

var alive = true

export (SpatialMaterial) var enemy_material

export (SpatialMaterial) var player_material

export (SpatialMaterial) var fire_material

export (SpatialMaterial) var ice_material

export (SpatialMaterial) var corrosion_material

func _ready():
	set_laser()
	
	if follow_player == true: $FollowTimer.start()
	if sender.is_in_group("players"): speed *= -1 # Goes up if from player
	
	$LaserSound.pitch_scale = rand_range(0.9, 1.1)
	$LaserSound.play()


func _process(delta):
	if follow_player == true and is_instance_valid(followed_player) and followed_player.health > 0:
		$Laser.look_at(followed_player.translation, Vector3(0, 1, 0))
		if stepify(translation.z, follow_speed) != stepify(followed_player.translation.z, follow_speed): translation.z += follow_speed*delta if stepify(translation.z, follow_speed) < stepify(followed_player.translation.z, follow_speed) else -follow_speed*delta
		if stepify(translation.x, follow_speed) != stepify(followed_player.translation.x, follow_speed): translation.x += follow_speed*delta if stepify(translation.x, follow_speed) < stepify(followed_player.translation.x, follow_speed) else -follow_speed*delta
	else:
		translation.z += speed * delta # otherwise, it's from an enemy ship, so move it down.

# Called to set the laser's material
func set_laser():
	# Sets the material of the laser
	if sender.is_in_group("players") == false:
		$Laser.set_surface_material(0, enemy_material)
	else:
		$Laser.set_surface_material(0, player_material)
	
	# Sets the material of the laser depeding on modifiers
	match modifier:
		MODIFIERS.fire:
			$Laser.set_surface_material(0, fire_material)
		
		MODIFIERS.ice:
			$Laser.set_surface_material(0, ice_material)
		
		MODIFIERS.corrosion:
			$Laser.set_surface_material(0, corrosion_material)
	
	# Sets the material of the particle thing
	$Particles.draw_pass_1.surface_set_material(0, $Laser.get_surface_material(0))

# Called when the laser collides with objects
func _on_Laser_area_entered(area):
	if (area.get_parent().is_in_group("enemies") or area.get_parent().is_in_group("bosses")) and area == area.get_parent().enemy_model and (invincible and area.get_parent() == sender) == false:  # If the area this is colliding with is an enemy (and it is from the player)
		area.get_parent().health -= damage # subtract health from the enemy
		area.get_parent().last_hit_from = sender
		# Laser modifiers
		handle_modifiers(area.get_parent())
		remove_laser(true)  # Removes the laser
	elif area.is_in_group("players") and area != sender:  # If the area this is colliding with is the PLAYER (and it is from the enemy)
		if area.godmode == false: area.health -= damage  # send it to BRAZIL
		# Laser modifiers
		handle_modifiers(area)
		Input.start_joy_vibration(0, 0.6, 1, .1)  # vibrate any controllers a bit
		remove_laser(true)  # Removes the laser


func handle_modifiers(ship):
	match modifier:
		MODIFIERS.fire:
			ship.get_node("LaserEffects").bleed(.5, 3)
			ship.get_node("LaserEffects").start_fire()
			ship.get_node("LaserEffects").sender = sender
		MODIFIERS.corrosion:
			ship.get_node("LaserEffects").bleed(2, 20)
			ship.get_node("LaserEffects").start_corrosion()
			ship.get_node("LaserEffects").sender = sender
		MODIFIERS.ice:
			ship.get_node("LaserEffects").freeze(3)
			ship.get_node("LaserEffects").start_ice()
			ship.get_node("LaserEffects").sender = sender


func remove_laser(hit_ship=false):
	if not alive:
		return
	else:
		alive = false
	
	# Stops and removes stuff
	set_process(false)
	$CollisionShape.queue_free()
	$VisibilityNotifier.queue_free()
	$FollowTimer.queue_free()
	$Laser.hide()
	if hit_ship == false:
		set_laser()
		$Particles.emitting = true
	if hit_ship == true:
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(.15)  # Shakes the screen a little bit
		$HitSound.pitch_scale = rand_range(0.9, 1.1) # and plays a sound
		$HitSound.play()
	
	# Waits a bit before queue_free-ing
	if $HitSound.playing == true: yield($HitSound, "finished")
	if $LaserSound.playing == true: yield($LaserSound, "finished")
	if $Particles.emitting == true: yield(Utils.timeout(.5), "timeout")
	queue_free()


func _on_VisibilityNotifier_screen_exited():
	remove_laser(false)


func _on_FollowTimer_timeout():
	remove_laser(false)


func _on_Laser_area_exited(area):
	if area == sender or area.get_parent() == sender: invincible = false # Removes invincibility once exiting a node
