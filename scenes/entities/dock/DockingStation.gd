#
# NOTE: THE CODE BELOW "JUST WORKS" ALTHOUGH IT IS VERY MUCH SPAGHETTI CODE. DO NOT BE ALARMED IF IT LOOKS CRIMINALLY CONCERNING.
#
extends Spatial

signal finished

func _ready():
	$AnimationPlayer.play("Enter")

func _on_Entrance_body_entered(body):
	if body.is_in_group("players") and $AnimationPlayer.is_playing() == false:
		# Stop player movement and wait a sec
		$Timer.stop()
		$Entrance/IndicatorArrow.hide()
		body.freeze_movement = true
		body.hide()
		CameraEquipment.slow_sky()
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
		$AnimationPlayer.play("Exit")


func _on_Timer_timeout():
	$HUDToast.alert("Get into the ship.", 5)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Enter":
		$Timer.start()
		# Checks if anything is currently colliding with the entrance (ex. the player has already entered the docking station
		for body in $Entrance.get_overlapping_bodies():
			_on_Entrance_body_entered(body)
	elif anim_name == "Exit":
		emit_signal("finished")
		queue_free()
