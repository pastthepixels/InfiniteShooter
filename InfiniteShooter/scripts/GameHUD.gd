extends Control

# Variables that display in-game variables

var level_progress = 0

var animated_health = 100

var animated_ammo = 100

var low_health = false


func _process(_delta):
	$ProgressBars/HealthBar.value = animated_health
	$ProgressBars/AmmoBar.value = animated_ammo
	$StatusBar/Labels/FPS.text = "%s FPS" % Engine.get_frames_per_second()

#
# Updating the status bar
#
func update_score(score):
	$StatusBar/Labels/Score.text = "Score: %s" % score


func update_level(level, progress):
	$StatusBar/Labels/Level.text = "Level %s" % level
	$StatusBar/Labels/Level/Progress.value = progress


func update_wave(wave, progress):
	$StatusBar/Labels/Wave.text = "Wave %s" % wave
	$StatusBar/Labels/Wave/Progress.value = progress

#
# Updating the top bars
#
func update_health(value):
	$ProgressTween.interpolate_property(
		self,
		"animated_health",
		animated_health,
		value * 1000,
		0.2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	if not $ProgressTween.is_active():
		$ProgressTween.start()

	if value < .3 and low_health == false:
		low_health = true
		$AnimationPlayer.play("FadeVignette")

	if value > .3 and $AnimationPlayer.is_playing() == false and low_health == true:
		low_health = false
		$AnimationPlayer.play_backwards("FadeVignette")

func update_ammo(value, refills):
	
	$ProgressTween.interpolate_property(
		self, "animated_ammo", animated_ammo, value * 100, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN
	)
	$ProgressBars/AmmoBar/Refills.text = str(refills)
	$ProgressBars/AmmoBar/Refills.visible = not refills == 0
	if not $ProgressTween.is_active():
		$ProgressTween.start()

#
# Alerting text to the player
#
func alert(text, duration, switchto_text=""):
	# Sets text and shows the label
	$Alert/Label.text = text
	$Alert.show()
	# Fades in
	$Alert/AnimationPlayer.play("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	# Waits
	yield(Utils.timeout(duration/2), "timeout")
	if switchto_text != "": # This variable is for animations like when the level is increased, showing the previous and new level.
		$Alert/Label.text = switchto_text
	yield(Utils.timeout(duration/2), "timeout")
	# Fades out
	$Alert/AnimationPlayer.play_backwards("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	$Alert.hide()
