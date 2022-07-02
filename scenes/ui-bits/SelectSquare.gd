extends Control

# Use the group "selectsquare_ignore" to ignore certain nodes
export (NodePath) var options_path

# Whether or not to automatically show
export var auto_show = true

# Index of the vbox of labels (options)
export var index = 0

# Vbox containing lables (options)
onready var options = get_node(options_path)

# What object is selected
var select_child

export var margin = 12

var ignore_hits = 0 # Fixes a bug where, if you press space, multiple select squares work at the same time on the main menu

signal selected

signal update

func _ready():
	if auto_show == true:
		$AnimationPlayer.play("Fade")


func _input(event):
	if visible == false or get_parent().visible == false or ("visible" in owner and owner.visible == false) or event.is_echo():
		return  # If the select square is not visible, don't use it
	
	if ignore_hits > 0 and (event is InputEventKey or event is InputEventJoypadButton):
		ignore_hits -= 1
		return

	if event.is_action_pressed("ui_up"):
		index -= 1
		if 0 < index and index < options.get_child_count() and options.get_child(index).is_in_group("selectsquare_ignore"):
			index -= 1

	if event.is_action_pressed("ui_down"):
		index += 1
		if 0 < index and index < options.get_child_count() and options.get_child(index).is_in_group("selectsquare_ignore"):
			index += 1

	if index >= options.get_child_count():
		index = 0

	if index <= -1:
		index = options.get_child_count() - 1  # because zero indexing rules
	
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
		$SelectSound.play()
		$AnimationPlayer.play("Fade")
	
	if event.is_action_pressed("ui_accept"):
		$KeyDownSound.play()
	
	if event.is_action_released("ui_accept"):
		$AcceptSound.play()
		emit_signal("selected")
	


func update():
	assert(options != null, "Error: You did't set the \"options_path\" variable for this instance!")
	select_child = options.get_child(index)
	margin_left = select_child.margin_left
	margin_right = select_child.margin_right + margin
	margin_top = select_child.margin_top
	margin_bottom = select_child.margin_bottom + margin
	set_global_position(select_child.get_global_position() - Vector2(margin/2, margin/2))

func _process(_delta):
	if visible == true and get_parent().visible == true:
		emit_signal("update")
		update()
		$Background/Highlight.visible = Input.is_action_pressed("ui_accept")
		if Input.is_action_pressed("ui_accept"):
			pass
		else:
			pass
