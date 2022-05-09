extends Control

signal closed

export var colors = { "red": Color(1, .27, .27), "green": Color(.27, 1, .27), "white": Color(1, 1, 1), "yellow": Color(1, 1, 0.27), "orange": Color(1, 0.6, 0.27) }

onready var settings = Saving.load_settings()


func _ready():
	update_gui()
	Saving.save_settings(settings)


func show_animated():
	rect_pivot_offset = rect_size/2
	$AnimationPlayer.play("open")


func _on_SelectSquare_selected():
	match $Content/MarginContainer/ScrollContainer/MarginContainer/Options.get_child($Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare.index).name:
		"Back":
			emit_signal("closed")
			$AnimationPlayer.play("close")

		"AntiAliasing":
			settings["antialiasing"] = not settings["antialiasing"]
			set_settings()

		"Bloom":
			settings["bloom"] = ! settings["bloom"]
			set_settings()
		
		"Fullscreen":
			settings["fullscreen"] = ! settings["fullscreen"]
			set_settings()
		
		"LensDistortion":
			settings["distortion"] = ! settings["distortion"]
			set_settings()
		
		"Shockwaves":
			settings["shockwaves"] = ! settings["shockwaves"]
			set_settings()
		
		"Up":
			$KeyPopup.map_actions(["move_up", "ui_up"])
		
		"Down":
			$KeyPopup.map_actions(["move_down", "ui_down"])
		
		"Left":
			$KeyPopup.map_actions(["move_left", "ui_left"])
		
		"Right":
			$KeyPopup.map_actions(["move_right", "ui_right"])
		
		"Slow":
			$KeyPopup.map_actions(["move_slow"])
		
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
		match $Content/MarginContainer/ScrollContainer/MarginContainer/Options.get_child($Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare.index).name:  # Now we see which option has been selected...
			"MusicVolume":
				$Content/MarginContainer/ScrollContainer/MarginContainer/Options/MusicVolume/TextureProgress.value += 10 if event.is_action_pressed("ui_right") else -10
				$Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare/AcceptSound.play()
				set_settings()

			"SFXVolume":
				$Content/MarginContainer/ScrollContainer/MarginContainer/Options/SFXVolume/TextureProgress.value += 10 if event.is_action_pressed("ui_right") else -10
				$Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare/AcceptSound.play()
				set_settings()
			
			"Difficulty":
				$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected += 1 if event.is_action_pressed("ui_right") else -1
				$Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare/AcceptSound.play()
				set_settings()
				
# To save/set settings
func set_settings():
	# Music/Sound Volume(s) <- GUI slider values
	settings["musicvol"] = $Content/MarginContainer/ScrollContainer/MarginContainer/Options/MusicVolume/TextureProgress.value
	settings["sfxvol"] = $Content/MarginContainer/ScrollContainer/MarginContainer/Options/SFXVolume/TextureProgress.value
	
	# Difficulty
	match $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.get_item_text($Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected) :
		"Easy":
			settings["difficulty"] = GameVariables.DIFFICULTIES.easy
		
		"Medium":
			settings["difficulty"] = GameVariables.DIFFICULTIES.medium
		
		"Hard":
			settings["difficulty"] = GameVariables.DIFFICULTIES.hard
		
		"Nightmare":
			settings["difficulty"] = GameVariables.DIFFICULTIES.nightmare
		
		"Ultranightmare":
			settings["difficulty"] = GameVariables.DIFFICULTIES.ultranightmare
	
	# Updates the GUI
	update_gui()
	
	# Saves settings
	Saving.save_settings(settings)

func update_gui():
	# Music/Sound Volume(s) -> GUI slider values
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/MusicVolume/TextureProgress.value = settings["musicvol"]
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/SFXVolume/TextureProgress.value = settings["sfxvol"]
	
	# Updates colors for some settings
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/AntiAliasing/Title.set(
		"custom_colors/font_color",
		colors.green if settings["antialiasing"] else colors.red
	)
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Bloom/Title.set(
		"custom_colors/font_color",
		colors.green if settings["bloom"] else colors.red
	)
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/LensDistortion/Title.set(
		"custom_colors/font_color",
		colors.green if settings["distortion"] else colors.red
	)
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Shockwaves/Title.set(
		"custom_colors/font_color",
		colors.green if settings["shockwaves"] else colors.red
	)
	$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Fullscreen/Title.set(
		"custom_colors/font_color",
		colors.green if settings["fullscreen"] else colors.red
	)
	
	# Difficulty
	match int(settings["difficulty"]):
		GameVariables.DIFFICULTIES.easy:
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected = 0
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.set(
				"custom_colors/font_color",
				colors.green
			)
		
		GameVariables.DIFFICULTIES.medium:
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected = 1
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.set(
				"custom_colors/font_color",
				colors.white
			)
		
		GameVariables.DIFFICULTIES.hard:
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected = 2
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.set(
				"custom_colors/font_color",
				colors.yellow
			)
		
		GameVariables.DIFFICULTIES.nightmare:
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected = 3
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.set(
				"custom_colors/font_color",
				colors.orange
			)
		
		GameVariables.DIFFICULTIES.ultranightmare:
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.selected = 4
			$Content/MarginContainer/ScrollContainer/MarginContainer/Options/Difficulty/OptionButton.set(
				"custom_colors/font_color",
				colors.red
			)

# To reset settings
func _on_ResetConfirmation_confirmed():
	Saving.reset_all()
	$Alert.alert("Game reset! Restart it for changes to take effect.")

# To do with keybindings
func _on_KeyPopup_key_set():
	$Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare.show()
	if "move_up" in $KeyPopup.set_actions: $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Up/Key.text = $KeyPopup.set_actions["move_up"][1].as_text()
	if "move_down" in $KeyPopup.set_actions: $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Down/Key.text = $KeyPopup.set_actions["move_down"][1].as_text()
	if "move_left" in $KeyPopup.set_actions: $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Left/Key.text = $KeyPopup.set_actions["move_left"][1].as_text()
	if "move_right" in $KeyPopup.set_actions: $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Right/Key.text = $KeyPopup.set_actions["move_right"][1].as_text()
	if "move_slow" in $KeyPopup.set_actions: $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Slow/Key.text = $KeyPopup.set_actions["move_slow"][1].as_text()
	if "shoot_laser" in $KeyPopup.set_actions: $Content/MarginContainer/ScrollContainer/MarginContainer/Options/Confirm/Key.text = $KeyPopup.set_actions["shoot_laser"][1].as_text()


func _on_KeyPopup_opened():
	$Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare.hide()


func _on_SelectSquare_update():
	if $Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare.select_child:
		$Content/MarginContainer/ScrollContainer.ensure_control_visible($Content/MarginContainer/ScrollContainer/MarginContainer/SelectSquare.select_child)

