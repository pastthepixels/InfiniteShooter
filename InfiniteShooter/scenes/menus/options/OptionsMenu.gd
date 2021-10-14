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
				Color(0, 1, 0) if settings["antialiasing"] else Color(1, 0, 0)
			)

		"Bloom":
			settings["bloom"] = ! settings["bloom"]
			$Content/Options/Bloom/Title.set(
				"custom_colors/font_color",
				Color(0, 1, 0) if settings["bloom"] else Color(1, 0, 0)
			)
		
		"Up":
			$KeyPopup.set_key("move_up")
		
		"Down":
			$KeyPopup.set_key("move_down")
		
		"Left":
			$KeyPopup.set_key("move_left")
		
		"Right":
			$KeyPopup.set_key("move_right")
		
		"Confirm":
			$KeyPopup.set_key("shoot_laser")


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
	var keys = {}
	for action in $KeyPopup.ACTIONS:
		for key in InputMap.get_action_list(action):
			if key is InputEventKey:
				keys[action] = key.as_text()
	$Content/Options/Up/Key.text = keys["move_up"]
	$Content/Options/Down/Key.text = keys["move_down"]
	$Content/Options/Left/Key.text = keys["move_left"]
	$Content/Options/Right/Key.text = keys["move_right"]
	$Content/Options/Confirm/Key.text = keys["shoot_laser"]


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
		"custom_colors/font_color", Color(0, 1, 0) if settings["antialiasing"] else Color(1, 0, 0)
	)
	$Content/Options/Bloom.set(
		"custom_colors/font_color", Color(0, 1, 0) if settings["bloom"] else Color(1, 0, 0)
	)
	$Content/Options/MusicVolume/TextureProgress.value = settings["musicvol"]
	$Content/Options/SFXVolume/TextureProgress.value = settings["sfxvol"]

	# Lastly we tell the parent node, MainMenu, to update everything

	emit_signal("settings_changed", settings)
