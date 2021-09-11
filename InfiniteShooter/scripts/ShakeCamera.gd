#
# Modified (very slightly) from https://kidscancode.org/godot_recipes/2d/screen_shake/
#
extends Camera2D

export (NodePath) var three_camera # Any 3D camera that also needs to be shaken.

export var decay = 0.8  # How quickly the shaking stops [0, 1].

export var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.

export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

export (NodePath) var target  # Assign the node this camera will follow.

var trauma = 2.0  # Current shake strength.

var trauma_power = 2  # Trauma exponent. Use [2, 3].

onready var noise = OpenSimplexNoise.new()

var noise_y = 0


func _ready():
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2


func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)


func _process(delta):
	if target:
		global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()
	if three_camera:
		get_node(three_camera).translation.x = offset.x
		get_node(three_camera).translation.z = offset.y
		get_node(three_camera).rotation.y = rotation


func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * rand_range(-1, 1)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)
