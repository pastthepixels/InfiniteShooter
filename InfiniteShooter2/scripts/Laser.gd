extends Area


# Declare member variables here. Examples:
onready var main = get_tree().get_root().get_node( "Main" )
onready var utils = load( "res://scripts/Utils.gd" ).new()
export var damage = 0
export var from_player = true
var freeze = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	utils.init( get_viewport() )
	if from_player == false: # By default the player laser is visible where the enemy laser model is not. If this laser is from an enemy, swap this.
		
			$PlayerLaser.hide()
			$EnemyLaser.show()
	
	$LaserSound.pitch_scale = rand_range( 0.9, 1.1 )
	$LaserSound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if freeze == true:
		
		return
		
	if from_player == true:
		
		translation.z -= .4 # If the laser is from the player, move it up
	
	else:
		
		translation.z += .4 # otherwise, it's from an enemy ship, so move it down.
		
	if translation.z < utils.screen_to_local( Vector2( 0, 0 ) ).z or\
	   translation.z > utils.screen_to_local( Vector2( 0, utils.screen_size.y ) ).z: # If the laser goes past the top of the screen (or the bottom of it)...
		
		remove_laser( false ) # ...remove it

# Called when the laser collides with objects
func on_collision( area ):
	
	if area.get_parent().is_in_group( "enemy" ) and from_player == true: # If the area this is colliding with is an enemy (and it is from the player)
		
		area.get_parent().health -= damage # subtract health from the enemy
		remove_laser( true ) # and remove the laser
	
	if ( "Player" in area.name ) and from_player == false: # If the area this is colliding with is the PLAYER (and it is from the enemy)
		 
		area.health -= damage # send it to BRAZIL
		area.emit_signal( "health_changed", float(area.health) / float(area.max_health) )
		Input.start_joy_vibration(0, 0.6, 1, .1) # vibrate any controllers a bit
		remove_laser( true ) # and remove the laser

func remove_laser( hit_ship ):
	
	if freeze == true: # The variable "freze" is a good indicator of whether this function was called or not. This function cannot be called twice!
		
		return
	
	freeze = true
	hide()
	$CollisionShape.queue_free()
	if hit_ship == true:
		
		$HitSound.pitch_scale = rand_range( 0.9, 1.1 )
		$HitSound.play()
		yield( $HitSound, "finished" )
	
	yield( $LaserSound, "finished" )
	queue_free()
