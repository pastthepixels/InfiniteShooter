extends Node

onready var file = File.new()

onready var dir = Directory.new()

var PATHS = {
	"userdata": "user://userdata.txt",
	"leaderboard": "user://scores.txt",
	"settings": "user://settings.json",
	"keybindings": "user://keybindings.json",
	"upgrades": "user://upgrades.txt",
	"saves": "user://saves/", # Needed to check if the folder exists
	"save_file": "user://saves/save%s.json", # Replace %s with save number
	"save_slot_data": "user://saves/data.json"
}

var default_userdata = {
	"score": 0,
	# Player variables
	"damage": 20,
	"health": 100,
	"max_ammo": 20,
	"ammo_refills": 8
}

var default_settings = {
	"antialiasing": true,
	"bloom": true,
	"distortion": true,
	"shockwaves": true,
	"vsync": true,
	"fullscreen": false,
	"fps_indicator": false,
	"fps_limit": 60,
	"physics_fps": 60,
	"skyanimations_speed": 1.0,
	"musicvol": 100,
	"sfxvol": 100,
	"mouse_sensitivity": 1.0,
	"difficulty": GameVariables.DIFFICULTIES.medium,
	"quit_dialog_lines": false
}

var current_settings

var default_save_slot_data = [ # By default there's 4. You can add more but it will break SaveScreen.tscn
	{ "name": "", "active": false },
	{ "name": "", "active": false },
	{ "name": "", "active": false },
	{ "name": "", "active": false }
]

var default_save_json = [
	{
		"path": "/root/Game",
		"save": {}
	},
	{
		"path": "/root/Game/GameSpace/Player",
		"save": {}
	},
	{
		"path": "/root/Game/GameSpace/Player/LaserEffects",
		"save": {}
	},
	{
		"path": "/root/CameraEquipment",
		"save": {}
	},
]

var current_save_slot = 0

#
# Check if every folder necessary exists
#
func _ready():
	if dir.dir_exists(PATHS.saves) == false:
		dir.make_dir(PATHS.saves)

#
# Userdata -- Player information and total score accumulated
#
func load_userdata():
	if file.file_exists(PATHS.userdata):
		file.open(PATHS.userdata, File.READ) # Opens the userdata file for reading
		var line = file.get_line()
		if line == "":
			print("Something has gone very wrong with your userdata.txt file. A new one has been created.")
			save_userdata(Saving.default_userdata)
			return Saving.default_userdata.duplicate()
		else:
			return parse_json(line)
	else:
		return Saving.default_userdata.duplicate()

func save_userdata(userdata):
	file.open(PATHS.userdata, File.WRITE)
	file.store_line(to_json(userdata)) # Converts the userdata file to a JSON for cheating--I mean user editing
	file.close()

#
# Scores + getting the current date/time into a readable string
#
func create_leaderboard_entry(score):
	if file.file_exists(PATHS.leaderboard) == false: 
		file.open(PATHS.leaderboard, File.WRITE) # This creates a new file if there is none but truncates (writes over) existing files
	else:
		file.open(PATHS.leaderboard, File.READ_WRITE) # This does NOT create a new file if there is none but also does NOT truncate existing files
		file.seek_end() # Goes to the end of the file to write a new line
	file.store_line("%s ~> %s ~> %s" % [get_datetime(), score, get_datetime()]) # Writes a new line that looks like this: "$USERNAME ~> $SCORE ~> $DATE"

func has_leaderboard():
	var directory = Directory.new();
	return directory.file_exists(PATHS.leaderboard)

func load_leaderboard():
	var scores = []
	if has_leaderboard():
		file.open(PATHS.leaderboard, File.READ)
		for score_line in file.get_as_text().split("\n"):
			if score_line.split(" ~> ").size() == 3:
				scores.append(score_line.split(" ~> "))  # Excludes the last line which contains nothing
		scores.sort_custom(self, "sort_leaderboard")
	return scores

func sort_leaderboard(a, b):  # Think of this like a JS sort function
	if int(a[1]) > int(b[1]):  # Gets the score number into an integer for each score-array. Then compares them to create a descending list
		return true
	return false


func get_datetime():
	var datetime = OS.get_datetime()
	var time = str(datetime.hour).pad_zeros(2) + ":" + str(datetime.minute).pad_zeros(2) + ":" + str(datetime.second).pad_zeros(2) + " " + OS.get_time_zone_info().name
	var date = str(datetime.day) + "/" + str(datetime.month) + "/" + str(datetime.year)
	return date + " @ " + time

#
# Settings
#
func save_settings(settings):
	current_settings = settings
	# Sets music volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"), linear2db(float(settings["musicvol"]) / 100)
	)

	# Sets sound effect volume
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("SFX"), linear2db(float(settings["sfxvol"]) / 100)
	)
	
	# Sets bloom
	CameraEquipment.get_node("WorldEnvironment").environment.glow_enabled = settings["bloom"]

	# Shows/hides the FPS indicator
	CameraEquipment.get_node("FrameCounter").visible = settings["fps_indicator"]

	# Sets anti-aliasing (with the strangest ternary operator)
	get_viewport().msaa = (
		Viewport.MSAA_8X
		if settings["antialiasing"] == true
		else Viewport.MSAA_DISABLED
	)
	
	# Sets lens distortion
	if settings["distortion"] == true:
		CameraEquipment.get_node("LensDistortion").enable()
	else:
		CameraEquipment.get_node("LensDistortion").disable()
	
	# Makes the window fullscreen if desired
	OS.window_fullscreen = settings["fullscreen"]
	
	# Sets V-Sync
	OS.vsync_enabled = settings["vsync"]

	# Sets the frame rate limit per second
	Engine.target_fps = settings["fps_limit"]
	Engine.iterations_per_second = settings["physics_fps"]

	# Sets the movement speed of the background (affects all animations)
	CameraEquipment.get_node("SkyAnimations").playback_speed = settings["skyanimations_speed"]
	
	# Sets difficulty
	GameVariables.set_difficulty(int(settings["difficulty"]))
	
	# Stores settings
	file.open(PATHS.settings, File.WRITE)
	file.store_line(to_json(settings))
	file.close()


