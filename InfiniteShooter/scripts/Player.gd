extends Area

# Scenes
onready var laser_scene = load("res://scenes/Laser.tscn")

# Ammunition (in bullets)
export var max_ammo = 20

# Health (in HP/100)
export var max_health = 100

# Speed
export var speed = 14

# Damage per bullet (in HP/100)
export var damage = 20

# How much the player rotates when you use the arrow keys
export var player_rotation = 35

# Health (taken from the max health)
var health = max_health

# Ammo (taken from the max ammo)
var ammo = max_ammo

# Signals
signal died

signal health_changed

signal ammo_changed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Explosion.visible == true:
		return  # If the player is dying, don't bother about input stuff

	# Handling input
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
	translation += velocity * delta * speed

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
		and $Explosion.exploding != true
	):
		var laser = laser_scene.instance()
		laser.translation = translation
		laser.translation.z -= 1  # To get the laser firing from the "top" of the ship instead of the center for added realism
		laser.damage = damage
		get_parent().add_child(laser)
		Input.start_joy_vibration(0, 0.7, 1, .1)
		set_ammo(ammo - 1)
		emit_signal("ammo_changed", float(ammo) / max_ammo)

		if ammo <= 0:
			$ReloadTimer.start()
			$ReloadStart.play()


# When the player collides with enemies
func on_collision(area):
	if area.get_parent().is_in_group("enemies") and area.get_parent().health > 0:
		set_health(health - area.get_parent().health)
		area.get_parent().health -= area.get_parent().health


func reload():
	set_ammo(ammo + 1)
	$ReloadBoop.play()
	if ammo >= max_ammo:
		$ReloadTimer.stop()


func die_already():
	if ! $Explosion.exploding:  # If the explosion is exploding when this function is called, chances are it's being called twice. We don't want that.
		emit_signal("died")
		$Explosion.explode()
		$PlayerModel.queue_free()
		$CollisionShape.queue_free()
		$RegenTimer.stop()
		transform.basis = Basis()  # Resets the player's rotation
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(rand_range(.6, .7))


func cleanup_player():
	queue_free()


func heal():  # Regenerates a bit of health every time this function is called.
	if health < max_health:
		set_health(health + 1)

	if health >= max_health:
		set_health(max_health)


func set_ammo(new_ammo):
	ammo = new_ammo
	emit_signal("ammo_changed", float(ammo) / float(max_ammo))


func set_health(new_health):
	health = new_health
	emit_signal("health_changed", float(health) / float(max_health))
