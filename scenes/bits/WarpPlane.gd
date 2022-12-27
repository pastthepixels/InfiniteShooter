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
