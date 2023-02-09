extends Node

# Note: can be saved
# Also each ID *must* be unique

export var max_activated_laser_enhancements = 4

export var max_activated_ship_enhancements = 2

var laser_enhancements = [
	{
		"id": 0,
		"cost": 0,
		"name": "Standard Lasers",
		"description": "Standard-issue lasers for every ship. Fires once from the central cannon.",
		"purchased": true,
		"active": true
	},
	{
		"id": 1,
		"cost": 4000,
		"name": "Double Shot",
		"description": "Fires two lasers from the central cannon in the same direction."
	},
	{
		"id": 2,
		"cost": 4000,
		"name": "Triple Shot",
		"description": "Fires three lasers from the central cannon, two to the side."
	},
	{
		"id": 3,
		"cost": 4000,
		"name": "Triple Cannons",
		"description": "Fires a laser from each cannon."
	},
	{
		"id": 4,
		"cost": 4000,
		"name": "Plasma Shot",
		"description": "Slower but larger shots from the central cannon that do 1.5x damage."
	},
	{
		"id": 5,
		"cost": 4000,
		"name": "Homing Lasers",
		"description": "Lasers follow selected targets."
	},
	{
		"id": 6,
		"cost": 4000,
		"name": "Space Mines",
		"description": "Place explosives that can be detonated when ships run over them. Make sure to not accidentially damage yourself!"
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

func activate_enhancement(id):
	find(id)["active"] = true

func disable_enhancement(id):
	find(id)["active"] = false