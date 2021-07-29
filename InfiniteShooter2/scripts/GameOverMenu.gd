extends Control


# Engine vars
onready var main = get_tree().get_root().get_node( "Main" )


# Called when the node enters the scene tree for the first time.
func fade_show():
	
	show()
	$AnimationPlayer.play( "FadeAll" )
	$SelectSquare.update()

func _input( event ):
	
	if event.is_action_pressed( "ui_accept" ) and is_visible():
		
		$SelectSquare/AcceptSound.play()
		match $Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
			
			"Retry": # If it is the one named "play", play the game.
				
				main.get_node( "SceneTransition" ).play( self, "restart_game" )
				
			"Quit": # Otherwise, quit the game
			
				main.get_node( "SceneTransition" ).play( self, "quit_game" )
			
			"MainMenu": # or return to the main menu
			
				main.get_node( "SceneTransition" ).play( self, "main_menu" )

func restart_game():
	
	main.remove_child( get_parent() ) # Removes the node "Game" from the main menu
	get_parent().queue_free() # Calls `queue_free` on it
	main.add_child( load( "res://scenes/Game.tscn" ).instance() ) # adds a new game node

func quit_game():
	
	get_tree().quit()

func main_menu():
	
	main.remove_child( get_parent() ) # Removes the node "Game" from the main menu
	get_parent().queue_free() # Calls `queue_free` on it
	main.add_child( load( "res://scenes/ui/MainMenu.tscn" ).instance() ) # adds a new menu node
