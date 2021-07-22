extends TextureProgress


# Variables
var target_value = 100


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process( delta ): # `value` and `target_value` must be integers for this to work or else you will be in a constant loop of the value going above and below the target value.
	
	if value + 1 == target_value: value += 1
	if value - 1 == target_value: value -= 1
	if value < target_value: value += 2
	if value > target_value: value -= 2
