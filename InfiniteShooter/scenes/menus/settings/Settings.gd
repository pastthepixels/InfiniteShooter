extends Control

signal closed

export var colors = { "red": Color(1, .27, .27), "green": Color(.27, 1, .27) }

onready var settings = Saving.load_settings()


func _ready():
	update_gui()
	Saving.save_settings(settings)


func show_animated():
	$AnimationPlayer.play("open")


func _on_SelectSquare_selected():
	match $Content/Options.get_child($SelectSquare.index).name:
		"Back":
			emit_signal("closed")
			$AnimationPlayer.play("close")

		"AntiAliasing":
			settings["antialiasing"] = not settings["antialiasing"]
			set_settings()

		"Bloom":
			settings["bloom"] = ! settings["bloom"]
			set_settings()
		
		"Up":
			$KeyPopup.map_actions(["move_up", "ui_up"])
		
		"Down":
			$KeyPopup.map_actions(["move_down", "ui_down"])
		
		"Left":
			$KeyPopup.map_actions(["move_left", "ui_left"])
		
		"Right":
			$KeyPopup.map_actions(["move_right", "ui_right"])
		
		"Confirm":
			$KeyPopup.map_actions(["shoot_laser", "ui_accept"])
			
		"ApplyKeyBindings":
			$Alert.alert("Key bindings saved and applied!")
			$KeyPopup.set_keys()
			Saving.save_keys($KeyPopup.set_actions)
		
		"ResetGame":
			$ResetConfirmation.alert("Press the confirm key to reset all userdata", true)


# To handle percentage inputs/save settings on input
func _input(event):
	if event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		match $Content/Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
			"MusicVolume":
				$Content/Options/MusicVolume/TextureProgress.value += 10 if event.is_action_pressed("ui_right") else -10
				$SelectSquare/AcceptSound.play()
				set_settings()

			"SFXVolume":
				$Content/Options/SFXVolume/TextureProgress.value += 10 if event.is_action_pressed("ui_right") else -10
				$SelectSquare/AcceptSound.play()
				set_settings()

# To save/set settings
func set_settings():
	# Music/Sound Volume(s) <- GUI slider values
	settings["musicvol"] = $Content/Options/MusicVolume/TextureProgress.value
	settings["sfxvol"] = $Content/Options/SFXVolume/TextureProgress.value
	
	# Updates the GUI
	update_gui()
	
	# Saves settings
	Saving.save_settings(settings)

func update_gui():
	# Music/Sound Volume(s) -> GUI slider values
	$Content/Options/MusicVolume/TextureProgress.value = settings["musicvol"]
	$Content/Options/SFXVolume/TextureProgress.value = settings["sfxvol"]
	
	# Updates colors for some settings
	$Content/Options/AntiAliasing/Title.set(
		"custom_colors/font_color",
		colors.green if settings["antialiasing"] else colors.red
	)
	$Content/Options/Bloom/Title.set(
		"custom_colors/font_color",
		colors.green if settings["bloom"] else colors.red
	)

# To reset settings
func _on_ResetConfirmation_confirmed():
	Saving.reset_all()
	$Alert.alert("Game reset! Restart it for changes to take effect.")


func _on_AnimationPlayer_animation_started(_anim_name):
	show()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"close":
			hide()

# To do with keybindings
func _on_KeyPopup_key_set():
	$SelectSquare.show()
	if "move_up" in $KeyPopup.set_actions: $Content/Options/Up/Key.text = $KeyPopup.set_actions["move_up"][1].as_text()
	if "move_down" in $KeyPopup.set_actions: $Content/Options/Down/Key.text = $KeyPopup.set_actions["move_down"][1].as_text()
	if "move_left" in $KeyPopup.set_actions: $Content/Options/Left/Key.text = $KeyPopup.set_actions["move_left"][1].as_text()
	if "move_right" in $KeyPopup.set_actions: $Content/Options/Right/Key.text = $KeyPopup.set_actions["move_right"][1].as_text()
	if "shoot_laser" in $KeyPopup.set_actions: $Content/Options/Confirm/Key.text = $KeyPopup.set_actions["shoot_laser"][1].as_text()


func _on_KeyPopup_opened():
	$SelectSquare.hide()