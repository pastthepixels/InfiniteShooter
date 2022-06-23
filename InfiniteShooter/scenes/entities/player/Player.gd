extends KinematicBody

# MISC
var _ShootTimer_running = false

var _last_laser_tap_time = 0 # <-- Variable to help prevent over-spamming firing lasers

var laser_spam_threshold = 100 # <-- Threshold in ms (you can edit this)

# For debugging
export var godmode = false

# Userdata (set to the defaults)

var max_ammo = Saving.default_userdata.max_ammo

var ammo_refills = Saving.default_userdata.ammo_refills setget _update_ammo_refills

var max_health = Saving.default_userdata.health

var damage = Saving.default_userdata.damage

# Movement variables
export(float) var SCREEN_EDGE_MARGIN

var speed = 14

var actual_velocity = Vector3()

var impulse_velocity = Vector3()

var impulse_rotation = Vector3()

# Health (taken from the max health)
var health = max_health setget _update_health

var health_percent setget ,get_health_percent

# Ammo (taken from the max ammo)
export var infinite_ammo = false

var ammo = max_ammo setget _update_ammo

# Laser modifiers
var freeze_movement = false

# Signals
var alive = true

signal died

signal set_modifier # Godot will tell you this is never emitted. It is, just from Powerup.gd

signal health_changed(value)

signal ammo_changed(value, refills)

# Laser "modifiers"
var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none

# Setters and getters before we begin
func get_health_percent() -> float:
	return health / float(max_health)

func _update_health(new_value):
	health = clamp(new_value, 0, max_health)
	emit_signal("health_changed", get_health_percent())

func _update_ammo(new_value):
	ammo = clamp(new_value, 0, max_ammo)
	emit_signal("ammo_changed", float(ammo) / float(max_ammo), ammo_refills)

func _update_ammo_refills(new_value):
	ammo_refills = new_value
	emit_signal("ammo_changed", float(ammo) / float(max_ammo), ammo_refills)

func _process(_delta):
	# Killing the player when it should die
	if self.health == 0:
		resume_time()
		die_already()

func _physics_process(_delta):
	var velocity = impulse_velocity
	var delta_rotation = impulse_rotation  # The new rotation the player will have (NORMALIZED VECTOR)
	
	# Movement
	var leftright = clamp(Input.get_axis("move_left", "move_right") * 2, -1, 1)
	var updown =	clamp(Input.get_axis("move_down", "move_up") * 2, -1, 1)
	delta_rotation -= Vector3(updown, 0, leftright)
	velocity.x += leftright
	velocity.z -= updown
	
	# Sets position/rotation
	$PlayerModel.rotation = lerp($PlayerModel.rotation, delta_rotation * .6, .4)
	impulse_velocity = lerp(impulse_velocity, Vector3(), 0.1)
	impulse_rotation = lerp(impulse_rotation, Vector3(), 0.1)
	if freeze_movement == false:
		actual_velocity = lerp(actual_velocity, velocity, 0.6)
		move_and_slide(actual_velocity * speed)
	
	# Ship powers
	if Input.is_action_pressed("move_slow"):
		slow_time()
	elif Engine.time_scale == 0.5:
		resume_time()
	
	# Shooting lasers (pressing+holding)
	if Input.is_action_pressed("shoot_laser"):
		if _ShootTimer_running == false:
			_ShootTimer_running = true
			$ShootTimer.start()
	else:
		_ShootTimer_running = false
		$ShootTimer.stop()
	
	# Clamping z positions and wrapping around the screen
	translation.z = clamp(translation.z, Utils.top_left.z + SCREEN_EDGE_MARGIN, Utils.bottom_left.z - SCREEN_EDGE_MARGIN)
	translation.x = clamp(translation.x, Utils.top_left.x + SCREEN_EDGE_MARGIN, Utils.top_right.x - SCREEN_EDGE_MARGIN)

func slow_time():
	Engine.time_scale = 0.5
	CameraEquipment.set_animated_distortion(-0.15, -0.02)
	AudioServer.set_bus_effect_enabled(0, 0, true)

