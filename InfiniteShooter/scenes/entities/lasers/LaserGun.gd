extends Spatial

export(PackedScene) var laser_scene

export var show_cannon = true

export var follow_player = false

export var damage = 20

export var use_laser_modifiers = false

export(preload("res://scenes/game/GameVariables.gd").LASER_MODIFIERS) var laser_modifier

func _ready():
	$Cannon.visible = show_cannon

func set_modifier(modifier):
	laser_modifier = modifier
	use_laser_modifiers = true

func fire():
	# Creating the laser
	var laser = laser_scene.instance()
	laser.follow_player = follow_player
	laser.sender = get_parent()

	# Setting the laser's damage
	laser.damage = damage
	
	# Modifiers
	if use_laser_modifiers:
		laser.modifier = laser_modifier
		laser.set_laser()

	# Setting the laser's translation/rotation
	laser.translation = global_transform.origin
	laser.rotation.y = global_transform.basis.get_euler().y
	laser.translation.y = 0

	# Adds the laser to the GameSpace node
	get_node("/root/Game/GameSpace").add_child(laser)
