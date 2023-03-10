extends Node

enum TYPES { Single, Double, Triple, Dispersed }

# LaserGuns
#	-> Single
#		-> LaserGun
#	-> Double
#		-> LaserGun
#		-> LaserGun
#	-> and so forth, mirroring TYPES
export(NodePath) var node_path

export(TYPES) var fire_type = TYPES.Single

export(float) var damage = 0

var laser_type : int = 0

var modifier : int = GameVariables.LASER_MODIFIERS.none # Can't export this even though it works fine in the editor because Godot is being a @$#!

func _ready():
	for lasergun_group in get_node(node_path).get_children():
		for lasergun in lasergun_group.get_children():
			lasergun.sender = get_parent().get_path()

func fire():
	# Sets damage/modifiers for each laser and then fires it
	for lasergun in get_node(node_path).get_node(type_to_path()).get_children():
		lasergun.damage = damage
		lasergun.type = laser_type
		if modifier != GameVariables.LASER_MODIFIERS.none:
			lasergun.set_modifier(modifier)
		else:
			lasergun.use_laser_modifiers = false
		lasergun.fire()
	
	# Screen shake
	if CameraEquipment.get_node("ShakeCamera").ignore_shake == false:
		Input.start_joy_vibration(0, 0.7, 1, .1)

func type_to_path() -> String:
	match fire_type:
		TYPES.Double:
			return "Double"
		
		TYPES.Triple:
			return "Triple"
		
		TYPES.Dispersed:
			return "Dispersed"
		
		_:
			return "Single"
