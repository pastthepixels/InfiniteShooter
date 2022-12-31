extends Label3D

export(bool) var free_once_complete = false

export(float) var spread = 1.5

export(float) var animation_length = .800 # in milliseconds

var global_position

func _ready():
	visible = false

func activate(text=""):
	global_position = global_transform.origin
	set_as_toplevel(true)
	self.text = text
	show()
	animate()

func animate():
	var rand_pos = Vector3(2*randf() - 1, 0, 2*randf() - 1) * spread
	$Tween.interpolate_property(
		self,
		"translation",
		global_position,
		global_position + rand_pos,
		animation_length,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	$Tween.interpolate_property(
		self,
		"modulate:a",
		1,
		0,
		animation_length,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	$Tween.interpolate_property(
		self,
		"outline_modulate:a",
		1,
		0,
		animation_length,
		Tween.TRANS_LINEAR,
		Tween.EASE_OUT
	)
	$Tween.start()

func _on_Tween_tween_all_completed():
	if free_once_complete == true: queue_free()
