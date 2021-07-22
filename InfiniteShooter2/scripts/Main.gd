extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( delta ):
	
	if $Game.has_node( "Player" ) == true: # If the player is still in the scene, meaning that it is still alive, set GUI progress bars
		
		$GameHUD/HealthBar.target_value = $Game/Player.health / $Game/Player.max_health * 100 # FLOAT DIVISION
		$GameHUD/AmmoBar.target_value = float( $Game/Player.ammo ) / float( $Game/Player.max_ammo ) * 100 # FLOAT DIVISION
