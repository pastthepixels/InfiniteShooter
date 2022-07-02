extends Control

export var set_actions = {} # Format: { "action": [old_key, new_key] }

export (Array, String) var actions_to_set = []

signal opened

signal key_set

# Whether this is ready to set the mapped key or not
var check_for_keys = true

func _ready():
	set_actions = Saving.load_keys()
	set_keys()
	emit_signal("key_set")


func _input(event):
	if visible == true and check_for_keys == true and event is InputEventKey and event.is_pressed() == true:
		$AudioStreamPlayer.play()
		if event.is_action_pressed("ui_cancel"):
			$AnimationPlayer.play_backwards("fade")
		else:
			_change_key(event)


func _change_key(new_key):
	#Check if new key was assigned somewhere
	for key in set_actions: # already mapped in set_actions
		if set_actions[key][1].as_text() == new_key.as_text():
			$Alert.error("This key is already being used! Try a different one.")
			return
	
	for action in InputMap.get_actions(): # in existing actions and NOT in set_actions
		if InputMap.action_has_event(action, new_key) and (action in set_actions) == false:
			$Alert.error("This key is already being used! Try a different one.")
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

func map_actions(actions):
	emit_signal("opened")
	$Foreground/Content/Key.text = "No change set"
	$AnimationPlayer.play("fade")
	actions_to_set = actions

func set_keys():
	# Removes the old key and adds a new one for each action
	for action in set_actions:
		if InputMap.action_has_event(action, set_actions[action][0]):
			InputMap.action_erase_event(action, set_actions[action][0])
			InputMap.action_add_event(action, set_actions[action][1])
# The pizza is a lie!

func _on_AnimationPlayer_animation_started(_anim_name):
	show()


func _on_AnimationPlayer_animation_finished(_anim_name):
	if $AnimationPlayer.current_animation_position == 0: # Quick way to check if an animation finished playing backwards
		hide()
		check_for_keys = true
		emit_signal("key_set")
