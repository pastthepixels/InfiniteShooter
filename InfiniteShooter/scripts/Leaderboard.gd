extends Control


func show_animated():
	show()
	$AnimationPlayer.play("open")


func hide_animated():
	$AnimationPlayer.play_backwards("open")
	yield($AnimationPlayer, "animation_finished")
	hide()


func _ready():
	var scores = read_scores()
	for i in range(0, 12):
		if scores.size() > i:
			create_label(
				("%s. " + scores[i][0] + " with a score of " + scores[i][1]) % (i + 1), scores[i][2]
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


func create_label(text, tooltip):
	var label = Label.new()
	label.text = text
	label.hint_tooltip = tooltip
	label.mouse_filter = Control.MOUSE_FILTER_PASS  # <-- In order for the tooltip to work
	label.set("custom_colors/font_color", Color(0, 0, 0))
	$VBoxContainer.add_child(label)
