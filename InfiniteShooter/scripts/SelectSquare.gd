extends ColorRect


# Changeable vars
export (NodePath) var options_path
export var on_left = false
export var index = 0 # Index of the vbox of labels (options)

# Engine vars
onready var options = get_node( options_path )

func _ready():
	
	update()

func _input( event ):
	
	if visible == false or get_parent().visible == false: return # If the select square is not visible, don't use it
	
	if event.is_action_pressed( "ui_up" ): index -= 1
	
	if event.is_action_pressed( "ui_down" ): index += 1
	
	if event.is_action_pressed( "ui_up" ) or event.is_action_pressed( "ui_down" ): $SelectSound.play()
	
	if index == options.get_child_count(): index = 0
	
	if index == -1: index = options.get_child_count() - 1 # because zero indexing rules
	
	update()

func update():
	
	assert( options != null, "Error: You did't set the \"options_path\" variable for this instance!" )
	var select_child = options.get_child( index ) # Gets the current child selected
	var text_length = select_child.get_font( "font" ).get_string_size( select_child.text ).x # Gets the length of its text
	var difference_to_text = ( select_child.rect_size.x - text_length ) / 2 # The amount of space required from the label's origin (left) to where the text begins
	var position_offset = Vector2( difference_to_text - 20, select_child.get_size().y / 2 - 5 )
	if on_left == true: position_offset.x = -20
	set_position( select_child.get_global_position() + position_offset ) # Se ts the position to the position of the selected object MINUS 20px
	
