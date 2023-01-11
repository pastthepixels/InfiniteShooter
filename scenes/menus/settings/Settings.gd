extends "res://scenes/ui-bits/Submenu.gd"

onready var settings = Saving.load_settings()

# Loads GUI on init
func _ready():
	# Showing if it's the only scene
	if get_parent() == get_tree().get_root():
		show_animated()
	# Graphics
	get_node("%Options/AntiAliasing").pressed = settings["antialiasing"]
	get_node("%Options/Bloom").pressed = settings["bloom"]
	get_node("%Options/LensDistortion").pressed = settings["distortion"]
	get_node("%Options/Shockwaves").pressed = settings["shockwaves"]
	get_node("%Options/VSync").pressed = settings["vsync"]
	get_node("%Options/Fullscreen").pressed = settings["fullscreen"]
	get_node("%Options/FrameCounter").pressed = settings["fps_indicator"]
	get_node("%Options/FPSLimit/OptionButton").selected = get_node("%Options/FPSLimit/OptionButton").get_item_index(settings["fps_limit"])
	get_node("%Options/PhysicsFPS/OptionButton").selected = get_node("%Options/PhysicsFPS/OptionButton").get_item_index(settings["physics_fps"])
	# Gameplay
	match int(settings["difficulty"]):
		GameVariables.DIFFICULTIES.easy:
			get_node("%Options/Difficulty/OptionButton").selected = 0
		GameVariables.DIFFICULTIES.medium:
			get_node("%Options/Difficulty/OptionButton").selected = 1
		GameVariables.DIFFICULTIES.hard:
			get_node("%Options/Difficulty/OptionButton").selected = 2
		GameVariables.DIFFICULTIES.harder:
			get_node("%Options/Difficulty/OptionButton").selected = 3
		GameVariables.DIFFICULTIES.hardest:
			get_node("%Options/Difficulty/OptionButton").selected = 4
		GameVariables.DIFFICULTIES.carnage:
			get_node("%Options/Difficulty/OptionButton").selected = 5
	# Accessibility
	get_node("%Options/BackgroundMovement/HSlider").value = settings["skyanimations_speed"]
	# Sound
	get_node("%Options/MusicVolume/HSlider").value = settings["musicvol"]
	get_node("%Options/SFXVolume/HSlider").value = settings["sfxvol"]
	# Input
	get_node("%InputKeys/Up/Key").text =	$KeyPopup.get_keys_for_action("move_up")[0].as_text()
	get_node("%InputKeys/Down/Key").text =	$KeyPopup.get_keys_for_action("move_down")[0].as_text()
	get_node("%InputKeys/Left/Key").text =	$KeyPopup.get_keys_for_action("move_left")[0].as_text()
	get_node("%InputKeys/Right/Key").text =	$KeyPopup.get_keys_for_action("move_right")[0].as_text()
	get_node("%InputKeys/Laser/Key").text =	$KeyPopup.get_keys_for_action("shoot_laser")[0].as_text()
	# Input > Mouse input
	get_node("%Options/MouseSensitivity/HSlider").value = settings["mouse_sensitivity"]
# Going back
func _on_Back_pressed():
	hide_animated()

# Graphics toggles
func _on_AntiAliasing_toggled(button_pressed):
	settings["antialiasing"] = button_pressed
	Saving.save_settings(settings)

func _on_Bloom_toggled(button_pressed):
	settings["bloom"] = button_pressed
	Saving.save_settings(settings)

func _on_LensDistortion_toggled(button_pressed):
	settings["distortion"] = button_pressed
	Saving.save_settings(settings)

func _on_Shockwaves_toggled(button_pressed):
	settings["shockwaves"] = button_pressed
	Saving.save_settings(settings)

func _on_VSync_toggled(button_pressed):
	settings["vsync"] = button_pressed
	Saving.save_settings(settings)

func _on_Fullscreen_toggled(button_pressed):
	settings["fullscreen"] = button_pressed
	Saving.save_settings(settings)

func _on_FrameCounter_toggled(button_pressed):
	settings["fps_indicator"] = button_pressed
	Saving.save_settings(settings)

# FPS limits
func _on_PhysicsFPS_OptionButton_item_selected(index):
	settings["physics_fps"] = get_node("%Options/PhysicsFPS/OptionButton").get_item_id(index)
	Saving.save_settings(settings)

