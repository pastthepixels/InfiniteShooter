extends Spatial


# Declare member variables here.
onready var utils = load( "res://scripts/Utils.gd" ).new() # Man if I only had better Mono support... I'd replace this line with `Utils utils = new Utils()` in a *heartbeat*.
export (PackedScene) var Enemy

# Called when the node enters the scene tree for the first time.
func _ready():
	$EnemyTimer.start()
	utils.init( get_viewport() )

func make_enemy():
	
	# Creates an enemy
	var enemy =  Enemy.instance() # Every time I see "var" used to declare a variable, I only feel complete once I put a semicolon at the end of the line.
	add_child( enemy ) # like adding it to the scene
	enemy.transform.origin.x = utils.random_screen_point().x
	enemy.transform.origin.z = utils.screen_to_local( Vector2( 0, 0 ) ).z - ( enemy.enemy.transform.basis.get_scale().z * 2)


func _on_Player_died():
	
	$EnemyTimer.stop()
	$ScoreTimer.stop()
