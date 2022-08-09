extends PanelContainer

# Lazy programming in action
var level : int = 0
var level_progress : int = 0
var wave : int = 0
var wave_progress : int = 0
var points : int = 0


func set_stats(new_level, new_wave, new_level_progress, new_wave_progress, new_points):
	$Stats/Level/Level/Progress.value = new_level_progress
	$Stats/Level/Wave/Progress.value = new_wave_progress
	$Tween.interpolate_property(self, "level",
		self.level, new_level, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "wave",
		self.wave, new_wave, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property(self, "points",
		self.points, new_points, 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	$ReloadBoop.play()


func _on_Tween_tween_step(_object, _key, _elapsed, _value):
	$Stats/Level/Level/Label.text = "Level %s" % level
	$Stats/Level/Wave/Label.text = "Wave %s" % wave
	$Stats/Points/Points.text = "%s" % points


func _on_Tween_tween_all_completed():
	$ReloadBoop.stop()
