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
	hint_tooltip = ""

func set_tooltip(save):
	var stats = []
	for node in save:
		if node.path == "/root/GameVariables":
			stats.append("Difficulty level: %s" % GameVariables.name_difficulty(int(node.save.current_difficulty)))
		
		if node.path == "/root/Game":
			stats.append("Score: %d" % node.save.score)
			stats.append("Coins: %d" % node.save.coins)
			stats.append("Level %d" % node.save.level)
			stats.append("Wave %d/%d" % [node.save.wave, node.save.waves_per_level])
		
		if node.path == "/root/Game/GameSpace/Player":
			stats.append("Health: %d/%d" % [node.save.health, node.save.max_health])
			stats.append("Ammo: %d/%d with %d refills left" % [node.save.ammo, node.save.max_ammo, node.save.ammo_refills])
	hint_tooltip = PoolStringArray(stats).join("\n")
	$HBoxContainer/Label.hint_tooltip = hint_tooltip

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
