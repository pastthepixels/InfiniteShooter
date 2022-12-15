extends Control

# Variables that display in-game variables

var level_progress = 0

var animated_health = 100

var animated_ammo = 100

var low_health = false

var _previous_health = 0

var _previous_ammo = 0

# Textures vased on laser types
enum TEXTURES { fire, ice, corrosion, default }

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
func update_gradient(texture):
	get_node("%StatusBar/LaserModifier").visible = true
	match(texture):
		TEXTURES.fire:
			get_node("%StatusBar/LaserModifier/Label").text = "Fire"
			get_node("%StatusBar/LaserModifier/Panel").color = fire_color
		
		TEXTURES.ice:
			get_node("%StatusBar/LaserModifier/Label").text = "Ice"
			get_node("%StatusBar/LaserModifier/Panel").color = ice_color
		
		TEXTURES.corrosion:
			get_node("%StatusBar/LaserModifier/Label").text = "Corrosion"
			get_node("%StatusBar/LaserModifier/Panel").color = corrosion_color
		
		TEXTURES.default:
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
func alert(text, duration, switchto_text="", switch_sky=false, subtext=""):
	# Sets text and shows the label
	$Alert/Label.text = text
	# Sets subtext if entered
	if subtext != "":
		$Alert/CenterContainer/Subtext.show()
		$Alert/CenterContainer/Subtext/MarginContainer/Label.text = subtext
	else:
		$Alert/CenterContainer/Subtext.hide()
	
	# Fades in
	$Alert/AnimationPlayer.play("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	# Waits
	yield(Utils.timeout(duration/2), "timeout")
	if switchto_text != "": # This variable is for animations like when the level is increased, showing the previous and new level.
		CameraEquipment.get_node("ShakeCamera").add_trauma(.3)
		$Alert/Sound.play()
		$Alert/Label.text = switchto_text
		if switch_sky == true:
			CameraEquipment.set_rand_sky()
	yield(Utils.timeout(duration/2), "timeout")
	# Fades out
	$Alert/AnimationPlayer.play_backwards("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	$Alert.hide()
