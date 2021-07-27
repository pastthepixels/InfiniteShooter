extends AudioStreamPlayer

func _ready():
	
	pitch_scale = rand_range( 0.95, 1.05 ) # Relaxed pitch variation by default (because the player is shooting the laser)
	
func set_enemy_sound(): # Changes the default pitch when the program realizes that the player is NOT the one shooting a laser.
	
	pitch_scale = rand_range( 0.8, 1.2 )
