extends Area

# Variables related to the game
export var max_ammo = 20 # 20 bullets
export var max_health = 1.0
export var speed = 14
export var damage = .2
var health = max_health
var ammo = max_ammo

# Variables used by the engine
onready var main = get_tree().get_root().get_node( "Main" )
signal died
signal health_changed
signal ammo_changed
export (PackedScene) var Laser
export var player_rotation =  35
var utils

# Called when the node enters the scene tree for the first time.
func _ready():
	
	utils = load( "res://scripts/Utils.gd" ).new()
	utils.init( get_viewport() )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( delta ):
	
	if $Explosion.visible == true:
		
		return # If the player is dying, don't bother about input stuff
		
	var velocity = Vector3()  # The player's movement vector. (yes, I copied this from the "Your First Game" Godot tutorial. Don't judge.
	var deltaRotation = Vector3() # The new rotation the player will have.
	if Input.is_action_pressed( "move_right" ): # If a key is pressed (e.g. the right arrow key)
		
		deltaRotation.z -= deg2rad( player_rotation ) # Rotate the ship
		velocity.x += 1 # and alter its velocity.
	
	if Input.is_action_pressed( "move_left" ): # We do this 4 times for each direction you can press a key in
		
		deltaRotation.z += deg2rad( player_rotation )
		velocity.x -= 1
	
	if Input.is_action_pressed( "move_down" ) and ( translation.z < utils.bottom_left.z ):
		
		deltaRotation.x += deg2rad( player_rotation )
		velocity.z += 1
		
	if Input.is_action_pressed("move_up") and ( translation.z > utils.top_left.z ):
		
		deltaRotation.x -= deg2rad( player_rotation )
		velocity.z -= 1
	
	# Sets position
	translation += velocity * delta * speed
	
	# Sets rotation
	transform.basis = Basis(Vector3(1, 0, 0), deltaRotation.x )
	transform.basis = transform.basis.rotated(Vector3(0, 0, 1), deltaRotation.z )
	
	# If the player goes out of bounds (x axis only; see above for y)
	if ( translation.x < utils.top_left.x ): translation.x = utils.top_right.x
	if ( translation.x > utils.top_right.x ): translation.x = utils.top_left.x
	
	# Killing the player when it should die
	if health <= 0.0:
		
		die_already()

# Firing lasers
func _input( event ):
	
	if event.is_action_pressed("shoot_laser") and ammo > 0 and $ReloadTimer.time_left == 0 and $Explosion.exploding != true:
		
		var laser = Laser.instance()
		laser.translation = translation
		laser.translation.z -= 1 # To get the laser firing from the "top" of the ship instead of the center for added realism
		laser.damage = damage
		main.get_node( "Game" ).add_child( laser )
		Input.start_joy_vibration(0, 0.7, 1, .1)
		ammo -= 1
		emit_signal( "ammo_changed", float( ammo ) / max_ammo )
		
		if ammo <= 0:
			
			$ReloadTimer.start()
			$ReloadStart.play()

# When the player collides with stuff
func on_collision( area ): # area == EnemyX model with a custom collision box because each ship is different
	
	if "Enemy" in area.name and area.get_parent().health > 0: # Enemy collision boxes are named "Enemy"+enemy variant number. Thus we can filter collisions with enemies. (Also, make sure we aren't colliding with an exploding ship, which is already dead.)
		
		enemy_collisions( area.get_parent() )

# like enemies
func enemy_collisions( enemy ): # enemy must be an instance of the class Enemy (no numbers)

	enemy.health -= enemy.health
	health -= speed / 10 # Dear GDScript developers: *Every other language* has floating-point division.
	emit_signal( "health_changed", float(health) / float(max_health) )

func reload():
	
	ammo += 1
	emit_signal( "ammo_changed", float(ammo) / float(max_ammo) )
	$ReloadBoop.play()
	if ammo >= max_ammo:
		
		$ReloadTimer.stop()

func die_already():
	
	if !$Explosion.exploding: # If the explosion is exploding when this function is called, chances are it's being called twice. We don't want that.
		
		emit_signal( "died" )
		$Explosion.explode()
		$PlayerModel.queue_free()
		$CollisionShape.queue_free()
		$RegenTimer.stop()
		transform.basis = Basis() # Resets the player's rotation
		main.get_node( "Camera" ).get_node( "ScreenShake" ).shake( .1, .5 )

func cleanup_player():

	queue_free()

func heal(): # Regenerates a bit of health every time this function is called.
	
	if health < max_health:
		
		health += 0.01
		emit_signal( "health_changed", float(health) / float(max_health) )
	
	if health >= max_health:
		
		health = max_health
