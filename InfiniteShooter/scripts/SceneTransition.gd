extends Control

var callback

func _ready():
	
	VisualServer.canvas_item_set_z_index( get_canvas_item(), 100 ) # Tells Godot that this will be drawn over absolutely anything and everything else -- this is a transition, after all.
	
# Called when the node enters the scene tree for the first time.
func play( callback_object, callback_function ):
	
	show()
	callback = funcref( callback_object, callback_function )
	$SoundEffect.pitch_scale = rand_range( 0.9, 1.1 )
	$SoundEffect.play()
	$AnimationPlayer.play( "Wipe1" )

func _on_AnimationPlayer_animation_finished( anim_name ):
	
	if anim_name == "Wipe1":
		
		callback.call_func()
		$AnimationPlayer.play( "Wipe2" )
	
	if anim_name == "Wipe2":
		
		hide()
