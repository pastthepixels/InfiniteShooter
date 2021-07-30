extends Control

onready var game_parent = get_node( "../../" )
onready var game = get_parent()
onready var main = get_tree().get_root().get_node( "Main" )

func _ready():
	$SelectSquare.update()

func _input( event ):
	if event.is_action_pressed( "pause" ):
		
		toggle_pause( true )
	
	if event.is_action_pressed( "ui_accept" ) and is_visible():
		
		game.get_node( "Player" ).ammo = 0 # To prevent the player from firing right as we unpause (since we are unpausing with the space bar)
		toggle_pause( false )
		get_node( "SelectSquare/AcceptSound" ).play()
		match $Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
			
			"Retry": # If it is the one named "play", play the game.
				
				get_tree().get_root().get_node( "SceneTransition" ).play( self, "restart_game" )
				
			"Quit": # Otherwise, quit the game
			
				get_tree().get_root().get_node( "SceneTransition" ).play( self, "quit_game" )
			
			"MainMenu": # or return to the main menu
			
				get_tree().get_root().get_node( "SceneTransition" ).play( self, "main_menu" )

func toggle_pause( toggle_smoothly ):
	if visible == true and toggle_smoothly == true:
			
		$AnimationPlayer.play( "FadeOut" )
		yield( $AnimationPlayer, "animation_finished" )
	
	visible = !visible
	get_tree().paused = visible
	if toggle_smoothly == true: $AnimationPlayer.play( "FadeIn" )
	
	# If the screen isn't visible, you have resumed the game and thus a sound should be played. If it is, play a pause sound.
	if toggle_smoothly == true:
		
		if visible == false: $ResumeSound.play()
		if visible == true: $PauseSound.play()

func restart_game():
	game.queue_free()
	game_parent.remove_child( game ) # Removes the node "Game" from the main menu
	game_parent.add_child( load( "res://scenes/Game.tscn" ).instance() ) # adds a new game node

func quit_game():
	get_tree().quit()

func main_menu():
	game.queue_free()
	game_parent.remove_child( game ) # Removes the node "Game" from the main menu
	main.add_child( load( "res://scenes/ui/MainMenu.tscn" ).instance() ) # adds a new menu node