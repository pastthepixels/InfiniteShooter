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

var use_laser_modifiers = (randi() % 10 == 1)

# Powerups

var force_powerup

var powerup_randomness = 5 # 1/x chance that a non-ammo-related powerup will be available

var powerup_type = null

# Death

signal died(this)

signal exited_screen(this)

# Laser modifiers

var freeze_movement = false

var laser_modifier = GameVariables.LASER_MODIFIERS.values()[randi() % GameVariables.LASER_MODIFIERS.size()]

# Bounding box stuff

var bounding_box

# Scenes used

var powerup_scene = LoadingScreen.access_scene("res://scenes/entities/powerups/Powerup.tscn")

var enemy_types = {
	"normal": LoadingScreen.access_scene("res://scenes/entities/enemies/Normal.tscn"),
	"small": LoadingScreen.access_scene("res://scenes/entities/enemies/Small.tscn"),
	"tank": LoadingScreen.access_scene("res://scenes/entities/enemies/Tank.tscn"),
	"explosive": LoadingScreen.access_scene("res://scenes/entities/enemies/Explosive.tscn"),
	"multishot": LoadingScreen.access_scene("res://scenes/entities/enemies/Multishot.tscn"),
	"quadshot": LoadingScreen.access_scene("res://scenes/entities/enemies/Quadshot.tscn"),
	"gigatank": LoadingScreen.access_scene("res://scenes/entities/enemies/Gigatank.tscn")
}

var enemy_model

func initialize(difficulty, possible_enemy_types=null):
	if possible_enemy_types != null:
		enemy_type = possible_enemy_types[randi() % possible_enemy_types.size()]
	
	# Adds an enemy model and sets stats for that model
	match enemy_type:
		GameVariables.ENEMY_TYPES.normal:
			enemy_model = enemy_types["normal"].instance()
			# Sets enemy stats
			max_health = 40
			damage = 6
			speed_mult = 2

		GameVariables.ENEMY_TYPES.small:
			enemy_model = enemy_types["small"].instance()
			# Sets enemy stats
			max_health = 10
			damage = 5
			speed_mult = 3

		GameVariables.ENEMY_TYPES.tank:
			enemy_model = enemy_types["tank"].instance()
			# Sets enemy stats
			max_health = 60
			damage = 8
			speed_mult = 1.6
		
		GameVariables.ENEMY_TYPES.gigatank:
			enemy_model = enemy_types["gigatank"].instance()
			# Sets enemy stats
			max_health = 100
			damage = 10
			speed_mult = 1
		
		GameVariables.ENEMY_TYPES.explosive:
			enemy_model = enemy_types["explosive"].instance()
			# Sets enemy stats
			max_health = 2
			damage = 100
			speed_mult = 1.2
		
		GameVariables.ENEMY_TYPES.multishot:
			enemy_model = enemy_types["multishot"].instance()
			# Sets enemy stats
			max_health = 60
			damage = 4
			speed_mult = .7
		
		GameVariables.ENEMY_TYPES.quadshot:
			enemy_model = enemy_types["quadshot"].instance()
			# Sets enemy stats
			max_health = 45
			damage = 8
			speed_mult = 1.8
	
	# Adds the enemy model
	add_child(enemy_model)
	
	# Removes other enemy ships
	for child in get_children():
		if child.has_node("Ship") and child != enemy_model: #COMMON FACTOR BETWEEN ALL ENEMY SHIP MODELS: THEY HAVE THE NODE "SHIP"
			child.queue_free()
	
	# Does math on the max health/damage to implement difficulty
	max_health	+= GameVariables.health_diff * (difficulty - 1)
	damage		+= GameVariables.damage_diff * (difficulty - 1)
	
	# Sets the current health as the new max health
	self.health = max_health
	
	# Gets the bounding box for the enemy ship model
	bounding_box = enemy_model.get_node("Ship").get_aabb()

	# Starts all timers
	$LaserTimer.start()
	
	# Kills ships that don't move out of the way fast enough
	enemy_model.connect("area_entered", self, "collide_ship")
	
	# Some more stuff
	enemy_model.connect("body_entered", self, "_on_ship_body_entered")
	
	# Moves health bar into position
	$HealthBar2D.translation.z = -(bounding_box.size.z * enemy_model.scale.z) + .5
	$HealthBar2D.max_health = max_health
	$HealthBar2D.health = health
	
	# Updates an enemy's laser gun to reflect its damage
	if enemy_model.has_node("LaserGuns"):
		for LaserGun in enemy_model.get_node("LaserGuns").get_children():
			LaserGun.damage = damage
			#LaserGun.follow_player = use_homing_lasers
			if use_laser_modifiers:
				LaserGun.use_laser_modifiers = true
				LaserGun.laser_modifier = laser_modifier


