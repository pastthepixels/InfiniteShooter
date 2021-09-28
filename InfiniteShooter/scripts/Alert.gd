extends Label

signal finished

func alert(alert_text, duration=1):
	hide()
	text = alert_text
	$AnimationPlayer.play("slide")
	show()
	# Fading out
	yield(Utils.timeout(duration), "timeout")
	$AnimationPlayer.play_backwards("slide")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("finished")


func error(error_text):
	alert(error_text)
	$ErrorSound.play()
	Input.start_joy_vibration(0, 0.6, 1, .2)  # Vibrates a controller if you have one
