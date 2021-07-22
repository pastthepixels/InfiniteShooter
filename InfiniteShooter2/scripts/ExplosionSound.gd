extends AudioStreamPlayer


# Engine vars
export (AudioStream) var Sound1
export (AudioStream) var Sound2
export (AudioStream) var Sound3


# Called when the node enters the scene tree for the first time.
func _ready():
	
	stream = [ Sound1, Sound2, Sound3][ randi() % 3 ]
