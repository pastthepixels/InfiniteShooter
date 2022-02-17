extends Spatial

# Health, damage, & misc
var damage = 10

export var max_health = 2000

var health = max_health

export var explosions = 10

onready var enemy_model = $EnemyModel

var last_hit_from

# Dying

signal died(current_ship)

var killed_from_player = false

# Moving around
export(Array, Curve3D) var paths

# Laser mechanics
var freeze_movement = false

var cannon_alternation = false

# Homing lasers
export var homing_lasers = true

onready var followed_player = get_tree().get_nodes_in_group("players")[randi() % get_tree().get_nodes_in_group("players").size()] if len(get_tree().get_nodes_in_group("players")) > 0 else null

# Scenes used
export(PackedScene) var laser_scene

export(PackedScene) var explosion_scene


func initialize(difficulty):
	# Sets up the path to follow
	$Path.curve = paths[randi() % len(paths)]
	$Path/PathFollow.unit_offset = 0
	
	# Sets up explosions
	for _i in range(0, explosions):
		var explosion = explosion_scene.instance()
		explosion.hide()
		explosion.translation = Vector3(rand_range(-1.5, 1.5), rand_range(-.5, .5), rand_range(-1.5, 1.5))
		$Explosions.add_child(explosion)
	
	# Multiplies everything by the difficulty number for added difficulty (same as we would for Enemy.gd)
	max_health *= difficulty
	damage *= difficulty
	
	# Sets the current health as the new max health
	health = max_health
	
	# Mini-cutscene
	$Tween.interpolate_property(self, "translation:z", translation.z, 0, 4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	$Tween.interpolate_property(self, "translation", translation, $Path/PathFollow.translation, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	# Begins shooting fter the cutscene
	$LaserTimer.start()


# Called to process health and movement
func _process(delta):
	# Looking at the player
	if is_instance_valid(followed_player) and followed_player.health > 0 and health > 0:
		smooth_look_at(delta, 3)
	elif health > 0 and rotation.y != 0 and $Tween.is_active() == false:
		$Tween.interpolate_property(self, "rotation:y", rotation.y, (deg2rad(0) if rotation.y < deg2rad(180) else deg2rad(360)), 5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()
		$LaserTimer.stop()
	
	# If the health is between 100% and 0%, show the health bar.
	if health < max_health and health > 0:
		$HealthBar.show()
		$HealthBar.health = health
		$HealthBar.max_health = max_health
	elif health <= 0:
		set_process(false)
		$HealthBar.hide()
		explode_ship() # otherwise, explode the ship
		return
	
	# Moving around
	if (freeze_movement or $Tween.is_active()) == false:
		translation = $Path/PathFollow.translation
		$Path/PathFollow.unit_offset += .05 * delta

func smooth_look_at(delta, weight):
	# A. Creates a new Transform that is facing the player
	var new_transform = global_transform.looking_at(followed_player.translation, Vector3(0, 1, 0))
	# B. Rotates it 180 degrees
	new_transform = new_transform.rotated(Vector3(0, 1, 0), deg2rad(180))
	# C. Creates a quaternion to slerp between rotations, then applies it
	var new_quaternion = Quat(global_transform.basis).slerp(Quat(new_transform.basis), delta * weight)
	global_transform = Transform(Basis(new_quaternion), global_transform.origin)


func explode_ship():
	emit_signal("died", self)
	remove_from_group("enemies")
	$LaserTimer.stop()
	$EnemyModel.queue_free()
	$LaserEffects.reset()
	$Explosions.show()
	$Tween.stop_all()
	for explosion in $Explosions.get_children():
		explosion.explode()
		yield(Utils.timeout(.1), "timeout")
		if has_node("/root/Main/ShakeCamera"):
			get_node("/root/Main/ShakeCamera").add_trauma(.05)  # Shakes the screen
	yield($Explosions.get_child(explosions - 1), "exploded")
	queue_free()


func fire_laser():
	$EnemyModel/Boss/Cannon1.damage = damage
	$EnemyModel/Boss/Cannon2.damage = damage
	
	if health <= max_health/3: # Stage 3
		$EnemyModel/Boss/Cannon1.fire()
		$EnemyModel/Boss/Cannon2.fire()
	
	if health <= 2 * max_health/3: # Stage 2
		$EnemyModel/Boss/Cannon1.follow_player = true
		$EnemyModel/Boss/Cannon2.follow_player = true
	
	if health > max_health/3: # Stage 1 (this applies to both stages 1&2)
		cannon_alternation = !cannon_alternation
		if cannon_alternation:
			$EnemyModel/Boss/Cannon1.fire()
		else:
			$EnemyModel/Boss/Cannon2.fire()
