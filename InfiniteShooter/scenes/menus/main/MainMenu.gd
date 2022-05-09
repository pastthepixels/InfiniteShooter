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
		$Menu/SelectSquare/AcceptSound.play()
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
			Vector3(0, 6, -2),
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
		
		# Allows things to be selected
		$Menu/SelectSquare.show()
		$Menu/SelectSquare.ignore_hits = 1
		
		# Alerts new players of what buttons to press
		if Saving.get_tutorial_progress()["initial"] == false:
			yield(Utils.timeout(1), "timeout")
			$Alert.alert("Welcome to InfiniteShooter! Press the spacebar or A on a controller to start.", 5)


func _on_SelectSquare_selected():
	match $Menu/Options.get_child($Menu/SelectSquare.index).name:  # Now we see which option has been selected...
		"Play":  # If it is the one named "play", play the game.
			SceneTransition.start_game()

		"Leaderboard":  # Same with selecting the leaderboard
			$Leaderboard.show_animated()
			$Title.hide()
			$Menu/SelectSquare.hide()

		"Settings":  # settings screen
			$Settings.show_animated()
			$Title.hide()
			$Menu/SelectSquare.hide()

		"Quit":  # Otherwise, quit the game
			SceneTransition.quit_game()


func _on_Settings_closed():
	return_from_submenu()


func _on_Leaderboard_closed():
	return_from_submenu()


func return_from_submenu():
	$Title.show()
	$Menu/SelectSquare.show()
	$Menu/SelectSquare.ignore_hits += 1
