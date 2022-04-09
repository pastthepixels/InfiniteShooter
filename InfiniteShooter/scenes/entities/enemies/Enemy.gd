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

var last_hit_from

# Powerups

onready var create_powerup = randi() % 4 == 1

var powerup_type = null

# Death

signal died(this, from_player)

# Laser modifiers

var freeze_movement = false

var laser_modifier = GameVariables.LASER_MODIFIERS.values()[randi() % GameVariables.LASER_MODIFIERS.size()]

# Bounding box stuff

var bounding_box

# Scenes used

export(PackedScene) var powerup_scene

var enemy_types = {
	"normal": preload("res://scenes/entities/enemies/Normal.tscn"),
	"small": preload("res://scenes/entities/enemies/Small.tscn"),
	"tank": preload("res://scenes/entities/enemies/Tank.tscn"),
	"explosive": preload("res://scenes/entities/enemies/Explosive.tscn"),
	"multishot": preload("res://scenes/entities/enemies/Multishot.tscn"),
	"quadshot": preload("res://scenes/entities/enemies/Quadshot.tscn"),
	"gigatank": preload("res://scenes/entities/enemies/Gigatank.tscn")
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
			max_health = 80
			damage = 15
			speed_mult = 1

		GameVariables.ENEMY_TYPES.small:
			enemy_model = enemy_types["small"].instance()
			# Sets enemy stats
			max_health = 20
			damage = 10
			speed_mult = 1.5

		GameVariables.ENEMY_TYPES.tank:
			enemy_model = enemy_types["tank"].instance()
			# Sets enemy stats
			max_health = 100
			damage = 10
			speed_mult = .8
		
		GameVariables.ENEMY_TYPES.gigatank:
			enemy_model = enemy_types["gigatank"].instance()
			# Sets enemy stats
			max_health = 200
			damage = 20
			speed_mult = .5
		
		GameVariables.ENEMY_TYPES.explosive:
			enemy_model = enemy_types["explosive"].instance()
			# Sets enemy stats
			max_health = 10
			damage = 100
			speed_mult = .6
		
		GameVariables.ENEMY_TYPES.multishot:
			enemy_model = enemy_types["multishot"].instance()
			# Sets enemy stats
			max_health = 120
			damage = 15
			speed_mult = .7
		
		GameVariables.ENEMY_TYPES.quadshot:
			enemy_model = enemy_types["quadshot"].instance()
			# Sets enemy stats
			max_health = 70
			damage = 10
			speed_mult = .9
	
	# Adds the enemy model
	add_child(enemy_model)
	
	# Removes other enemy ships
	for child in get_children():
		if child.has_node("Ship") and child != enemy_model: #COMMON FACTOR BETWEEN ALL ENEMY SHIP MODELS: THEY HAVE THE NODE "SHIP"
			child.queue_free()
	
	# Multiplies everything by the difficulty number for added difficulty.
	var mult = float(difficulty) / 2
	max_health *= clamp(mult, .5, 512)
	damage *= clamp(mult, 1, 512)
	speed_mult *= clamp(mult / 5, 1, 3)
	
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


# To move the ship/calculate health
var previous_health
func _process(_delta):
	if has_node("/root/Game/GameSpace/Player") and get_node("/root/Game/GameSpace/Player").health - (health*GameVariables.enemy_collision_damage_multiplier) >= get_node("/root/Game/GameSpace/Player").max_health*0.3 and enemy_model.has_node("OutlineAnimations"):
		enemy_model.get_node("OutlineAnimations").play("FlashOutline")
	elif has_node("/root/Game/GameSpace/Player") and get_node("/root/Game/GameSpace/Player").health - (health*GameVariables.enemy_collision_damage_multiplier) < get_node("/root/Game/GameSpace/Player").max_health*0.3 and enemy_model.has_node("OutlineAnimations"):
		enemy_model.get_node("OutlineAnimations").play("RESET")
	if health != previous_health:
		previous_health = health
		update_health()

func _physics_process(delta):
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
	emit_signal("died", self, from_player)
	# Powerups (1/4 chance to create a powerup)
	if create_powerup and use_laser_modifiers == false:
		var powerup = powerup_scene.instance()
		if powerup_type != null: powerup.type = powerup_type
		powerup.translation = translation
		get_parent().add_child(powerup)
	elif use_laser_modifiers == true:
		var powerup = powerup_scene.instance()
		powerup.translation = translation
		powerup.modifier = laser_modifier
		get_parent().add_child(powerup)
	
	# then explodes
	$Explosion.explode()


func _on_Explosion_exploded():
	queue_free()


func _on_LaserTimer_timeout():
	# Some ships don't shoot lasers...
	if enemy_model.has_node("LaserGuns") == false:
		return
	
	# ...and some do
	for LaserGun in enemy_model.get_node("LaserGuns").get_children():
		LaserGun.damage = damage
		#LaserGun.follow_player = use_homing_lasers
		if use_laser_modifiers:
			LaserGun.use_laser_modifiers = true
			LaserGun.laser_modifier = laser_modifier
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
		if last_hit_from != null and is_instance_valid(last_hit_from) and (last_hit_from.get_parent().is_in_group("players") || last_hit_from.is_in_group("players")):
			explode_ship(true)
		else:
			explode_ship()
	last_hit_from = null

func hurt(damage):
	health -= damage

func _on_ship_body_entered(body):
	if body.is_in_group("players"):
		body.on_enemy_collision(self)
	else:
		explode_ship() # Otherwise the ship collided with something the player can collide with, so it would look weird if it passed through, so... we kill it.
