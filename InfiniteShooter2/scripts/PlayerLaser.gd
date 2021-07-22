extends Area


# Declare member variables here. Examples:
onready var utils = load( "res://scripts/Utils.gd" ).new()
export var damage = 0
export var from_player = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	utils.init( get_viewport() )
	if from_player == false: # By default the player laser is visible where the enemy laser model is not. If this laser is from an enemy, swap this.
		
			$PlayerLaser.hide()
			$EnemyLaser.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if from_player == true:
		
		transform.origin.z -= .4 # If the laser is from the player, move it up
	
	else:
		
		transform.origin.z += .4 # otherwise, it's from an enemy ship, so move it down.
		
	if transform.origin.z < utils.screen_to_local( Vector2( 0, 0 ) ).z or\
	   transform.origin.z > utils.screen_to_local( Vector2( 0, utils.screen_size.y ) ).z: # If the laser goes past the top of the screen (or the bottom of it)...
		
		queue_free() # ...remove it

# Called when the laser collides with objects
func on_collision( area ):
	
	if ( "Enemy" in area.name ) and from_player == true: # If the area this is colliding with is an enemy MODEL (and it is from the player)
		
		area.get_parent().health -= damage # subtract health from the enemy SCENE
		queue_free() # and remove the laser
	
	if ( "Player" in area.name ) and from_player == false: # If the area this is colliding with is the PLAYER (and it is from the enemy)
		
		area.health -= damage # send it to BRAZIL
		Input.start_joy_vibration(0, 0.6, 1, .1) # vibrate any controllers a bit
		queue_free() # and remove the laser
