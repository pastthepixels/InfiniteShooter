extends Control

func start():
	if visible == true: return
	$AnimationPlayer.play("FadeAll")


func _on_SelectSquare_selected():
	match $Options.get_child($SelectSquare.index).name:
		"Retry":
			SceneTransition.restart_game()

		"Quit":
			SceneTransition.quit_game()

		"MainMenu":
			SceneTransition.main_menu()


func _on_AnimationPlayer_animation_started(anim_name):
	visible = true


func _on_AnimationPlayer_animation_finished(anim_name):
	$SelectSquare/AnimationPlayer.play("Fade")
