extends Spatial


# Declare member variables here.
onready var utils = load( "res://scripts/Utils.gd" ).new() # Man if I only had better Mono support... I'd replace this line with `Utils utils = new Utils()` in a *heartbeat*.
export ( PackedScene ) var Enemy
export var score = 0
export var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	utils.init( get_viewport() )
	$EnemyTimer.start()
	$ScoreTimer.start()
	$LevelTimer.start()
	make_enemy()

func make_enemy():
	
	# Creates an enemy
	var enemy =  Enemy.instance() # Every time I see "var" used to declare a variable, I only feel complete once I put a semicolon at the end of the line.
	add_child( enemy ) # like adding it to the scene
	enemy.transform.origin.x = utils.random_screen_point().x
	enemy.transform.origin.z = utils.screen_to_local( Vector2( 0, 0 ) ).z - ( enemy.enemy.transform.basis.get_scale().z * 2)

func _on_Player_died():
	
	$PauseMenu.queue_free()
	$EnemyTimer.stop()
	$ScoreTimer.stop()
	$LevelTimer.stop()
	
	# Shows the "game over" menu and prevents the player from pausing the game
	yield( get_tree().create_timer( 1.0 ), "timeout" ) # AFTER waiting for a bit (if porting to different programming languages, this is Godot's setTimeout)
	$GameOverMenu.fade_show()

func _on_Player_ammo_changed( value ):
	
	$GameHUD.update_ammo( value )

func _on_Player_health_changed( value ):
	

	$GameHUD.update_health( value )


func _on_ScoreTimer_timeout():
	
	score += 1
	$GameHUD.update_score( score )

func _on_LevelTimer_timeout():
	
	level += 1
	if $EnemyTimer.wait_time > 2: $EnemyTimer.wait_time -= 0.2
	$GameHUD.update_level( level )
	$LevelSound.play()
