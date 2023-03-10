extends Area

#
# VARIABLES YOU CAN CHANGE FOR DERIVATIVES (not overridden by scripts)
#

# Whether or not you can use laser modifiers
export(bool) var use_modifiers = true

export(float) var speed_multiplier = 1

export(float) var damage_multiplier = 1

export(float) var homing_speed_multiplier = 0.4

#
# INTERNALLY USED/ IMMUTABLE VARIABLES
#

# Which direction the laser follows. You shouldn't have to use this; instead, change the laser's y rotation.
var attack_direction = Vector3(0, 0, 1) # Goes up. Also, this is a normalized vector.

var alive = true

#
# VARIABLES EDITABLE BY SCRIPTS (like LaserGun)
#

# How much damage the laser does
var damage = 0

# Laser speed
var speed = 24

# A variable for... the "sender" of a laser. Apparently set_owner doesn't work???
var sender : Node

# Following the player
var followed_entity

var follow_entity = false

# Laser "modifiers"
var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none

# Colors for various situations
export (Color) var enemy_color

export (Color) var player_color

export (Color) var fire_color

export (Color) var ice_color

export (Color) var corrosion_color

func set_sender(node : Node):
	sender = node

func _ready():
	set_laser()
	
	if follow_entity == true:
		speed *= homing_speed_multiplier # <-- To make homing lasers go slower
		$FollowTimer.start()
	
	if sender.is_in_group("players"):
		$FireSound.pitch_scale = rand_range(0.9, 1.1)
		$FireSound.play()
	else:
		$EnemyFireSound.pitch_scale = rand_range(0.9, 1.1)
		$EnemyFireSound.play()


func _physics_process(delta):
	if follow_entity == true and is_instance_valid(followed_entity) and followed_entity.health > 0:
		look_at(followed_entity.translation, Vector3(0, 1, 0))
		rotation.y += deg2rad(180)# <-- To make homing lasers go TOWARD the player instead of away from them
	translation += attack_direction.rotated(Vector3(0, 1, 0), rotation.y) * speed * speed_multiplier * delta

# Called to set the laser's material
func set_laser():
	if is_instance_valid(sender) == false: return
	
	# Sets the material of the laser
	if sender.is_in_group("enemies"):
		set_color(enemy_color)
	elif sender.is_in_group("players"):
		set_color(player_color)
	
	# Sets the material of the laser depeding on modifiers
	if use_modifiers == true:
		match modifier:
			MODIFIERS.fire:
				set_color(fire_color)
			
			MODIFIERS.ice:
				set_color(ice_color)
			
			MODIFIERS.corrosion:
				set_color(corrosion_color)

func set_color(color):
	var material = $Laser.get_surface_material(0)
	material.albedo_color = color
	material.emission = color
	$Laser.set_surface_material(0, material)

# Called when the laser collides with objects
func _on_Laser_area_entered(area):
	if area.get_owner() == get_owner() or area == get_owner():
		return
	if (area.get_parent().is_in_group("enemies") or area.get_parent().is_in_group("bosses")) and area == area.get_parent().enemy_model:  # If the area this is colliding with is an enemy (and it is from the player)
		area.get_parent().hurt(damage * damage_multiplier) # subtract health from the enemy
		# Laser modifiers
		if use_modifiers == true: handle_modifiers(area.get_parent())
		remove_laser(true)  # Removes the laser
	elif area.is_in_group("shield"):
		remove_laser(true) # Removes the laser

func _on_Laser_body_entered(body):
	if body.get_owner() == get_owner() or body == sender:
		return
	
	if body.is_in_group("players"): # If the area this is colliding with is the PLAYER 
		if body.godmode == false: body.health -= damage * damage_multiplier  # send them to BRAZIL
		# Laser modifiers
		handle_modifiers(body)
		if CameraEquipment.get_node("ShakeCamera").ignore_shake == false: Input.start_joy_vibration(0, 0.6, 1, .1)  # vibrate any controllers a bit
		remove_laser(true)  # Removes the laser
	elif body.is_in_group("coincrates") and sender.is_in_group("players"):
		body._on_Laser_hit()
		remove_laser(true)
	else:
		remove_laser(true)  # Removes the laser ANYWAY

func handle_modifiers(ship):
	match modifier:
		MODIFIERS.fire:
			if ship.is_in_group("players"):
				ship.get_node("LaserEffects").bleed(1, 8)
			else:
				ship.get_node("LaserEffects").bleed(.5, 10)
			ship.get_node("LaserEffects").start_fire()
			ship.get_node("LaserEffects").sender = sender
		MODIFIERS.corrosion:
			if ship.is_in_group("players"):
				ship.get_node("LaserEffects").bleed(2, 20)
			else:
				ship.get_node("LaserEffects").bleed(0.6, 8)
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
	set_physics_process(false)
	$CollisionShape.queue_free()
	$VisibilityNotifier.queue_free()
	$FollowTimer.queue_free()
	$Laser.hide()
	if hit_ship == false:
		set_laser()
		$Particles.emitting = true
	if hit_ship == true:
		CameraEquipment.get_node("ShakeCamera").add_trauma(.15)  # Shakes the screen a little bit
		$HitParticles.emitting = true
		$HitSound.pitch_scale = rand_range(0.9, 1.1) # and plays a sound
		$HitSound.play()
	
	# Waits a bit before queue_free-ing
	if $HitSound.playing == true: yield($HitSound, "finished")
	if $DisperseSound.playing == true: yield($DisperseSound, "finished")
	if $FireSound.playing == true: yield($FireSound, "finished")
	if $EnemyFireSound.playing == true: yield($EnemyFireSound, "finished")
	if $Particles.emitting == true: yield($Particles, "finished")
	if $HitParticles.emitting == true: yield($HitParticles, "finished")
	queue_free()

func _on_VisibilityNotifier_screen_exited():
	remove_laser(false)

func _on_FollowTimer_timeout():
	$DisperseSound.play()
	remove_laser(false)
