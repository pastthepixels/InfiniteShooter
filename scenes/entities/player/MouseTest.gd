extends Spatial

export(float, 0.1, 1.0) var speed = 0.2 # m/s

export(float) var speed_cursor = 200 # m/s

func _ready():
	pass#LoadingScreen.disable()

func _process(delta):
#	$MeshInstance.rotation_degrees.x = -$MouseControls.mouse_intensity.y * 90
#	$MeshInstance.rotation_degrees.z = $MouseControls.mouse_intensity.x * 90
	
	$MeshInstance.translation.x -= $MouseControls.get_mouse_intensity().x * speed
	$MeshInstance.translation.z -= $MouseControls.get_mouse_intensity().y * speed
	
	$MeshInstance/Label3D.text = "(%.2f, %.2f)" % [$MeshInstance.translation.x, $MeshInstance.translation.z]


func _on_MouseControls_mouse_moved(mouse_intensity):
	print(mouse_intensity)
	$Cursor.position.x -= mouse_intensity.x * speed_cursor
	$Cursor.position.y -= mouse_intensity.y * speed_cursor
