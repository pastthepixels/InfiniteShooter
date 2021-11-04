extends Control


func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()


func _on_SelectSquare_selected():
	if is_visible():
		for player in get_tree().get_nodes_in_group("players"):
			player.set_process_input(false)  # To prevent the player from firing right as we unpause (since the input function runs at the same time)
		toggle_pause()
		match $Options.get_child($SelectSquare.index).name:
			"Retry":
				SceneTransition.restart_game()

			"Quit":
				SceneTransition.quit_game()

			"MainMenu":
				SceneTransition.main_menu()


func toggle_pause():
	if is_visible():
		$Title.text = "not paused"
		$AnimationPlayer.play("FadeOut")
		yield($AnimationPlayer, "animation_finished")
	else:
		$AnimationPlayer.play("FadeIn")
		$Title.text = "paused"
	
	visible = !visible
	get_tree().paused = visible
	
	if get_tree().paused == true:
		$PauseSound.play()
	else:
		$ResumeSound.play()
