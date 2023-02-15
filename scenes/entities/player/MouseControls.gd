extends Node

signal mouse_moved(mouse_intensity)

export(float) var sensitivity = 1.0

export(bool) var use_sensitivity_from_settings = false

export(int) var max_mouse_speed = 500 # Maximum movement in pixels/second

export(bool) var pointer_lock_enabled = false

export(int) var frames_until_mouse_reset = 1

var timer = frames_until_mouse_reset

var mouse_moved : bool = false

var mouse_intensity : Vector2 setget ,get_mouse_intensity

var _mouse_intensity : Vector2


func _ready():
	if use_sensitivity_from_settings == true:
		sensitivity = Saving.current_settings["mouse_sensitivity"]

# _input: Calculate the intensity of each mouse movement and multiply it by -1 because for some reason down is positive for Godot???
func _input(event):
	# Pointer lock
	if pointer_lock_enabled == true and event is InputEventMouseButton and event.pressed == true:
		if event.button_index == 1:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseMotion:
		mouse_moved = true
		var mouse_speed = event.relative / get_process_delta_time() * -1
		var radius = clamp(abs(mouse_speed.length() * sensitivity), 0, max_mouse_speed) / max_mouse_speed # Divides by max_mouse_movement (and clamps) to get a value out of 1 (that can't be higher than 1)
		_mouse_intensity = Vector2(radius, 0).rotated(mouse_speed.angle())
		emit_signal("mouse_moved", _mouse_intensity)

func get_mouse_intensity():
	return _mouse_intensity if mouse_moved == true else Vector2(0, 0)

func _process(delta):
	if is_screen_open():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if get_tree().paused == false:
		calculate_mouse_movement()

func is_screen_open():
	if has_node("/root/Game") == false: return true
	for node in get_tree().get_nodes_in_group("menus"):
		if node.is_visible_in_tree():
			return true
	return false

func calculate_mouse_movement():
	if mouse_moved == true and timer == 0:
		mouse_moved = false
		timer = frames_until_mouse_reset
	elif mouse_moved == true:
		timer -= 1