func resume_time():
	Engine.time_scale = 1
	CameraEquipment.set_animated_distortion(CameraEquipment.initial_warp_amount, CameraEquipment.initial_dispersion_amount)
	AudioServer.set_bus_effect_enabled(0, 0, false)

# Firing lasers (cont.d)
func _input(event): # Keyboard taps
	if OS.get_ticks_msec() - _last_laser_tap_time > laser_spam_threshold and event.is_action_pressed("shoot_laser"):
			_last_laser_tap_time = OS.get_ticks_msec()
			fire_laser()

func fire_laser():
	if self.ammo == 0 and self.ammo_refills <= 0:
		$AmmoClick.play()
	elif $ReloadTimer.time_left == 0:
		if self.ammo > 0:
			if infinite_ammo == false: self.ammo -= 1
			$PlayerModel/LaserGun.damage = damage
			if modifier != MODIFIERS.none:
				$PlayerModel/LaserGun.set_modifier(modifier)
			else:
				$PlayerModel/LaserGun.use_laser_modifiers = false
			$PlayerModel/LaserGun.fire()
			Input.start_joy_vibration(0, 0.7, 1, .1)
		if self.ammo <= 0 and self.ammo_refills > 0:
			self.ammo_refills -= 1
			$ReloadTimer.start()
			$ReloadStart.play()
			$ReloadBoop.play()


# When the player collides with enemies
func on_enemy_collision(enemy):
	var deduct_health = 0
	if enemy.health > 0:
		CameraEquipment.get_node("ShakeCamera").add_trauma(0.5) # <-- EXTRA screen shake
		if enemy.is_in_group("enemies"): # Some extra stuff if it's an ENEMY and not a BOSS (creating powerups)
			if enemy.health_percent < GameVariables.gkill_health_ratio or enemy.test_hurt(damage) <= 0:
				enemy.force_powerup = true # Create a powerup ANYWAY (remind you of anything *cough cough* glory kills *cough cough*)
				if get_health_percent() < 0.50 or ammo_refills > 10:
					enemy.powerup_type = GameVariables.POWERUP_TYPES.medkit
				else:
					enemy.powerup_type = GameVariables.POWERUP_TYPES.ammo
				# [Awards you for running into ships that are glowing by not deducting your health]
			else: # v- Doesn't award you for running into ships that aren't.
				enemy.force_powerup = false
				deduct_health = enemy.health
			enemy.hurt(enemy.health)
		if enemy.is_in_group("bosses"):
			enemy.hurt(20)
			deduct_health = enemy.health
		if deduct_health > 0 and godmode == false:
			self.health = clamp(self.health - deduct_health, max_health * 0.05, self.max_health)
		impulse_velocity = actual_velocity * -2
		impulse_rotation.z = actual_velocity.x * -2
		impulse_rotation.x = actual_velocity.z * 2


# Reloading
func reload():
	self.ammo += 1
	if self.ammo == max_ammo:
		$ReloadTimer.stop()
		$ReloadBoop.stop()


func die_already():
	# Ensure the function cannot be called multiple times
	if alive == false:
		return
	else:
		alive = false
	# everything else
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	emit_signal("died")
	$Explosion.explode()
	$PlayerModel.hide()
	$CollisionShape.disabled = true
	$RegenTimer.stop()
	$ShootTimer.stop()
	$LaserEffects.reset()
	transform.basis = Basis()  # Resets the player's rotation
	if has_node("/root/Main/ShakeCamera"):
		get_node("/root/Main/ShakeCamera").add_trauma(rand_range(.6, .7))


 # Regenerates a bit of health every time this function is called.
func _on_RegenTimer_timeout():
	if self.health < max_health:
		self.health += max_health*0.01


func _on_Explosion_exploded():
	$Explosion.hide()


func _on_ShootTimer_timeout():
	fire_laser()

# Healing everything + giving ammo
func regenerate():
	if self.ammo_refills < Saving.default_userdata.ammo_refills:
		self.ammo_refills = Saving.default_userdata.ammo_refills
	self.health = self.max_health

func reset():
	max_ammo = Saving.default_userdata.max_ammo
	ammo_refills = Saving.default_userdata.ammo_refills
	max_health = Saving.default_userdata.health
	health = max_health
	damage = Saving.default_userdata.damage
