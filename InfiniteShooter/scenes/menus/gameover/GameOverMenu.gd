extends Control

onready var game = get_parent()

onready var game_space = get_node("." + game.game_space)

onready var main = get_node("/root/Main")


# Called when the node enters the scene tree for the first time.
func fade_show():
	if visible == true: return
	$AnimationPlayer.play("FadeAll")
	yield($AnimationPlayer, "animation_finished")
	$SelectSquare/AnimationPlayer.play("Fade")


func _on_SelectSquare_selected():
	match $Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
		"Retry":  # If it is the one named "play", play the game.
			SceneTransition.restart_game()

		"Quit":  # Otherwise, quit the game
			SceneTransition.quit_game()

		"MainMenu":  # or return to the main menu
			SceneTransition.main_menu()


func _on_AnimationPlayer_animation_started(anim_name):
	visible = true
