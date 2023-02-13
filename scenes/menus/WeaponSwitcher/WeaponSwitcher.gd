extends "res://scenes/ui-bits/Submenu.gd"

export var slow_scale_to = 0.4

var time_scale = 1

signal slot_selected(slot)

signal request_process_input(enabled)

func _ready():
	for button in $"%SlotContainer".get_children():
		button.connect("pressed", self, "_on_SlotButton_pressed", [button])

# Note index + 1 == slot number
func _on_SlotButton_pressed(button):
	for child in $"%SlotContainer".get_children():
		child.pressed = false
	button.pressed = true
	auto_select = button.get_path()
	emit_signal("slot_selected", button.get_index())
	restore_speed()
	hide_animated()

func _input(event):
	if event.is_action_pressed("open_weapon_switcher"):
		if visible == false and (get_node("/root/Game").is_submenu_visible() == false if has_node("/root/Game") else true):
			slow_game()
			show_animated()
		else:
			restore_speed()
			hide_animated()

func slow_game():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	emit_signal("request_process_input", false)
	
	time_scale = Engine.time_scale
	Engine.time_scale = slow_scale_to

func restore_speed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	emit_signal("request_process_input", true)
	Engine.time_scale = time_scale
