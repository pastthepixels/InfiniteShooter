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
	#Check if new key was assigned somewhere
	for key in set_actions:
		if set_actions[key][1].as_text() == new_key.as_text():
			$Alert.error("This key already being used! Try a different one.")
			return
	
	for action in ACTIONS:
		if InputMap.action_has_event(action, new_key) and (action in set_actions) == false:
			$Alert.error("This key already being used! Try a different one.")
			return
	
	# For all the actions to set...
	for action_string in actions_to_set:
		# Gets the old mapped key
		var old_key
		for key in InputMap.get_action_list(action_string):
			if key is InputEventKey:
				old_key = key
		
		# Switch it for the new one
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

func map_actions(actions):
	show()
	$Foreground/Content/Key.text = "No change set"
	$AnimationPlayer.play("fade")
	actions_to_set = actions
	get_tree().paused = true

# Actually *doing* the stuff.
func _ready():
	load_keys()
	set_keys()
	
func set_keys():
	# Removes the old key and adds a new one for each action
	for action in set_actions:
		if InputMap.action_has_event(action, set_actions[action][0]):
			InputMap.action_erase_event(action, set_actions[action][0])
			InputMap.action_add_event(action, set_actions[action][1])

func save_keys():
	# Converts InputEventKey --> Scancode
	var stored_variable = {}
	for action in set_actions:
		stored_variable[action] = [set_actions[action][0].scancode, set_actions[action][1].scancode]
	# Stores key bindings
	var file = File.new()
	file.open("user://keybindings.json", File.WRITE)
	file.store_line(to_json(stored_variable))
	file.close()

func load_keys():
	# Loads key bindings
	var file = File.new()
	if file.file_exists("user://keybindings.json") == false: return # Returns if keybindings.json doesn't exist
	file.open("user://keybindings.json", File.READ)
	var stored_variable = parse_json(file.get_line())
	
	# Converts Scancode --> InputEventKey
	for action in stored_variable:
		var old_key = InputEventKey.new()
		var new_key = InputEventKey.new()
		old_key.scancode = stored_variable[action][0]
		new_key.scancode = stored_variable[action][1]
		set_actions[action] = [old_key, new_key]
	
	get_parent().set_key_labels()
