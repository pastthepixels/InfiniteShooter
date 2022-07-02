extends Control

signal closed

func show_animated():
	rect_pivot_offset = rect_size/2
	$AnimationPlayer.play("open")


func _on_SelectSquare_selected():
	emit_signal("closed")
	$AnimationPlayer.play("close")