# To move the ship/calculate health
var previous_health
func _process(_delta):
	if has_node("/root/Game/GameSpace/Player") and enemy_model.has_node("OutlineAnimations") and ((health / max_health) < GameVariables.powerup_health_ratio or health < GameVariables.powerup_health_points):
		enemy_model.get_node("OutlineAnimations").play("FlashOutline")
	if health != previous_health:
		previous_health = health
		update_health()

func _physics_process(delta):
	if freeze_movement: return
	translation.z += 2 * speed_mult * delta


func explode_ship(silent=false):
	alive = false
	
	# Stops moving
	set_physics_process(false)
	
	# Does any last things depending on enemy type (ex. explosive enemies would take health from surrounding enemies)
	match enemy_type:
		GameVariables.ENEMY_TYPES.explosive:
			enemy_model.explode()
			yield(enemy_model, "exploded")
	
	# Resets, emitting a signal at the end
	$LaserTimer.stop()
	$LaserEffects.reset()
	$HealthBar2D.hide()
	for node in get_children():
		if node is Area:
			node.queue_free()
	remove_from_group("enemies")
	set_process(false)
	if silent == false: emit_signal("died", self)
	
	# Powerups
	if $VisibilityNotifier.is_on_screen() and has_node(self.get_path()):
		var powerup = powerup_scene.instance()
		powerup.translation = translation
		if force_powerup == true and use_laser_modifiers == false: # <-- Forced custom powerups
			if powerup_type != null: powerup.type = powerup_type
			get_parent().add_child(powerup)
		elif use_laser_modifiers == true: # <-- Laser modifiers
			powerup.modifier = laser_modifier
			get_parent().add_child(powerup)
		elif get_tree().get_nodes_in_group("players")[0].health < 30 and (randi() % powerup_randomness) == 1: # <-- Health
			powerup.type = GameVariables.POWERUP_TYPES.medkit
			get_parent().add_child(powerup)
		elif get_tree().get_nodes_in_group("players")[0].ammo_refills <= 5 or (randi() % (powerup_randomness * 2)) == 1 and get_tree().get_nodes_in_group("players")[0].ammo_refills <= 20: # <-- Ammo (rarer)
			powerup.type = GameVariables.POWERUP_TYPES.ammo
			get_parent().add_child(powerup)
	
	# then explodes
	if silent == false:
		$Explosion.explode()
	else:
		_on_Explosion_exploded()

func _on_Explosion_exploded():
	if $LaserEffects.resetting: yield($LaserEffects, "finished_reset")
	queue_free()


func _on_LaserTimer_timeout():
	if enemy_model.has_node("LaserGuns") == true:
		for LaserGun in enemy_model.get_node("LaserGuns").get_children():
			LaserGun.fire()


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
		$HealthBar2D.visible = true
		$HealthBar2D.health = health
	if health <= 0 and alive == true:
		explode_ship()

func hurt(hurt_amount):
	health -= hurt_amount

func _on_ship_body_entered(body):
	if body.is_in_group("players"):
		body.on_enemy_collision(self)
	else:
		explode_ship() # Otherwise the ship collided with something the player can collide with, so it would look weird if it passed through, so... we kill it.


func _on_VisibilityNotifier_screen_exited():
	if translation.z > 0: # Ensuring the enemy left the BOTTOM of the screen
		emit_signal("exited_screen", self)
		explode_ship(true)
