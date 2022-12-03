extends "res://scenes/ui-bits/Submenu.gd"

func _ready():
	$Content/Back.grab_focus()
	$Content/Slots.get_child(0).set_status_saved()


func _on_Back_pressed():
	hide_animated()
