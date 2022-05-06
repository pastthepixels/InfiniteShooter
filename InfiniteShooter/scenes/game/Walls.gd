extends Spatial

enum SLANT_TYPES {DOWN, UP, FLAT}

# touch this
export(Vector2) var bounds # Positive vector of bounds from center

export(int) var max_width = 4

export(int) var min_width = 2

# don't touch this
var buffer_space

onready var left_array = create_width_rows()

onready var right_array = create_width_rows()

func _ready():
	set_tiles()
	get_tree().get_root().connect("size_changed", self, "set_tiles")

func set_tiles():
	visible = (OS.window_size != Vector2(1067, 800))
	$LeftWall.clear()
	$RightWall.clear()
	$LeftWall.translation = Vector3(-bounds.x, 0, -bounds.y)
	$RightWall.translation = Vector3(bounds.x, 0, -bounds.y)
	buffer_space = floor(abs(Utils.top_left.x - bounds.x)) - max_width + 1
	# Left side
	for i in left_array.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and left_array[i-1] < left_array[i]:
			slant = SLANT_TYPES.UP
		if i < left_array.size()-1 and left_array[i+1] < left_array[i]:
			slant = SLANT_TYPES.DOWN
		set_left_row(left_array[i], i, slant)
	
	# Right side
	for i in right_array.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and right_array[i-1] < right_array[i]:
			slant = SLANT_TYPES.UP
		if i < right_array.size()-1 and right_array[i+1] < right_array[i]:
			slant = SLANT_TYPES.DOWN
		set_right_row(right_array[i], i, slant)

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
		for length in range(0, 3): width_array_expanded.append(main_width)
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
