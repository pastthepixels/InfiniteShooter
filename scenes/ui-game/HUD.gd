extends Control

export var alert_duration = 3 # In seconds

# Variables that display in-game variables

var level_progress = 0

var animated_health = 100

var animated_ammo = 100

var low_health = false

var _previous_health = 0

var _previous_ammo = 0

# Textures vased on laser types
export (Color) var corrosion_color

export (Color) var fire_color

export (Color) var ice_color

func _process(_delta):
	if _previous_health != animated_health:
		_previous_health = animated_health
		get_node("%HealthBar").value = animated_health
	if _previous_ammo != animated_ammo:
		_previous_ammo = animated_ammo
		get_node("%AmmoBar").value = animated_ammo

func _ready():
	update_laser_modifier_label()

#
# Updating the status bar
#
func update_coins(coins):
	get_node("%StatusBar").get_node("Coins").text = "$%s" % coins


func update_score(score):
	get_node("%StatusBar").get_node("Score").text = "%s" % score


func update_level(level, progress):
	get_node("%StatusBar").get_node("Level/Label").text = "Level %s" % level
	get_node("%StatusBar").get_node("Level/Progress").value = progress


func update_wave(wave, progress):
	get_node("%StatusBar").get_node("Wave/Label").text = "Wave %s" % wave
	get_node("%StatusBar").get_node("Wave/Progress").value = progress

func update_wave_boss():
	get_node("%StatusBar").get_node("Wave/Label").text = "Boss fight"
	get_node("%StatusBar").get_node("Wave/Progress").value = 100

#
# Updating the top bars
#
func update_laser_modifier_label(modifier=GameVariables.LASER_MODIFIERS.none):
	get_node("%StatusBar/LaserModifier").visible = true
	match(modifier):
		GameVariables.LASER_MODIFIERS.fire:
			get_node("%StatusBar/LaserModifier/Label").text = "Fire"
			get_node("%StatusBar/LaserModifier/Panel").color = fire_color
		
		GameVariables.LASER_MODIFIERS.ice:
			get_node("%StatusBar/LaserModifier/Label").text = "Ice"
			get_node("%StatusBar/LaserModifier/Panel").color = ice_color
		
		GameVariables.LASER_MODIFIERS.corrosion:
			get_node("%StatusBar/LaserModifier/Label").text = "Corrosion"
			get_node("%StatusBar/LaserModifier/Panel").color = corrosion_color
		
		GameVariables.LASER_MODIFIERS.none:
			get_node("%StatusBar/LaserModifier").visible = false


func update_health(value : float, hp):
	$ProgressTween.interpolate_property(
		self,
		"animated_health",
		animated_health,
		value * 100,
		0.2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	get_node("%HealthBar/HealthPoints").text = String(int(hp))
	
	if not $ProgressTween.is_active():
		$ProgressTween.start()

	if value < 0.4 and value > 0 and low_health == false and $Vignette.visible == false:
		low_health = true
		$AnimationPlayer.play("FadeInVignette")
		$HUDToast.alert("Low health!", 1)
	elif value > 0.4 and $AnimationPlayer.is_playing() == false and low_health == true and $Vignette.visible == true:
		low_health = false
		$AnimationPlayer.play("FadeOutVignette")

func update_ammo(value, refills):
	$ProgressTween.interpolate_property(
		self,
		"animated_ammo",
		animated_ammo,
		value * 100,
		0.1,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	if not $ProgressTween.is_active():
		$ProgressTween.start()
	get_node("%AmmoBar/Refills").text = str(refills)
	get_node("%AmmoBar/Refills").visible = not refills == 0

#
# Alerting text to the player
#
func alert(text, switchto_text="", subtext=""):
	# Sets text and shows the label
	get_node("%AlertContents/Title").text = text
	
	# Sets the subtitle if entered
	get_node("%AlertContents/Subtitle").visible = subtext != ""
	get_node("%AlertContents/Subtitle").text = subtext
	
	# Makes the HSeparator visible if both the subtitle and progress bar are
	get_node("%AlertContents/HSeparator").visible = get_node("%AlertContents/Subtitle").visible == true and get_node("%AlertContents/ProgressBar").visible == true
	
	# Animates the progress bar
	$Alert/Tween.stop_all()
	$Alert/Tween.interpolate_property(
		get_node("%AlertContents/ProgressBar"),
		"value",
		0,
		get_node("%AlertContents/ProgressBar").value,
		$Alert/AnimationPlayer.get_animation("fade_alert").length + alert_duration/2,
		$Alert/Tween.TRANS_CUBIC,
		$Alert/Tween.EASE_IN
	)
	$Alert/Tween.start()
	
	# Fades in
	$Alert/AnimationPlayer.play("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	
	# Waits
	yield(Utils.timeout(alert_duration/2), "timeout")
	
	# Animates text (e.g. Wave 2 > Wave 3)
	if switchto_text != "": # This variable is for animations like when the level is increased, showing the previous and new level.
		CameraEquipment.get_node("ShakeCamera").add_trauma(.3)
		$Alert/Sound.play()
		get_node("%AlertContents/Title").text = switchto_text
	
	# Waits again
	yield(Utils.timeout(alert_duration/2), "timeout")
	
	# Fades out
	$Alert/AnimationPlayer.play_backwards("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	$Alert.hide()

func hide_alert_progress():
	get_node("%AlertContents/ProgressHint").visible = false
	get_node("%AlertContents/ProgressBar").visible = false

func set_alert_progress(value, max_value=100, hint=""):
	# Sets the hint on the progress bar (ex. "5 waves left" or "1 level until next difficulty reset")
	get_node("%AlertContents/ProgressHint").visible = hint != ""
	get_node("%AlertContents/ProgressHint").text = hint
	
	# Sets the progress bar
	get_node("%AlertContents/ProgressBar").visible = true
	get_node("%AlertContents/ProgressBar").max_value = max_value
	get_node("%AlertContents/ProgressBar").value = value
