extends Area

# How much damage the laser does
var damage = 0

# A variable for... the "sender" of a laser
var sender

# Whether or not it is from the player
onready var from_player = sender.is_in_group("players")

# To stop ships from hurting themselves as soon as they shoot lasers
var invincible = true

# Materials
export (SpatialMaterial) var enemy_material

export (SpatialMaterial) var player_material

export (SpatialMaterial) var fire_material

export (SpatialMaterial) var ice_material

export (SpatialMaterial) var corrosion_material

# Following the player
onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()] if len(get_tree().get_nodes_in_group("players")) > 0 else null

export var follow_player = false

export var follow_speed = 0.05

# Laser "modifiers"
enum MODIFIERS { fire, ice, corrosion, none }

export(MODIFIERS) var modifier = MODIFIERS.none

# Called when the node enters the scene tree for the first time.
func _ready():
	set_laser()
	
	if follow_player == true: $FollowTimer.start()
	
	$LaserSound.pitch_scale = rand_range(0.9, 1.1)
	$LaserSound.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if from_player == true:
		translation.z -= .4  # If the laser is from the player, move it up

	else:
		if follow_player == true and is_instance_valid(followed_player) and followed_player.health > 0:
			$Laser.look_at(followed_player.translation, Vector3(0, 1, 0))
			if stepify(translation.z, follow_speed) != stepify(followed_player.translation.z, follow_speed): translation.z += follow_speed if stepify(translation.z, follow_speed) < stepify(followed_player.translation.z, follow_speed) else -follow_speed
			if stepify(translation.x, follow_speed) != stepify(followed_player.translation.x, follow_speed): translation.x += follow_speed if stepify(translation.x, follow_speed) < stepify(followed_player.translation.x, follow_speed) else -follow_speed
		else:
			translation.z += .4  # otherwise, it's from an enemy ship, so move it down.

# Called to set the laser's material
func set_laser():
	# Sets the material of the laser
	if from_player == false:
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
func on_collision(area):
	if (area.get_parent().is_in_group("enemies") or area.get_parent().is_in_group("bosses")) and area.name != "ShipDetection" and (invincible and area.get_parent() == sender) == false:  # If the area this is colliding with is an enemy (and it is from the player)
		area.get_parent().health -= damage  # subtract health from the enemy
		# Laser modifiers
		match modifier:
			MODIFIERS.fire:
				area.get_node("../LaserEffects").bleed(.5, 3)
				area.get_node("../LaserEffects").start_fire()
			MODIFIERS.corrosion:
				area.get_node("../LaserEffects").bleed(2, 20)
				area.get_node("../LaserEffects").start_corrosion()
			MODIFIERS.ice:
				area.get_node("../LaserEffects").freeze(5)
				area.get_node("../LaserEffects").start_ice()
		# End laser modifiers
		if area.get_parent().health <= 0: area.get_parent().killed_from_player = true
		remove_laser(true)  # Removes the laser
	elif area.is_in_group("players") and area != sender:  # If the area this is colliding with is the PLAYER (and it is from the enemy)
		if area.godmode == false: area.set_health(area.health - damage)  # send it to BRAZIL
		Input.start_joy_vibration(0, 0.6, 1, .1)  # vibrate any controllers a bit
		remove_laser(true)  # Removes the laser
	elif area.is_in_group("lasers"):
		remove_laser(false)


func remove_laser(hit_ship):
	set_process(false)
	if has_node("CollisionShape") == false: return
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
	
	if $HitSound.playing == true: yield($HitSound, "finished")
	if $LaserSound.playing == true: yield($LaserSound, "finished")
	if $Particles.emitting == true: yield(Utils.timeout(.5), "timeout")
	queue_free()


func _on_VisibilityNotifier_screen_exited():
	remove_laser(false)


func _on_FollowTimer_timeout():
	remove_laser(false)


func _on_Laser_area_exited(area):
	if area == sender or area.get_parent() == sender: invincible = false
