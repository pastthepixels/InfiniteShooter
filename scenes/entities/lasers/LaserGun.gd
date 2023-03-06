extends Spatial

enum TYPES { DEFAULT, HOMING, PLASMA, MINES, BEAM } # Beam not implemented yet

export(NodePath) var sender

export(NodePath) var raycast = NodePath("RayCast")

export(TYPES) var type = TYPES.DEFAULT

export var show_cannon = true

export var damage = 20

export var use_laser_modifiers = false

export var from_player = false

export(preload("res://scenes/variables/GameVariables.gd").LASER_MODIFIERS) var laser_modifier

var laser_scene = LoadingScreen.access_scene("res://scenes/entities/lasers/Laser.tscn")

var selected_entity

func _ready():
	$Cannon.visible = show_cannon
	if has_node(sender) == false and  Utils.get_parent_entity(self) != null:
		sender = Utils.get_parent_entity(self).get_path()
	if get_node(raycast) != $RayCast:
		$RayCast.enabled = false

func _process(_delta):
	if type == TYPES.HOMING and get_node(raycast).is_colliding() and selected_entity != get_node(raycast).get_collider().get_parent():
		if get_node(raycast).is_colliding() and get_node(raycast).get_collider().get_parent().is_in_group("entities"):
			selected_entity = Utils.get_parent_entity(get_node(raycast).get_collider())

func set_modifier(modifier):
	laser_modifier = modifier
	use_laser_modifiers = true

func fire(type=self.type):
	# EXPLOSION
	$Explosion.explode()
	
	# Creates a laser
	var laser
	match type:
		TYPES.HOMING:
			if selected_entity != null:
				laser = fire_default_laser()
				laser.follow_entity = true
				laser.followed_entity = selected_entity
			else:
				laser = fire_default_laser()
		
		TYPES.PLASMA:
			print("Plasma lasers not implemented yet.")
			return
		
		TYPES.MINES:
			print("Mines not implemented yet.")
			return
		
		TYPES.BEAM:
			print("Laser beams not implemented yet.")
			return
		
		_:
			laser = fire_default_laser()
	
	# Setting the laser's translation/rotation
	laser.translation = global_transform.origin
	laser.rotation.y = global_transform.basis.get_euler().y
	laser.translation.y = 0

	# Adds the laser to the GameSpace node
	if has_node("/root/Game/GameSpace"):
		get_node("/root/Game/GameSpace").add_child(laser)
	else:
		get_parent().add_child(laser)
		
	laser.set_sender(get_node(self.sender))

func fire_default_laser():
	# Creating the laser
	var laser = laser_scene.instance()
	laser.from_player = from_player
	

	# Setting the laser's damage
	laser.damage = damage
	
	# Modifiers
	if use_laser_modifiers:
		laser.modifier = laser_modifier
		laser.set_laser()

	return laser
