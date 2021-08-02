extends Spatial


# Declare member variables here.
onready var utils = load( "res://scripts/Utils.gd" ).new() # Man if I only had better Mono support... I'd replace this line with `Utils utils = new Utils()` in a *heartbeat*.
export ( PackedScene ) var Enemy
export onready var save_data = { "points": 0, "damage": $Player.damage, "health": $Player.max_health }
export var score = 0
export var level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	
	utils.init( get_viewport() )
	load_data()

func _on_Countdown_finished():
	
	make_enemy()
	$EnemyTimer.start()
	$ScoreTimer.start()
	$LevelTimer.start()

func make_enemy():
	
	# Creates an enemy
	var enemy =  Enemy.instance() # Every time I see "var" used to declare a variable, I only feel complete once I put a semicolon at the end of the line.
	add_child( enemy ) # adds it to the scene
	enemy.initialize() # Initializes the enemy
	enemy.translation.x = utils.random_screen_point().x
	enemy.translation.z = utils.screen_to_local( Vector2( 0, 0 ) ).z - ( enemy.get_node( "EnemyModel" ).transform.basis.get_scale().z * 2)
	# Dynamically changing the interval time
	$EnemyTimer.wait_time = dynamic_enemy_interval( 1.5, 5, level * 50, 1 )

# Makes the game harder with this complicated formula!
func dynamic_enemy_interval( min_interval_time, max_interval_time, typical_enemy_health, multiplier ):
	return clamp( max_interval_time - (float($Player.damage) / typical_enemy_health * max_interval_time / multiplier ), min_interval_time, max_interval_time )
	
func _on_Player_died():
	
	$EnemyTimer.stop()
	$ScoreTimer.stop()
	$LevelTimer.stop()
	store_score()
	save_data()
	
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
	file.store_line( ( OS.get_environment("USERNAME") + " ~> %s" % score ) + " ~> " + get_datetime() ) # Writes a new line that looks like this: "$USERNAME ~> $SCORE ~> $DATE"
	file.close()
	
func get_datetime():
	var datetime = OS.get_datetime()
	var time = str(datetime.hour) + ":" + str(datetime.minute) + ":" + str(datetime.second) + " " + OS.get_time_zone_info().name
	var date = str(datetime.day) + "/" + str(datetime.month) + "/" + str(datetime.year)
	return time + " " + date
	
# Loading/saving damage/health stats
func load_data():
	
	var file = File.new() # Creates a new File object, for handling file operations
	if not file.file_exists("user://userdata.txt"): return # If there is no file containing these stats, don't worry because we have defaults.
	file.open( "user://userdata.txt", File.READ ) # Opens the userdata file for reading
	save_data = file.get_var(true)
	$Player.set_health(save_data.health)
	$Player.damage = save_data.damage
	file.close()

func save_data():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://userdata.txt", File.WRITE )
	save_data.points += score
	file.store_var( save_data )
	file.close()
