extends HBoxContainer

signal button_pressed(label)

export(float) var scroll_speed

export(float) var scroll_mirror_padding

var scrolling = false

func _process(delta):
	if scrolling == true:
		for label in $Control.get_children():
			if label is Label:
				label.rect_position.x -= scroll_speed * delta
				if label.rect_position.x < -label.rect_size.x:
					$Control.move_child(label, 1)
					print(scroll_mirror_padding)
					label.rect_position.x = $Control.get_child(0).rect_size.x + $Control.get_child(0).rect_position.x + scroll_mirror_padding

func _on_Button_pressed():
	emit_signal("button_pressed", self)

func _on_Button_focus_entered():
	start_scrolling()

func _on_Button_focus_exited():
	stop_scrolling()

func _on_Control_mouse_entered():
	start_scrolling()

func _on_Control_mouse_exited():
	stop_scrolling()

func start_scrolling(): # Bit of work to get ticker text/scrolling to work. Essentially a "mirror" node is created that helps to make the text look like it's being wrapped around.
	scrolling = true
	$Control/Mirror.rect_position.x = $Control/Name.rect_size.x + scroll_mirror_padding
	$Control/Mirror.show()

func stop_scrolling():
	scrolling = false
	$Control/Name.rect_position.x = 6
	$Control/Mirror.hide()

func set_stats(cost, damage, health):
	$Stats/Cost.text = "$%s" % cost
	$Stats/Damage.text = "+ %0.2f" % damage
	$Stats/Health.text = "+ %s" % health

func set_name(text):
	$Control/Name.text = text
	$Control/Mirror.text = text
