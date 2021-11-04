extends Node

onready var file = File.new()

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
	if file.file_exists(PATHS.userdata):
		file.open(PATHS.userdata, File.READ) # Opens the userdata file for reading
		return parse_json(file.get_line())
	return Saving.default_userdata

func save_userdata(userdata):
	file.open(PATHS.userdata, File.WRITE)
	file.store_line(to_json(userdata)) # Converts the userdata file to a JSON for cheating--I mean user editing

#
# Tutorial information
#
func is_tutorial_complete():
	return file.file_exists(PATHS.tutorial_complete)

func complete_tutorial():
	var file = File.new() # Creates a new File object, for handling file operations
	file.open(PATHS.tutorial_complete, File.WRITE)
	file.store_line("true")

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
	file.close()

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
