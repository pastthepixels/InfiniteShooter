extends Control

func _input( event ):
	
	if event.is_action_pressed( "pause" ):
		
		if visible == true:
			
			fade_out()
			yield( $Tween, "tween_completed" )
		
		visible = !visible
		get_tree().paused = visible
		fade_in()
			

func fade_in():
	
	$Tween.interpolate_property( $Background, "color", Color( 0, 0, 0, 0 ), Color( 0, 0, 0, .8 ), .3, Tween.TRANS_BACK, Tween.EASE_OUT )
	$Tween.start()

func fade_out():
	
	$Tween.interpolate_property( $Background, "color", Color( 0, 0, 0, .8 ), Color( 0, 0, 0, 0 ), .3, Tween.TRANS_BACK, Tween.EASE_IN )
	$Tween.start()
