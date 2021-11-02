extends Node

var PATHS = {
	"userdata": "user://userdata.txt",
	"tutorial_complete": "user://tutorial-complete",
	"leaderboard": "user://scores.txt"
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

#
# Userdata -- Player information and points (total score accumulated)
#
func load_userdata():
	var file = File.new()
	if file.file_exists(PATHS.userdata):
		file.open(PATHS.userdata, File.READ) # Opens the userdata file for reading
		return parse_json(file.get_line())
	print(true)
	return Saving.default_userdata

func save_userdata(userdata):
	var file = File.new()
	file.open(PATHS.userdata, File.WRITE)
	file.store_line(to_json(userdata)) # Converts the userdata file to a JSON for cheating--I mean user editing
	file.close()

#
# Tutorial information
#
func is_tutorial_complete():
	var file = File.new() # Creates a new File object, for handling file operations
	return file.file_exists(PATHS.tutorial_complete)

func complete_tutorial():
	var file = File.new() # Creates a new File object, for handling file operations
	file.open(PATHS.tutorial_complete, File.WRITE)
	file.store_line("true")
	file.close()

#
# Scores + getting the current date/time into a readable string
#
func create_leaderboard_entry(score):
	var file = File.new() # Creates a new File object, for handling file operations
	if file.file_exists(PATHS.leaderboard) == false: 
		file.open(PATHS.leaderboard, File.WRITE) # This creates a new file if there is none but truncates (writes over) existing files
	else:
		file.open(PATHS.leaderboard, File.READ_WRITE) # This does NOT create a new file if there is none but also does NOT truncate existing files
		file.seek_end() # Goes to the end of the file to write a new line
	file.store_line("%s ~> %s ~> %s" % [OS.get_environment("USERNAME"), score, get_datetime()]) # Writes a new line that looks like this: "$USERNAME ~> $SCORE ~> $DATE"
	file.close()

func get_datetime():
	var datetime = OS.get_datetime()
	var time = str(datetime.hour) + ":" + str(datetime.minute) + ":" + str(datetime.second) + " " + OS.get_time_zone_info().name
	var date = str(datetime.day) + "/" + str(datetime.month) + "/" + str(datetime.year)
	return time + " " + date
