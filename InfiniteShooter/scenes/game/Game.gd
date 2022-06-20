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
	if waves_per_level > 0:
		$HUD.update_level(level, 100 * wave/waves_per_level)
		$HUD.update_wave(wave, 100 * 1.0/GameVariables.enemies_per_wave)
	# Begins the countdown/plays appropiate music
	$Countdown.start()
	$GameMusic.start_game()


func _on_Countdown_finished():
	make_enemies()

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
	enemy.initialize(level, possible_enemies)
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
	boss.initialize(level) # Initializes the enemy
	# Hides the indicator arrow after a while
	yield(Utils.timeout(2), "timeout")
	$GameSpace/IndicatorArrow.hide()

func _on_Boss_died(_boss):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		level_up()
		score += GameVariables.get_points_boss()
		points += GameVariables.get_points_boss()
		$HUD.update_points(points)

func _on_Enemy_died(ship):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Score: "If an enemy didn't just slip away past the bottom of the screen, that means you probably killed it!"
		score += GameVariables.get_points(ship.max_health)
		points += GameVariables.get_points(ship.max_health)
		$HUD.update_points(points)
		_on_Enemy_exited_screen(ship)

func _on_Enemy_exited_screen(ship):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Wave progression
		if enemies_in_wave >= GameVariables.enemies_per_wave and len(get_tree().get_nodes_in_group("enemies")) == 1: # 1 because the ship would be the only one in the group
			wave_up()

		# Spawning new enemies
		if autospawn_enemies == true and\
			len(get_tree().get_nodes_in_group("enemies")) < max_enemies_on_screen + 1:
			yield(Utils.timeout(0.2), "timeout")
			make_enemy()

#
# Player stuff
#
func _on_Player_died():
	died = true
	$PauseMenu.set_process_input(false)
	$HUD.update_health(0, 0)
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
	$HUD.update_health(value, $GameSpace/Player.health)


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


func _on_GameOverMenu_done_opening():
	$GameOverMenu/GameStats.set_stats(level, wave, 100 * wave/waves_per_level, 100 * 1.0/GameVariables.enemies_per_wave, score)
