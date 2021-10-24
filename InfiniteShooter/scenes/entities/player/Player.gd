extends Area

# For debugging
export var godmode = false

# Scenes
export(PackedScene) var laser_scene

# Ammunition (in bullets)
export var max_ammo = 20

# Ammo refills
export var ammo_refills = 10

# Health (in HP/100)
export var max_health = 100

# Speed
export var speed = 14

# Damage per bullet (in HP/100)
export var damage = 30

# How much the player rotates when you use the arrow keys
export var player_rotation = 35

# Health (taken from the max health)
var health = max_health

# Ammo (taken from the max ammo)
var ammo = max_ammo

# Freezing movement
var freeze_movement = false

# Signals
signal moved

signal died

signal laser_fired(laser)

signal health_changed(value)

signal ammo_changed(value, refills)

# Laser "modifiers"
var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none

var previous_health
func _process(delta):
	# HEALTH
	if health != previous_health:
		previous_health = health
		update_hud()
	
	# INPUT
	if $Explosion.visible == true:
		return  # If the player is dying, don't bother about input stuff

	var velocity = Vector3()  # The player's movement vector. (yes, I copied this from the "Your First Game" Godot tutorial. Don't judge.
	var delta_rotation = Vector3()  # The new rotation the player will have (NORMALIZED VECTOR)
	if Input.is_action_pressed("move_right"):  # If a key is pressed (e.g. the right arrow key)
		delta_rotation.z -= 1  # Rotate the ship
		velocity.x += 1  # and alter its velocity.

	if Input.is_action_pressed("move_left"):  # We do this 4 times for each direction you can press a key in
		delta_rotation.z += 1
		velocity.x -= 1

	if Input.is_action_pressed("move_down") and (translation.z < Utils.bottom_left.z):
		delta_rotation.x += 1
		velocity.z += 1

	if Input.is_action_pressed("move_up") and (translation.z > Utils.top_left.z):
		delta_rotation.x -= 1
		velocity.z -= 1

	# Sets position
	if freeze_movement == false:
		translation += velocity * delta * speed
		if velocity * delta * speed != Vector3():
			emit_signal("moved")

	# Sets rotation
	rotation = delta_rotation * deg2rad(player_rotation)

	# If the player goes out of bounds (x axis only; see above for y)
	if translation.x < Utils.top_left.x:
		translation.x = Utils.top_right.x
	if translation.x > Utils.top_right.x:
		translation.x = Utils.top_left.x

	# Killing the player when it should die
	if health <= 0.0:
		die_already()


# Firing lasers
func _input(event):
	if (
		event.is_action_pressed("shoot_laser")
		and ammo > 0
		and $ReloadTimer.time_left == 0
		and health > 0
	):
		var laser = laser_scene.instance()
		laser.sender = self
		laser.translation = translation
		laser.translation.z -= 1  # To get the laser firing from the "top" of the ship instead of the center for added realism
		laser.damage = damage
		if modifier != MODIFIERS.none:
			laser.modifier = modifier
			laser.set_laser()
		get_parent().add_child(laser)
		Input.start_joy_vibration(0, 0.7, 1, .1)
		set_ammo(ammo - 1)
		emit_signal("laser_fired", laser)

		if ammo <= 0 and ammo_refills > 0:
			ammo_refills -= 1
			$ReloadTimer.start()
			$ReloadStart.play()


# When the player collides with enemies
func on_collision(area):
	if godmode == false and (area.get_parent().is_in_group("enemies") or area.get_parent().is_in_group("bosses")) and area.name != "ShipDetection" and area.get_parent().health > 0:
		self.health -= area.get_parent().health
		area.get_parent().health -= area.get_parent().health


func reload():
	set_ammo(ammo + 1)
	$ReloadBoop.play()
	if ammo >= max_ammo:
		$ReloadTimer.stop()


func die_already():
	set_process(false)
	emit_signal("died")
	$Explosion.explode()
	$PlayerModel.queue_free()
	$CollisionShape.queue_free()
	$RegenTimer.stop()
	$LaserEffects.reset()
	transform.basis = Basis()  # Resets the player's rotation
	if has_node("/root/Main/ShakeCamera"):
		get_node("/root/Main/ShakeCamera").add_trauma(rand_range(.6, .7))


func cleanup_player():
	queue_free()


func heal():  # Regenerates a bit of health every time this function is called.
	if self.health < max_health:
		self.health += 1


func set_ammo(new_ammo):
	ammo = new_ammo
	update_hud()


func update_hud():
	emit_signal("ammo_changed", float(ammo) / float(max_ammo), ammo_refills)
	emit_signal("health_changed", float(health) / float(max_health))
