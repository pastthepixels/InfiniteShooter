extends Node

# Viewport/screen size
onready var viewport = get_viewport()

onready var screen_size = get_viewport().get_visible_rect().size

# Screen positions
onready var top_left = screen_to_local(Vector2(0, 0))

onready var top_right = screen_to_local(Vector2(screen_size.x, 0))

onready var bottom_left = screen_to_local(Vector2(0, screen_size.y))

onready var bottom_right = screen_to_local(Vector2(screen_size.x, screen_size.y))

# Recalculates everything
func _ready():
	get_tree().get_root().connect("size_changed", self, "recalculate")

func recalculate():
	viewport = get_viewport()
	screen_size = get_viewport().get_visible_rect().size
	top_left = screen_to_local(Vector2(0, 0))
	top_right = screen_to_local(Vector2(screen_size.x, 0))
	bottom_left = screen_to_local(Vector2(0, screen_size.y))
	bottom_right = screen_to_local(Vector2(screen_size.x, screen_size.y))

# Converts a screen coordinate to a local one (e.g., Vector2( 0, 0 ) == top left of screen, so it gets the camera and gives the relative position in global 3d coordinates.
func screen_to_local(vector2):
	return viewport.get_camera().project_position(vector2, viewport.get_camera().translation.y)

# Converts a local coordinate to a screen one
func local_to_screen(vector3):
	return viewport.get_camera().unproject_position(vector3)


# Gets a random screen point and converts it to 3d coordinates
# Note that this depends on top_left.x < top_right.x and top_left.z < bottom_left.z
func random_screen_point(margin=0):
	return Vector3(
		rand_range(top_left.x+margin, top_right.x-margin), # X values
		0, # Y values
		rand_range(top_left.z+margin, bottom_left.z-margin)
	)


# Setting timeouts
func timeout(seconds=1): # Usage: yield(Utils.timeout(1), "timeout")
	return get_tree().create_timer(seconds)
