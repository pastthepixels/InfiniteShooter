extends Node


func _ready():
	CameraEquipment.get_node("SkyAnimations").play("intro")
	$Music.stream.loop = false
	$Music.play() # Autoplay doesn't work with looping disabled.

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
		# Plays the "gui-accept" sound
		$Menu/SelectSquare/AcceptSound.play()

		# Hides the start screen and shows the options/other stuff
		$Menu/StartScreen.hide()
		$Menu/Options.show()
		
		# Animations
		$Title.rotation.x = 0
		$AnimationPlayer.play("switch")
		CameraEquipment.get_node("SkyAnimations").seek(CameraEquipment.get_node("SkyAnimations").current_animation_length, true)
		
		# We need the tween so we can animate the position of the title no matter where it is
		$Tween.interpolate_property(
			$Title,
			"translation",
			$Title.translation,
			Vector3(0, 6, -2),
			$AnimationPlayer.current_animation_length,
			Tween.TRANS_QUAD,
			Tween.EASE_OUT
		)
		$Tween.start()
		
		# Allows things to be selected
		$Menu/SelectSquare.show()
		$Menu/SelectSquare.ignore_hits = 1


func _on_SelectSquare_selected():
	match $Menu/Options.get_child($Menu/SelectSquare.index).name:  # Now we see which option has been selected...
		"Play":  # If it is the one named "play", play the game.
			SceneTransition.start_game()

		"Leaderboard":  # Same with selecting the leaderboard
			$Leaderboard.show_animated()
			$Menu/SelectSquare.hide()

		"Upgrades":  # Same with selecting the upgrades screen
			$Upgrades.show_animated()
			$Menu/SelectSquare.hide()

		"Settings":  # settings screen
			$Settings.show_animated()
			$Menu/SelectSquare.hide()

		"Quit":  # Otherwise, quit the game
			SceneTransition.quit_game()


func _on_OptionsMenu_closed():
	return_from_submenu()


func _on_Upgrades_closed():
	return_from_submenu()


func _on_Leaderboard_closed():
	return_from_submenu()


func return_from_submenu():
	$Menu/SelectSquare.show()
	$Menu/SelectSquare.ignore_hits += 1
