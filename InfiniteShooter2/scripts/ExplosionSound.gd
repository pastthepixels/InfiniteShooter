extends AudioStreamPlayer


# Engine vars
export (AudioStream) var Sound

# Called when the node enters the scene tree for the first time.
func _ready():
	
	stream = Sound
	pitch_scale = rand_range( 0.8, 1.2 )
