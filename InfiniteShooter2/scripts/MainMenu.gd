extends Control

func _input( event ):
	
	# If the start screen is still there, remove it! Also return the function so we don't trigger a menu option at the same time.
	if ( event is InputEventKey or event is InputEventJoypadButton ) and event.pressed and has_node( "StartScreen" ) and has_node( "StartScreen/LogoContainer" ):
		
		# Ensures the scrolling background is not playing
		get_node( "../ScrollingBackground" ).stop()
		
		# Plays the "gui-accept" sound
		$SelectSquare/AcceptSound.play()
		
		# Reparents the logo
		var logo = $StartScreen/LogoContainer # <-- This houses the logo, allowing it to be centered AND have an origin point in its middle.
		$StartScreen.remove_child( logo ) # First we remove the logo from this object.
		self.add_child( logo ) # Then we put it in the parent node.
		logo.set_owner( self ) # Then we tell Godot that the logo's parent is `MainMenu`.
		
		# Gets rid of this background
		$StartScreen.queue_free()
		
		# Slides the scale of the logo
		logo.get_node( "LogoSlide" ).play( "LogoSlide" )
		
		# Slides the logo container -- DYNAMICALLY
		var tween = Tween.new() # Makes a tween node
		add_child( tween ) # and adds it to the MainMenu node
		# vvv Does some fancy math to center the logo just 100 pixels above the middle
		tween.interpolate_property( logo, "rect_position", logo.get_position(), Vector2( logo.get_position().x, logo.get_position().y - 100 ), 1, Tween.TRANS_QUAD, Tween.EASE_OUT )
		tween.start() # Starts it!
		
		# Allows things to be selected
		$SelectSquare.show()
		
		# Returns the rest of this function
		return
		
	if event.is_action_pressed( "ui_accept" ):
		
		$SelectSquare/AcceptSound.play()
		match $Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
			
			"Play": # If it is the one named "play", play the game.
				
				SceneTransition.play( self, "play_game" )
			
			"Leaderboard": # Same with selecting the leaderboard
				
				if $Leaderboard.visible == false:
					$Leaderboard.show()
					$LogoContainer.hide()
					$SelectSquare.hide()
				else:
					$Leaderboard.hide()
					$LogoContainer.show()
					$SelectSquare.show()
			
			"Upgrades": # Same with selecting the upgrades screen
				
				if $Upgrades.visible == false:
					$Upgrades.show()
					$LogoContainer.hide()
					$SelectSquare.hide()
				else:
					$Upgrades.handle_selection()
				
			"Quit": # Otherwise, quit the game
			
				SceneTransition.play( self, "quit_game" )
				
func play_game():
	
	queue_free()
	get_node( "../ScrollingBackground" ).play()
	get_node( "../ViewportContainer/Viewport" ).add_child( load( "res://scenes/Game.tscn" ).instance() )

func quit_game():
	
	get_tree().quit()
