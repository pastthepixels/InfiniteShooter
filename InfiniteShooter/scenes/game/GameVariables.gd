extends Node

# User-editable game mechanics variables.

var enemy_difficulty = 1 # default 1

var waves_per_level = 5  # default 5

var enemies_per_wave = 20 # default 20

var max_enemies_on_screen = 6 # default 6

enum LASER_MODIFIERS { none, fire, ice, corrosion }

enum ENEMY_TYPES { normal, small, tank }
