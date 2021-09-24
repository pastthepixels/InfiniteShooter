extends Node

# To do with creating enemies
onready var enemy_scene = preload("res://scenes/enemies/Enemy.tscn")

export (String) var game_space = "./GameSpace"

# Data used when saving the game
export onready var save_data = { "points": 0, "damage": get_node(game_space + "/Player").damage, "health": get_node(game_space + "/Player").max_health }

# Game mechanics variables
var score = 0

var level = 1

var wave = 1

var enemies_in_wave = 0

# User-adjustable game mechanics variables
export var enemy_difficulty = 1

export var waves_per_level = 5

export var enemies_per_wave = 20

#
# Countdown timers, initialization and music
#
func _ready():
	# Music stuff
	GameMusic.start_game() # Fade to a game song
	load_game() # Load save data (player damage/health)
	# HUD stuff
	$HUD.update_level(level, 100 * wave/waves_per_level)
	$GameSpace/Player.update_hud()

func _on_Countdown_finished():
	make_enemy()
	$EnemyTimer.start()

#
# Waves, levels, and score
#
func wave_up():
	# Stops enemies from spawning and waits until they all die.
	$EnemyTimer.paused = true
	while len(get_tree().get_nodes_in_group("enemies")) > 0: yield(Utils.timeout(.05), "timeout") # Simply wait until all enemies die
	# Switches the wave number and (if possible) levels up
	wave += 1
	enemies_in_wave = 0
	if wave == waves_per_level + 1:
		level_up()
	else:
		yield($HUD.alert("Wave %s" % (wave - 1), 2, "Wave %s" % wave), "completed")
	# Updates the HUD
	$HUD.update_wave(wave, 0)
	$HUD.update_level(level, 100 * wave/waves_per_level)
	# Resumes enemy spawning
	$EnemyTimer.paused = false

func level_up():
	
	level += 1
	wave = 1
	if $EnemyTimer.wait_time > 2: $EnemyTimer.wait_time -= 0.2
	yield($HUD.alert("Level %s" % (level - 1), 2, "Level %s" % level), "completed")
	$HUD.update_wave(wave, 0)
	$HUD.update_level(level, 0)
	$LevelSound.play()

#
# Making enemies
#
var last_enemy_position = Vector3()
func make_enemy():
	# Ensures no enemy ships have the ability to create a new enemy when they die
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_user_signal("died"): enemy.disconnect("died", self, "_on_enemy_died")
	# Creates an enemy
	var enemy = enemy_scene.instance()
	enemy.connect("died", self, "_on_enemy_died") # Basically says that if you kill this enemy dies before the next one spawns automatically, spawn it now
	enemy.connect("died", self, "_on_enemy_died_score")
	get_node(game_space).add_child(enemy) # adds it to the scene
	enemy.initialize(level * enemy_difficulty) # Initializes the enemy
	
	# Sets the enemy ship's position to a random X point and just above the screen
	enemy.translation.x = Utils.random_screen_point().x
	enemy.translation.z = Utils.screen_to_local(Vector2()).z - rand_range(-2.0, 0)
	if enemy.translation.distance_to(last_enemy_position) < 1:
		enemy.translation.x = Utils.random_screen_point().x
	last_enemy_position = enemy.translation
	
	# Updates the HUD with the current amount of enemies in the wave
	enemies_in_wave += 1
	$HUD.update_wave(wave, 100 * enemies_in_wave/enemies_per_wave)
	if enemies_in_wave == enemies_per_wave:
		wave_up()

func _on_enemy_died(_enemy):
	if $EnemyTimer.paused == false: make_enemy()

func _on_enemy_died_score(enemy):
	if enemy.killed_from_player: score += enemy.max_health / 2
	enemy.disconnect("died", self, "_on_enemy_died_score")
	$HUD.update_score(score)

# Makes the game harder with this complicated formula!
func dynamic_enemy_interval(min_interval_time, max_interval_time, typical_enemy_health, multiplier):
	if has_node(game_space + "/Player"):
		return clamp(max_interval_time - (float(get_node(game_space + "/Player").damage) / typical_enemy_health * max_interval_time / multiplier ), min_interval_time, max_interval_time )
	else:
		return 0

#
# Player stuff
#
func _on_Player_died():
	$HUD.update_health(0)
	$EnemyTimer.stop()
	store_score()
	save_game()
	
	# Shows the "game over" menu and prevents the player from pausing the game
	yield(Utils.timeout(1), "timeout") # AFTER waiting for a bit
	$GameOverMenu.fade_show()


func _on_Player_ammo_changed(value, refills):
	$HUD.update_ammo(value, refills)


func _on_Player_health_changed( value ):
	$HUD.update_health( value )

#
# Saving and loading data
#
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
	$GameSpace/Player.set_health(save_data.health)
	$GameSpace/Player.damage = save_data.damage
	file.close()


func save_game():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://userdata.txt", File.WRITE )
	save_data.points += score
	file.store_var( save_data )
	file.close()
