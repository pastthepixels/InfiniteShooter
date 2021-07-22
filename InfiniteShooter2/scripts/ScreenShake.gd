extends Spatial

onready var camera = get_parent()
var running = false
var timer = Timer.new()
var intensity = 0

func shake( newIntensity, duration ):
	
	intensity = newIntensity
	running = true
	
	# Disposes of old timers
	timer.stop()
	# Creates a new timer
	timer = Timer.new()
	
	# sets its wait time for the duration of the animation in seconds
	timer.wait_time = duration
	
	# when the timer ends, run end_shake
	timer.connect( "timeout", self, "end_shake" )
	
	# adds the timer to the scene and starts it
	add_child( timer )
	timer.start()

func end_shake():
	
	# Resets the camera's position
	camera.transform.origin.x = 0
	camera.transform.origin.z = 0
	
	# and sets "running" to false.
	running = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( delta ):
	
	if running == true:
		
		camera.transform.origin.x = rand_range(-1.0, 1.0) * intensity
		camera.transform.origin.z = rand_range(-1.0, 1.0) * intensity
