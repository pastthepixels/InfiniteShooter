extends Label

signal finished

export var user_confirmation = false

var waiting = false

func _input(event):
	print(waiting)
	print(event.is_action_pressed("ui_dismiss"))
	if event.is_action_pressed("ui_dismiss") and waiting == true:
		waiting = false
		fade_out()

func alert(alert_text, duration=1):
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
