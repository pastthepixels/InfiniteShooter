extends Node


var mouse_moved = false 

var max_rotation  = 25
var interpolation_time = 4

var interpolation_vector_default : Vector2 = Vector2(0, 0)
var last_mouse_move_relative : Vector2
var interpolate_torwards_vector : Vector2
var current_interpolating_vector : Vector2

func _ready():
	#CameraEquipment.get_node("Camera").current = false
	#$Spatial/Camera.current = true
	LoadingScreen.disable()

func _input(event):
	if event is InputEventMouseButton and event.pressed == true: # TODO: REMOVE/MOVE TO UTILS OR SOMETHING
		if event.button_index == 1:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseMotion:
		mouse_moved = true
		last_mouse_move_relative = Vector2(clamp(event.relative.y, -max_rotation, max_rotation), 
		clamp(event.relative.x, -max_rotation, max_rotation)) * -1


func _process(delta):

	if mouse_moved:
		mouse_moved = false
		interpolate_torwards_vector = last_mouse_move_relative
	else:
		interpolate_torwards_vector = interpolation_vector_default

	current_interpolating_vector = current_interpolating_vector.linear_interpolate(interpolate_torwards_vector, 
	interpolation_time * delta)
	
	var current_interpolating_vector_normalized = current_interpolating_vector / max_rotation
	
	$Control/Label.text = "%s" % current_interpolating_vector_normalized
	
	$Spatial/MeshInstance.rotation_degrees.x = -current_interpolating_vector_normalized.x * 50
	$Spatial/MeshInstance.rotation_degrees.z = current_interpolating_vector_normalized.y * 50
	
	$Spatial/MeshInstance.translation.x -= current_interpolating_vector_normalized.y / 10
	$Spatial/MeshInstance.translation.z -= current_interpolating_vector_normalized.x / 10
	
	$Spatial/MeshInstance/Label3D.text = "%s" % $Spatial/MeshInstance.translation
