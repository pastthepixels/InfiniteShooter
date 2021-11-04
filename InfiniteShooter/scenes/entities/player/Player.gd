extends Area

# For debugging
export var godmode = false

# Scenes used
export(PackedScene) var laser_scene

# Userdata (set to the defaults)
var max_ammo = Saving.default_userdata.max_ammo

var ammo_refills = Saving.default_userdata.ammo_refills setget _update_ammo_refills

var max_health = Saving.default_userdata.health

var damage = Saving.default_userdata.damage

# Movement variables
var speed = 14

# Health (taken from the max health)
var health = max_health setget _update_health

# Ammo (taken from the max ammo)
var ammo = max_ammo setget _update_ammo

# Laser modifiers
var freeze_movement = false

# Signals
signal died

signal health_changed(value)

signal ammo_changed(value, refills)

# Laser "modifiers"
var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none

# Setters and getters before we begin
func _update_health(new_value):
	health = clamp(new_value, 0, max_health)
	emit_signal("health_changed", float(health) / float(max_health))

func _update_ammo(new_value):
	ammo = clamp(new_value, 0, max_ammo)
	emit_signal("ammo_changed", float(ammo) / float(max_ammo), ammo_refills)

func _update_ammo_refills(new_value):
	ammo_refills = new_value
	emit_signal("ammo_changed", float(ammo) / float(max_ammo), ammo_refills)

func _process(delta):
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

	if Input.is_action_pressed("move_down"):
		delta_rotation.x += 1
		velocity.z += 1

	if Input.is_action_pressed("move_up"):
		delta_rotation.x -= 1
		velocity.z -= 1

	# Sets position
	if freeze_movement == false:
		translation += velocity * delta * speed

	# Sets rotation
	rotation = delta_rotation * .6
	
	# Clamping z positions and wrapping around the screen
	translation.z = clamp(translation.z, Utils.top_left.z, Utils.bottom_left.z)
	translation.x = wrapf(translation.x, Utils.top_left.x, Utils.top_right.x)

	# Killing the player when it should die
	if self.health == 0:
		die_already()


# Firing lasers
func _input(event):
	if (
		event.is_action_pressed("shoot_laser")
		and self.ammo > 0
		and $ReloadTimer.time_left == 0
	):
		self.ammo -= 1
		var laser = laser_scene.instance()
		laser.sender = self
		laser.translation = translation - Vector3(0, 0, 1)
		laser.damage = damage
		if modifier != MODIFIERS.none:
			laser.modifier = modifier
			laser.set_laser()
		get_parent().add_child(laser)
		Input.start_joy_vibration(0, 0.7, 1, .1)

		if self.ammo == 0 and self.ammo_refills > 0:
			self.ammo_refills -= 1
			$ReloadTimer.start()
			$ReloadStart.play()


# When the player collides with enemies
func on_collision(area):
	if godmode == false and (area.get_parent().is_in_group("enemies") or area.get_parent().is_in_group("bosses")) and area == area.get_parent().enemy_model and area.get_parent().health > 0:
		self.health -= area.get_parent().health
		area.get_parent().health -= area.get_parent().health


# Reloading
func reload():
	self.ammo += 1
	$ReloadBoop.play()
	if self.ammo == max_ammo:
		$ReloadTimer.stop()


func die_already():
	set_process(false)
	set_process_input(false)
	emit_signal("died")
	$Explosion.explode()
	$PlayerModel.queue_free()
	$CollisionShape.queue_free()
	$RegenTimer.stop()
	$LaserEffects.reset()
	transform.basis = Basis()  # Resets the player's rotation
	if has_node("/root/Main/ShakeCamera"):
		get_node("/root/Main/ShakeCamera").add_trauma(rand_range(.6, .7))


 # Regenerates a bit of health every time this function is called.
func _on_RegenTimer_timeout():
	if self.health < max_health:
		self.health += 1


func _on_Explosion_exploded():
	queue_free()
