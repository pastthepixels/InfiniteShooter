extends Node

# User-editable game mechanics variables.

export var enemy_collision_damage_multiplier = 1 # When the player runs into an enemy, subtract its health by the enemy health * this number.

export var powerup_health_ratio = 0.35 # Percentage of enemy health it needs to be below so that when you crash into it it generates powerups

export var powerup_health_points = 20 # Same as above but for enemy HP

# TIP: TRY TO KEEP THESE CLOSE TO THE VALUES THAT GENERATE IN THE UPGRADES SCREEN
var health_diff = 20 # <-- How much health all enemies go up by per level (constant value, HP)
var damage_diff = 3 # <-- How much damage all enemies go up by per level (constant value, also HP)
var health_diff_boss = 128

# TIP: TRY TO NOT EDIT; EDIT THE ABOVE VALUES INSTEAD
var cost_per_point = 48 # <-- Cost of an upgrade per HP/damage (damage is measured in HP, too, so it checks out) you receive

var max_points_per_upgrade = 16 # <-- Note: For EITHER damage or health

var max_purchasable_points = calculate_total_points(1) / cost_per_point # <-- Maximum amount of points you should be able to purchase after each level -- AUTO GENERATED TO MATCH THE FIRST LEVEL

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

const max_powerups_on_screen = 5

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
			health_diff -= 2
			damage_diff /= 2

		DIFFICULTIES.medium:
			pass

		DIFFICULTIES.hard:
			health_diff += 2
			cost_per_point += 2

		DIFFICULTIES.nightmare:
			health_diff += 2
			damage_diff += 2
			cost_per_point += 2

		DIFFICULTIES.ultranightmare:
			health_diff += 3
			damage_diff += 3
			cost_per_point += 3

func _ready():
	if enemy_difficulty == null:
		set_difficulty(DIFFICULTIES.medium)

# Functions to do some stuff
func get_points(enemy_max_health): # Dynamic
	return ceil(enemy_max_health/2)

func get_points_boss(): # Flat (but could be dynamic)
	return 1000

func calculate_total_points(level, normal_ship_health=40): # Calculates the points you get for completing a certain level
	var waves = min(level+waves_per_level_range[0]-1, waves_per_level_range[1])
	var health = normal_ship_health + health_diff * (level-1) # Health with extra health applied depending on difficulty
	return  waves * enemies_per_wave * get_points(health) + get_points_boss()

func get_cost_per_point(level): # Dynamically sets upgrade costs so that you can only upgrade a certain amount of points after each level. Used in the upgrades screen to dynamically generate balanced upgrades
	return calculate_total_points(level)/max_purchasable_points
