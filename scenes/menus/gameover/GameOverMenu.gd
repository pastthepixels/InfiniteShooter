extends Control

signal done_opening

func start():
	$AnimationPlayer.play("FadeAll")
	CameraEquipment.slow_sky()


func _on_SelectSquare_selected():
	match $Options.get_child($SelectSquare.index).name:
		"Retry":
			SceneTransition.restart_game()

		"Quit":
			SceneTransition.quit_game()

		"MainMenu":
			SceneTransition.main_menu()


func _on_AnimationPlayer_animation_finished(_anim_name):
	if _anim_name != "RESET":
		$SelectSquare/AnimationPlayer.play("Fade")
		emit_signal("done_opening")
