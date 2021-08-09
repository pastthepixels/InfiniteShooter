extends Control

func show_animated():
	show()
	$AnimationPlayer.play("open")

func hide_animated():
	$AnimationPlayer.play_backwards("open")
	yield($AnimationPlayer, "animation_finished")
	hide()

# To handle when something is selected -- all input starts from the main menu but go over here for the upgrade screen
func handle_selection():
	match $VBoxContainer/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"Back":
			hide_animated()
			get_node("../SelectSquare").show()
