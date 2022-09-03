extends Control

signal done_opening

func _on_AnimationPlayer_animation_finished(_anim_name):
	if _anim_name != "RESET":
		$Options/Retry.grab_focus()
		emit_signal("done_opening")


func _on_Retry_pressed():
	SceneTransition.restart_game()


func _on_Quit_pressed():
	SceneTransition.quit_game()


func _on_MainMenu_pressed():
	SceneTransition.main_menu()


func start():
	$AnimationPlayer.play("FadeAll")
	CameraEquipment.slow_sky()
