extends "res://scenes/ui-bits/Submenu.gd"

signal slot_selected(slot)

func _ready():
	for button in $"%SlotContainer".get_children():
		button.connect("pressed", self, "_on_SlotButton_pressed", [button])

# Note index + 1 == slot number
func _on_SlotButton_pressed(button):
	for child in $"%SlotContainer".get_children():
		child.pressed = false
	button.pressed = true
	emit_signal("slot_selected", button.get_index())
	hide_animated()
