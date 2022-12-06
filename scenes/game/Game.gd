extends Node

### SAVE THESE VARIABLES ###

var score = 0 # Score => from enemies you kill

var coins = 0 # Coins => from coin crates and can be used in upgrades

var level = 1

var difficulty = 1

var wave = 1

var enemies_in_wave = 0

var possible_enemies = GameVariables.level_dependent_enemy_types[0][1]

var max_enemies_on_screen = GameVariables.enemies_on_screen_range[0]

var waves_per_level = GameVariables.waves_per_level_range[0]

var enemies_in_level = 0

var use_laser_modifiers = false # Whether or not to use laser modifiers

var crate_spawn_points = [] # Crates will spawn when the enemies in a level equals a number in this array

var crate_spawnpoint_margin = 4 # See generate_crate_spawnpoint()

func save():
	return {
		"score": score,
		"coins": coins,
		"level": level,
		"difficulty": difficulty,
		"wave": wave,
		"enemies_in_wave": enemies_in_wave,
		"possible_enemies": possible_enemies,
		"max_enemies_on_screen": max_enemies_on_screen,
		"waves_per_level": waves_per_level,
		"enemies_in_level": enemies_in_level,
		"use_laser_modifiers": use_laser_modifiers,
		"crate_spawn_points": crate_spawn_points,
		"crate_spawnpoint_margin": crate_spawnpoint_margin
	}

## DON'T SAVE THESE ONES ###

var died = false

var autospawn_enemies = false # Whether or not to spawn new enemies when they die (used within this script)

# To do with creating enemies
var enemy_scene = LoadingScreen.access_scene("res://scenes/entities/enemies/Enemy.tscn")

var coincrate_scene = LoadingScreen.access_scene("res://scenes/entities/coincrate/CoinCrate.tscn")

var boss_scene = LoadingScreen.access_scene("res://scenes/entities/bosses/Boss.tscn")

var dock_scene = LoadingScreen.access_scene("res://scenes/entities/dock/DockingStation.tscn")

onready var next_enemy_position = set_random_enemy_position()

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
	# Locks the cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# HUD stuff
	if waves_per_level > 0:
		$HUD.update_level(level, 100 * wave/waves_per_level)
		$HUD.update_wave(wave, 100 * 1.0/GameVariables.enemies_per_wave)
	# Begins the countdown/plays appropiate music
	if has_node("Countdown"):
		$Countdown.start()
	else:
		make_enemies()
	if $PauseMenu.visible == true: $PauseMenu.hide()
	$GameMusic.start_game()
	
	set_coincrate_spawn()

func update_status_bar(): # Called from Saving.tscn
	# Updates coins/score
	$HUD.update_coins(coins)
	$HUD.update_score(score)
	# Updates laser modifiers
	_on_Player_set_modifier()
	# Updates the level/wave
	$HUD.update_level(level, 100 * wave/waves_per_level)
	$HUD.update_wave(wave, 100 * enemies_in_wave/GameVariables.enemies_per_wave)
	# Unless there's a boss rush/save indicates a boss will spawn, in which case we'll update the HUD to reflect that
	if GameVariables.enemies_per_wave == 0 or wave == waves_per_level + 1:
		$HUD.update_wave_boss()

func _on_Countdown_finished():
	make_enemies()

func set_coincrate_spawn():
	crate_spawn_points.clear()
	for _i in range(0, GameVariables.crates_per_level):
		crate_spawn_points.append(generate_crate_spawnpoint())

func generate_crate_spawnpoint():
	if get_max_enemies_in_level() < (2*crate_spawnpoint_margin):
		return 0 # Checks if the max enemies per level is smaller than the spawnpoint margin
	var spawnpoint = floor(rand_range(crate_spawnpoint_margin, get_max_enemies_in_level() - crate_spawnpoint_margin))
	if (spawnpoint in crate_spawn_points
	or (spawnpoint-1) in crate_spawn_points
	or (spawnpoint+1) in crate_spawn_points) and (get_max_enemies_in_level() - (2*crate_spawnpoint_margin) >= GameVariables.crates_per_level):
		if len(crate_spawn_points) <= GameVariables.crates_per_level:
			return spawnpoint
		else:
			return generate_crate_spawnpoint()
	else:
		return spawnpoint
		

#
# Waves, levels, and score
#
func wave_up():
	# Switches the wave number and (if possible) levels up
	wave += 1
	enemies_in_wave = 0
	# Updates the HUD
	$HUD.update_wave(wave, 0)
	$HUD.update_level(level, 100 * wave/waves_per_level)
	# Spawns a boss/enemies
	if wave == waves_per_level + 1:
		$HUD.update_wave_boss()
		yield(Utils.timeout(1), "timeout") # Waits exactly one second to give the player breathing room
		make_boss() # then initiates a boss battle (and updates the hud because instead of a new wave there's a boss battle)
	else:
		yield($HUD.alert("Wave %s" % (wave - 1), 2, "Wave %s" % wave), "completed")
		# Resumes enemy spawning after the popup
		make_enemies()

