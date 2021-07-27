extends Spatial

# Game vars
export var damage = .1
export var max_health = 1
var health = max_health

# Engine vars
onready var main = get_tree().get_root().get_node( "Main" )
var utils
var enemy
export (PackedScene) var Enemy1
export (PackedScene) var Enemy2
export (PackedScene) var Enemy3
export (PackedScene) var Laser

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Initializes the instance of the class Utils
	utils = load( "res://scripts/Utils.gd" ).new()
	utils.init( get_viewport() )
	
	# Adds an enemy
	var enemyType = utils.randint( 0, 2 )
	match enemyType: # Actually a switch statement!
		
		0:
			enemy = Enemy1.instance()
			$MovingTimer.wait_time = 0.002
			
		1:
			enemy = Enemy2.instance()
			$MovingTimer.wait_time = 0.003
			
		2:
			enemy = Enemy3.instance()
			$MovingTimer.wait_time = 0.001
			
	add_child( enemy )
	$MovingTimer.start()
	$LaserTimer.start()
	$HealthBar.hide() # Hides the health bar by default.
	
	# Moves the health bar above the ship model. First, it gets the mesh in the model:
	# This scene
	#  |-->  Enemy model scene (Area)
	#			|--> Enemy glTF (Spatial) (first child)
	#					|--> Enemy model (mesh) (first/only child)
	# Then it gets the base size of that, multiplies that by its scale, and then moves the health bar down .5 for aesthetic purposes.
	# Remember that a negative Z value actually moves the health bar UP.
	$HealthBar.transform.origin.z = -( enemy.get_child( 0 ).get_child( 0 ).get_aabb().size.z * enemy.scale.z ) + .5

	
# Called to process GAME stuff like health
func _process( delta ):
	
	if health <= 0: explode_ship()
	if ( health / max_health ) < 1 and health > 0: $HealthBar.show()# If the health is between 100% and 0%, show the health bar.
	$HealthBar.health = health
	$HealthBar.max_health = max_health

func move_down():
	
	transform.origin.z += .1
	if transform.origin.z > utils.screen_to_local( Vector2( 0, utils.screen_size.y ) ).z:
		
		if get_parent().get_node( "Player" ) != null: get_parent().get_node( "Player" ).health -= health # This check makes sure if the player is still in the scene, meaning that is still alive.
		health = 0

func explode_ship():
	
	if !$Explosion.exploding: # If the explosion is exploding when this function is called, chances are it's being called twice. We don't want that.
		
		$Explosion.explode()
		$MovingTimer.stop()
		$LaserTimer.stop()
		$HealthBar.hide()
		enemy.queue_free()
		main.get_node( "Camera" ).get_node( "ScreenShake" ).shake( .1, .5 )
 
func cleanup_ship():
	
	queue_free()


func fire_laser():
	
	var laser = Laser.instance()
	laser.from_player = false
	laser.transform.origin = transform.origin
	laser.transform.origin.z += 1 # Makes the laser come from the "top" of the ship instead of the center for added realism
	laser.damage = damage
	main.get_node( "Game" ).add_child( laser ) # Gets the scene "Main" and adds to it this laser
