extends "res://scenes/ui-bits/Submenu.gd"

export var slow_scale_to = 0.4

var time_scale = 1

signal slot_selected(slot)

signal request_process_input(enabled)

func _ready():
	_on_Enhancements_active_enhancements_changed()
	Enhancements.connect("active_enhancements_changed", self, "_on_Enhancements_active_enhancements_changed")
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
	emit_signal("request_process_input", false)
	
	time_scale = Engine.time_scale
	Engine.time_scale = slow_scale_to
	$AnimationPlayer.playback_speed = 1 / slow_scale_to

func restore_speed():
	emit_signal("request_process_input", true)
	Engine.time_scale = time_scale
	$AnimationPlayer.playback_speed = 1

func _on_Enhancements_active_enhancements_changed():
	for i in range(0, $"%SlotContainer".get_child_count()):
		get_node("%SlotContainer/Slot" + String(i + 1)).visible = Enhancements.get_weapon_slot(i) != null
		if Enhancements.get_weapon_slot(i) != null: get_node("%SlotContainer/Slot" + String(i + 1)).text = Enhancements.get_weapon_slot(i)["name"]

