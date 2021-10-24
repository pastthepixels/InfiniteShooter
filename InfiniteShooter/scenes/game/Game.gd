extends Node

# To do with creating enemies
export(PackedScene) var enemy_scene

export(PackedScene) var boss_scene

export(NodePath) var game_space

# Data used when saving the game
export onready var save_data = { "points": 0, "damage": get_node(game_space).get_node("Player").damage, "health": get_node(game_space).get_node("Player").max_health }

# Game mechanics variables
var score = 0

var level = 1

var wave = 1

var enemies_in_wave = 0

var max_enemies_on_screen = GameVariables.enemies_on_screen_range[0]

export var show_tutorial = true

# User-adjustable game mechanics variables. Can be found in scripts/GameVariables.gd
var enemy_difficulty = GameVariables.enemy_difficulty

var waves_per_level = GameVariables.waves_per_level

var enemies_per_wave = GameVariables.enemies_per_wave

var MODIFIERS = GameVariables.LASER_MODIFIERS

# Scripts
export var tutorial_script = [
	"Welcome to InfniteShooter!",
	"begin_wait",
	"Use the arrow keys to move around (left stick on a controller).",
	"wait_movement", # Command to wait for player movement
	"Excellent work!",
	"begin_wait_laser",
	"Now press space or A on a controller to fire a laser.",
	"wait_laser", # Command to wait for the player to fire a laser
	"begin_wait",
	"Here comes an enemy ship; don't let it reach the bottom of the screen!",
	"wait_enemy", # Command to spawn an enemy
	"Next, let's talk about the in-game HUD.",
	"Your health is the green bar in the top left corner.",
	"The grey bar is your ammo (the number beside it notes your refills).",
	"On the bottom, we have the current level, wave, score, and frame rate.",
	"And that's all you need to know about InfiniteShooter!",
	"Let's see if you can keep up with the game... good luck!",
]

#
# Countdown timers, initialization, music, and _process
#
func _ready():
	# Starts spinning the sky
	CameraEquipment.get_node("SkyAnimations").play("SkyRotate")
	# Music stuff
	GameMusic.start_game() # Fade to a game song
	load_game() # Load save data (player damage/health)
	# HUD stuff
	$HUD.update_level(level, 100 * wave/waves_per_level)
	$GameSpace/Player.update_hud()
	# Loads tutorial information
	load_tutorialcomplete()

func _process(_delta):
	if has_node("GameSpace/Player"):
		match($GameSpace/Player.modifier):
			MODIFIERS.fire:
				$HUD.update_gradient($HUD.TEXTURES.fire)
			
			MODIFIERS.ice:
				$HUD.update_gradient($HUD.TEXTURES.ice)
			
			MODIFIERS.corrosion:
				$HUD.update_gradient($HUD.TEXTURES.corrosion)
			
			MODIFIERS.none:
				$HUD.update_gradient($HUD.TEXTURES.default)

func _on_Countdown_finished():
	if show_tutorial == true:
		activate_tutorial()
	else:
		make_enemy()
		$EnemyTimer.start()

#
# the Tutorial
#
func activate_tutorial():
	yield(Utils.timeout(.5), "timeout")
	for line in tutorial_script:
		match line:
			"begin_wait":
				$TutorialAlert.waiting = false
				$TutorialAlert.user_confirmation = false
			"begin_wait_laser":
				$TutorialAlert.confirmation_key = "shoot_laser"
				$TutorialAlert.user_confirmation = true
			"wait_enemy":
				yield(make_enemy(false), "died")
				$TutorialAlert.user_confirmation = true
			"wait_movement":
				yield($GameSpace/Player, "moved")
				$TutorialAlert.user_confirmation = true
			"wait_laser":
				$TutorialAlert.confirmation_key = "ui_dismiss"
			_:
				$TutorialAlert.alert(line, len(line) * .05)
				yield($TutorialAlert, "finished")
	yield(Utils.timeout(1), "timeout")
	make_enemy()
	$EnemyTimer.start()
	save_tutorialcomplete()

func load_tutorialcomplete():
	
	var file = File.new() # Creates a new File object, for handling file operations
	show_tutorial = not file.file_exists("user://tutorial-complete")
	file.close()


func save_tutorialcomplete():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://tutorial-complete", File.WRITE )
	file.store_line( "true" )
	file.close()

