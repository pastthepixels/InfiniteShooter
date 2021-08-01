extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready(): # TODO: Read user://scores.txt
	for i in range(1,11):
		var userdata = "placeholder"
		create_label( ( "%s. " + userdata ) % i )

func create_label( text ):
	var label = Label.new()
	label.text = text
	label.set("custom_colors/font_color", Color(0,0,0))
	$VBoxContainer.add_child( label )
