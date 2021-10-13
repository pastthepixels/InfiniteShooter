extends Label

signal finished

export var user_confirmation = false

export var confirmation_key = "ui_dismiss"

var waiting = false

func _input(event):
	if event.is_action_pressed(confirmation_key) and waiting == true:
		waiting = false
		fade_out()

func alert(alert_text, duration=1):
	# user confirmation stuff
	$UserInputWarning.visible = user_confirmation and confirmation_key == "ui_dismiss"
	if Input.get_joy_name(0) != "":
		$UserInputWarning/Keyboard.hide()
		$UserInputWarning/Controller.show()
	else:
		$UserInputWarning/Keyboard.show()
		$UserInputWarning/Controller.hide()
	
	# everything else
	hide()
	text = alert_text
	$AnimationPlayer.play("slide")
	show()
	# Fading out
	if user_confirmation == false:
		yield(Utils.timeout(duration), "timeout")
		fade_out()
	else:
		waiting = true

func fade_out():
	$AnimationPlayer.play_backwards("slide")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("finished")


func error(error_text):
	alert(error_text)
	$ErrorSound.play()
	Input.start_joy_vibration(0, 0.6, 1, .2)  # Vibrates a controller if you have one