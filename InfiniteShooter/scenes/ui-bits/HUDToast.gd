extends CenterContainer


func alert(text, duration=3):
	$Panel/MarginContainer/Label.text = text
	$AnimationPlayer.play("Show")
	$Timer.wait_time = duration


func _on_Timer_timeout():
	$AnimationPlayer.play("Hide")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Show":
		$Timer.start()
