extends Node

# User-editable game mechanics variables.

var enemy_difficulty

var enemies_per_wave

var enemies_on_screen_range # default [min,max]

var waves_per_level_range # [min, max]

# Set all of the above (excl. difficulty) to zero for a boss-run-type mode.

enum LASER_MODIFIERS { none, fire, ice, corrosion }

enum ENEMY_TYPES { normal, small, tank, explosive, multishot, quadshot, gigatank }

enum BOSS_TYPES { normal, trishot, multishot }

# A function to set the difficulty of the game. (I mean, what more can I say?)
enum DIFFICULTIES { easy, medium, hard, nightmare, ultranightmare }

func set_difficulty(difficulty):
	match difficulty:
		DIFFICULTIES.easy:
			enemy_difficulty = 0.5
			enemies_per_wave = 6
			enemies_on_screen_range = [2, 10]
			waves_per_level_range = [5, 10]

		DIFFICULTIES.medium:
			enemy_difficulty = 1
			enemies_per_wave = 10
			enemies_on_screen_range = [2, 10]
			waves_per_level_range = [5, 10]

		DIFFICULTIES.hard:
			enemy_difficulty = 1.5
			enemies_on_screen_range = [3, 11]

		DIFFICULTIES.nightmare:
			enemy_difficulty = 2
			enemies_per_wave = 15
			enemies_on_screen_range = [4, 12]

		DIFFICULTIES.ultranightmare:
			enemy_difficulty = 3
			enemies_per_wave = 20
			enemies_on_screen_range = [5, 12]
