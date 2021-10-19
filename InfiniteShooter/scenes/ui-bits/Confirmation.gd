extends Control

signal confirmed

func _input(event):
	if visible == true and (event is InputEventKey or event is InputEventJoypadButton):
		if event.is_action_pressed("ui_cancel"):
			hide()
			get_tree().paused = false
			return
		if event.is_action_pressed("ui_accept"):
			$AnimationPlayer.play_backwards("fade")
			yield($AnimationPlayer, "animation_finished")
			get_tree().paused = false
			emit_signal("confirmed")
			hide()

func open():
	show()
	$AnimationPlayer.play("fade")
	get_tree().paused = true
