extends Node

# To do with creating enemies
var enemy_scene = LoadingScreen.access_scene("res://scenes/entities/enemies/Enemy.tscn")

var boss_scene = LoadingScreen.access_scene("res://scenes/entities/bosses/Boss.tscn")

var dock_scene = LoadingScreen.access_scene("res://scenes/entities/dock/DockingStation.tscn")

export(NodePath) var game_space

onready var next_enemy_position = set_random_enemy_position()

# Game mechanics variables
var died = false

var score = 0

var points = 0

var level = 1

var wave = 1

var enemies_in_wave = 0

var possible_enemies = GameVariables.level_dependent_enemy_types[0][1]

var max_enemies_on_screen = GameVariables.enemies_on_screen_range[0]

var waves_per_level = GameVariables.waves_per_level_range[0]

var use_laser_modifiers = false # Whether or not to use laser modifiers

var autospawn_enemies = false # Whether or not to spawn new enemies when they die (used within this script)

# Scripts
export var tutorial_script = [
	"Welcome to InfniteShooter!",
	"Use the arrow keys to move around (left stick on a controller), and press space or A on a controller to fire a laser. Try it out!",
	"wait_5",
	"Optionally, you can press the control key (LB or RB on a controller) to slow time.",
	"Here comes an enemy ship! SHOOT IT UNTIL IT DIES!",
	"wait_enemy",
	"You may have noticed that the enemy may have dropped a powerup. To use it, simply run over it with your ship. Different powerups have different effects, so try them all out!",
	"If you are, however, sick and tired of powerups only appearing randomly, you can just run into ships. Seriously. Not only will it look cool, but you can also get health or ammo powerups to get you back into the game.",
	"Just make sure to watch your health, however, as running into ships will decrease it by the amount of health the enemy has! When enemies flash red, that means it's safe to run into them without taking a hit to your health.",
	"Next, let's talk about the in-game HUD.",
	"Your health is the green bar in the top left corner. The grey bar is your ammo (the number beside it notes your refills).",
	"For the status bar, we have the current level, wave, score, and frame rate, respectively.",
	"And that's all you need to know about InfiniteShooter! Thank you for playing and good luck!"
]

export var tutorial_elemental_script = [
	"On this level, we'll introduce elemental damage, where different enemy ships have a chance of using a different type of laser.",
	"You may now be familiar with the concpet of powerups. Now, evey time you destroy a ship that uses elemental damage, it will drop a powerup which gives you its elemental ability when collected.",
	"However, the white and red powerup you may have previously used to destroy all enemies on the screen actually resets the screen, killing all enemies but resetting your elemental ability.",
	"Lastly, while dealing with elemental damage, make sure you don't get hit yourself!"
]

#
# Countdown timers, initialization, music, and _process
#
func _ready():
	# Starts spinning the sky (and plays another cool animation)
	CameraEquipment.set_sky(0)
	CameraEquipment.reset_sky_animation_speed()
	CameraEquipment.get_node("SkyAnimations").play("SkyRotate")
	CameraEquipment.get_node("CameraAnimations").stop()
	CameraEquipment.get_node("CameraAnimations").play("ZoomOut")
	# HUD stuff
	if waves_per_level > 0: $HUD.update_level(level, 100 * wave/waves_per_level)
	# Begins the countdown/shows the tutorial/plays appropiate music
	if Saving.get_tutorial_progress()["initial"] == true:
		$Countdown.start()
		$GameMusic.start_game()
	else:
		$Countdown.queue_free()
		$GameSpace/IndicatorArrow.hide()
		$TutorialMusic.play()
		yield(CameraEquipment.get_node("CameraAnimations"), "animation_finished")
		activate_tutorial()


func _on_Countdown_finished():
	make_enemies()

