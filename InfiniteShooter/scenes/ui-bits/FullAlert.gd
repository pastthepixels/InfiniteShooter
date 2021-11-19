extends Control

export var enable_exiting = false

onready var initial_background_color = $Background.color

var signal_to_emit

signal exited

signal confirmed


func _input(event):
	if visible == true and (event is InputEventKey or event is InputEventJoypadButton):
		if enable_exiting and event.is_action_pressed("ui_cancel"):
			signal_to_emit = "exited"
			$Background.color = Color("#32ff0000")
			$AnimationPlayer.play_backwards("fade")
		if event.is_action_pressed("ui_accept"):
			signal_to_emit = "confirmed"
			if enable_exiting == true: $Background.color = Color("#3200ff00")
			$AnimationPlayer.play_backwards("fade")

func alert(text, can_be_exited=false):
	get_tree().paused = true
	enable_exiting = can_be_exited
	if can_be_exited == true:
		$Foreground/PanelContainer/Content/Escape.text = "Press the escape key to cancel this operation"
	else:
		$Foreground/PanelContainer/Content/Escape.text = "Press the confirm key to continue"
	$Background.color = initial_background_color
	$Foreground/PanelContainer/Content/MarginContainer/Alert.text = text
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("fade")


func _on_AnimationPlayer_animation_started(anim_name):
	yield(get_tree(), "idle_frame")
	if anim_name != "RESET":
		show()
		set_process_input(false)


func _on_AnimationPlayer_animation_finished(_anim_name):
	set_process_input(true)
	if $AnimationPlayer.current_animation_position == 0: # Quick way to check if an animation finished playing backwards
		get_tree().paused = false
		hide()
		emit_signal(signal_to_emit)
