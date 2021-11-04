extends Node

# To do with creating enemies
export(PackedScene) var enemy_scene

export(PackedScene) var boss_scene

export(NodePath) var game_space

# Game mechanics variables
var score = 0

var level = 1

var wave = 1

var enemies_in_wave = 0

var max_enemies_on_screen = GameVariables.enemies_on_screen_range[0]

export var autospawn_enemies = false # Whether or not to spawn new enemies when they die

# Scripts
export var tutorial_script = [
	"Welcome to InfniteShooter!",
	"Use the arrow keys to move around (left stick on a controller).",
	"wait_movement", # Command to wait for player movement
	"Excellent work!",
	"begin_wait_laser",
	"Now press space or A on a controller to fire a laser.",
	"end_wait_laser", # Command to wait for the player to fire a laser
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
	# Music stuff and save stuff
	GameMusic.start_game() # Fade to a game song
	load_game() # Load save data (player damage/health)
	# HUD stuff
	$HUD.update_level(level, 100 * wave/GameVariables.waves_per_level)
	# Begins the countdown/shows the tutorial
	if Saving.is_tutorial_complete():
		$Countdown.start()
	else:
		activate_tutorial()

func _process(_delta):
	if has_node("GameSpace/Player"):
		match($GameSpace/Player.modifier):
			GameVariables.LASER_MODIFIERS.fire:
				$HUD.update_gradient($HUD.TEXTURES.fire)
			
			GameVariables.LASER_MODIFIERS.ice:
				$HUD.update_gradient($HUD.TEXTURES.ice)
			
			GameVariables.LASER_MODIFIERS.corrosion:
				$HUD.update_gradient($HUD.TEXTURES.corrosion)
			
			GameVariables.LASER_MODIFIERS.none:
				$HUD.update_gradient($HUD.TEXTURES.default)

func _on_Countdown_finished():
	make_enemies()

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
				yield(make_enemy(), "died")
				$TutorialAlert.user_confirmation = true
			
			"wait_movement":
				yield($GameSpace/Player, "moved")
				$TutorialAlert.user_confirmation = true
			
			"end_wait_laser":
				$TutorialAlert.confirmation_key = "ui_dismiss"
			
			_:
				$TutorialAlert.alert(line, len(line) * .05)
				yield($TutorialAlert, "finished")
	Saving.complete_tutorial()
	SceneTransition.restart_game()

#
# Waves, levels, and score
#
func wave_up():
	# Switches the wave number and (if possible) levels up
	wave += 1
	enemies_in_wave = 0
	if wave == GameVariables.waves_per_level + 1:
		yield(Utils.timeout(1), "timeout") # Waits exactly one second
		make_boss() # then initiates a boss battle
	else:
		yield($HUD.alert("Wave %s" % (wave - 1), 2, "Wave %s" % wave), "completed")
		# Resumes enemy spawning after the popup
		make_enemies()
		# Updates the HUD
		$HUD.update_wave(wave, 0)
		$HUD.update_level(level, 100 * wave/GameVariables.waves_per_level)

func level_up():
	level += 1
	wave = 1
	max_enemies_on_screen = clamp(max_enemies_on_screen+1, GameVariables.enemies_on_screen_range[0], GameVariables.enemies_on_screen_range[1])
	# GUI stuff
	yield($HUD.alert("Level %s" % (level - 1), 2, "Level %s" % level), "completed")
	$HUD.update_wave(wave, 0)
	$HUD.update_level(level, 0)
	$LevelSound.play()
	# Resumes enemy spawning after the popup
	make_enemies()

#
# Making enemies
#
func make_enemies():
	autospawn_enemies = true
	for enemy in max_enemies_on_screen:
		make_enemy()
		yield(Utils.timeout(.5), "timeout")

func make_enemy():
	# Creates an enemy
	var enemy = enemy_scene.instance()
	enemy.connect("died", self, "_on_Enemy_died")
	
	# Sets the enemy ship's position to a random X point and just above the screen, then adds it to the scene and initializes it.
	enemy.translation = set_random_enemy_position()
	get_node(game_space).add_child(enemy)
	enemy.initialize(level * GameVariables.enemy_difficulty)
	
	# Updates the HUD with the current amount of enemies in the wave
	enemies_in_wave += 1
	$HUD.update_wave(wave, 100 * enemies_in_wave/GameVariables.enemies_per_wave)
	if enemies_in_wave == GameVariables.enemies_per_wave:
		autospawn_enemies = false
	
	return enemy

func set_random_enemy_position(times_ran=0):
	var position = Vector3(Utils.random_screen_point().x, 0, Utils.top_left.z - (.2 * times_ran))
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if position.distance_to(enemy.translation) < 4:
			return set_random_enemy_position(times_ran + 1)
	return position

func make_boss():
	# Creates a boss
	var boss = boss_scene.instance()
	boss.translation.z = Utils.screen_to_local(Vector2()).z - 5
	boss.connect("died", self, "_on_Boss_died")
	get_node(game_space).add_child(boss) # adds it to the scene
	boss.initialize(level * GameVariables.enemy_difficulty) # Initializes the enemy

func _on_Boss_died(_boss):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0: level_up()

func _on_Enemy_died(ship, from_player):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Score
		if from_player: score += ship.max_health / 2
		ship.disconnect("died", self, "_on_enemy_died_score")
		$HUD.update_score(score)
		
		# Wave progression
		if enemies_in_wave >= GameVariables.enemies_per_wave and len(get_tree().get_nodes_in_group("enemies")) == 0:
			wave_up()
		
		# Spawning new enemies
		if autospawn_enemies == true and\
			len(get_tree().get_nodes_in_group("enemies")) < max_enemies_on_screen:
			make_enemy()

#
# Player stuff
#
func _on_Player_died():
	$PauseMenu.set_process_input(false)
	$HUD.update_health(0)
	$HUD/AnimationPlayer.play("fade_out")
	Saving.create_leaderboard_entry(score)
	save_game()
	# Shows the "game over" menu and prevents the player from pausing the game
	yield(Utils.timeout(1), "timeout") # AFTER waiting for a bit
	$GameOverMenu.start()


func _on_Player_ammo_changed(value, refills):
	$HUD.update_ammo(value, refills)


func _on_Player_health_changed(value):
	$HUD.update_health(value)

#
# Saving and loading data
#
func load_game():
	var save_data = Saving.load_userdata()
	$GameSpace/Player.health = save_data.health
	$GameSpace/Player.damage = save_data.damage

func save_game():
	var save_data = Saving.load_userdata()
	save_data.points += score
	Saving.save_userdata(save_data)
