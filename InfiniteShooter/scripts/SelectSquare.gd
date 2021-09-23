extends TextureRect

export (NodePath) var options_path

# Whether or not the square is on the left (e.g. upgrades screen)
export var on_left = false

# Index of the vbox of labels (options)
export var index = 0

# Vbox containing lables (options)
onready var options = get_node(options_path)

export var margin = 20


func _input(event):
	if visible == false or get_parent().visible == false:
		return  # If the select square is not visible, don't use it

	if event.is_action_pressed("ui_up"):
		index -= 1

	if event.is_action_pressed("ui_down"):
		index += 1

	if index == options.get_child_count():
		index = 0

	if index == -1:
		index = options.get_child_count() - 1  # because zero indexing rules
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		update()
		$SelectSound.play()



func update():
	assert(options != null, "Error: You did't set the \"options_path\" variable for this instance!")
	
	# Gets the current child selected and creates some variables
	var select_child = options.get_child(index)
	var position_offset = Vector2()

	# If the selected text is a Label node, use some fancy functions to get the length of the *text* (not the node) and position the square accordingly
	if select_child is Label:
		var text_length = select_child.get_font("font").get_string_size(select_child.text).x  # Gets the length of its text
		var difference_to_text = (select_child.rect_size.x - text_length) / 2  # The amount of space required from the label's origin (left) to where the text begins
		position_offset = Vector2(difference_to_text - margin, select_child.get_size().y / 2 - rect_size.y / 2)
	else:
		pass  # TODO: get the centers of non-label objects

	# If the select square is to be on the left, do some math
	if on_left == true:
		position_offset.x = -margin

	# Sets the position to the position of the selected object
	set_position(select_child.get_global_position() + position_offset)

func _process(_delta):
	update()
	if Input.is_action_pressed("ui_select"):
		$ColorRect.color = Color(.8, .8, .8)
	elif $ColorRect.color == Color(.8, .8, .8):
		$ColorRect.color = Color(1, 1, 1)
