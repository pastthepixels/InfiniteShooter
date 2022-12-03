extends "res://scenes/ui-bits/Submenu.gd"

func _ready():
	$Content/Slots.get_child(0).set_status_saved()
