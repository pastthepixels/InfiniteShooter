extends Control

export(Vector2) var position

func _process(_delta):
	if $Shockwave.visible:
		$Shockwave.material.set_shader_param("position", position)

func explode():
	if Saving.load_settings()["shockwaves"] == true:
		$AnimationPlayer.play("EXPLODE")
	else:
		$Shockwave.disable()
