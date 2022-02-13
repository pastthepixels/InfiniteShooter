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

func _ready():
	if OS.window_fullscreen == false: # Moves the status bar to the bottom of the screen if the game is in windowed mode 
		# 1. Reparents the status bar
		$HUD.remove_child(status_bar)
		add_child(status_bar)
		status_bar.set_owner(self)
		move_child(status_bar, 4)
		# 2. Moves it to the bottom of the screen like InfiniteShooter used to have with the magic of hard-coding
		status_bar.anchor_left = 0
		status_bar.anchor_top = 1
		status_bar.anchor_right = 1
		status_bar.anchor_bottom = 1
		status_bar.rect_size = Vector2(600, 36)
		status_bar.rect_position = Vector2(0, 764)
		

func _process(_delta):
	status_bar.get_node("MarginContainer/Labels/FPS").text = "%s FPS" % Engine.get_frames_per_second()
	if _previous_health != animated_health:
		_previous_health = animated_health
		$HUD/ProgressBars/HealthBar.value = animated_health
	if _previous_ammo != animated_ammo:
		_previous_ammo = animated_ammo
		$HUD/ProgressBars/AmmoBar.value = animated_ammo

#
# Updating the status bar
#
func update_score(score):
	status_bar.get_node("MarginContainer/Labels/Score").text = "Score: %s" % score


func update_level(level, progress):
	status_bar.get_node("MarginContainer/Labels/Level/Label").text = "Level %s" % level
	status_bar.get_node("MarginContainer/Labels/Level").value = progress


func update_wave(wave, progress):
	status_bar.get_node("MarginContainer/Labels/Wave/Label").text = "Wave %s" % wave
	status_bar.get_node("MarginContainer/Labels/Wave").value = progress

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


func update_health(value):
	$ProgressTween.interpolate_property(
		self,
		"animated_health",
		animated_health,
		value * 100,
		0.2,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	if not $ProgressTween.is_active():
		$ProgressTween.start()

	if value < 0.3 and low_health == false:
		low_health = true
		$AnimationPlayer.play("FadeVignette")
	elif value > 0.3 and $AnimationPlayer.is_playing() == false and low_health == true:
		low_health = false
		$AnimationPlayer.play_backwards("FadeVignette")

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
		CameraEquipment.get_node("ShakeCamera").add_trauma(.3)
		$Alert/Sound.play()
		$Alert/Label.text = switchto_text
	yield(Utils.timeout(duration/2), "timeout")
	# Fades out
	$Alert/AnimationPlayer.play_backwards("fade_alert")
	yield($Alert/AnimationPlayer, "animation_finished")
	$Alert.hide()
