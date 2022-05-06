extends Spatial

enum SLANT_TYPES {DOWN, UP, FLAT}

# touch this
export(float) var boundsX # position from 0 that is where the bounds should be

export(int) var margin

# don't touch this
onready var depth = abs(Utils.top_left.z - Utils.bottom_left.z)

onready var max_width = floor(abs(Utils.top_left.x - boundsX))

onready var min_width = max_width - margin

func _ready():
	# Left side
	var width_array_expanded = createWidthRows()
	$LeftWall.translation = Utils.top_left - Vector3(0.5, 0, 0)
	for i in width_array_expanded.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and width_array_expanded[i-1] < width_array_expanded[i]:
			slant = SLANT_TYPES.UP
		if i < width_array_expanded.size()-1 and width_array_expanded[i+1] < width_array_expanded[i]:
			slant = SLANT_TYPES.DOWN
		setLeftRow(width_array_expanded[i], i, slant)
	
	# Right side
	width_array_expanded = createWidthRows()
	$RightWall.translation = Utils.top_right
	for i in width_array_expanded.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and width_array_expanded[i-1] < width_array_expanded[i]:
			slant = SLANT_TYPES.UP
		if i < width_array_expanded.size()-1 and width_array_expanded[i+1] < width_array_expanded[i]:
			slant = SLANT_TYPES.DOWN
		setRightRow(width_array_expanded[i], i, slant)

func createWidthRows():
	var width_array = []
	var width_array_expanded = []
	var main_width = min_width + 1
	for i in range(0, ceil(depth/3.0)):
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

func setLeftRow(width=4, z=0, slant=SLANT_TYPES.FLAT):
	for x in range(0, width):
		$LeftWall.set_cell_item(x, 0, z, 0, 0)
		if x == width - 1:
			match slant:
				SLANT_TYPES.FLAT:
					$LeftWall.set_cell_item(x, 0, z, 0, 0)
				SLANT_TYPES.DOWN:
					$LeftWall.set_cell_item(x, 0, z, 1, 4)
				SLANT_TYPES.UP:
					$LeftWall.set_cell_item(x, 0, z, 1, 12)

func setRightRow(width=4, z=0, slant=SLANT_TYPES.FLAT):
	for x in range(0, width):
		$RightWall.set_cell_item(0-x, 0, z, 0, 0)
		if x == width - 1:
			match slant:
				SLANT_TYPES.FLAT:
					$RightWall.set_cell_item(0-x, 0, z, 0, 0)
				SLANT_TYPES.DOWN:
					$RightWall.set_cell_item(0-x, 0, z, 1, 6)
				SLANT_TYPES.UP:
					$RightWall.set_cell_item(0-x, 0, z, 1, 14)
