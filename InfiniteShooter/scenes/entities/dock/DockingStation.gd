extends Spatial

signal finished

func _ready(): # NOTE: The ship is 16x12
	translation.z = Utils.top_left.z - 10
	$Tween.interpolate_property(self, "translation:z", Utils.top_left.z - 10, 0, 6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Timer.start()

func _on_Entrance_body_entered(body):
	if body.is_in_group("players") and $Tween.is_active() == false:
		# Stop player movement and wait a sec
		$Timer.stop()
		$Entrance/IndicatorArrow.hide()
		body.freeze_movement = true
		body.hide()
		slow_sky(false)
		yield($Tween, "tween_completed")
		
		# Stop everything and show the screen
		$HUDToast.queue_free()
		get_tree().paused = true
		get_node("/root/Game/Upgrades").show_animated()
		get_node("/root/Game/PauseMenu").ignore_all = true
		
		# wait for the player to hit the back button on the upgrades screen
		yield(get_node("/root/Game/Upgrades"), "closed")
		
		# Start everything back up again
		get_node("/root/Game/PauseMenu").ignore_all = false
		get_tree().paused = false
		body.translation = $Exit.global_transform.origin
		body.freeze_movement = false
		body.show()
		
		# Go away
		slow_sky(true)
		yield($Tween, "tween_completed")
		$Tween.interpolate_property(self, "translation:z", 0, Utils.bottom_left.z + 10, 6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		emit_signal("finished")
		queue_free()

func slow_sky(resume):
	$Tween.interpolate_property(
		CameraEquipment.get_node("SkyAnimations"),
		"playback_speed",
		0 if resume else 1,
		1 if resume else 0,
		3,
		Tween.TRANS_QUAD
	)
	$Tween.start()


func _on_Timer_timeout():
	$HUDToast.alert("Get into the ship.", 5)
