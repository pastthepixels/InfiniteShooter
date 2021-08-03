extends Label

func alert( alert_text ):
	
	text = alert_text
	$AnimationPlayer.play( "slide" )
	$Timer.start()

func error( error_text ):
	alert( error_text )
	$ErrorSound.play()
	Input.start_joy_vibration( 0, 0.6, 1, .2 ) # Vibrates a controller if you have one

func _on_Timer_timeout():
	$AnimationPlayer.play_backwards( "slide" )
