extends Control

export (PackedScene) var stats_label

export var list_length = 16

func show_animated():
	show()
	$AnimationPlayer.play("open")


func hide_animated():
	$AnimationPlayer.play("close")
	yield($AnimationPlayer, "animation_finished")
	hide()

func _on_SelectSquare_selected():
	hide_animated()
	get_node("../SelectSquare").show()
	get_node("../SelectSquare").ignore_hits += 1

func _ready():
	var scores = read_scores()
	for i in range(0, list_length):
		if scores.size() > i:
			var label = create_label(
				scores[i][0] + " with a score of " + scores[i][1],
				scores[i][2],
				i + 1
			)

	if scores.size() == 0:
		create_label(
			"There are no scores yet!",
			"Hover over leaderboard entries to see the dates in which they were entered."
		)
		create_label("Finish a game to have your score listed.", "")
		create_label("This screen lists the top 10 scores.", "")


func read_scores():
	var scores = []
	var file = File.new()  # Creates a new File instance
	file.open("user://scores.txt", File.READ)  # Opens the scores.txt file for reading
	for score_line in file.get_as_text().split("\n"):
		if score_line.split(" ~> ").size() == 3:
			scores.append(score_line.split(" ~> "))  # Excludes the last line which contains nothing
	scores.sort_custom(self, "score_sorter")  # Sorts descending
	file.close()  # Closes the File instance
	return scores


func score_sorter(a, b):  # Think of this like a JS sort function
	if int(a[1]) > int(b[1]):  # Gets the score number into an integer for each score-array. Then compares them to create a descending list
		return true
	return false


func create_label(text, tooltip, number=null):
	var label = stats_label.instance()
	label.get_node("Text").text = text
	label.get_node("Text/Background").hint_tooltip = tooltip
	# Custom backgrounds
	if number != null:
		label.get_node("Text/Background").color = Color(1, 1, 1, 1 - float(number)/list_length)
		if float(number)/list_length < .5:
			label.get_node("Text").set("custom_colors/font_color", Color(0, 0, 0))
		# More specific custom backgrounds
		if number == 1: label.get_node("Number/Background").color = Color(.8, .64, .2)
		if number == 2: label.get_node("Number/Background").color = Color(1, 1, 1, .6)
		if number == 3: label.get_node("Number/Background").color = Color(.8, .4, .2)
		if number <= 3: label.get_node("Number").set("custom_colors/font_color", Color(0, 0, 0))
		label.get_node("Number").text = "%02d" % number
	else:
		label.get_node("Number").hide()
	
	$Content/Stats.add_child(label)
	return label
