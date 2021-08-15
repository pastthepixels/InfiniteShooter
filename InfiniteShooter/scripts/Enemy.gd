extends Spatial

# Variables related to enemy properties

var damage

var max_health = 100

var health = max_health

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
	var enemyType = randi() % 3 + 1  # Generates either a 1, 2, or 3
	match enemyType:
		1:
			add_child(enemy_scenes[0].instance())

			# Sets enemy stats
			max_health = 80
			damage = 7
			$MovingTimer.wait_time = 0.002

		2:
			add_child(enemy_scenes[1].instance())

			# Sets enemy stats
			max_health = 40
			damage = 10
			$MovingTimer.wait_time = 0.003

		3:
			add_child(enemy_scenes[2].instance())

			# Sets enemy stats
			max_health = 120
			damage = 5
			$MovingTimer.wait_time = 0.001

	# Multiplies everything by the level number for added difficulty.
	var mult = float(level) / 2
	max_health *= mult
	damage *= mult

	# Sets the current health as the new max health
	health = max_health

	# Starts all timers
	$MovingTimer.start()
	$LaserTimer.start()
	$HealthBar.hide()  # Hides the health bar by default.

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
	translation.z += .05
	# If it is such that the center of the ship moves past the center of the screen...
	if translation.z > Utils.screen_to_local(Vector2(0, Utils.screen_size.y)).z:
		if has_node("../Player"):
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
	if has_node("/root/Main/ShakeCamera"):
		get_node("/root/Main/ShakeCamera").add_trauma(.5)  # Shakes the screen
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
