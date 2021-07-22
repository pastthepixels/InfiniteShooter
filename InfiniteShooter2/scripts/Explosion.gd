extends Spatial


# Declare member variables here.
signal exploded

# Called when the node enters the scene tree for the first time.
func _ready():
	
	hide() # Hides the animation until needed

func explode():
	
	show()
	$ExplosionAnimation.playing = true
	Input.start_joy_vibration( 0, 0.5, 0.7, .2 ) # Vibrates a controller if you have one

func end_explosion():
	
	emit_signal( "exploded" )
	queue_free()
