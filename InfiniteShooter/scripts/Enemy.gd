extends Spatial

# Variables related to enemy properties

var damage

var max_health = 100

var health = max_health

var enemy_type

var bounding_box

var speed_mult = 1 # Multiplier for speed (pretty straightforward)

# Scenes used

onready var powerup_scene = load("res://scenes/enemies/Powerup.tscn")

onready var laser_scene = load("res://scenes/Laser.tscn")

onready var enemy_scenes = [
	load("res://scenes/enemies/Enemy1.tscn"),
	load("res://scenes/enemies/Enemy2.tscn"),
	load("res://scenes/enemies/Enemy3.tscn")
]


func _ready():
	randomize()


func initialize(level):
	# Adds an enemy
	enemy_type = randi() % 3 + 1  # Generates either a 1, 2, or 3
	match enemy_type:
		1:
			add_child(enemy_scenes[0].instance())

			# Sets enemy stats
			max_health = 80
			damage = 7
			speed_mult = 1

		2:
			add_child(enemy_scenes[1].instance())

			# Sets enemy stats
			max_health = 20
			damage = 10
			speed_mult = 1.5

		3:
			add_child(enemy_scenes[2].instance())

			# Sets enemy stats
			max_health = 100
			damage = 5
			speed_mult = .8

	# Multiplies everything by the level number for added difficulty.
	var mult = float(level) / 2
	max_health *= clamp(mult / 2, .5, 512)
	damage *= mult
	speed_mult *= clamp(mult / 5, 1, 2)

	# Sets the current health as the new max health
	health = max_health
	
	# Gets the bounding box for the enemy ship model
	bounding_box = $EnemyModel.get_child(1).get_aabb()

	# Starts all timers
	$MovingTimer.start()
	$LaserTimer.start()
	$HealthBar.hide()  # Hides the health bar by default.
	
	# Kills ships that don't move out of the way fast enough
	var _will_godot_please_shut_up_about_unused_variables = $EnemyModel.connect("area_entered", self, "collide_ship")
	
	# Adjusts the ShipDetection node's size
	$ShipDetection/CollisionShape.shape.extents = $EnemyModel.get_child(0).shape.extents
	$ShipDetection/CollisionShape.shape.extents.z *= 2
	# Uncomment and add a cube MeshInstance to the ShipDetection node with dimensions (2, 2, 2) to have a visual helper
#	$ShipDetection/MeshInstance.scale = $ShipDetection/CollisionShape.shape.extents

	# Moves the health bar above the ship model. First, it gets the $EnemyModel/ShipModel
	# Then it gets the base size of that, multiplies that by its scale, and then moves the health bar down .5 for aesthetic purposes.
	# Remember that a negative Z value actually moves the health bar UP.
	$HealthBar.translation.z = -($EnemyModel/ShipModel.get_aabb().size.z * $EnemyModel.scale.z) + .5


# Called to process health
func _process(_delta):
	# If the health is below or equal to zero, explode the ship.
	if health <= 0:
		explode_ship()

	# If the health is between 100% and 0%, show the health bar.
	if health < max_health and health > 0:
		$HealthBar.show()
		$HealthBar.health = health
		$HealthBar.max_health = max_health


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
	$HealthBar.hide()
	$EnemyModel.queue_free()
	remove_from_group("enemies")
	if has_node("/root/Main/ShakeCamera"):
		get_node("/root/Main/ShakeCamera").add_trauma(.4)  # Shakes the screen
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
