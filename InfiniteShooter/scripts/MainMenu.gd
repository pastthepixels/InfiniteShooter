extends Node


func _ready():
	GameMusic.play_main()
	get_node("../SkyScrolling").stop(true)
	$AnimationPlayer.play("introduce-title")


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
		$AnimationPlayer.play("switch")
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
		$Menu/SelectSquare.ignore_hits += 1

func _on_SelectSquare_selected():
	match $Menu/Options.get_child($Menu/SelectSquare.index).name:  # Now we see which option has been selected...
		"Play":  # If it is the one named "play", play the game.
			SceneTransition.play(self, "play_game")

		"Leaderboard":  # Same with selecting the leaderboard
			if $Menu/Leaderboard.visible == false:
				$Menu/Leaderboard.show_animated()
				$Menu/SelectSquare.hide()
			else:
				$Menu/Leaderboard.hide_animated()
				$Menu/SelectSquare.show()

		"Upgrades":  # Same with selecting the upgrades screen
			$Menu/Upgrades.show_animated()
			$Menu/SelectSquare.hide()

		"Options":  # /options screen
			$Menu/OptionsMenu.show_animated()
			$Menu/SelectSquare.hide()

		"Quit":  # Otherwise, quit the game
			SceneTransition.play(self, "quit_game")


func play_game():
	queue_free()
	get_node("../SkyScrolling").play("SkyRotate")
	get_node("/root/Main/").add_child(load("res://scenes/Game.tscn").instance())


func quit_game():
	get_tree().quit()


func _on_OptionsMenu_settings_changed(settings):
	# Sets music volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"), linear2db(float(settings["musicvol"]) / 100)
	)

	# Sets sound effect volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"), linear2db(float(settings["sfxvol"]) / 100)
	)
	# Sets bloom
	get_node("../WorldEnvironment").environment.glow_enabled = settings["bloom"]

	# Sets anti-aliasing (with the strangest ternary operator)
	get_viewport().msaa = (
		Viewport.MSAA_4X
		if settings["antialiasing"] == true
		else Viewport.MSAA_DISABLED
	)
