extends Control

export(Vector2) var position

func _process(_delta):
	print($BackBufferCopy.copy_mode)
	if $Shockwave.visible and visible:
		$BackBufferCopy.set_copy_mode(BackBufferCopy.COPY_MODE_VIEWPORT)
		$Shockwave.material.set_shader_param("position", position)
	else:
		$BackBufferCopy.set_copy_mode(BackBufferCopy.COPY_MODE_DISABLED)

func explode():
	if Saving.load_settings()["shockwaves"] == true:
		$AnimationPlayer.play("EXPLODE")
	else:
		$Shockwave.disable()
