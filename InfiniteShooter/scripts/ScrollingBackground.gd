extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func play():
	
	$AnimationPlayer.play( "RotateCamera" )

func stop():
	
	$AnimationPlayer.stop( true )
