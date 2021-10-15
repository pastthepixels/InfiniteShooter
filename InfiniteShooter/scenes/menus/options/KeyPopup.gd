extends Control

enum ACTIONS { ui_accept, ui_up, ui_down, move_up, move_down, move_left, move_right, shoot_laser, pause, ui_dismiss }

export var action_string = "ui_accept"

export var set_actions = {} # Format: { "action": [old_key, new_key] }


# Whether this is ready to set the mapped key or not
var check_for_keys = true

func _input(event):
	if visible == true and check_for_keys == true and event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			hide()
			check_for_keys = true
			get_tree().paused = false
			return
		else:
			_change_key(event)

# Modified from https://www.gotut.net/godot-key-bindings-tutorial/
# Changes a key based on an action which uses it.
func _change_key(new_key):
	# Gets the old mapped key
	var old_key
	for key in InputMap.get_action_list(action_string):
		if key is InputEventKey:
			old_key = key
	
	#Check if new key was assigned somewhere
	for key in set_actions:
		if set_actions[key][1].as_text() == new_key.as_text():
			$Alert.error("This key already being used! Try a different one.")
			return
	
	set_actions[action_string] = [old_key, new_key]
	
	# Shows the player the new key they pressed
	$Foreground/Content/Key.text = new_key.as_text()
	
	# Hides the popup
	check_for_keys = false
	$AnimationPlayer.play_backwards("fade")
	yield($AnimationPlayer, "animation_finished")
	hide()
	check_for_keys = true
	get_tree().paused = false
	get_parent().set_key_labels()

func set_key(action):
	show()
	$AnimationPlayer.play("fade")
	action_string = action
	get_tree().paused = true

func set_keys():
	# Removes the old key and adds a new one for each action
	for action in set_actions:
		print(action)
		if InputMap.action_has_event(action, set_actions[action][0]):
			InputMap.action_erase_event(action, set_actions[action][0])
			InputMap.action_add_event(action, set_actions[action][1])
