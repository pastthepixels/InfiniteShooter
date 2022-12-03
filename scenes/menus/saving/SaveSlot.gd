extends PanelContainer

export(Color) var indicator_modulate_unsaved

export(Color) var indicator_modulate_saved

func _ready():
	set_status_unsaved()

func set_status_unsaved():
	$HBoxContainer/Label.editable = true
	$HBoxContainer/Play.disabled = true
	$HBoxContainer/Indicator.modulate = indicator_modulate_unsaved

func set_status_saved():
	$HBoxContainer/Label.editable = false
	$HBoxContainer/Play.disabled = false
	$HBoxContainer/Indicator.modulate = indicator_modulate_saved