# To load settings
func load_settings():
	if file.file_exists(PATHS.settings) == false:
		return default_settings.duplicate()
	else:
		file.open(PATHS.settings, File.READ)
		var settings = parse_json(file.get_line())
		if settings == null:
			return default_settings
		for i in default_settings: # Goes through default_settings
			if (i in settings) == false:
				settings[i] = default_settings[i] # and sets any missing variables
		return settings

#
# Key mapping
#
func save_keys(set_actions): # set_actions is from a KeyPopup scene instance
	# Converts InputEventKey --> Scancode
	var stored_variable = {}
	for action in set_actions:
		stored_variable[action] = [set_actions[action][0].scancode, set_actions[action][1].scancode]
	# Stores key bindings
	file.open(PATHS.keybindings, File.WRITE)
	file.store_line(to_json(stored_variable))
	file.close()

func load_keys():
	var set_actions = {}
	
	# Loads key bindings
	if file.file_exists(PATHS.keybindings) == false:
		return {} # Returns if keybindings.json doesn't exist
	file.open(PATHS.keybindings, File.READ)
	var stored_variable = parse_json(file.get_line())
	
	# Converts Scancode --> InputEventKey
	for action in stored_variable:
		var old_key = InputEventKey.new()
		var new_key = InputEventKey.new()
		old_key.scancode = stored_variable[action][0]
		new_key.scancode = stored_variable[action][1]
		set_actions[action] = [old_key, new_key]
	
	return set_actions

#
# Upgrades
#
func save_upgrades(upgrades_list): # As defined in /scenes/menus/upgrades/Upgrades.gd
	file.open(PATHS.upgrades, File.WRITE)
	file.store_var(upgrades_list)
	file.close()

func load_upgrades():
	if file.file_exists(PATHS.upgrades) == false: # If the file `upgrades.txt` does not exist, create a batch of upgrades and save them. Then proceed to read them.
		return []
	else:
		file.open(PATHS.upgrades, File.READ)
		return file.get_var(true)

#
# Resetting everything by removing all user files
#
func reset_all():
	if dir.open("user://") == OK: # Modified from https://docs.godotengine.org/en/stable/classes/class_directory.html?highlight=directory
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false:
				dir.remove("user://" + file_name)
			file_name = dir.get_next()

#
# Saving/loading games
#
func save_game(slot=current_save_slot):
	var save_json = default_save_json.duplicate()
	for node in save_json: # Assumes the node that is being saved has a function where it returns a dict of variables/values
		node.save = get_node(node.path).save()
	file.open(PATHS.save_file % slot, File.WRITE)
	file.store_string(to_json(save_json))
	file.close()
	$AnimationPlayer.play("SaveLabel")
	

func load_game(slot=current_save_slot): # Only to be run when there's /root/Game exists and is loaded.
	file.open(PATHS.save_file % slot, File.READ)
	var save_json = parse_json(file.get_as_text())
	# 1. Update variables for all nodes
	for node in save_json: # Assumes the node that is being saved has a function where it returns a dict of variables/values
		for key in node.save:
			if key in get_node(node.path):
				get_node(node.path)[key] = Utils.match_variable_types(get_node(node.path)[key], node.save[key])
			### EDGE CASES ###
			# Ensuring the player's max health is set before its health
			if key == "health" and node.path == "/root/Game/GameSpace/Player":
				get_node(node.path)["max_health"] = node.save["max_health"]
				get_node(node.path)[key] = node.save[key]
			# same with ammo
			if key == "ammo" and node.path == "/root/Game/GameSpace/Player":
				get_node(node.path)["max_ammo"] = node.save["max_ammo"]
				get_node(node.path)[key] = node.save[key]
		### MORE EDGE CASES ###
		# Loading LaserEffects saves
		if "LaserEffects" in node.path:
			get_node(node.path).load_save(node.save)
	# 2. Update the GUI
	get_node("/root/Game").update_status_bar()

func delete_save(slot=current_save_slot):
	dir.remove(PATHS.save_file % slot)
	# Add in the metadata that the save is no longer active
	var slot_data = load_save_slot_data()
	slot_data[slot].active = false
	save_save_slot_data(slot_data)

func save_exists(slot=current_save_slot):
	return file.file_exists(PATHS.save_file % slot)

func save_save_slot_data(data):
	file.open(PATHS.save_slot_data, File.WRITE)
	file.store_string(to_json(data))
	file.close()

func load_save_slot_data():
	if file.file_exists(PATHS.save_slot_data) == false:
		return default_save_slot_data.duplicate()
	else:
		file.open(PATHS.save_slot_data, File.READ)
		return parse_json(file.get_as_text())
