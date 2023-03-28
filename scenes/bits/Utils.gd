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
	# warning-ignore:return_value_discarded
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

func screen_to_local_custom_camera(camera, vector2): # There's no method overloading in GDScript :(
	return camera.project_position(vector2, camera.translation.y)

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

# True-feeling random
var previous_rand_numbers = [0, 0, 0]
func true_rand_range(min_num, max_num):
	var rand = rand_range(min_num, max_num)
	if rand in previous_rand_numbers:
		pass
	previous_rand_numbers.push_front(rand)
	previous_rand_numbers.remove(0)
	return rand

# Setting timeouts
func timeout(seconds=1): # Usage: yield(Utils.timeout(1), "timeout")
	return get_tree().create_timer(seconds)

# Hacked together function to do some basic sorting
# Modified from https://godotengine.org/qa/28998/how-do-i-sort-a-scroll-containers-contents
func sort_container(box_container, node_with_function, function):
	var child_list = box_container.get_children()
	var num_children = child_list.size()
	for ii in range(0, num_children):
		for i in range(0, num_children):
			if i+1 < num_children:
				if node_with_function.call(function, box_container.get_child(i), box_container.get_child(i+1)) == true:
					box_container.move_child(box_container.get_child(i+1),i)

# Matching variable types (used in Saving.gd
func match_variable_types(original, value):
	match typeof(original):
		TYPE_NIL:
			return null
		TYPE_BOOL:
			return bool(value)
		TYPE_INT:
			return int(value)
		TYPE_REAL:
			return float(value)
		TYPE_STRING:
			return str(value)
		TYPE_ARRAY:
			for i in value.size():
				value[i] = match_variable_types(original[i if i in original else -1], value[i])
			return value
		_:
			return value

# Recursive until it finds a parent that is an entity
func get_parent_entity(node):
	if node.is_in_group("entities"):
		return node
	elif node.get_parent() == null:
		return null
	else:
		return get_parent_entity(node.get_parent())
