extends Control

export(String, MULTILINE) var text : String

export(bool) var is_confirmation = false

var previous_focus_owner

var pause_previous_state = false

var signal_to_emit

# warning-ignore:unused_signal
signal exited

# warning-ignore:unused_signal
signal confirmed


func _on_AnimationPlayer_animation_finished(_anim_name):
	if _anim_name == "hide":
		get_tree().paused = pause_previous_state
		emit_signal(signal_to_emit)


func _on_Yes_pressed():
	if previous_focus_owner != null: previous_focus_owner.grab_focus()
	signal_to_emit = "confirmed"
	$AnimationPlayer.play("hide")


func _on_No_pressed():
	if previous_focus_owner != null: previous_focus_owner.grab_focus()
	signal_to_emit = "exited"
	$AnimationPlayer.play("hide")


func _on_Ok_pressed():
	if previous_focus_owner != null: previous_focus_owner.grab_focus()
	signal_to_emit = "exited"
	$AnimationPlayer.play("hide")

func alert(text=self.text, is_confirmation=self.is_confirmation):
	previous_focus_owner = get_focus_owner()
	pause_previous_state = get_tree().paused
	get_tree().paused = true
	get_node("%ConfirmationButtons").hide()
	get_node("%DismissButtons").hide()
	if is_confirmation == true:
		get_node("%ConfirmationButtons").show()
		get_node("%ConfirmationButtons/HBoxContainer/Yes").grab_focus()
	else:
		get_node("%DismissButtons").show()
		get_node("%DismissButtons/HBoxContainer/Ok").grab_focus()
	$Foreground/PanelContainer/Content/MarginContainer/Alert.text = text
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("fade")
	$Sound.play()

func confirm(text):
	alert(text, true)
