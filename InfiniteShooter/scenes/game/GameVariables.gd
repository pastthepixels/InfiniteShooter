extends Node

# User-editable game mechanics variables.

export var enemy_collision_damage_multiplier = 1 # When the player runs into an enemy, subtract its health by the enemy health * this number.

export var powerup_health_ratio = 0.3 # Percentage of enemy health it needs to be below so that when you crash into it it generates powerups

export var powerup_health_points = 20 # Same as above but for enemy HP

# TIP: TRY TO KEEP THESE CLOSE TO THE VALUES THAT GENERATE IN THE UPGRADES SCREEN
var health_diff = 16 # <-- How much health all enemies go up by per level (constant value, HP)
var damage_diff = 3 # <-- How much damage all enemies go up by per level (constant value, also HP)

# TIP: TRY TO NOT EDIT; EDIT THE ABOVE VALUES INSTEAD
var cost_per_point = 50 # <-- Cost of an upgrade per HP/damage (damage is measured in HP, too, so it checks out) you receive

var level_dependent_enemy_types = [ # 3-D ARRAY: Each line is a level and an array containg the enemy types avaiable
	[1, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank]], # Level 1. We start with the 3 basic types.
	[3, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive]], # Level 3. We now have the explosive type because we are dealing with more enemies
	[6, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot, ENEMY_TYPES.quadshot]], # Level 5. We are now introducing the quadshot/multishot enemies.
	[9, [ENEMY_TYPES.normal, ENEMY_TYPES.small, ENEMY_TYPES.tank, ENEMY_TYPES.explosive, ENEMY_TYPES.multishot, ENEMY_TYPES.quadshot, ENEMY_TYPES.gigatank]] # Level 9. Lastly, we introduce the Gigatank.
]

# Non-editable game mechanics variables.

const enemies_on_screen_range = [2, 4] # [min,max]

const waves_per_level_range = [5, 10] # [min, max]

const enemies_per_wave = 10

# Editable game mechanics variables (but by the game)

var enemy_difficulty

# Enums

enum LASER_MODIFIERS { none, fire, ice, corrosion }

enum ENEMY_TYPES { normal, small, tank, explosive, multishot, quadshot, gigatank }

enum BOSS_TYPES { normal, trishot, multishot }

enum POWERUP_TYPES { ammo, medkit, wipe }

enum DIFFICULTIES { easy, medium, hard, nightmare, ultranightmare }

# A function to set the difficulty of the game. (I mean, what more can I say?)

func set_difficulty(difficulty):
	match difficulty:
		DIFFICULTIES.easy:
			enemy_difficulty = 0.5

		DIFFICULTIES.medium:
			enemy_difficulty = 1

		DIFFICULTIES.hard:
			enemy_difficulty = 1.5

		DIFFICULTIES.nightmare:
			enemy_difficulty = 2

		DIFFICULTIES.ultranightmare:
			enemy_difficulty = 3

func _ready():
	if enemy_difficulty == null:
		set_difficulty(DIFFICULTIES.medium)
