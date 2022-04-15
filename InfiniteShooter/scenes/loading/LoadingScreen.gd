extends Spatial

export var file_path = "res://scenes/entities/" # Has to have that forward slash

var scenes = []

func _ready():
	get_tree().paused = true

func _on_InitTimer_timeout():
	loop_scenes(file_path)
	instance_scenes_then_quit()

func loop_scenes(path): # from https://docs.godotengine.org/en/3.1/classes/class_directory.html
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if dir.current_is_dir() and ("." in file_name) == false:
				loop_scenes(path + file_name)
			elif ".tscn" in file_name:
				scenes.append(load(path + "/" + file_name))
				print("Loaded scene " + path + "/" + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func instance_scenes_then_quit():
	for scene_path in scenes:
		var scene = scene_path.instance()
		if scene.is_in_group("enemies"):
			scene.initialize(1)
		if scene.is_in_group("explosions"):
			scene.explode()
		scene.set_pause_mode(PAUSE_MODE_STOP)
		add_child(scene)
		$Timer.start()
		yield($Timer, "timeout")
		scene.queue_free()
	$Timer.start()
	yield($Timer, "timeout")
	get_tree().paused = false
	# Hides everything but still runs in the background so we can access scenes
	$Cover.queue_free()
	hide()

func access_scene(path):
	for scene_path in scenes:
		if scene_path.resource_path == path:
			return scene_path
	return load(path)