#
# Waves, levels, and score
#
func wave_up():
	if has_node("GameSpace/Player") == false: return
	# Stops enemies from spawning and waits until they all die.
	$EnemyTimer.paused = true
	if is_instance_valid(self): while len(get_tree().get_nodes_in_group("enemies")) > 0: yield(Utils.timeout(.05), "timeout")
	# Switches the wave number and (if possible) levels up
	wave += 1
	enemies_in_wave = 0
	if wave == waves_per_level + 1:
		yield(Utils.timeout(1), "timeout") # Waits exactly one second
		make_boss() # then initiates a boss battle
	else:
		yield($HUD.alert("Wave %s" % (wave - 1), 2, "Wave %s" % wave), "completed")
		# Resumes enemy spawning after the popup
		$EnemyTimer.paused = false
		# Updates the HUD
		$HUD.update_wave(wave, 0)
		$HUD.update_level(level, 100 * wave/waves_per_level)

func level_up():
	if has_node("GameSpace/Player") == false: return
	level += 1
	wave = 1
	max_enemies_on_screen = clamp(max_enemies_on_screen+1, GameVariables.enemies_on_screen_range[0], GameVariables.enemies_on_screen_range[1])
	yield($HUD.alert("Level %s" % (level - 1), 2, "Level %s" % level), "completed")
	$HUD.update_wave(wave, 0)
	$HUD.update_level(level, 0)
	$LevelSound.play()
	# Resumes enemy spawning after the popup
	$EnemyTimer.paused = false

#
# Making enemies
#
func make_enemy(spawn_more=true):
	# Ensures no enemy ships have the ability to create a new enemy when they die
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_user_signal("died"): enemy.disconnect("died", self, "_on_enemy_died")
	# Creates an enemy
	var enemy = enemy_scene.instance()
	if spawn_more == true: enemy.connect("died", self, "_on_enemy_died") # Basically says that if you kill this enemy dies before the next one spawns automatically, spawn it now
	enemy.connect("died", self, "_on_enemy_died_score")
	
	# Sets the enemy ship's position to a random X point and just above the screen, then adds it to the scene and initializes it.
	enemy.translation = set_random_enemy_position()
	get_node(game_space).add_child(enemy)
	enemy.initialize(level * enemy_difficulty)
	
	# Updates the HUD with the current amount of enemies in the wave
	enemies_in_wave += 1
	$HUD.update_wave(wave, 100 * enemies_in_wave/enemies_per_wave)
	if enemies_in_wave == enemies_per_wave:
		wave_up()
	
	return enemy


func _on_EnemyTimer_timeout():
	if len(get_tree().get_nodes_in_group("enemies")) < max_enemies_on_screen: make_enemy()

func set_random_enemy_position(times_ran=0):
	var position = Vector3(Utils.random_screen_point().x, 0, Utils.screen_to_local(Vector2()).z - rand_range(-2.0, 1.0) - (.2 * times_ran))
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if position.distance_to(enemy.translation) < 4:
			return set_random_enemy_position(times_ran + 1)
	return position

func make_boss():
	# Creates a boss
	var boss = boss_scene.instance()
	boss.translation.z = Utils.screen_to_local(Vector2()).z - 5
	boss.connect("died", self, "_on_boss_died")
	get_node(game_space).add_child(boss) # adds it to the scene
	boss.initialize(level * enemy_difficulty) # Initializes the enemy

func _on_boss_died(_boss):
	level_up()

func _on_enemy_died(_ship, _from_player):
	if $EnemyTimer.time_left > 0 and $EnemyTimer.paused == false: _on_EnemyTimer_timeout()

func _on_enemy_died_score(ship, from_player):
	if $EnemyTimer.time_left > 0:
		if from_player: score += ship.max_health / 2
		ship.disconnect("died", self, "_on_enemy_died_score")
		$HUD.update_score(score)

#
# Player stuff
#
func _on_Player_died():
	$HUD.update_health(0)
	$HUD/AnimationPlayer.play("fade_out")
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
	$GameSpace/Player.health = save_data.health
	$GameSpace/Player.damage = save_data.damage
	file.close()


func save_game():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://userdata.txt", File.WRITE )
	save_data.points += score
	file.store_var( save_data )
	file.close()
