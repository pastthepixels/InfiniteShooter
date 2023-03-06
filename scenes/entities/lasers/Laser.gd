extends Area

# How much damage the laser does
var damage = 0

# Laser speed

export var speed = 24

export var follow_speed = 3

# Which direction the laser follows
export var attack_direction = Vector3(0, 0, 1) # Goes up. Also, this is a normalized vector.
# This is a variable used internally and you shouldn't have to use this. Instead, change the laser's y rotation.

# A variable for... the "sender" of a laser. Apparently set_owner doesn't work???
var sender : Node

# Following the player

var followed_entity

export var follow_entity = false

# Laser "modifiers"

var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none

# Materials and extra stuff

var alive = true

export var from_player = false

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
		speed /= 2.5 # <-- To make homing lasers go slower
		$FollowTimer.start()
	
	if from_player == true:
		$LaserSound.pitch_scale = rand_range(0.9, 1.1)
		$LaserSound.play()
	else:
		$EnemyLaserSound.pitch_scale = rand_range(0.9, 1.1)
		$EnemyLaserSound.play()


func _physics_process(delta):
	if follow_entity == true and is_instance_valid(followed_entity) and followed_entity.health > 0:
		look_at(followed_entity.translation, Vector3(0, 1, 0))
		rotation.y += deg2rad(180)# <-- To make homing lasers go TOWARD the player instead of away from them
	translation += attack_direction.rotated(Vector3(0, 1, 0), rotation.y) * speed * delta

# Called to set the laser's material
func set_laser():
	if is_instance_valid(sender) == false: return
	
	# Sets the material of the laser
	if from_player == false:
		set_color(enemy_color)
	else:
		set_color(player_color)
	
	# Sets the material of the laser depeding on modifiers
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
		area.get_parent().hurt(damage) # subtract health from the enemy
		# Laser modifiers
		handle_modifiers(area.get_parent())
		remove_laser(true)  # Removes the laser
	elif area.is_in_group("shield"):
		remove_laser(true) # Removes the laser

func _on_Laser_body_entered(body):
	if body.get_owner() == get_owner() or body == sender:
		return
	
	if body.is_in_group("players"): # If the area this is colliding with is the PLAYER 
		if body.godmode == false: body.health -= damage  # send them to BRAZIL
		# Laser modifiers
		handle_modifiers(body)
		if CameraEquipment.get_node("ShakeCamera").ignore_shake == false: Input.start_joy_vibration(0, 0.6, 1, .1)  # vibrate any controllers a bit
		remove_laser(true)  # Removes the laser
	elif body.is_in_group("coincrates") and from_player == true:
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
	if $EOLSound.playing == true: yield($EOLSound, "finished")
	if $LaserSound.playing == true: yield($LaserSound, "finished")
	if $EnemyLaserSound.playing == true: yield($EnemyLaserSound, "finished")
	if $Particles.emitting == true: yield($Particles, "finished")
	if $HitParticles.emitting == true: yield($HitParticles, "finished")
	queue_free()

func _on_VisibilityNotifier_screen_exited():
	remove_laser(false)

func _on_FollowTimer_timeout():
	$EOLSound.play()
	remove_laser(false)
