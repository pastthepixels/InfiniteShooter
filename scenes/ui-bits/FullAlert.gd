extends Control

var previous_focus_owner

var pause_previous_state = false

var signal_to_emit

# warning-ignore:unused_signal
signal exited

# warning-ignore:unused_signal
signal confirmed


func _on_AnimationPlayer_animation_started(anim_name):
	yield(get_tree(), "idle_frame")
	if anim_name != "RESET":
		show()
		set_process_input(false)


func _on_AnimationPlayer_animation_finished(_anim_name):
	set_process_input(true)
	if $AnimationPlayer.current_animation_position == 0: # Quick way to check if an animation finished playing backwards
		get_tree().paused = pause_previous_state
		hide()
		emit_signal(signal_to_emit)


func _on_Yes_pressed():
	previous_focus_owner.grab_focus()
	signal_to_emit = "confirmed"
	$AnimationPlayer.play_backwards("fade")


func _on_No_pressed():
	previous_focus_owner.grab_focus()
	signal_to_emit = "exited"
	$AnimationPlayer.play_backwards("fade")


func _on_Ok_pressed():
	previous_focus_owner.grab_focus()
	signal_to_emit = "exited"
	$AnimationPlayer.play_backwards("fade")

func alert(text, is_confirmation=false):
	previous_focus_owner = get_focus_owner()
	pause_previous_state = get_tree().paused
	get_tree().paused = true
	if is_confirmation == true:
		get_node("%ConfirmationButtons").show()
		get_node("%ConfirmationButtons/HBoxContainer/Yes").grab_focus()
	else:
		get_node("%DismissButtons").show()
		get_node("%ConfirmationButtons/HBoxContainer/Ok").grab_focus()
	$Foreground/PanelContainer/Content/MarginContainer/Alert.text = text
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("fade")
	$Sound.play()

func confirm(text):
	alert(text, true)
