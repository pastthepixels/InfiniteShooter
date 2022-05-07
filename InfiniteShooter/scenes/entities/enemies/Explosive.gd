extends Area

signal exploded

func explode():
	$AnimationPlayer.play("Explode")


func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("exploded")


func _on_Area_area_entered(area):
	if area.get_parent().is_in_group("enemies"):
		area.get_parent().health -= get_parent().damage
