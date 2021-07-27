extends Control

func _input( event ):
	
	if event.is_action_pressed( "pause" ):
		
		if visible == true:
			
			fade_out()
			yield( $BackgroundTween, "tween_completed" )
		
		visible = !visible
		get_tree().paused = visible
		fade_in()
		
		# If the screen isn't visible, you have resumed the game and thus a sound should be played. If it is, play a pause sound.
		if visible == false: $ResumeSound.play()
		if visible == true: $PauseSound.play()
			

func fade_in():
	
	$BackgroundTween.interpolate_property( $Background, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), .3, Tween.TRANS_BACK, Tween.EASE_OUT )
	$BackgroundTween.start()

func fade_out():
	
	$BackgroundTween.interpolate_property( $Background, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), .3, Tween.TRANS_BACK, Tween.EASE_IN )
	$BackgroundTween.start()
