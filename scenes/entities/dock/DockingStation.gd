#
# NOTE: THE CODE BELOW "JUST WORKS" ALTHOUGH IT IS VERY MUCH SPAGHETTI CODE. DO NOT BE ALARMED IF IT LOOKS CRIMINALLY CONCERNING.
#
extends Spatial

signal finished

func _ready(): # NOTE: The ship is 16x12
	translation.z = Utils.top_left.z - 10
	# Animates the ship, then starts a timer that warns the player when it finishes
	$Tween.interpolate_property(self, "translation:z", translation.z, 0, 6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Entrance/IndicatorArrow.show()
	$Timer.start()

func _on_Entrance_body_entered(body):
	if body.is_in_group("players") and $Tween.is_active() == false:
		# Stop player movement and wait a sec
		$Timer.stop()
		$Entrance/IndicatorArrow.hide()
		body.freeze_movement = true
		body.hide()
		CameraEquipment.slow_sky();
		get_node("/root/Game/GameMusic").fade_out(3)
		yield(CameraEquipment.get_node("Tween"), "tween_completed")
		
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
		body.regenerate()
		body.show()
		
		# Go away
		get_node("/root/Game/GameMusic").fade_in(3)
		CameraEquipment.resume_sky();
		yield(CameraEquipment.get_node("Tween"), "tween_completed")
		$Tween.interpolate_property(self, "translation:z", 0, Utils.bottom_left.z + 10, 6, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_completed")
		emit_signal("finished")
		queue_free()

func _on_Timer_timeout():
	$HUDToast.alert("Get into the ship.", 5)