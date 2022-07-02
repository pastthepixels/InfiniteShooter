extends Label

signal finished

export var user_confirmation = false

var alerting = false

var waiting = false

func _ready():
	if Input.get_joy_name(0) != "":
		$UserInputWarning/Keyboard.hide()
		$UserInputWarning/Controller.show()
	else:
		$UserInputWarning/Keyboard.show()
		$UserInputWarning/Controller.hide()

func _input(event):
	if event.is_action_pressed("ui_dismiss") and waiting == true:
		waiting = false
		fade_out()

func alert(alert_text, duration=1):
	alerting = true
	# user confirmation stuff
	$UserInputWarning.visible = user_confirmation
	
	# everything else
	hide()
	text = alert_text
	$AnimationPlayer.play("slide")
	# Fading out
	if user_confirmation == false:
		$AlertTimer.wait_time = duration
		$AlertTimer.start()
	else:
		waiting = true

func fade_out():
	$AnimationPlayer.play_backwards("slide")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("finished")


func error(error_text):
	alert(error_text)
	$ErrorSound.play()
	if CameraEquipment.get_node("ShakeCamera").ignore_shake == false: Input.start_joy_vibration(0, 0.6, 1, .2) # Vibrates a controller if you have one


func _on_AlertTimer_timeout():
	fade_out()


func _on_AnimationPlayer_animation_started(_anim_name):
	visible = true
