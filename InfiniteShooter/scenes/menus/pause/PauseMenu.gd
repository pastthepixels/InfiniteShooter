extends Control

var ignore_hits = 0

var ignore_all = false

func _input(event):
	if event.is_action_pressed("pause") and ignore_all == false:
		if ignore_hits == 0: 
			toggle_pause()
		else:
			ignore_hits -= 1


func _on_SelectSquare_selected():
	if is_visible():
		match $Options.get_child($SelectSquare.index).name:
				"Retry":
					for player in get_tree().get_nodes_in_group("players"):
						player.set_process_input(false)  # To prevent the player from firing right as we unpause (since the input function runs at the same time)
					toggle_pause()
					SceneTransition.restart_game()
				_:
					ignore_hits += 1
					$SelectSquare.hide()
					$FullAlert.alert("Are you sure you would like to continue? Your score will not be accounted for until you die.", true)

func toggle_pause():
	if has_node("/root/Game") and get_node("/root/Game").has_node("GameSpace/Player"):
		get_node("/root/Game/GameSpace/Player").resume_time()
	
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
		$Ambience.play()
		$PauseSound.play()
	else:
		$Ambience.stop()
		$ResumeSound.play()


func _on_FullAlert_confirmed():
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


func _on_FullAlert_exited():
	$SelectSquare.show()
