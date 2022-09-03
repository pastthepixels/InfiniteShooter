extends Control

var ignore_hits = 0

var ignore_all = false

func _input(event):
	if event.is_action_pressed("pause") and ignore_all == false:
		if ignore_hits == 0: 
			toggle_pause()
		else:
			ignore_hits -= 1

func _on_QuitAlert_confirmed():
	toggle_pause()
	SceneTransition.quit_game()

func _on_MainAlert_confirmed():
	toggle_pause()
	SceneTransition.main_menu()

func _on_MainAlert_exited():
	$Options/MainMenu.grab_focus()

func _on_QuitAlert_exited():
	$Options/Quit.grab_focus()

func _on_Return_pressed():
	toggle_pause()

func _on_MainMenu_pressed():
	$MainAlert.alert("Are you sure you want to go back to the main menu?", true)

func _on_Quit_pressed():
	$QuitAlert.alert("Are you sure you want to quit?", true)

func toggle_pause():
	if is_visible():
		rect_pivot_offset = rect_size/2
		$AnimationPlayer.play("FadeOut")
		$Title.text = "not paused"
		yield($AnimationPlayer, "animation_finished")
	else:
		rect_pivot_offset = rect_size/2
		$AnimationPlayer.play("FadeIn")
		$Options/Return.grab_focus()
		$Title.text = "paused"
	
	visible = !visible
	get_tree().paused = visible
	
	if get_tree().paused == true:
		$Ambience.play()
		$PauseSound.play()
	else:
		$Ambience.stop()
		$ResumeSound.play()
