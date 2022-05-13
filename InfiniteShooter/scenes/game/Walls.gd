extends Spatial

# touch this
export(Vector2) var bounds # Positive vector of bounds from center

export(int) var max_width = 4

export(int) var min_width = 2

export(float) var speed

# don't touch this
enum SLANT_TYPES {DOWN, UP, FLAT}

var buffer_space

onready var left_array = create_width_rows()

onready var right_array = create_width_rows()

func _ready():
	# Set the translation of the walls so they are on the top edges of the screen.
	$LeftWall.translation = Vector3(-bounds.x, 0, -bounds.y)
	$RightWall.translation = Vector3(bounds.x, 0, -bounds.y)
	# Then, fill them with thiles. Ensure that whenever the screen size is changed the tiles are filled again to fit the new screen size.
	set_tiles()
	get_tree().get_root().connect("size_changed", self, "set_tiles")

func set_tiles():
	# Only show the tiles if the size of the screen isn't what's default.
	visible = (OS.window_size != Vector2(1067, 800))
	# Once again, ensure that the walls are on the top edges of the screen, and clear them.
	$LeftWall.translation.x = -bounds.x
	$RightWall.translation.x = bounds.x
	$LeftWall.clear()
	$RightWall.clear()
	# What is buffer_space?
	# In short, that slanty bit you see at the end of the walls is what is being generated
	# and is only as thick as specified by min_width and max_width. So the rest of the space
	# between the walls and the edges of the screen is space we need to fill.
	# That takes us to buffer_space. It's the distance from the edges of the walls to the
	# edges of the screen, in 3d space.
	buffer_space = floor(abs(Utils.top_left.x - bounds.x)) - max_width + 1
	# Draws left tiles
	for i in left_array.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and left_array[i-1] < left_array[i]:
			slant = SLANT_TYPES.UP
		if i < left_array.size()-1 and left_array[i+1] < left_array[i]:
			slant = SLANT_TYPES.DOWN
		set_left_row(left_array[i], i, slant)
		# Draws the same row, but above the wall. That way, we can scroll down to this second half
		# and just reset our position when the wall gets low enough. Infinite scrolling achieved.
		set_left_row(left_array[i], -left_array.size() + i, slant)
		# Draws a sort of "bleed" because, in short, we can actually see the bottom of the walls and there would be some flickering when we wrap them around
		if i == left_array.size() - 1: set_left_row(left_array[i], -left_array.size() - 1, slant)
	
	# Draws right tiles
	for i in right_array.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and right_array[i-1] < right_array[i]:
			slant = SLANT_TYPES.UP
		if i < right_array.size()-1 and right_array[i+1] < right_array[i]:
			slant = SLANT_TYPES.DOWN
		set_right_row(right_array[i], i, slant)
		# Draws UP
		set_right_row(right_array[i], -right_array.size() + i, slant)
		if i == right_array.size() - 1: set_right_row(right_array[i], -right_array.size() - 1, slant)

# Here we create an array called width_array, where each number is different from the previous
# but only by 1 or -1. Then we "expand" that array so each number represents three rows that
# are drawn.
func create_width_rows():
	var width_array = []
	var width_array_expanded = []
	var main_width = min_width + 1
	for i in range(0, ceil((bounds.y*2)/3.0)):
		var delta_width = 1 if (randi() & 1 == 1) else -1
		# Preventing lines at the minimum/maximum width
		if(i-1 >= 0 and width_array[i-1] == min_width): delta_width = 1
		if(i-1 >= 0 and width_array[i-1] == max_width): delta_width = -1
		# Preventing a "checkerboard" effect at the caps
		if(i-2 >= 0 and width_array[i-2] == max_width and width_array[i-1] == max_width - 1): delta_width = -1
		if(i-2 >= 0 and width_array[i-2] == min_width and width_array[i-1] == max_width + 1): delta_width = 1 
		#
		main_width += delta_width
		main_width = clamp(main_width, min_width, max_width)
		width_array.append(main_width)
		#
		for _length in range(0, 3): width_array_expanded.append(main_width)
	# so the array can loop
	while main_width != width_array[0]:
		main_width += 1 if main_width < width_array[0] else -1
		width_array.append(main_width)
		#
		for _length in range(0, 3): width_array_expanded.append(main_width)
	return width_array_expanded

func set_left_row(width=4, z=0, slant=SLANT_TYPES.FLAT):
	for x in range(0, width):
		$LeftWall.set_cell_item(x-max_width, 0, z, 0, 0)
		if x == width - 1:
			match slant:
				SLANT_TYPES.FLAT:
					$LeftWall.set_cell_item(x-max_width, 0, z, 0, 0)
				SLANT_TYPES.DOWN:
					$LeftWall.set_cell_item(x-max_width, 0, z, 1, 4)
				SLANT_TYPES.UP:
					$LeftWall.set_cell_item(x-max_width, 0, z, 1, 12)
	
	for x in range(0, buffer_space):
		$LeftWall.set_cell_item(-x-max_width, 0, z, 0, 0)

func set_right_row(width=4, z=0, slant=SLANT_TYPES.FLAT):
	for x in range(0, width):
		$RightWall.set_cell_item(max_width-x, 0, z, 0, 0)
		if x == width - 1:
			match slant:
				SLANT_TYPES.FLAT:
					$RightWall.set_cell_item(max_width-x, 0, z, 0, 0)
				SLANT_TYPES.DOWN:
					$RightWall.set_cell_item(max_width-x, 0, z, 1, 6)
				SLANT_TYPES.UP:
					$RightWall.set_cell_item(max_width-x, 0, z, 1, 14)
	
	for x in range(0, buffer_space):
		$RightWall.set_cell_item(max_width+x, 0, z, 0, 0)

# movemtn (sic)
func _physics_process(delta):
	var delta_translation = speed * delta * CameraEquipment.get_node("SkyAnimations").playback_speed
	$LeftWall.translation.z = -bounds.y if $LeftWall.translation.z >= left_array.size()-bounds.y else $LeftWall.translation.z + delta_translation
	$RightWall.translation.z = -bounds.y if $RightWall.translation.z >= right_array.size()-bounds.y else $RightWall.translation.z + delta_translation
