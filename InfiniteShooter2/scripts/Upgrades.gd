extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	create_label( "50 PTS: +5% damage, +5% health", "" )
	
func handle_selection():
	match $VBoxContainer/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"Back":
			hide()
			get_node("../LogoContainer").show()
			get_node("../SelectSquare").show()

func create_label( text, tooltip ):
	var label = Label.new()
	label.text = text
	label.hint_tooltip = tooltip
	label.mouse_filter = Control.MOUSE_FILTER_PASS # <-- In order for the tooltip to work
	label.set("custom_colors/font_color", Color(0,0,0))
	$VBoxContainer/Options.add_child( label )
	return label
