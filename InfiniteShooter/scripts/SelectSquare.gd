extends Control

export (NodePath) var options_path

# Whether or not the square is on the left (e.g. upgrades screen)
export var on_left = false

# Index of the vbox of labels (options)
export var index = 0

# Vbox containing lables (options)
onready var options = get_node(options_path)

export var margin = 2

var ignore_hits = 0 # Fixes a bug where, if you press space, multiple select squares work at the same time on the main menu

signal selected


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
		$AnimationPlayer.play("Fade")
	
	if event.is_action_released("ui_accept") and ignore_hits == 0:
		$AcceptSound.play()
		emit_signal("selected")
	elif event.is_action_released("ui_accept"):
		ignore_hits -= 1



func update():
	assert(options != null, "Error: You did't set the \"options_path\" variable for this instance!")
	
	var select_child = options.get_child(index)
	margin_left = select_child.margin_left
	margin_right = select_child.margin_right + margin
	margin_top = select_child.margin_top
	margin_bottom = select_child.margin_bottom + margin
	set_position(select_child.get_global_position() - Vector2(margin/2, margin/2))

func _process(_delta):
	update()
	if Input.is_action_pressed("ui_accept"):
		$Square.color = Color(.8, .8, .8)
	elif $Square.color == Color(.8, .8, .8):
		$Square.color = Color(1, 1, 1)
