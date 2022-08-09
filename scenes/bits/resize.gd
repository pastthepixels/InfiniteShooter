extends Node

onready var original_size = OS.window_size

func _ready():
	OS.set_min_window_size(original_size)
	# warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_on_screen_resized")

func _on_screen_resized(): # Draws bars across the top and bottom of the window
	var new_size = Vector2(OS.window_size.y * original_size.aspect(), OS.window_size.y)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP_HEIGHT, new_size)
