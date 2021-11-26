#
# Modified (very slightly) from https://kidscancode.org/godot_recipes/2d/screen_shake/
#
extends Camera2D

export var decay = 0.8  # How quickly the shaking stops [0, 1].

export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.

export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

export (NodePath) var target  # Assign the node this camera will follow.

var trauma = 0.0  # Current shake strength.

export var max_trauma = 1.0 # Max shake strength.

var trauma_power = 2  # Trauma exponent. Use [2, 3].

onready var noise = OpenSimplexNoise.new()

var noise_y = 0


func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2


func add_trauma(amount):
	print(amount)
	trauma = min(trauma + amount, max_trauma)


func _process(delta):
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()


func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)
	
	# Added code to work with 3d stuff
	get_parent().translation = Vector3()
	get_parent().translation = Utils.screen_to_local(global_position+offset) + Vector3()
	get_parent().rotation.y = rotation
