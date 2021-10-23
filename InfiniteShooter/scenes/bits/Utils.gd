extends Node

# Viewport/screen size
onready var viewport = get_viewport()

onready var screen_size = get_viewport().get_visible_rect().size

# Screen positions
onready var top_left = screen_to_local(Vector2(0, 0))

onready var top_right = screen_to_local(Vector2(screen_size.x, 0))

onready var bottom_left = screen_to_local(Vector2(0, screen_size.y))

onready var bottom_right = screen_to_local(Vector2(screen_size.x, screen_size.y))

# Converts a screen coordinate to a local one (e.g., Vector2( 0, 0 ) == top left of screen, so it gets the camera and gives the relative position in global 3d coordinates.
func screen_to_local(vector2):
	return viewport.get_camera().project_position(vector2, viewport.get_camera().translation.y)


# Gets a random screen point and converts it to 3d coordinates
func random_screen_point():
	var screenPoint = Vector2(
		rand_range(screen_size.x - 50, 50), rand_range(50, screen_size.y - 50)
	)
	return screen_to_local(screenPoint)


# Setting timeouts
func timeout(seconds=1): # Usage: yield(Utils.timeout(1), "timeout")
	return get_tree().create_timer(seconds)