func _on_FPSLimit_OptionButton_item_selected(index):
	settings["fps_limit"] =  get_node("%Options/FPSLimit/OptionButton").get_item_id(index)
	Saving.save_settings(settings)

# Difficulty
func _on_Difficulty_OptionButton_item_selected(index):
	match index:
		0:
			settings["difficulty"] = GameVariables.DIFFICULTIES.easy
		1:
			settings["difficulty"] = GameVariables.DIFFICULTIES.medium
		2:
			settings["difficulty"] = GameVariables.DIFFICULTIES.hard
		3:
			settings["difficulty"] = GameVariables.DIFFICULTIES.harder
		4:
			settings["difficulty"] = GameVariables.DIFFICULTIES.hardest
		5:
			settings["difficulty"] = GameVariables.DIFFICULTIES.carnage
	Saving.save_settings(settings)

# Background movement
func _on_BackgroundMovement_HSlider_value_changed(value):
	settings["skyanimations_speed"] = value
	$Content/ScrollContainer/Options/BackgroundMovement/Hint.text = "(x%0.2f)" % settings["skyanimations_speed"]
	Saving.save_settings(settings)

# Volume
func _on_MusicVolume_HSlider_value_changed(value):
	settings["musicvol"] = value
	Saving.save_settings(settings)

func _on_SFXVolume_HSlider_value_changed(value):
	settings["sfxvol"] = value
	Saving.save_settings(settings)

# Resetting all data
func _on_ResetGame_pressed():
	$ResetConfirmation.alert("Are you sure you want to reset ALL DATA for this game? What's done cannot be undone. No like seriously, all your data will be gone FOREVER.", true)

func _on_ResetConfirmation_confirmed():
	Saving.reset_all()
	settings = Saving.load_settings() # <-- Reloads settings
	_ready() # <-- Reloads GUI
	$Alert.alert("Game reset! Restart it for changes to take effect.")

# Keybindings
func _map_up_key():
	$KeyPopup.map_actions(["move_up", "ui_up"])

func _map_down_key():
	$KeyPopup.map_actions(["move_down", "ui_down"])

func _map_left_key():
	$KeyPopup.map_actions(["move_left", "ui_left"])

func _map_right_key():
	$KeyPopup.map_actions(["move_right", "ui_right"])

func _map_shoot_key():
	$KeyPopup.map_actions(["shoot_laser", "ui_accept"])

func _on_ApplyBindings_pressed():
	$Alert.alert("Key bindings saved and applied!")
	$KeyPopup.set_keys()
	Saving.save_keys($KeyPopup.set_actions)

func _on_KeyPopup_key_set():
	if "move_up" in $KeyPopup.set_actions:		get_node("%InputKeys/Up/Key").text = $KeyPopup.set_actions["move_up"][1].as_text()
	if "move_down" in $KeyPopup.set_actions:	get_node("%InputKeys/Down/Key").text = $KeyPopup.set_actions["move_down"][1].as_text()
	if "move_left" in $KeyPopup.set_actions:	get_node("%InputKeys/Left/Key").text = $KeyPopup.set_actions["move_left"][1].as_text()
	if "move_right" in $KeyPopup.set_actions:	get_node("%InputKeys/Right/Key").text = $KeyPopup.set_actions["move_right"][1].as_text()
	if "shoot_laser" in $KeyPopup.set_actions:	get_node("%InputKeys/Laser/Key").text = $KeyPopup.set_actions["shoot_laser"][1].as_text()

# Mouse sensitivity
func _on_MouseSensitivity_HSlider_value_changed(value):
	settings["mouse_sensitivity"] = value
	$Content/ScrollContainer/Options/MouseSensitivity/Hint.text = "(x%0.2f)" % settings["mouse_sensitivity"]
	Saving.save_settings(settings)

# Special lines for the quit dialog
func _on_QuitLines_toggled(button_pressed):
	settings["quit_dialog_lines"] = button_pressed
	Saving.save_settings(settings)

# Logs in the loading screen
func _on_LoadScreenLog_toggled(button_pressed):
	settings["load_screen_live_log"] = button_pressed
	Saving.save_settings(settings)
