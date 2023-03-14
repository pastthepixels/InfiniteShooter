extends Node

# Note: can be saved
# Also each ID *must* be unique

export var max_activated_laser_enhancements = 4

export var max_activated_ship_enhancements = 2

signal updated() # For when restoring enhancements

signal active_enhancements_changed()

var LASER_TYPES = preload("res://scenes/entities/lasers/LaserGun.gd").TYPES

var FIRE_TYPES = preload("res://scenes/entities/player/LaserController.gd").TYPES

var laser_enhancements = [
	{
		"id": 0,
		"cost": 0,
		"name": "Standard Lasers",
		"description": "Standard-issue lasers for every ship. Fires once from the central cannon.",
		"purchased": true,
		"active": true,
		"laser_type": LASER_TYPES.DEFAULT,
		"fire_type": FIRE_TYPES.Single
	},
	{
		"id": 1,
		"cost": 4000,
		"name": "Double Shot",
		"description": "Fires two lasers from the central cannon in the same direction.",
		"laser_type": LASER_TYPES.DEFAULT,
		"fire_type": FIRE_TYPES.Double
	},
	{
		"id": 2,
		"cost": 4000,
		"name": "Triple Shot",
		"description": "Fires three lasers from the central cannon, two to the side.",
		"laser_type": LASER_TYPES.DEFAULT,
		"fire_type": FIRE_TYPES.Dispersed
	},
	{
		"id": 3,
		"cost": 4000,
		"name": "Triple Cannons",
		"description": "Fires a laser from each cannon.",
		"laser_type": LASER_TYPES.DEFAULT,
		"fire_type": FIRE_TYPES.Triple
	},
	{
		"id": 4,
		"cost": 4000,
		"name": "Plasma Shot",
		"description": "Slower but larger shots from the central cannon that do 1.5x damage.",
		"laser_type": LASER_TYPES.PLASMA,
		"fire_type": FIRE_TYPES.Single
	},
	{
		"id": 5,
		"cost": 4000,
		"name": "Homing Lasers",
		"description": "Lasers follow selected targets.",
		"laser_type": LASER_TYPES.HOMING,
		"fire_type": FIRE_TYPES.Single
	},
	{
		"id": 6,
		"cost": 4000,
		"name": "Plasma Wall",
		"description": "Fires a plasma shot from each cannon.",
		"laser_type": LASER_TYPES.PLASMA,
		"fire_type": FIRE_TYPES.Triple
	}
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
	# If the currently seleced slot is the one that has been deactivated, set the current slot to the first one (index 0)
	if has_node("/root/Game") and get_weapon_slot(get_node("/root/Game").get_selected_slot()) == null:
		get_node("/root/Game")._on_WeaponSwitcher_slot_selected(0)

func is_enhancement_active(id):
	return find(id)["active"]

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

# Returns true if the number of equipped enhancements is less than the number of max enhancements to equip
func check_maximum_enhancements(id):
	if find(id) in ship_enhancements:
		return get_activated_enhancements()[1] < max_activated_ship_enhancements
	elif find(id) in laser_enhancements:
		return get_activated_enhancements()[0] < max_activated_laser_enhancements

# Returns true if there are more than 1 laser enhancements selected.
# You have to have at least one to play the game.
func check_minimum_enhancements(id):
	if find(id) in laser_enhancements:
		return get_activated_enhancements()[0] > 1

# WEAPON SLOTS AREN'T REAL.
# YOU'VE BEEN LIED TO YOUR ENTIRE LIFE.
# Gets an enhancement at an index of a weapon slot (ex: 0, 1, 2, 3)
func get_weapon_slot(index):
	var counter = 0
	for enhancement in (laser_enhancements):
		if "active" in enhancement and enhancement["active"] == true:
			if counter == index:
				return enhancement
			counter += 1
