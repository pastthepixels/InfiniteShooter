extends MeshInstance

signal finished

func warp():
	$AnimationPlayer.play("BackgroundSwap")
	CameraEquipment.get_node("SkyAnimations2").play("ReduceSkyIntensity")

func set_rand_sky():
	CameraEquipment.set_rand_sky()

func increase_sky_intensity():
	CameraEquipment.get_node("SkyAnimations2").play_backwards("ReduceSkyIntensity")

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("finished")

# If you go the main menu in the middle of a warp sequence, this code is the only thing between you and a borked game.
func _process(_delta):
	if $AnimationPlayer.is_playing() and has_node("/root/Game") == false:
		CameraEquipment.get_node("SkyAnimations2").play("RESET")
		$AnimationPlayer.play("RESET")
