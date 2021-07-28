extends Control

onready var main = get_tree().get_root().get_node( "Main" )

func _ready():
	
	$SelectSquare.update()

func _input( event ):
	
	if event.is_action_pressed( "pause" ):
		
		if visible == true:
			
			fade_out()
			yield( $BackgroundTween, "tween_completed" )
		
		visible = !visible
		get_tree().paused = visible
		fade_in()
		
		# If the screen isn't visible, you have resumed the game and thus a sound should be played. If it is, play a pause sound.
		if visible == false: $ResumeSound.play()
		if visible == true: $PauseSound.play()
	
	if event.is_action_pressed( "ui_accept" ) and is_visible():
		
		get_tree().paused = false
		get_parent().get_node( "Player" ).ammo = 0
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

func fade_in():
	
	$BackgroundTween.interpolate_property( $Background, "modulate", Color( 1, 1, 1, 0 ), Color( 1, 1, 1, 1 ), .3, Tween.TRANS_BACK, Tween.EASE_OUT )
	$BackgroundTween.start()

func fade_out():
	
	$BackgroundTween.interpolate_property( $Background, "modulate", Color( 1, 1, 1, 1 ), Color( 1, 1, 1, 0 ), .3, Tween.TRANS_BACK, Tween.EASE_IN )
	$BackgroundTween.start()
