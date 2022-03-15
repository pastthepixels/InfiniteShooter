extends Spatial

func _on_Entrance_body_entered(body):
	if body.is_in_group("players"):
		body.translation = $Exit.global_transform.origin
