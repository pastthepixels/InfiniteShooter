extends Control

export(Vector2) var position

func _ready():
	if Saving.load_settings()["shockwaves"] == false:
		$Shockwave.disable()

func _process(_delta):
	if $Shockwave.visible and visible and $Shockwave.active:
		print(true)
		$BackBufferCopy.set_copy_mode(BackBufferCopy.COPY_MODE_VIEWPORT)
		$Shockwave.material.set_shader_param("position", position)
	else:
		$BackBufferCopy.set_copy_mode(BackBufferCopy.COPY_MODE_DISABLED)

func explode():
	if Saving.load_settings()["shockwaves"] == true:
		$AnimationPlayer.play("EXPLODE")
	else:
		$Shockwave.disable()
