extends Spatial


# Declare member variables here.
onready var utils = load( "res://scripts/Utils.gd" ).new() # Man if I only had better Mono support... I'd replace this line with `Utils utils = new Utils()` in a *heartbeat*.
export ( PackedScene ) var Enemy
export var score = 0
export var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	utils.init( get_viewport() )

func _on_Countdown_finished():
	
	$EnemyTimer.start()
	$ScoreTimer.start()
	$LevelTimer.start()
	make_enemy()

func make_enemy():
	
	# Creates an enemy
	var enemy =  Enemy.instance() # Every time I see "var" used to declare a variable, I only feel complete once I put a semicolon at the end of the line.
	add_child( enemy ) # adds it to the scene
	enemy.initialize() # Initializes the enemy
	enemy.translation.x = utils.random_screen_point().x
	enemy.translation.z = utils.screen_to_local( Vector2( 0, 0 ) ).z - ( enemy.get_node( "EnemyModel" ).transform.basis.get_scale().z * 2)

func _on_Player_died():
	
	$EnemyTimer.stop()
	$ScoreTimer.stop()
	$LevelTimer.stop()
	store_score()
	
	# Shows the "game over" menu and prevents the player from pausing the game
	yield( get_tree().create_timer( 1.0 ), "timeout" ) # AFTER waiting for a bit (if porting to different programming languages, this is Godot's setTimeout)
	$GameOverMenu.fade_show()

func _on_Player_ammo_changed( value ):
	
	$HUD.update_ammo( value )

func _on_Player_health_changed( value ):
	

	$HUD.update_health( value )


func _on_ScoreTimer_timeout():
	
	score += 1
	$HUD.update_score( score )

func _on_LevelTimer_timeout():
	
	level += 1
	if $EnemyTimer.wait_time > 2: $EnemyTimer.wait_time -= 0.2
	$HUD.update_level( level )
	$LevelSound.play()

func store_score():
	
	var file = File.new() # Creates a new File object, for handling file operations
	if file.file_exists("user://scores.txt") == false: 
		file.open( "user://scores.txt", File.WRITE ) # This creates a new file if there is none but truncates (writes over) existing files
	else:
		file.open( "user://scores.txt", File.READ_WRITE ) # This does NOT create a new file if there is none but also does NOT truncate existing files
		file.seek_end() # Goes to the end of the file to write a new line
	file.store_line( OS.get_environment("USERNAME") + " ~> %s" % score) # Writes a new line that looks like this: "$USERNAME ~> $SCORE"
	file.close()
