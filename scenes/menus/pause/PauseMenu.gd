extends Control

var ignore_hits = 0

var ignore_all = false

var previous_time_scale

func _input(event):
	if event.is_action_pressed("pause") and ignore_all == false:
		if ignore_hits == 0: 
			if is_visible():
				_on_Return_pressed()
			else:
				toggle_pause()
		else:
			ignore_hits -= 1

func _on_QuitAlert_confirmed():
	ignore_all = false
	toggle_pause()
	#Saving.save_game()
	SceneTransition.quit_game()

func _on_MainAlert_confirmed():
	ignore_all = false
	toggle_pause()
	#Saving.save_game()
	SceneTransition.main_menu()

func _on_MainAlert_exited():
	ignore_all = false
	$Options/MainMenu.grab_focus()

func _on_QuitAlert_exited():
	ignore_all = false
	$Options/Quit.grab_focus()

func _on_Return_pressed():
	toggle_pause()

func _on_MainMenu_pressed():
	ignore_all = true
	$MainAlert.alert("Are you sure you want to go back to the main menu? Your progress will be saved after each wave/level.", true)

func _on_Quit_pressed():
	ignore_all = true
	$QuitAlert.alert("Are you sure you want to quit? Your progress will be saved after each wave/level.", true)

func toggle_pause():
	if is_visible():
		rect_pivot_offset = rect_size/2
		$AnimationPlayer.play("FadeOut")
		$Title.text = "not paused"
		yield($AnimationPlayer, "animation_finished")
		if SceneTransition.is_visible() == false: Engine.time_scale = previous_time_scale
	else:
		previous_time_scale = Engine.time_scale
		Engine.time_scale = 1
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
