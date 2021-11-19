extends Node

# User-editable game mechanics variables.

var enemy_difficulty = 1 # default 1

var waves_per_level = 1  # default 5

var enemies_per_wave = 2 # default 20

var enemies_on_screen_range = [2, 10] # [min=2,max=10]

enum LASER_MODIFIERS { none, fire, ice, corrosion }

enum ENEMY_TYPES { normal, small, tank }

# Game-editable game mechanics variables.

var use_laser_modifiers = false # We have this set to false to start with but then will set it to true after level 2
