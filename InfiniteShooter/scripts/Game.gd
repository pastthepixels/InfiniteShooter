extends Node

# To do with creating enemies
onready var enemy_scene = preload("res://scenes/enemies/Enemy.tscn")
export (String) var game_space = "./ViewportContainer/Viewport/GameSpace"

# Data used when saving the game
export onready var save_data = { "points": 0, "damage": get_node(game_space + "/Player").damage, "health": get_node(game_space + "/Player").max_health }

# Game score/level
export var score = 0

export var level = 1


func _ready():
	# Inherits graphics settings
	get_node("ViewportContainer/Viewport").msaa = get_viewport().msaa
	# Inits "utils" with the viewport
	Utils.init("Game/ViewportContainer/Viewport")
	# Player signals
	get_node(game_space + "/Player").connect("ammo_changed", self, "_on_Player_ammo_changed")
	get_node(game_space + "/Player").connect("health_changed", self, "_on_Player_health_changed")
	get_node(game_space + "/Player").connect("died", self, "_on_Player_died")
	# Music stuff
	GameMusic.play_game() # Fade to a game song
	GameMusic.connect("finished", self, "switch_song") # when finished, switch to a random game song
	load_game() # Load save data (player damage/health)


func switch_song():
	if has_node(game_space + "/Player"): GameMusic.switch_game()


func _on_Countdown_finished():
	make_enemy()
	$EnemyTimer.start()
	$ScoreTimer.start()
	$LevelTimer.start()


func make_enemy():
	# Creates an enemy
	var enemy = enemy_scene.instance()
	get_node(game_space).add_child(enemy) # adds it to the scene
	enemy.initialize( level ) # Initializes the enemy
	
	# Sets the enemy ship's position to a random X point and just above the screen
	enemy.translation.x = Utils.random_screen_point().x
	enemy.translation.z = Utils.screen_to_local(Vector2()).z - (enemy.get_node("EnemyModel").transform.basis.get_scale().z * 2)
	
	# Dynamically changing the interval time
	$EnemyTimer.wait_time = dynamic_enemy_interval( 1.5, 3.5, level * 25, 1 )
	
	# And decreasing it per level
	$EnemyTimer.wait_time -= clamp(level/20, 0, $EnemyTimer.wait_time/2)


# Makes the game harder with this complicated formula!
func dynamic_enemy_interval( min_interval_time, max_interval_time, typical_enemy_health, multiplier ):
	if has_node(game_space + "/Player"):
		return clamp(max_interval_time - (float(get_node(game_space + "/Player").damage) / typical_enemy_health * max_interval_time / multiplier ), min_interval_time, max_interval_time )
	else:
		return 0

func _on_Player_died():
	$EnemyTimer.stop()
	$ScoreTimer.stop()
	$LevelTimer.stop()
	store_score()
	save_game()
	
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
func load_game():
	
	var file = File.new() # Creates a new File object, for handling file operations
	if not file.file_exists("user://userdata.txt"): return # If there is no file containing these stats, don't worry because we have defaults.
	file.open( "user://userdata.txt", File.READ ) # Opens the userdata file for reading
	save_data = file.get_var(true)
	$ViewportContainer/Viewport/GameSpace/Player.set_health(save_data.health)
	$ViewportContainer/Viewport/GameSpace/Player.damage = save_data.damage
	file.close()


func save_game():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://userdata.txt", File.WRITE )
	save_data.points += score
	file.store_var( save_data )
	file.close()
