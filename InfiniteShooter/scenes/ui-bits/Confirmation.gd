extends Control

signal confirmed

func _input(event):
	if visible == true and (event is InputEventKey or event is InputEventJoypadButton):
		if event.is_action_pressed("ui_cancel"):
			$AnimationPlayer.play_backwards("fade")
		if event.is_action_pressed("ui_accept"):
			emit_signal("confirmed")
			$AnimationPlayer.play_backwards("fade")

func open():
	$AnimationPlayer.play("fade")
	get_tree().paused = true


func _on_AnimationPlayer_animation_started(_anim_name):
	show()


func _on_AnimationPlayer_animation_finished(_anim_name):
	if $AnimationPlayer.current_animation_position == 0: # Quick way to check if an animation finished playing backwards
		hide()
		get_tree().paused = false