#
# the Tutorial
#
func activate_tutorial():
	yield(Utils.timeout(.5), "timeout")
	yield(parse_tutorial(tutorial_script), "completed")
	var progress = Saving.get_tutorial_progress()
	progress["initial"] = true
	Saving.set_tutorial_progress(progress)
	SceneTransition.restart_game()

func activate_tutorial_elemental():
	yield(parse_tutorial(tutorial_elemental_script), "completed")
	var progress = Saving.get_tutorial_progress()
	progress["elemental"] = true
	Saving.set_tutorial_progress(progress)

func parse_tutorial(script):
	for line in script:
		match line:
			"wait_enemy":
				yield(make_enemy(), "died")
				yield(Utils.timeout(2), "timeout")

			"wait_5":
				yield(Utils.timeout(5), "timeout")

			_:
				$TutorialAlert.alert(line)
				yield($TutorialAlert, "confirmed")
#
# Waves, levels, and score
#
func wave_up():
	# Switches the wave number and (if possible) levels up
	wave += 1
	enemies_in_wave = 0
	if wave == waves_per_level + 1:
		yield(Utils.timeout(1), "timeout") # Waits exactly one second
		make_boss() # then initiates a boss battle
	else:
		yield($HUD.alert("Wave %s" % (wave - 1), 2, "Wave %s" % wave), "completed")
		# Resumes enemy spawning after the popup
		make_enemies()
		# Updates the HUD
		$HUD.update_wave(wave, 0)
		$HUD.update_level(level, 100 * wave/waves_per_level)

func level_up():
	level += 1
	wave = 1
	max_enemies_on_screen = clamp(max_enemies_on_screen+1, GameVariables.enemies_on_screen_range[0], GameVariables.enemies_on_screen_range[1])
	waves_per_level = clamp(waves_per_level+1, GameVariables.waves_per_level_range[0], GameVariables.waves_per_level_range[1])
	# First, the docking station
	var dock = dock_scene.instance()
	get_node(game_space).add_child(dock)
	yield(dock, "finished")
	# Then, GUI stuff
	yield($HUD.alert("Level %s" % (level - 1), 2, "Level %s" % level, true), "completed")
	$HUD.update_wave(wave, 0)
	$HUD.update_level(level, 0)
	$LevelSound.play()
	# Game mechanics stuff (introducing new features on certain levels)
	match level:
		2:
			yield(Utils.timeout(1), "timeout")
			use_laser_modifiers = true
			if Saving.get_tutorial_progress()["elemental"] == false: activate_tutorial_elemental()
	for enemy_types in GameVariables.level_dependent_enemy_types:
		if enemy_types[0] == level:
			possible_enemies = enemy_types[1]
	# Resumes enemy spawning after the popup
	make_enemies()

#
# Making enemies
#
func make_enemies():
	if GameVariables.enemies_per_wave == 0:
		make_boss()
		return
	autospawn_enemies = true
	for enemy in max_enemies_on_screen:
		make_enemy()
		yield(Utils.timeout(1), "timeout")

func make_enemy():
	# Creates an enemy
	var enemy = enemy_scene.instance()
	if use_laser_modifiers == false: enemy.use_laser_modifiers = false
	enemy.connect("died", self, "_on_Enemy_died")
	enemy.connect("exited_screen", self, "_on_Enemy_exited_screen")

	# Sets the enemy ship's position to a random X point and just above the screen, then adds it to the scene and initializes it.
	enemy.translation = next_enemy_position
	get_node(game_space).add_child(enemy)
	enemy.initialize(level * GameVariables.enemy_difficulty, possible_enemies)
	next_enemy_position = set_random_enemy_position()

	# Updates the HUD with the current amount of enemies in the wave
	if GameVariables.enemies_per_wave > 0:
		enemies_in_wave += 1
		$HUD.update_wave(wave, 100 * enemies_in_wave/GameVariables.enemies_per_wave)
		if enemies_in_wave >= GameVariables.enemies_per_wave: # If this is the last enemy to spawn...
			autospawn_enemies = false # Well, stop enemies from spawning
			# but also set the position of the indicator arrow to let players know where the boss is coming from
			if wave == waves_per_level: $GameSpace/IndicatorArrow.translation = Vector3(0, 0, Utils.top_left.z + 0.8)

	return enemy

