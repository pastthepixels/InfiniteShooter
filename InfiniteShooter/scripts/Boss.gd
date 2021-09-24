extends Spatial

# Variables related to enemy properties

signal died(current_ship)

var killed_from_player = false

var damage = 10

var max_health = 2500

var health = max_health

var bounding_box

export var homing_lasers = true

# Scenes used
export var boss_type = 1

onready var laser_scene = load("res://scenes/Laser.tscn")

onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()] if len(get_tree().get_nodes_in_group("players")) > 0 else null


func _ready():
	initialize(1)


func initialize(difficulty):
	# Handles enemy types
#	match boss_type:
#		1:

	# Multiplies everything by the difficulty number for added difficulty (same as we would for Enemy.gd)
	max_health *= difficulty
	damage *= difficulty
	
	print(max_health)
	# Sets the current health as the new max health
	health = max_health
	
	# Gets the bounding box for the enemy ship model
	bounding_box = $EnemyModel/Boss.get_child(0).get_aabb()

	# Starts all timers and gets the health bar into position
	$LaserTimer.start()
	$HealthBar.translation.z = -(bounding_box.size.z * $EnemyModel.scale.z) + .5


# Called to process health and movement
func _process(delta):
	translation = $Path/PathFollow.translation
	$Path/PathFollow.unit_offset += .05 * delta
	# Looking at the player
	if is_instance_valid(followed_player) and followed_player.health > 0:
		look_at(followed_player.translation, Vector3(0, 1, 0))
		rotation.y += deg2rad(180)
	else:
		rotation.y = 0
	# If the health is between 100% and 0%, show the health bar.
	if health < max_health and health > 0:
		$HealthBar.show()
		$HealthBar.health = health
		$HealthBar.max_health = max_health
	elif health <= 0:
		$HealthBar.hide()
		explode_ship() # otherwise, explode the ship

func explode_ship():
	for explosion in $Explosions.get_children():
		if explosion.exploding: return
		explosion.explode()
		yield(Utils.timeout(.1), "timeout")
	$LaserTimer.stop()
	$EnemyModel.queue_free()
	remove_from_group("enemies")
	emit_signal("died", self)
	if has_node("/root/Main/ShakeCamera"):
		get_node("/root/Main/ShakeCamera").add_trauma(.4)  # Shakes the screen


func cleanup_ship():  # Used to "clean up" the ship for some event or something
	queue_free()


func fire_laser():
	# Creating the laser
	var laser = laser_scene.instance()
	laser.follow_player = true
	laser.sender = self

	# Telling the laser that it is not from the player + sets its damage
	laser.from_player = false
	laser.damage = damage

	# Setting the laser's position
	laser.translation = translation
	laser.translation.z += 1  # Makes the laser come from the "top" of the ship instead of the center for added realism
	
	# Specific stuff to do with boss types
	match boss_type:
		1:
			var cannon = rand_range(0, 1) > .5
			if cannon == false:
				laser.translation = $EnemyModel/Boss/Cannon1.translation
			else:
				laser.translation = $EnemyModel/Boss/Cannon2.translation
			laser.translation += translation

	# Gets the scene that housed the enemy and adds to it the laser
	get_parent().add_child(laser)
