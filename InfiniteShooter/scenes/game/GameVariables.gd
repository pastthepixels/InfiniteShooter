extends Node

# User-editable game mechanics variables.

export var enemy_collision_damage_multiplier = 2 # When the player runs into an enemy, subtract its health by the enemy health * this number.

export var use_debug_values = false

export var dbg_enemy_difficulty = 0.4

export var dbg_enemies_per_wave = 30

export var dbg_enemies_on_screen_range = [5, 10] # default [min,max]

export var dbg_waves_per_level_range = [10, 20] # [min, max]

var level_dependent_enemy_types = [ # 3-D ARRAY: Each line is a level and an array containg the enemy types avaiable
	[1, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank]], # Level 1. We start with the 3 basic types.
	[3, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive]], # Level 3. We now have the explosive type because we are dealing with more enemies
	[6, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot, ENEMY_TYPES.quadshot]], # Level 5. We are now introducing the quadshot/multishot enemies.
	[9, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot, ENEMY_TYPES.quadshot, ENEMY_TYPES.gigatank]] # Level 9. Lastly, we introduce the Gigatank.
]

# Non-editable game mechanics variables.

const enemies_on_screen_range = [2, 6] # [min,max]

const waves_per_level_range = [5, 10] # [min, max]

# Editable game mechanics variables

var enemy_difficulty

var enemies_per_wave

# Enums

enum LASER_MODIFIERS { none, fire, ice, corrosion }

enum ENEMY_TYPES { normal, small, tank, explosive, multishot, quadshot, gigatank }

enum BOSS_TYPES { normal, trishot, multishot }

enum POWERUP_TYPES { ammo, medkit, wipe }

# A function to set the difficulty of the game. (I mean, what more can I say?)
enum DIFFICULTIES { easy, medium, hard, nightmare, ultranightmare }

func set_difficulty(difficulty):
	if use_debug_values:
		enemy_difficulty = dbg_enemy_difficulty
		enemies_per_wave = dbg_enemies_per_wave
		return
	
	match difficulty:
		DIFFICULTIES.easy:
			enemy_difficulty = 0.5
			enemies_per_wave = 6

		DIFFICULTIES.medium:
			enemy_difficulty = 1
			enemies_per_wave = 10

		DIFFICULTIES.hard:
			enemy_difficulty = 1.5

		DIFFICULTIES.nightmare:
			enemy_difficulty = 2
			enemies_per_wave = 15

		DIFFICULTIES.ultranightmare:
			enemy_difficulty = 3
			enemies_per_wave = 20

func _ready():
	if enemy_difficulty == null:
		set_difficulty(DIFFICULTIES.medium)
