extends Spatial

export(NodePath) var sender = NodePath("../")

export var show_cannon = true

export var follow_player = false

export var damage = 20

export var use_laser_modifiers = false

export var from_player = false

export(preload("res://scenes/variables/GameVariables.gd").LASER_MODIFIERS) var laser_modifier

var laser_scene = LoadingScreen.access_scene("res://scenes/entities/lasers/Laser.tscn")

func _ready():
	$Cannon.visible = show_cannon

func set_modifier(modifier):
	laser_modifier = modifier
	use_laser_modifiers = true

func fire():
	# EXPLOSION
	$Explosion.explode()
	
	# Creating the laser
	var laser = laser_scene.instance()
	laser.follow_player = follow_player
	laser.from_player = from_player
	laser.sender = get_node(sender)

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
	if has_node("/root/Game/GameSpace"):
		get_node("/root/Game/GameSpace").add_child(laser)
	else:
		get_parent().add_child(laser)
