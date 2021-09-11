extends Node

# Screen positions
var top_left

var top_right

var bottom_left

var bottom_right

var viewport

var screen_size

# Random number generation
var last_random_number = 0


# Sets some variables with the viewport
func set_viewport(viewport_node):
	# Sets viewport
	viewport = viewport_node
	print(viewport_node)
	screen_size = viewport.get_visible_rect().size
	
	# other stuff
	top_left = screen_to_local(Vector2(0, 0))
	top_right = screen_to_local(Vector2(screen_size.x, 0))
	bottom_left = screen_to_local(Vector2(0, screen_size.y))
	bottom_right = screen_to_local(Vector2(screen_size.x, screen_size.y))


# Converts a screen coordinate to a local one (e.g., Vector2( 0, 0 ) == top left of screen, so it gets the camera and gives the relative position in global 3d coordinates.
func screen_to_local(vector2):
	return viewport.get_camera().project_position(vector2, viewport.get_camera().translation.y)


func random_screen_point():
	var screenPoint = Vector2(
		rand_range(screen_size.x - 50, 50), rand_range(50, screen_size.y - 50)
	)
	return screen_to_local(screenPoint)
