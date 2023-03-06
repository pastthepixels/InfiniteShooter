extends Node

# Note: can be saved
# Also each ID *must* be unique

export var max_activated_laser_enhancements = 4

export var max_activated_ship_enhancements = 2

signal updated() # For when restoring enhancements

signal active_enhancements_changed()

var LASER_TYPES = preload("res://scenes/entities/lasers/LaserGun.gd").TYPES

var laser_enhancements = [
	{
		"id": 0,
		"cost": 0,
		"name": "Standard Lasers",
		"description": "Standard-issue lasers for every ship. Fires once from the central cannon.",
		"purchased": true,
		"active": true,
		"laser_type": LASER_TYPES.DEFAULT
	},
	{
		"id": 1,
		"cost": 4000,
		"name": "Double Shot",
		"description": "Fires two lasers from the central cannon in the same direction.",
		"laser_type": LASER_TYPES.DEFAULT
	},
	{
		"id": 2,
		"cost": 4000,
		"name": "Triple Shot",
		"description": "Fires three lasers from the central cannon, two to the side.",
		"laser_type": LASER_TYPES.DEFAULT
	},
	{
		"id": 3,
		"cost": 4000,
		"name": "Triple Cannons",
		"description": "Fires a laser from each cannon.",
		"laser_type": LASER_TYPES.DEFAULT
	},
	{
		"id": 4,
		"cost": 4000,
		"name": "Plasma Shot",
		"description": "Slower but larger shots from the central cannon that do 1.5x damage.",
		"laser_type": LASER_TYPES.PLASMA
	},
	{
		"id": 5,
		"cost": 4000,
		"name": "Homing Lasers",
		"description": "Lasers follow selected targets.",
		"laser_type": LASER_TYPES.HOMING
	},
	{
		"id": 6,
		"cost": 4000,
		"name": "Space Mines",
		"description": "Place explosives that can be detonated when ships run over them. Make sure to not accidentially damage yourself!",
		"laser_type": LASER_TYPES.MINES
	},
]

var ship_enhancements = [
	{
		"id": 100,
		"cost": 4000,
		"name": "Shields",
		"description": "25% of your health will become shields which can regenrate faster than your ship."
	},
	{
		"id": 101,
		"cost": 4000,
		"name": "Fire Resistance",
		"description": "Decrease the damage dealt by burning by 1/2."
	},
	{
		"id": 102,
		"cost": 4000,
		"name": "Corrosive Resistance",
		"description": "Decrease the duration of corrosion damage by 1/2."
	},
	{
		"id": 103,
		"cost": 4000,
		"name": "Ice Resistance",
		"description": "Decrease the amount of time your ship freezes by 1/2."
	}
]

func save():
	return {
		"laser_enhancements": laser_enhancements,
		"ship_enhancements": ship_enhancements
	}

func find(id):
	for enhancement in (ship_enhancements + laser_enhancements):
		if enhancement["id"] == id:
			return enhancement

func purchase_enhancement(id):
	find(id)["purchased"] = true

func set_enhancement_active(id, active : bool):
	find(id)["active"] = active
	emit_signal("active_enhancements_changed")

func get_activated_enhancements():
	var counter_lasers = 0
	var counter_ship = 0
	for enhancement in (laser_enhancements):
		if "active" in enhancement and enhancement["active"] == true:
			counter_lasers += 1
	for enhancement in (ship_enhancements):
		if "active" in enhancement and enhancement["active"] == true:
			counter_ship += 1
	return [counter_lasers, counter_ship]

# Returns true if you can still equip enhancements
func check_equipped_enhancements(id):
	if find(id) in ship_enhancements:
		return get_activated_enhancements()[1] < max_activated_ship_enhancements
	elif find(id) in laser_enhancements:
		return get_activated_enhancements()[0] < max_activated_laser_enhancements

# WEAPON SLOTS AREN'T REAL.
# YOU'VE BEEN LIED TO YOUR ENTIRE LIFE.
func get_weapon_slot(index):
	var counter = 0
	for enhancement in (laser_enhancements):
		if "active" in enhancement and enhancement["active"] == true:
			if counter == index:
				return enhancement
			counter += 1
