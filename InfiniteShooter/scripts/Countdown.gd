extends Control


# Declare member variables here. Examples:
export var starting_number = 3
signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range( 0, starting_number + 1 ):
		if i == starting_number:
			
			$FinishedSound.play()
		
		else:
			
			$CountdownSound.play()
			
		$Label.text = str( starting_number - i )
		$AnimationPlayer.play( "show" )
		yield( $AnimationPlayer, "animation_finished" )
		yield( get_tree().create_timer( .5 ), "timeout" ) # Waits a bit for the gamer to see the text
	emit_signal( "finished" )
	queue_free()
