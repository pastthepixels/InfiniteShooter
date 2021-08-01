extends Spatial

# Game vars
var damage
var max_health = 1
var health = max_health

# Engine vars
export (PackedScene) var Enemy1
export (PackedScene) var Enemy2
export (PackedScene) var Enemy3
export (PackedScene) var Laser
export (PackedScene) var Powerup
onready var game = get_node( "../" ) # Enemies are placed directly inside the "Game" node.
onready var player = get_node( "../Player" )
var utils

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize() # Makes more random numbers
	# Initializes the instance of the class Utils
	utils = load( "res://scripts/Utils.gd" ).new()
	utils.init( get_viewport() )
	
func initialize():
	# Adds an enemy
	var enemyType = randi() % 3 + 1 # Generates either a 1, 2, or 3
	match enemyType: # Actually a switch statement!
		
		1:
			add_child( Enemy1.instance() )
			
			# Sets enemy stats
			max_health = .8
			health = max_health
			damage = .07
			$MovingTimer.wait_time = 0.002
			
		2:
			add_child( Enemy2.instance() )
			
			# Sets enemy stats
			max_health = .4
			health = max_health
			damage = .1
			$MovingTimer.wait_time = 0.003
			
		3:
			add_child( Enemy3.instance() )
			
			# Sets enemy stats
			max_health = 1.2
			health = max_health
			damage = .05
			$MovingTimer.wait_time = 0.001
	
	# Multiplies everything by the level number for added difficulty.
	if game.level > 1:
		
		var mult = game.level / 2
		max_health *= mult
		health = max_health
		damage *= mult
	
	# Starts all timers
	$MovingTimer.start()
	$LaserTimer.start()
	$HealthBar.hide() # Hides the health bar by default.
	
	# Moves the health bar above the ship model. First, it gets the mesh in the model:
	# This scene
	#  |-->  Enemy model scene (Area)
	#		|--> Enemy model (mesh) (all titled "ShipModel")
	# Then it gets the base size of that, multiplies that by its scale, and then moves the health bar down .5 for aesthetic purposes.
	# Remember that a negative Z value actually moves the health bar UP.
	$HealthBar.translation.z = -( $EnemyModel/ShipModel.get_aabb().size.z * $EnemyModel.scale.z ) + .5
	
# Called to process GAME stuff like health
func _process( _delta ):
	
	# Uncovering the mystery: `health` is actually around 0.00000000001 99% of the time for some reason but Godot chooses to print it as 0.
	# Hence, it doesn't == 0 and you will never know why because it says "0".
	# And I spent countelss hours trying to fix the next `if` statement because of it. 
	health = stepify( health, 0.01 )
	
	if health == 0: explode_ship()
	
	if ( health / max_health ) < 1 and health > 0: $HealthBar.show()# If the health is between 100% and 0%, show the health bar.
	$HealthBar.health = health
	$HealthBar.max_health = max_health

func move_down():
	
	translation.z += .05
	if translation.z > utils.screen_to_local( Vector2( 0, utils.screen_size.y ) ).z:
		
		if get_parent().get_node( "Player" ) != null: get_parent().get_node( "Player" ).health -= health # This check makes sure if the player is still in the scene, meaning that is still alive.
		health = 0

func explode_ship():
	
	if $Explosion.exploding: return # If the explosion is exploding when this function is called, chances are it's being called twice. We don't want that.
		
	$Explosion.explode()
	$MovingTimer.stop()
	$LaserTimer.stop()
	$HealthBar.hide()
	$EnemyModel.queue_free()	
	game.get_node( "../Camera" ).get_node( "ScreenShake" ).shake( .1, .5 )
	if randi() % 5 <= 2:
		var powerup = Powerup.instance()
		powerup.translation = translation
		game.add_child( powerup )
 
func cleanup_ship():
	
	queue_free()


func fire_laser():
	
	# If the player is not close to the enemy (5 metres in this case), why shoot a laser? This helps with performance and also with basic logic
	if game.has_node( "Player" ) and abs( player.translation.x - translation.x ) > 5: return
	
	# Creating the laser
	var laser = Laser.instance()
	
	# Telling the laser that it is not from the player + sets its damage
	laser.from_player = false
	laser.damage = damage
	
	# Setting the laser's position
	laser.translation = translation
	laser.translation.z += 1 # Makes the laser come from the "top" of the ship instead of the center for added realism
	
	# Gets the scene "Main" and adds to it this laser
	game.add_child( laser )
