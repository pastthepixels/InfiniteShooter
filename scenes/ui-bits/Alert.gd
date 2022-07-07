extends CenterContainer

export(StyleBox) var warning_theme

export var is_warning = false

export(float) var animation_speed = 1

func _ready():
	if is_warning == true:
		$Panel.add_stylebox_override("panel", warning_theme)

func alert(text, duration=2):
	$AnimationPlayer.stop()
	$AnimationPlayer.playback_speed = animation_speed
	$AnimationPlayer.play("Show")
	$Panel/MarginContainer/Label.text = text
	$Timer.wait_time = duration

func error(text, duration=3):
	alert(text, duration)
	$ErrorSound.play()
	if CameraEquipment.get_node("ShakeCamera").ignore_shake == false: Input.start_joy_vibration(0, 0.6, 1, .2) # Vibrates a controller if you have one
	CameraEquipment.get_node("ShakeCamera").add_trauma(0.3)


func _on_Timer_timeout():
	$AnimationPlayer.play("Hide")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Show":
		$Timer.start()
