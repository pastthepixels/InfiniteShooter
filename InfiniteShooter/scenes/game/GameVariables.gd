extends Node

# User-editable game mechanics variables.

var enemy_difficulty = 1 # default 1

var enemies_per_wave = 10 # default 10

var enemies_on_screen_range = [2, 10] # default [min=2,max=10]

var waves_per_level_range = [5, 10] # default [min=5, max=10]

enum LASER_MODIFIERS { none, fire, ice, corrosion }

enum ENEMY_TYPES { normal, small, tank, explosive }

# A function to set the difficulty of the game. (I mean, what more can I say?)
enum DIFFICULTIES { easy, medium, hard, nightmare, ultranightmare }

func set_difficulty(difficulty):
	match difficulty:
		DIFFICULTIES.easy:
			enemy_difficulty = 0.5
			enemies_on_screen_range[0] += clamp(int(difficulty - 1), 0, 3)
			enemies_on_screen_range[1] += clamp(int(difficulty - 1), 0, 3)
	
		DIFFICULTIES.medium:
			pass # DEFAULTS
		
		DIFFICULTIES.hard:
			enemy_difficulty = 1.5
			enemies_on_screen_range[0] += 1
			enemies_on_screen_range[1] += 1
		
		DIFFICULTIES.nightmare:
			enemy_difficulty = 2
			enemies_per_wave = 15
			enemies_on_screen_range[0] += 2
			enemies_on_screen_range[1] += 2
		
		DIFFICULTIES.ultranightmare:
			enemy_difficulty = 3
			enemies_per_wave = 20
			enemies_on_screen_range[0] += 3
			enemies_on_screen_range[1] += 3