func level_up():
	difficulty += 1
	level += 1
	wave = 1
	enemies_in_level = 0
	max_enemies_on_screen = clamp(max_enemies_on_screen+1, GameVariables.enemies_on_screen_range[0], GameVariables.enemies_on_screen_range[1])
	waves_per_level = clamp(waves_per_level+1, GameVariables.waves_per_level_range[0], GameVariables.waves_per_level_range[1])
	set_coincrate_spawn()
	# First, the docking station
	var dock = dock_scene.instance()
	get_node("%GameSpace").add_child(dock)
	dock.set_owner(get_node("%GameSpace"))
	yield(dock, "finished")
	# Then, GUI stuff
	yield($HUD.alert("Level %s" % (level - 1), 2, "Level %s" % level, true, "Difficulty reset!" if fmod(level, GameVariables.reset_level) == 0 else ""), "completed")
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
	# Resets difficulty if the level is a multiple of x
	if fmod(level, GameVariables.reset_level) == 0:
		reset()
		set_coincrate_spawn()
	
	# Resumes enemy spawning after the popup
	make_enemies()

func get_max_enemies_in_level():
	return waves_per_level * GameVariables.enemies_per_wave

#
# Making enemies
#
func make_enemies():
	# If there are no enemies per wave or your savefile is set to spawn a boss, spawn a boss!
	if GameVariables.enemies_per_wave == 0 or wave == waves_per_level + 1:
		$HUD.update_wave_boss()
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
	get_node("%GameSpace").add_child(enemy)
	enemy.set_owner(get_node("%GameSpace"))
	enemy.initialize(difficulty, possible_enemies)
	next_enemy_position = set_random_enemy_position()
	
	# Updates the number of enemies in the level/spawns coin crates
	enemies_in_level += 1
	if enemies_in_level in crate_spawn_points:
		for _i in range(0, crate_spawn_points.count(float(enemies_in_level))): make_coincrate()

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
	get_node("%GameSpace").add_child(boss) # adds it to the scene
	boss.set_owner(get_node("%GameSpace"))
	yield(get_tree(), "idle_frame")
	boss.initialize(difficulty) # Initializes the enemy
	# Hides the indicator arrow after a while
	yield(Utils.timeout(2), "timeout")
	$GameSpace/IndicatorArrow.hide()

func _on_CoinCrate_opened():
	coins += GameVariables.coins_per_level/GameVariables.crates_per_level
	$HUD.update_coins(coins)
	

func make_coincrate():
	# Creates a coin crate
	var coincrate = coincrate_scene.instance()
	coincrate.translation = next_enemy_position
	next_enemy_position = set_random_enemy_position()
	coincrate.connect("opened", self, "_on_CoinCrate_opened")
	get_node("%GameSpace").add_child(coincrate) # adds it to the scene
	coincrate.set_owner(get_node("%GameSpace"))

func reset():
	$GameSpace/Player.reset()
	max_enemies_on_screen = GameVariables.enemies_on_screen_range[0]
	waves_per_level = GameVariables.waves_per_level_range[0]
	difficulty = 1
	coins = 0
	$HUD.update_coins(coins)


func _on_Boss_died(_boss):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		level_up()
		score += GameVariables.get_points_boss()
		$HUD.update_score(score)

func _on_Enemy_died(ship):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Score: "If an enemy didn't just slip away past the bottom of the screen, that means you probably killed it!"
		score += GameVariables.get_points(ship.max_health)
		$HUD.update_score(score)
		_on_Enemy_exited_screen(ship)

func is_last_enemy(ship):
	return len(get_tree().get_nodes_in_group("enemies")) == 1 and get_tree().get_nodes_in_group("enemies")[0] == ship

func _on_Enemy_exited_screen(ship):
	if has_node("GameSpace/Player") and get_node("GameSpace/Player").health > 0:
		# Wave progression
		if enemies_in_wave >= GameVariables.enemies_per_wave and is_last_enemy(ship): # 1 because the ship would be the only one in the group
			wave_up()

		# Spawning new enemies
		if autospawn_enemies == true and\
			(len(get_tree().get_nodes_in_group("enemies")) < max_enemies_on_screen + 1) and (ship in get_tree().get_nodes_in_group("enemies")):
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

func _on_GameOverMenu_done_opening():
	$GameOverMenu/GameStats.set_stats(level, wave, 100 * wave/waves_per_level, 100 * 1.0/GameVariables.enemies_per_wave, score)


func _on_Upgrades_subtract_coins(amount):
	coins -= amount
	get_node("HUD").update_coins(coins)


func _on_Upgrades_upgrade_damage(amount):
	$GameSpace/Player.damage += amount


func _on_Upgrades_upgrade_health(amount):
	$GameSpace/Player.max_health += amount


func _on_Upgrades_request_player_stats():
	$Upgrades.update_player_information($GameSpace/Player.max_health, $GameSpace/Player.damage, coins)
