extends Control


# Engine variables
onready var select_square = $SelectSquare
onready var options = $Options
var select_index = 0 # Index of $Options.

# Called when the node enters the scene tree for the first time.
func _ready():
	
	update_selection()

func _input( event ):
	
	# If the start screen is still there, remove it! Also return the function so we don't trigger a menu option at the same time.
	if ( event is InputEventKey or event is InputEventJoypadButton ) and event.pressed and has_node( "StartScreen" ):
		
		
		# Reparents the logo
		var logo = $StartScreen/LogoContainer # <-- This houses the logo, allowing it to be centered AND have an origin point in its middle.
		$StartScreen.remove_child( logo ) # First we remove the logo from this object.
		self.add_child( logo ) # Then we put it in the parent node.
		logo.set_owner( self ) # Then we tell Godot that the logo's parent is `MainMenu`.
		
		# Gets rid of this background
		$StartScreen.queue_free()
		
		# Slides the logo
		logo.get_node( "LogoSlide" ).play( "LogoSlide" )
		
		# Returns the rest of this function
		return
		
	if event.is_action_pressed( "ui_accept" ):
		
		match options.get_child( select_index ).name: # Now we see which option has been selected...
			
			"Play": # If it is the one named "play", play the game.
				
				get_parent().get_node( "SceneTransition" ).play( self, "play_game" )
				
			"Quit": # Otherwise, quit the game
			
				get_parent().get_node( "SceneTransition" ).play( self, "quit_game" )
	
	if event.is_action_pressed( "ui_up" ): select_index -= 1
		
	if event.is_action_pressed( "ui_down" ): select_index += 1
	
	if select_index == options.get_child_count(): select_index = 0
	
	if select_index == -1: select_index = options.get_child_count() - 1 # because zero indexing rules
	
	update_selection()

func update_selection():
	
	var select_child = options.get_child( select_index ) # Gets the current child selected
	var text_length = select_child.get_font( "font" ).get_string_size( select_child.text ).x # Gets the length of its text
	var difference_to_text = ( select_child.rect_size.x - text_length ) / 2 # The amount of space required from the label's origin (left) to where the text begins
	select_square.set_position( select_child.get_global_position() + Vector2( difference_to_text - 20, 0 ) ) # Se ts the position to the position of the selected object MINUS 20px
 
func play_game():
	
	queue_free()
	get_parent().add_child( load( "res://scenes/Game.tscn" ).instance() )

func quit_game():
	
	get_tree().quit()
