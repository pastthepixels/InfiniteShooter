extends Node

onready var file = File.new()

onready var dir = Directory.new()

var PATHS = {
	"userdata": "user://userdata.txt",
	"tutorial_complete": "user://tutorial-progress.json",
	"leaderboard": "user://scores.txt",
	"settings": "user://settings.json",
	"keybindings": "user://keybindings.json",
	"upgrades": "user://upgrades.txt"
}

var default_userdata = {
	# Points (not to be confused with score; this is an accumulation of scores)
	"points": 0,
	# Player variables
	"damage": 20,
	"health": 100,
	"max_ammo": 20,
	"ammo_refills": 10
}

var default_settings = {
	"antialiasing": true,
	"bloom": true,
	"musicvol": 100,
	"sfxvol": 100
}

var default_tutorial_progress = {
	"initial": false,
	"elemental": false
}

#
# Userdata -- Player information and points (total score accumulated)
#
func load_userdata():
	if file.file_exists(PATHS.userdata):
		file.open(PATHS.userdata, File.READ) # Opens the userdata file for reading
		var line = file.get_line()
		if line == "":
			print("Something has gone very wrong with your userdata.txt file. A new one has been created.")
			return Saving.default_userdata
		else:
			return parse_json(line)
	else:
		return Saving.default_userdata

func save_userdata(userdata):
	file.open(PATHS.userdata, File.WRITE)
	file.store_line(to_json(userdata)) # Converts the userdata file to a JSON for cheating--I mean user editing

#
# Tutorial information
#
func get_tutorial_progress():
	file.open(PATHS.tutorial_complete, File.READ)
	var line = file.get_line()
	if line == "":
		return Saving.default_tutorial_progress
	else:
		return parse_json(line)

func set_tutorial_progress(progress):
	file.open(PATHS.tutorial_complete, File.WRITE)
	file.store_line(to_json(progress))

#
# Scores + getting the current date/time into a readable string
#
func create_leaderboard_entry(score):
	if file.file_exists(PATHS.leaderboard) == false: 
		file.open(PATHS.leaderboard, File.WRITE) # This creates a new file if there is none but truncates (writes over) existing files
	else:
		file.open(PATHS.leaderboard, File.READ_WRITE) # This does NOT create a new file if there is none but also does NOT truncate existing files
		file.seek_end() # Goes to the end of the file to write a new line
	file.store_line("%s ~> %s ~> %s" % [OS.get_environment("USERNAME"), score, get_datetime()]) # Writes a new line that looks like this: "$USERNAME ~> $SCORE ~> $DATE"

func load_leaderboard():
	var scores = []
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
	var time = str(datetime.hour) + ":" + str(datetime.minute) + ":" + str(datetime.second) + " " + OS.get_time_zone_info().name
	var date = str(datetime.day) + "/" + str(datetime.month) + "/" + str(datetime.year)
	return time + " " + date

#
# Settings
#
func save_settings(settings):
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

	# Sets anti-aliasing (with the strangest ternary operator)
	get_viewport().msaa = (
		Viewport.MSAA_8X
		if settings["antialiasing"] == true
		else Viewport.MSAA_DISABLED
	)
	
	
	# Stores settings
	file.open(PATHS.settings, File.WRITE)
	file.store_line(to_json(settings))


# To load settings
func load_settings():
	if file.file_exists(PATHS.settings) == false:
		return default_settings
	else:
		file.open(PATHS.settings, File.READ)
		return parse_json(file.get_line())

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

func load_upgrades():
	if file.file_exists("user://upgrades.txt") == false: # If the file `upgrades.txt` does not exist, create a batch of upgrades and save them. Then proceed to read them.
		return []
	else:
		file.open( "user://upgrades.txt", File.READ )
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
