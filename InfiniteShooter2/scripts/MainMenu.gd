extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$Options.add_constant_override( "separation", 10 )

func _input( event ):
	
	# If the start screen is still there, remove it! Also return the function so we don't trigger a menu option at the same time.
	if ( event is InputEventKey or event is InputEventJoypadButton ) and event.pressed and has_node( "StartScreen" ):
		
		# Plays the "gui-accept" sound
		$SelectSquare/AcceptSound.play()
		
		# Reparents the logo
		var logo = $StartScreen/LogoContainer # <-- This houses the logo, allowing it to be centered AND have an origin point in its middle.
		$StartScreen.remove_child( logo ) # First we remove the logo from this object.
		self.add_child( logo ) # Then we put it in the parent node.
		logo.set_owner( self ) # Then we tell Godot that the logo's parent is `MainMenu`.
		
		# Gets rid of this background
		$StartScreen.queue_free()
		
		# Slides the logo
		logo.get_node( "LogoSlide" ).play( "LogoSlide" )
		
		# Allows things to be selected
		$SelectSquare.show()
		
		# Returns the rest of this function
		return
		
	if event.is_action_pressed( "ui_accept" ):
		
		$SelectSquare/AcceptSound.play()
		match $Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
			
			"Play": # If it is the one named "play", play the game.
				
				get_parent().get_node( "SceneTransition" ).play( self, "play_game" )
				
			"Quit": # Otherwise, quit the game
			
				get_parent().get_node( "SceneTransition" ).play( self, "quit_game" )
				
func play_game():
	
	queue_free()
	get_parent().add_child( load( "res://scenes/Game.tscn" ).instance() )

func quit_game():
	
	get_tree().quit()
