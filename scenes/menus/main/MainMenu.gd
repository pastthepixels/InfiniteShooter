extends Node

func _ready():
	CameraEquipment.reset_sky_animation_speed()
	CameraEquipment.get_node("SkyAnimations").play("intro")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"introduce_title":
			$Menu/StartScreen/AnimationPlayer.play("flash_text")


func _input(event):
	# If the start screen is still there, remove it! Also return the function so we don't trigger a menu option at the same time.
	if (
		(event is InputEventKey or event is InputEventJoypadButton)
		and event.pressed
		and $Menu/StartScreen.visible == true
	):
		# Plays the "gui-accept" sound and the main menu theme
		MenuSFX.get_node("UseSound").play()
		$Music.play()

		# Hides the start screen and shows the options/other stuff
		$Menu/StartScreen.hide()
		$Menu/Options.show()
		
		# Animations
		$AnimationPlayer.play("switch")
		CameraEquipment.get_node("SkyAnimations").play("Wander")
		
		# We need the tween so we can animate the position/rotation of the title no matter where it is
		$Tween.interpolate_property(
			$Title,
			"translation",
			$Title.translation,
			Vector3(0, 8, -2),
			$AnimationPlayer.current_animation_length + 2,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		$Tween.interpolate_property(
			$Title,
			"rotation:x",
			$Title.rotation.x,
			deg2rad(-364),
			$AnimationPlayer.current_animation_length + 1,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		$Tween.start()

func _on_Settings_closed():
	$Title.show()
	$Menu/Options/Settings.grab_focus()


func _on_Leaderboard_closed():
	$Title.show()
	$Menu/Options/Leaderboard.grab_focus()


func _on_Readme_closed():
	$Title.show()
	$Menu/Options/Readme.grab_focus()


func _on_Play_pressed():
	SceneTransition.start_game()


func _on_Leaderboard_pressed():
	$Leaderboard.show_animated()
	$Title.hide()


func _on_Readme_pressed():
	$Readme.show_animated()
	$Title.hide()


func _on_Settings_pressed():
	$Settings.show_animated()
	$Title.hide()


func _on_Quit_pressed():
	SceneTransition.quit_game()


func _on_Tween_tween_all_completed():
	$Menu/Options/Play.grab_focus()