func set_random_enemy_position(times_ran=0):
	$GameSpace/SpawnLine/PathFollow.unit_offset = rand_range(0, 1)
	var position = $GameSpace/SpawnLine/PathFollow.translation - Vector3(0, 0, 2)
	if died == false: $GameSpace/IndicatorArrow.show()
	$GameSpace/IndicatorArrow.translation = Vector3(position.x, 0, Utils.top_left.z + 0.8) # <-- Sets the position of the indicator arrow to let players know where the next ship is coming from
	if enemies_in_wave == 0:
		$GameSpace/IndicatorArrow.translation.x = 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if position.distance_to(enemy.translation) <= 3:
			return set_random_enemy_position(times_ran + 1)
	return position

func make_boss():
	# Creates a boss
	var boss = boss_scene.instance()
	boss.translation.z = Utils.screen_to_local(Vector2()).z - 5
	boss.connect("died", self, "_on_Boss_died")
	get_node(game_space).add_child(boss) # adds it to the scene
	boss.initialize(level * GameVariables.enemy_difficulty) # Initializes the enemy
	# Hides the indicator arrow after a while
	yield(Utils.timeout(2), "timeout")
	$GameSpace/IndicatorArrow.hide()

func _on_Boss_died(_boss):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		level_up()
		score += 1000
		points += 1000
		$HUD.update_points(points)

func _on_Enemy_died(ship):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Score: "If an enemy didn't just slip away past the bottom of the screen, that means you probably killed it!"
		score += ceil(ship.max_health/2)
		points += ceil(ship.max_health/2)
		$HUD.update_points(points)
		_on_Enemy_exited_screen(ship)

func _on_Enemy_exited_screen(ship):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Wave progression
		if enemies_in_wave >= GameVariables.enemies_per_wave and len(get_tree().get_nodes_in_group("enemies")) == 0:
			wave_up() # TODO: edit for enemeis that get past the bottom

		# Spawning new enemies
		if autospawn_enemies == true and\
			len(get_tree().get_nodes_in_group("enemies")) < max_enemies_on_screen:
			yield(Utils.timeout(0.2), "timeout")
			make_enemy()

#
# Player stuff
#
func _on_Player_died():
	died = true
	$PauseMenu.set_process_input(false)
	$HUD.update_health(0)
	$GameSpace/IndicatorArrow.hide()
	$HUD/AnimationPlayer.play("fade_out")
	$GameMusic.autoswitch = false
	Saving.create_leaderboard_entry(score)
	save_game()
	# Shows the "game over" menu and prevents the player from pausing the game
	yield(Utils.timeout(1), "timeout") # AFTER waiting for a bit
	$GameOverMenu.start()


func _on_Player_ammo_changed(value, refills):
	$HUD.update_ammo(value, refills)


func _on_Player_health_changed(value):
	$HUD.update_health(value)


func _on_Player_set_modifier():
	match($GameSpace/Player.modifier):
		GameVariables.LASER_MODIFIERS.fire:
			$HUD.update_gradient($HUD.TEXTURES.fire)

		GameVariables.LASER_MODIFIERS.ice:
			$HUD.update_gradient($HUD.TEXTURES.ice)

		GameVariables.LASER_MODIFIERS.corrosion:
			$HUD.update_gradient($HUD.TEXTURES.corrosion)

		GameVariables.LASER_MODIFIERS.none:
			$HUD.update_gradient($HUD.TEXTURES.default)

#
# Saving and loading data
#
func save_game():
	var save_data = Saving.load_userdata()
	save_data.points += score
	Saving.save_userdata(save_data)
