extends Control


# Variables that display in-game variables
var animated_health = 100
var animated_ammo = 100
var low_health = false

# Called when the node enters the scene tree for the first time.
func _process( _delta ):
	
	$HealthBar.value = animated_health
	$AmmoBar.value = animated_ammo
	$StatusBar/Labels/FPS.text = "%s FPS" % Engine.get_frames_per_second()

func update_score( score ):
	
	$StatusBar/Labels/Score.text = "Score: %s" % score

func update_level( level ):
	
	$StatusBar/Labels/Level.text = "Level %s" % level
	
func update_health( value ):
	
	$ProgressTween.interpolate_property( self, "animated_health", animated_health, value * 100, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not $ProgressTween.is_active(): $ProgressTween.start()
	if value < .3 and low_health == false:
		
		low_health = true
		$AnimationPlayer.play( "FadeVignette" )
		
	if value > .3 and $AnimationPlayer.is_playing() == false and low_health == true:
		
		low_health = false
		$AnimationPlayer.play_backwards( "FadeVignette" )
	

func update_ammo( value ):
	
	$ProgressTween.interpolate_property( self, "animated_ammo", animated_ammo, value * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	if not $ProgressTween.is_active(): $ProgressTween.start()
