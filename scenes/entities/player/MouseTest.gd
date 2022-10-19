extends Node

export var max_mouse_movement = 25 # Maximum movement in the X or Y direction

export var speed = 1

export var interpolation_time = 4

var mouse_moved = false

var last_mouse_move_relative : Vector2
var mouse_move_relative_interpolated : Vector2 # Interpolated to the last position the mouse was moved to
var mouse_intensity : Vector2 # Mouse velocity, normalized (mouse_velocity_pixels / max_mouse_movement)

func _ready():
	if has_node("/root/MouseTest"): LoadingScreen.disable()

func _input(event):
	if event is InputEventMouseButton and event.pressed == true:
		if event.button_index == 1:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		mouse_moved = true
		last_mouse_move_relative = Vector2(
			clamp(event.relative.y, -max_mouse_movement, max_mouse_movement), 
			clamp(event.relative.x, -max_mouse_movement, max_mouse_movement)
		) * -1


func _process(delta):
	# Check if the mouse was just moved and reset last_mouse_move if it wasn't moved at all
	if mouse_moved:
		mouse_moved = false
	else:
		last_mouse_move_relative = Vector2(0, 0)
	
	# Interpolate to the last position the mouse moved to 
	mouse_move_relative_interpolated = mouse_move_relative_interpolated.linear_interpolate(last_mouse_move_relative, interpolation_time * delta)
	mouse_intensity = mouse_move_relative_interpolated / max_mouse_movement
	
	# Printing and moving/rotating
	$Control/Label.text = "(%.2f, %.2f)" % [mouse_intensity.x, mouse_intensity.y]
	
	$Spatial/MeshInstance.rotation_degrees.x = -mouse_intensity.x * 60
	$Spatial/MeshInstance.rotation_degrees.z = mouse_intensity.y * 60
	
	$Spatial/MeshInstance.translation.x -= mouse_intensity.y / 10 * speed
	$Spatial/MeshInstance.translation.z -= mouse_intensity.x / 10 * speed
	
	$Spatial/MeshInstance/Label3D.text = "(%.2f, %.2f)" % [$Spatial/MeshInstance.translation.x, $Spatial/MeshInstance.translation.z]
