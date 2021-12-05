extends Spatial

# Damage, health, and enemy type
var enemy_type = GameVariables.ENEMY_TYPES.values()[randi() % GameVariables.ENEMY_TYPES.size()]

var damage

var max_health = 100

var health = max_health

var alive = true

# Enemy modifiers

var speed_mult = 1 # Multiplier for speed (pretty straightforward)

onready var use_homing_lasers = rand_range(0, 1) > .5

var use_laser_modifiers = (randi() % 10 == 1) and GameVariables.use_laser_modifiers

var last_hit_from

# Death

signal died(this, from_player)

# Laser modifiers
var freeze_movement = false

var laser_modifier = GameVariables.LASER_MODIFIERS.values()[randi() % GameVariables.LASER_MODIFIERS.size()]

# Bounding box stuff
var bounding_box

# Scenes used

export(PackedScene) var powerup_scene

export(PackedScene) var laser_scene

var enemy_model


func initialize(difficulty):
	# Adds an enemy model and sets stats for that model
	match enemy_type:
		GameVariables.ENEMY_TYPES.normal:
			enemy_model = $Normal
			# Sets enemy stats
			max_health = 80
			damage = 30
			speed_mult = 1

		GameVariables.ENEMY_TYPES.small:
			enemy_model = $Small
			# Sets enemy stats
			max_health = 20
			damage = 40
			speed_mult = 1.5

		GameVariables.ENEMY_TYPES.tank:
			enemy_model = $Tank
			# Sets enemy stats
			max_health = 100
			damage = 20
			speed_mult = .8
	
	# Multiplies everything by the difficulty number for added difficulty.
	var mult = float(difficulty) / 2
	max_health *= clamp(mult / 2, .5, 512)
	damage *= mult
	speed_mult *= clamp(mult / 5, 1, 3)

	# Sets the current health as the new max health
	self.health = max_health
	
	# Gets the bounding box for the enemy ship model
	bounding_box = enemy_model.get_child(1).get_aabb()

	# Starts all timers
	$LaserTimer.start()
	
	# Kills ships that don't move out of the way fast enough
	enemy_model.connect("area_entered", self, "collide_ship")
	
	# Moves health bar into position
	$HealthBar.translation.z = -(bounding_box.size.z * enemy_model.scale.z) + .5
	$HealthBar.max_health = max_health
	
	# LASTLY makes the current ship visible
	enemy_model.show()


# To move the ship/calculate health
var previous_health
func _process(delta):
	if health != previous_health:
		previous_health = health
		update_health()
	if freeze_movement: return
	translation.z += 2 * speed_mult * delta
	# If it is such that the center of the ship moves past the bottom of the screen...
	if translation.z >= Utils.bottom_left.z:
		if has_node("../Player") and get_node("../Player").godmode == false:
			get_node("../Player").health -= health  # deduct health from the player
		explode_ship() # and kill this ship


func explode_ship(from_player=false):
	# Ensures last_hit_from is null
	last_hit_from = null
	alive = false
	
	# Explodes and resets, emitting a signal at the end
	$Explosion.explode()
	$LaserTimer.stop()
	$LaserEffects.reset()
	$HealthBar.queue_free()
	for node in get_children():
		if node is Area:
			node.queue_free()
	remove_from_group("enemies")
	set_process(false)
	emit_signal("died", self, from_player)

	# Powerups (1/4 chance to create a powerup)
	if randi() % 4 == 1 and use_laser_modifiers == false:
		var powerup = powerup_scene.instance()
		powerup.translation = translation
		get_parent().add_child(powerup)
	elif use_laser_modifiers == true:
		var powerup = powerup_scene.instance()
		powerup.translation = translation
		powerup.modifier = laser_modifier
		get_parent().add_child(powerup)


func _on_Explosion_exploded():
	queue_free()


func fire_laser():
	# Creating the laser
	var laser = laser_scene.instance()
	laser.follow_player = use_homing_lasers
	laser.sender = self

	# Setting the laser's damage
	laser.damage = damage
	
	# Modifiers
	if use_laser_modifiers:
		laser.modifier = laser_modifier
		laser.set_laser()

	# Setting the laser's position
	laser.translation = translation
	laser.translation.z += 1  # Makes the laser come from the "top" of the ship instead of the center for added realism

	# Gets the scene that housed the enemy and adds to it the laser
	get_parent().add_child(laser)

func _on_LaserTimer_timeout():
	fire_laser()


func _on_ShipDetection_area_entered(area):
	if freeze_movement == false and area.get_parent().is_in_group("enemies") and speed_mult > area.get_parent().speed_mult and health > 0 and  area.get_parent().health > 0:
		# Basciallly moving a ship from the center of another ship to beside it (left/right)
		# Subtracting this makes you go left, adding this makes you go right
		var common_formula = area.get_parent().bounding_box.size.x/2 + bounding_box.size.x/2 + .2
		var direction = -1 # Goes left
		# If we are closer to the right of the ship, go to the right
		if translation.x > area.get_parent().translation.x:
			direction = 1
		# Now we try to switch the direction if the ship will go off screen.
		if (area.get_parent().translation.x + (common_formula*direction)) > Utils.bottom_right.x:
			direction = -1
		elif (area.get_parent().translation.x + (common_formula*direction)) < Utils.bottom_left.x:
			direction = 1
		# Uses the Tween node to smoothly move around the other ship, preventing a collision
		$Tween.interpolate_property(self, "translation:x", translation.x, area.get_parent().translation.x + (common_formula*direction), 1 * speed_mult, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()

func collide_ship(area):
	# Kills the ship if it collides with other enemy ships
	if area.get_parent().is_in_group("enemies") and area.get_parent().health > 0 and area != enemy_model and area == area.get_parent().enemy_model:
		area.get_parent().health -= health
		explode_ship()

# Updating health-related info
func update_health():
	if health > 0 and health < max_health:
		$HealthBar.visible = true
		$HealthBar.health = health
	if health <= 0 and alive == true:
		if last_hit_from != null and is_instance_valid(last_hit_from) and last_hit_from.is_in_group("players"):
			explode_ship(true)
		else:
			explode_ship()
	last_hit_from = null
