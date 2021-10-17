extends Control

signal settings_changed
export var colors = { "red": Color(1, .27, .27), "green": Color(.27, 1, .27) }
var settings = {"antialiasing": true, "bloom": true, "musicvol": 100, "sfxvol": 100}


func _ready():
	get_settings()


func show_animated():
	show()
	$AnimationPlayer.play("open")


func hide_animated():
	$AnimationPlayer.play("close")
	yield($AnimationPlayer, "animation_finished")
	hide()


func _on_SelectSquare_selected():
	match $Content/Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
		"Back":
			hide_animated()
			get_node("../SelectSquare").show()
			get_node("../SelectSquare").ignore_hits += 1

		"AntiAliasing":
			settings["antialiasing"] = ! settings["antialiasing"]
			$Content/Options/AntiAliasing/Title.set(
				"custom_colors/font_color",
				colors.green if settings["antialiasing"] else colors.red
			)

		"Bloom":
			settings["bloom"] = ! settings["bloom"]
			$Content/Options/Bloom/Title.set(
				"custom_colors/font_color",
				colors.green if settings["bloom"] else colors.red
			)
		
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
			$KeyPopup.save_keys()
		
		"ResetGame":
			$ResetConfirmation.open()


# To handle percentage inputs/save settings on input
func _input(event):
	if visible == true:
		set_settings()
		
	match $Content/Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
		"MusicVolume":
			if event.is_action_pressed("ui_left"):
				$Content/Options/MusicVolume/TextureProgress.value -= 10
				$SelectSquare/AcceptSound.play()
			if event.is_action_pressed("ui_right"):
				$Content/Options/MusicVolume/TextureProgress.value += 10
				$SelectSquare/AcceptSound.play()

		"SFXVolume":
			if event.is_action_pressed("ui_left"):
				$Content/Options/SFXVolume/TextureProgress.value -= 10
				$SelectSquare/AcceptSound.play()
			if event.is_action_pressed("ui_right"):
				$Content/Options/SFXVolume/TextureProgress.value += 10
				$SelectSquare/AcceptSound.play()

# To set the labels for the key mapping stuff
func set_key_labels():
	if "move_up" in $KeyPopup.set_actions: $Content/Options/Up/Key.text = $KeyPopup.set_actions["move_up"][1].as_text()
	if "move_down" in $KeyPopup.set_actions: $Content/Options/Down/Key.text = $KeyPopup.set_actions["move_down"][1].as_text()
	if "move_left" in $KeyPopup.set_actions: $Content/Options/Left/Key.text = $KeyPopup.set_actions["move_left"][1].as_text()
	if "move_right" in $KeyPopup.set_actions: $Content/Options/Right/Key.text = $KeyPopup.set_actions["move_right"][1].as_text()
	if "shoot_laser" in $KeyPopup.set_actions: $Content/Options/Confirm/Key.text = $KeyPopup.set_actions["shoot_laser"][1].as_text()


# To save/set settings
func set_settings():
	# Updates music/sound effects volume
	settings["musicvol"] = $Content/Options/MusicVolume/TextureProgress.value
	settings["sfxvol"] = $Content/Options/SFXVolume/TextureProgress.value

	# Tells the node MainMenu that settings have changed and it needs to set them
	emit_signal("settings_changed", settings)

	# Stores settings
	var file = File.new()  # Creates a new File object, for handling file operations
	file.open("user://settings.json", File.WRITE)
	file.store_line(to_json(settings))
	file.close()


# To load settings
func get_settings():
	# Reads settings and puts that in a variable called "loaded_settings"
	var file = File.new()  # Creates a new File object, for handling file operations
	if file.file_exists("user://settings.json") == false: return # Returns if settings.json doesn't exist
	file.open("user://settings.json", File.READ)
	var loaded_settings = parse_json(file.get_line())
	file.close()  # We're done with the `file` for now.

	# Sets our "settings" variable, but with this code in case an extra setting is here but not in config files
	# (e.g. something a user would experience after an update)
	for key in loaded_settings:
		settings[key] = loaded_settings[key]

	# Now we set colors/values of elements
	$Content/Options/AntiAliasing.set(
		"custom_colors/font_color", colors.green if settings["antialiasing"] else colors.red
	)
	$Content/Options/Bloom.set(
		"custom_colors/font_color", colors.green if settings["bloom"] else colors.red
	)
	$Content/Options/MusicVolume/TextureProgress.value = settings["musicvol"]
	$Content/Options/SFXVolume/TextureProgress.value = settings["sfxvol"]

	# Lastly we tell the parent node, MainMenu, to update everything

	emit_signal("settings_changed", settings)

# To reset settings
func _on_ResetConfirmation_confirmed():
	var dir = Directory.new()
	if dir.open("user://") == OK: # Modified from https://docs.godotengine.org/en/stable/classes/class_directory.html?highlight=directory
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false:
				dir.remove("user://" + file_name)
			file_name = dir.get_next()
	$Alert.alert("Game reset! Restart it for changes to take effect.")
