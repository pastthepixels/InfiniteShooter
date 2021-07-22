extends Area

# Variables related to the game
export var max_ammo = 20 # 20 bullets
export var max_health = 1
export var speed = 14
export var damage = .2
var health = max_health
var ammo = max_ammo

# Variables used by the engine
signal died
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
	
	if Input.is_action_pressed( "move_down" ) and ( transform.origin.z < utils.bottom_left.z ):
		
		deltaRotation.x += deg2rad( player_rotation )
		velocity.z += 1
		
	if Input.is_action_pressed("move_up") and ( transform.origin.z > utils.top_left.z ):
		
		deltaRotation.x -= deg2rad( player_rotation )
		velocity.z -= 1
	
	# Sets position
	transform.origin += velocity * delta * speed
	
	# Sets rotation
	transform.basis = Basis(Vector3(1, 0, 0), deltaRotation.x )
	transform.basis = transform.basis.rotated(Vector3(0, 0, 1), deltaRotation.z )
	
	# If the player goes out of bounds (x axis only; see above for y)
	if ( transform.origin.x < utils.top_left.x ): transform.origin.x = utils.top_right.x
	if ( transform.origin.x > utils.top_right.x ): transform.origin.x = utils.top_left.x
	
	# Killing the player when it should die
	if health <= 0:
		
		die_already()

# Firing lasers
func _input( event ):
	
	if event.is_action_pressed("shoot_laser") and ammo > 0 and $ReloadTimer.time_left == 0 and $Explosion.visible != true:
		
		var laser = Laser.instance()
		laser.transform.origin = transform.origin
		laser.transform.origin.z -= 1 # To get the laser firing from the "top" of the ship instead of the center for added realism
		laser.damage = damage
		get_parent().add_child( laser )
		Input.start_joy_vibration(0, 0.7, 1, .1)
		ammo -= 1
		
		if ammo <= 0:
			
			$ReloadTimer.start()

# When the player collides with stuff
func on_collision( area ):
	
	if "Enemy" in area.name: # Enemy collision boxes are named "Enemy"+enemy variant number. Thus we can filter collisions with enemies.
		
		enemy_collisions( area.get_parent() )

# like enemies
func enemy_collisions( enemy ): # enemy must be an instance of the class Enemy (no numbers)
	
	enemy.health -= speed / 10 # Dear GDScript developers: *Every other language* has floating-point division.
	health -= speed / 10

func reload():
	
	ammo += 1
	if ammo >= max_ammo:
		
		$ReloadTimer.stop()

func die_already():
	
	emit_signal( "died" )
	$Explosion.explode()
	$player.hide()
	
	# ( Player < Game < Main )  > Camera          > ScreenShake                 .shake
	# backtracks to "main"      gets the camera   gets its child "ScreenShake"  and shakes the screen
	get_parent().get_parent().get_node( "Camera" ).get_node( "ScreenShake" ).shake( .1, .5 )

func cleanup_player():

	queue_free()
