extends Control

var pause_previous_state = false

export var enable_exiting = false

onready var initial_background_color = $Background.color

var signal_to_emit

# warning-ignore:unused_signal
signal exited

# warning-ignore:unused_signal
signal confirmed

func _process(_delta):
	if visible == true:
		$Foreground/Highlight.visible = Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_cancel")

func _input(event):
	if visible == true and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept")):
		$KeyDownSound.play()
	
	if visible == true and (event is InputEventKey or event is InputEventJoypadButton):
		if enable_exiting and event.is_action_released("ui_cancel"):
			signal_to_emit = "exited"
			$Background.color = Color("#32ff0000")
			$AnimationPlayer.play_backwards("fade")
			$AcceptSound.play()
		elif event.is_action_released("ui_accept"):
			signal_to_emit = "confirmed"
			if enable_exiting == true: $Background.color = Color("#3200ff00")
			$AnimationPlayer.play_backwards("fade")
			$AcceptSound.play()

func alert(text, can_be_exited=false):
	pause_previous_state = get_tree().paused
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
	$Sound.play()
	update_corners()

func update_corners():
	# Waits to make sure $Foreground/PanelContainer is automatically resized
	yield(get_tree(),"idle_frame") # I copied and pasted this a bunch of times and it "just works", so I'll just leave this here.
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	# Sets the new size for the corners as a minimum size so that the responsive UI doesn't override it
	$Foreground/Corners.rect_min_size = $Foreground/PanelContainer.rect_size
	$Foreground/Highlight.rect_min_size = $Foreground/PanelContainer.rect_size
	# Forces an update to resize the corners
	$Foreground/Corners.rect_size = Vector2()
	$Foreground/Highlight.rect_size = Vector2()


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
