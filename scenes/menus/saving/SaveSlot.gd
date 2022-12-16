extends PanelContainer

export(Color) var indicator_modulate_unsaved

export(Color) var indicator_modulate_saved

var _is_saved = false

signal pressed(is_saved)

signal delete_save()

func _ready():
	set_status_unsaved()

func set_status_unsaved():
	_is_saved = false
	$HBoxContainer/Label.editable = true
	$HBoxContainer/Label.selecting_enabled = true
	$HBoxContainer/Label.focus_mode = Control.FOCUS_ALL
	$HBoxContainer/Play.text = "New game"
	$HBoxContainer/Delete.disabled = true
	$HBoxContainer/Indicator.modulate = indicator_modulate_unsaved

func set_status_saved():
	_is_saved = true
	$HBoxContainer/Label.editable = false
	$HBoxContainer/Label.selecting_enabled = false
	$HBoxContainer/Label.focus_mode = Control.FOCUS_NONE
	$HBoxContainer/Play.text = "Continue"
	$HBoxContainer/Delete.disabled = false
	$HBoxContainer/Indicator.modulate = indicator_modulate_saved

func _on_Play_pressed():
	emit_signal("pressed", _is_saved)


func _on_Delete_pressed():
	emit_signal("delete_save")
