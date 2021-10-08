extends Spatial

# Variables related to enemy properties

signal died(current_ship)

var killed_from_player = false

var damage

var max_health = 100

var health = max_health

var enemy_type

var bounding_box

var speed_mult = 1 # Multiplier for speed (pretty straightforward)

onready var homing_lasers = rand_range(0, 1) > .5

# Scenes used

onready var powerup_scene = load("res://scenes/enemies/Powerup.tscn")

onready var laser_scene = load("res://scenes/Laser.tscn")

var enemy_model


func initialize(difficulty):
	# Adds an enemy
	randomize()
	enemy_type = randi() % 3 + 1  # Generates either a 1, 2, or 3
	match enemy_type:
		1:
			enemy_model = $Enemy1
			$Enemy2.queue_free()
			$Enemy3.queue_free()
			# Sets enemy stats
			max_health = 80
			damage = 30
			speed_mult = 1

		2:
			enemy_model = $Enemy2
			$Enemy1.queue_free()
			$Enemy3.queue_free()
			# Sets enemy stats
			max_health = 20
			damage = 40
			speed_mult = 1.5

		3:
			enemy_model = $Enemy3
			$Enemy1.queue_free()
			$Enemy2.queue_free()
			# Sets enemy stats
			max_health = 100
			damage = 20
			speed_mult = .8
	# Multiplies everything by the difficulty number for added difficulty.
	var mult = float(difficulty) / 2
	max_health *= clamp(mult / 2, .5, 512)
	damage *= mult
	speed_mult *= clamp(mult / 5, 1, 2)

	# Sets the current health as the new max health
	health = max_health
	
	# Gets the bounding box for the enemy ship model
	bounding_box = enemy_model.get_child(1).get_aabb()

	# Starts all timers
	$MovingTimer.start()
	$LaserTimer.start()
	
	# Kills ships that don't move out of the way fast enough
	enemy_model.connect("area_entered", self, "collide_ship")
	
	# Adjusts the ShipDetection node's size
	$ShipDetection/CollisionShape.shape.extents = enemy_model.get_child(0).shape.extents
	$ShipDetection/CollisionShape.shape.extents.z *= 2
	# Uncomment and add a cube MeshInstance to the ShipDetection node with dimensions (2, 2, 2) to have a visual helper
#	$ShipDetection/MeshInstance.scale = $ShipDetection/CollisionShape.shape.extents
	
	# Moves health bar into position
	$HealthBar.translation.z = -(bounding_box.size.z * enemy_model.scale.z) + .5


# Called to process health
func _process(_delta):
	# If the health is between 100% and 0%, show the health bar.
	if health < max_health and health > 0:
		$HealthBar.show()
		$HealthBar.health = health
		$HealthBar.max_health = max_health
	elif health <= 0:
		$HealthBar.hide()
		explode_ship() # otherwise, explode the ship

func move_down():
	translation.z += .05 * speed_mult
	# If it is such that the center of the ship moves past the center of the screen...
	if translation.z > Utils.screen_to_local(Vector2(0, Utils.screen_size.y)).z:
		if has_node("../Player") and get_node("../Player").godmode == false:
			get_node("../Player").health -= health  # deduct health from the player
		health = 0  # and kill this ship


func explode_ship():
	if $Explosion.exploding:
		return  # If the explosion is exploding when this function is called, chances are it's being called twice. We don't want that.
	$Explosion.explode()
	$MovingTimer.stop()
	$LaserTimer.stop()
	enemy_model.queue_free()
	remove_from_group("enemies")
	emit_signal("died", self)
	if randi() % 4 == 1:  # 1/4 chance to create a powerup
		var powerup = powerup_scene.instance()
		powerup.translation = translation
		get_parent().add_child(powerup)


func cleanup_ship():  # Used to "clean up" the ship for some event or something
	queue_free()


func fire_laser():
	# If the player is not close to the enemy (5 metres in this case), why shoot a laser? This helps with performance and also with basic logic
	if has_node("../Player") and abs(get_node("../Player").translation.x - translation.x) > 5:
		return

	# Creating the laser
	var laser = laser_scene.instance()
	laser.follow_player = homing_lasers
	laser.sender = self

	# Telling the laser that it is not from the player + sets its damage
	laser.from_player = false
	laser.damage = damage

	# Setting the laser's position
	laser.translation = translation
	laser.translation.z += 1  # Makes the laser come from the "top" of the ship instead of the center for added realism

	# Gets the scene that housed the enemy and adds to it the laser
	get_parent().add_child(laser)


func _on_ShipDetection_area_entered(area):
	if area.get_parent().is_in_group("enemies") and speed_mult > area.get_parent().speed_mult and health > 0 and  area.get_parent().health > 0:
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
		$Tween.interpolate_property(self, "translation:x", translation.x, area.get_parent().translation.x + (common_formula*direction), 1/speed_mult, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()

func collide_ship(area):
	# Kills the ship if it collides with other enemy ships
	if area.get_parent().is_in_group("enemies") and area.get_parent().health > 0 and area.get_parent() != self and area.name != "ShipDetection":
		area.get_parent().health -= health
		health = 0
