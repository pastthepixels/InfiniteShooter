extends Control

export(Vector2) var position

func _process(_delta):
	$Shockwave.material.set_shader_param("position", position)
	print($Shockwave.rect_size)

func explode():
	$AnimationPlayer.play("EXPLODE")
