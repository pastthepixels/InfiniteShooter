extends GridMap

enum SLANT_TYPES {DOWN, UP, FLAT}

# touch this
export var boundsX = -8 # position from 0 that is where the bounds should be

export var margin = 2

# don't touch this
onready var depth = abs(Utils.top_left.z - Utils.bottom_left.z)

onready var max_width = floor(abs(Utils.top_left.x - boundsX - 0.5))

onready var min_width = max_width - margin

var width_array = []

var width_array_expanded = []

func _ready():
	translation = Utils.top_left
	
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
		width_array_expanded.append(main_width)
		width_array_expanded.append(main_width)
		width_array_expanded.append(main_width)



	for i in width_array_expanded.size():
		var slant = SLANT_TYPES.FLAT
		if i-1 >= 0 and width_array_expanded[i-1] < width_array_expanded[i]:
			slant = SLANT_TYPES.UP
		if i < width_array_expanded.size()-1 and width_array_expanded[i+1] < width_array_expanded[i]:
			slant = SLANT_TYPES.DOWN
		setRow(width_array_expanded[i], i, slant)

func setRow(width=4, z=0, slant=SLANT_TYPES.FLAT):
	for x in range(0, width):
		set_cell_item(x, 0, z, 0, 0)
		if x == width - 1:
			match slant:
				SLANT_TYPES.FLAT:
					set_cell_item(x, 0, z, 0, 0)
				SLANT_TYPES.DOWN:
					set_cell_item(x, 0, z, 1, 4)
				SLANT_TYPES.UP:
					set_cell_item(x, 0, z, 1, 12)
