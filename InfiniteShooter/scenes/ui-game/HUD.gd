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

export (GradientTexture) var default_gradient

export (GradientTexture) var corrosion_gradient

export (GradientTexture) var fire_gradient

export (GradientTexture) var ice_gradient

# Other variables
onready var status_bar = get_node("HUD/StatusBar")

func _process(_delta):
	if _previous_health != animated_health:
		_previous_health = animated_health
		$HUD/ProgressBars/HealthBar.value = animated_health
	if _previous_ammo != animated_ammo:
		_previous_ammo = animated_ammo
		$HUD/ProgressBars/AmmoBar.value = animated_ammo

#
# Updating the status bar
#
func update_points(points):
	status_bar.get_node("MarginContainer/Labels/Points").text = "%s" % points


func update_level(level, progress):
	status_bar.get_node("MarginContainer/Labels/Level/Label").text = "Level %s" % level
	status_bar.get_node("MarginContainer/Labels/Level/Progress").value = progress


func update_wave(wave, progress):
	status_bar.get_node("MarginContainer/Labels/Wave/Label").text = "Wave %s" % wave
	status_bar.get_node("MarginContainer/Labels/Wave/Progress").value = progress

#
# Updating the top bars
#
func update_gradient(texture):
	match(texture):
		TEXTURES.fire:
			$HUD/ProgressBars.texture = fire_gradient
		
		TEXTURES.ice:
			$HUD/ProgressBars.texture = ice_gradient
		
		TEXTURES.corrosion:
			$HUD/ProgressBars.texture = corrosion_gradient
		
		TEXTURES.default:
			$HUD/ProgressBars.texture = default_gradient


func update_health(value, hp):
	$ProgressTween.interpolate_property(
		self,
		"animated_health",
		animated_health,
		value * 100,
		0.2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	
	$HUD/ProgressBars/HealthBar/HealthPoints.text = String(hp)
	
	if not $ProgressTween.is_active():
		$ProgressTween.start()

	if value < 0.4 and value > 0 and low_health == false and $Vignette.visible == false:
		low_health = true
		$AnimationPlayer.play("FadeInVignette")
		$HUDToast.alert("Low health!", 1)
	elif value > 0.3 and $AnimationPlayer.is_playing() == false and low_health == true and $Vignette.visible == true:
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
	$HUD/ProgressBars/AmmoBar/Refills.text = str(refills)
	$HUD/ProgressBars/AmmoBar/Refills.visible = not refills == 0

#
# Alerting text to the player
#
func alert(text, duration, switchto_text="", switch_sky=false):
	# Sets text and shows the label
	$Alert/Label.text = text
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
