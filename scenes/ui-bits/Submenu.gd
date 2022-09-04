extends Control

signal closed

export(NodePath) var auto_select

func show_animated():
	rect_pivot_offset = rect_size/2
	$AnimationPlayer.play("open")

func close_animated():
	emit_signal("closed")
	$AnimationPlayer.play("close")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "open" and has_node(auto_select):
		get_node(auto_select).grab_focus()
