extends "res://scenes/ui-bits/Submenu.gd"

var saves

var slot_to_delete = 0

func update():
	saves = Saving.load_save_slot_data()
	for i in saves.size():
		if saves[i].active == true and Saving.save_exists(i):
			get_node("Content/Slots/Slot%s" % (i+1)).set_status_saved()
			get_node("Content/Slots/Slot%s/HBoxContainer/Label" % (i+1)).text = saves[i].name
			get_node("Content/Slots/Slot%s" % (i+1)).set_tooltip(Saving.get_save_json(i))
		else:
			get_node("Content/Slots/Slot%s" % (i+1)).set_status_unsaved()


func update_slot_data(slot_node):
	var slot_data = Saving.load_save_slot_data()
	slot_data[Saving.current_save_slot]["name"] = slot_node.get_node("HBoxContainer/Label").text if slot_node.get_node("HBoxContainer/Label").text else slot_node.get_node("HBoxContainer/Label").placeholder_text 
	slot_data[Saving.current_save_slot]["active"] = true
	Saving.save_save_slot_data(slot_data)


func start_game(is_saved):
	if is_saved == false:
		SceneTransition.start_game()
	else:
		SceneTransition.continue_game()

func _ready():
	update()


func _on_Back_pressed():
	hide_animated()


func _on_Slot1_pressed(is_saved):
	Saving.current_save_slot = 0
	update_slot_data($Content/Slots/Slot1)
	start_game(is_saved)

func _on_Slot1_delete_save():
	slot_to_delete = 0
	$FullAlert.confirm("Are you sure you want to delete your first save slot?")


func _on_Slot2_pressed(is_saved):
	Saving.current_save_slot = 1
	update_slot_data($Content/Slots/Slot2)
	start_game(is_saved)

func _on_Slot2_delete_save():
	slot_to_delete = 1
	$FullAlert.confirm("Are you sure you want to delete your second save slot?")


func _on_Slot3_pressed(is_saved):
	Saving.current_save_slot = 2
	update_slot_data($Content/Slots/Slot3)
	start_game(is_saved)

func _on_Slot3_delete_save():
	slot_to_delete = 2
	$FullAlert.confirm("Are you sure you want to delete your third save slot?")


func _on_Slot4_pressed(is_saved):
	Saving.current_save_slot = 3
	update_slot_data($Content/Slots/Slot4)
	start_game(is_saved)

func _on_Slot4_delete_save():
	slot_to_delete = 3
	$FullAlert.confirm("Are you sure you want to delete your fourth save slot?")


func _on_FullAlert_confirmed():
	Saving.delete_save(slot_to_delete)
	update()
