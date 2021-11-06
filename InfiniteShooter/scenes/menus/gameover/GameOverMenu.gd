extends Control

func start():
	if visible == true: return
	$AnimationPlayer.play("FadeAll")
	print(CameraEquipment.get_node("SkyAnimations").playback_speed)
	$Tween.interpolate_property(
		CameraEquipment.get_node("SkyAnimations"),
		"playback_speed",
		1,
		0,
		3,
		Tween.TRANS_QUAD
	)
	$Tween.start()


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


func _on_Tween_tween_completed(object, key):
	CameraEquipment.get_node("SkyAnimations").stop()
	CameraEquipment.get_node("SkyAnimations").playback_speed = 1
