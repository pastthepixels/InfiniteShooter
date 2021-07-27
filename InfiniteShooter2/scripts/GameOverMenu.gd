extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func fade_show():
	
	$Image.modulate = Color( 1, 1, 1, 0 ) # Makes the image transparent
	show() # THEN shows it
	# THEN animates it to being fully opaque again!
	$FadeTween.interpolate_property( $Image, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), 4, Tween.TRANS_LINEAR, Tween.EASE_OUT )
	$FadeTween.start()
