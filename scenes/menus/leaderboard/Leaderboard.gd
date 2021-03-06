extends Control

signal closed

export(PackedScene) var stats_label

export var list_length = 16

func show_animated():
	rect_pivot_offset = rect_size/2
	$AnimationPlayer.play("open")


func _on_SelectSquare_selected():
	emit_signal("closed")
	$AnimationPlayer.play("close")


func _ready():
	var scores = Saving.load_leaderboard()
	for i in range(0, min(scores.size(), list_length)):
		create_label(scores[i][1] + " points, " + scores[i][0], i + 1)

	if scores.size() == 0:
		create_label("There are no scores yet!")
		create_label("Finish a game to have your score listed.")
		create_label("This screen lists the top 10 scores.")



func create_label(text, number=null):
	var label = stats_label.instance()
	label.get_node("Text").text = text
	# Custom backgrounds
	if number != null:
		label.get_node("Number").text = "%02d" % number
		
		var style = label.get_node("Number").get_stylebox("normal")
		# More specific custom backgrounds
		match number:
			1:
				style.bg_color = Color(.8, .64, .2)
				label.get_node("Number").set("custom_colors/font_color", Color(0, 0, 0))
			
			2:
				style.bg_color = Color(1, 1, 1, .6)
				label.get_node("Number").set("custom_colors/font_color", Color(0, 0, 0))
			
			3:
				style.bg_color = Color(.8, .4, .2)
				label.get_node("Number").set("custom_colors/font_color", Color(0, 0, 0))
		label.get_node("Number").add_stylebox_override("normal", style)
	else:
		label.get_node("Number").hide()
	
	$Content/Stats.add_child(label)
	return label
