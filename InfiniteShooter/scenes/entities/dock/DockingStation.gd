extends Spatial

signal finished

func _ready(): # NOTE: The ship is 16x12
	$Tween.interpolate_property(self, "translation:z", Utils.top_left.z - 10, 0, 6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

func _on_Entrance_body_entered(body):
	if body.is_in_group("players") and $Tween.is_active() == false:
		# Stop everything and show the screen
		get_tree().paused = true
		get_node("/root/Game/Upgrades").show_animated()
		get_node("/root/Game/PauseMenu").ignore_all = true
		# wait for the player to hit the back button
		yield(get_node("/root/Game/Upgrades"), "closed")
		# Start everything back up again
		get_node("/root/Game/PauseMenu").ignore_all = false
		get_tree().paused = false
		body.translation = $Exit.global_transform.origin
		# Go away
		$Tween.interpolate_property(self, "translation:z", 0, Utils.bottom_left.z + 10, 6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		emit_signal("finished")
		queue_free()
