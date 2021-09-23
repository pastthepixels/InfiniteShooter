extends Control

signal settings_changed
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


# To handle when something is selected -- all input starts from the main menu but go over here for the [OPTIONS] screen
func handle_selection():
	match $VBoxContainer/Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
		"Back":
			hide_animated()
			get_node("../SelectSquare").show()

		"AntiAliasing":
			settings["antialiasing"] = ! settings["antialiasing"]
			$VBoxContainer/Options/AntiAliasing.set(
				"custom_colors/font_color",
				Color(0, 1, 0) if settings["antialiasing"] else Color(1, 0, 0)
			)

		"Bloom":
			settings["bloom"] = ! settings["bloom"]
			$VBoxContainer/Options/Bloom.set(
				"custom_colors/font_color",
				Color(0, 1, 0) if settings["bloom"] else Color(1, 0, 0)
			)


# To handle percentage inputs/save settings on input
func _input(event):
	if visible == true:
		set_settings()
	match $VBoxContainer/Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
		"MusicVolume":
			if event.is_action_pressed("ui_left"):
				$VBoxContainer/Options/MusicVolume/TextureProgress.value -= 10
				$SelectSquare/AcceptSound.play()
			if event.is_action_pressed("ui_right"):
				$VBoxContainer/Options/MusicVolume/TextureProgress.value += 10
				$SelectSquare/AcceptSound.play()

		"SFXVolume":
			if event.is_action_pressed("ui_left"):
				$VBoxContainer/Options/SFXVolume/TextureProgress.value -= 10
				$SelectSquare/AcceptSound.play()
			if event.is_action_pressed("ui_right"):
				$VBoxContainer/Options/SFXVolume/TextureProgress.value += 10
				$SelectSquare/AcceptSound.play()


# To save/set settings
func set_settings():
	# Updates music/sound effects volume
	settings["musicvol"] = $VBoxContainer/Options/MusicVolume/TextureProgress.value
	settings["sfxvol"] = $VBoxContainer/Options/SFXVolume/TextureProgress.value

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
	file.open("user://settings.json", File.READ)
	var loaded_settings = parse_json(file.get_line())
	if loaded_settings == null:
		return  # Returns if settings.json doesn't exist
	file.close()  # We're done with the `file` for now.

	# Sets our "settings" variable, but with this code in case an extra setting is here but not in config files
	# (e.g. something a user would experience after an update)
	for key in loaded_settings:
		settings[key] = loaded_settings[key]

	# Now we set colors/values of elements
	$VBoxContainer/Options/AntiAliasing.set(
		"custom_colors/font_color", Color(0, 1, 0) if settings["antialiasing"] else Color(1, 0, 0)
	)
	$VBoxContainer/Options/Bloom.set(
		"custom_colors/font_color", Color(0, 1, 0) if settings["bloom"] else Color(1, 0, 0)
	)
	$VBoxContainer/Options/MusicVolume/TextureProgress.value = settings["musicvol"]
	$VBoxContainer/Options/SFXVolume/TextureProgress.value = settings["sfxvol"]

	# Lastly we tell the parent node, MainMenu, to update everything

	emit_signal("settings_changed", settings)
