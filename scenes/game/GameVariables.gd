extends Node

#
# Editable game mechanics variables.
#
export(int) var reset_level = 10 # Difficulty resets every x levels

export(float) var gkill_health_ratio = 0.35 # Percentage of enemy health it needs to be below so that when you crash into it it generates powerups

export(int) var crates_per_level = 10 # How much crates you see per level (the more crates the more annoying they get but also the more opportunities you have to get coins_per_level)
export(int) var coins_per_level = 2400 # How much coins you get per level

export var enemies_on_screen_range = [2, 4] # [min,max]
export var waves_per_level_range = [5, 10] # [min, max]
export var enemies_per_wave = 10

export(int) var max_powerups_on_screen = 5

export var health_diff = 20 # <-- How much health all enemies go up by per level (constant value, HP)
export var damage_diff = 3 # <-- How much damage all enemies/bosses go up by per level (constant value, also HP)
export var health_diff_boss = 256 # <-- How much health all bosses go up by per level (constant value, also HP)

export var target_purchasable_health = 48
export var target_purchasable_damage = 10
# coins_per_upgrades: How much coins should be spent to fully upgrade health OR damage
# 					  Note: You need to upgrade BOTH upgrade/damage to the max amounts
export(int) var coins_per_upgrade = 1400
export(int) var max_damage_per_upgrade = 3
export(int) var max_health_per_upgrade = 16

# 3-D ARRAY: Each line is a level and an array containg the enemy types avaiable
var level_dependent_enemy_types = [
	[1, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank]], # We start with the 3 basic types.
	[5, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive]], # We now have the explosive type because we are dealing with more enemies
	[10, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot]], # We are now introducing the multishot enemy.
	[20, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot, ENEMY_TYPES.quadshot]], # We are now introducing the quadshot enemy.
	[30, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot, ENEMY_TYPES.quadshot, ENEMY_TYPES.gigatank]] # Level 9. Lastly, we introduce the Gigatank.
]

# Note: When you update this, make sure to update ENEMY_TYPES as well.
# Stats for bosses are in their respective scripts.
var enemy_stats = [
	{
		"name": "normal",
		"max_health": 40,
		"damage": 6,
		"speed": 4
	},
	{
		"name": "small",
		"max_health": 10,
		"damage": 5,
		"speed": 6
	},
	{
		"name": "tank",
		"max_health": 60,
		"damage": 8,
		"speed": 3.2
	},
	{
		"name": "gigatank",
		"max_health": 100,
		"damage": 12,
		"speed": 2
	},
	{
		"name": "explosive",
		"max_health": 2,
		"damage": 100,
		"speed": 2.4
	},
	{
		"name": "multishot",
		"max_health": 40,
		"damage": 4,
		"speed": 1.4
	},
	{
		"name": "quadshot",
		"max_health": 60,
		"damage": 8,
		"speed": 3.6
	}
]

#
# Enums
#

enum LASER_MODIFIERS { none, fire, ice, corrosion }
enum ENEMY_TYPES { normal, small, tank, explosive, multishot, quadshot, gigatank }
enum BOSS_TYPES { normal, trishot, multishot }
enum POWERUP_TYPES { ammo, medkit, wipe }
enum DIFFICULTIES { easy, medium, hard, nightmare, ultranightmare, carnage }

#
# Non-editable game mechanics variables (automatically set by the game)
#
# Difficulty
var difficulty_health = 0
var difficulty_damage = 0

var max_points_per_upgrade = 16 # <-- Note: For EITHER damage or health

var enemy_difficulty

# A function to set the difficulty of the game. (I mean, what more can I say?)
var backups = {}
var vars_to_backup = ["difficulty_health", "difficulty_damage", "enemies_on_screen_range", "enemies_per_wave", "target_purchasable_health", "target_purchasable_damage"]
func back_up_vars():
	backups.clear()
	for variable in vars_to_backup:
		backups[variable] = self[variable]

func restore_vars():
	for variable in vars_to_backup:
		self[variable] = backups[variable]
	
func set_difficulty(difficulty):
	if backups.empty():
		back_up_vars()
	else:
		restore_vars()
	match difficulty:
		DIFFICULTIES.easy:
			difficulty_health = 0
			difficulty_damage = -2

		DIFFICULTIES.medium:
			pass

		DIFFICULTIES.hard:
			difficulty_health = 10
			difficulty_damage = 4

		DIFFICULTIES.nightmare:
			target_purchasable_health -= 3
			target_purchasable_damage -= 3
			difficulty_health = 20
			difficulty_damage = 6

		DIFFICULTIES.ultranightmare:
			target_purchasable_health -= 5
			target_purchasable_damage -= 5
			difficulty_health = 20
			difficulty_damage = 6
		
		DIFFICULTIES.carnage: # Something... different.
			enemies_on_screen_range = [10,10]
			enemies_per_wave = 50

func _ready():
	if enemy_difficulty == null:
		set_difficulty(DIFFICULTIES.medium)

# Misc. functions
func get_enemy_stats(enemy_type):
	var stats = enemy_stats[0].duplicate()
	match enemy_type:
		GameVariables.ENEMY_TYPES.normal:
			stats = enemy_stats[0].duplicate()
			
		GameVariables.ENEMY_TYPES.small:
			stats = enemy_stats[1].duplicate()
		
		GameVariables.ENEMY_TYPES.tank:
			stats = enemy_stats[2].duplicate()
			
		GameVariables.ENEMY_TYPES.gigatank:
			stats = enemy_stats[3].duplicate()
			
		GameVariables.ENEMY_TYPES.explosive:
			stats = enemy_stats[4].duplicate()
			
		GameVariables.ENEMY_TYPES.multishot:
			stats = enemy_stats[5].duplicate()
			
		GameVariables.ENEMY_TYPES.quadshot:
			stats = enemy_stats[6].duplicate()
	
	stats["max_health"] += difficulty_health
	stats["damage"] += difficulty_damage
	return stats

#
# Cost per health/damage
#
# Notes:
#	- The 10 and 2 you see in these functions are just used as a margin
#	- Half of the coins you get per level is deligated to the cost/health and half for the cost/damage
func get_cost_per_health():
	return coins_per_upgrade / target_purchasable_health

func get_cost_per_damage():
	return coins_per_upgrade / target_purchasable_damage

func get_points(health): # Input parameter == enemy max health
	return ceil(health/2)

func get_points_boss():
	return 1000
