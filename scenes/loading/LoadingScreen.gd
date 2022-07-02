extends Spatial

export var file_path = "res://scenes/entities/" # Has to have that forward slash

var scenes = []

func _ready():
	get_tree().paused = true
	CameraEquipment.get_node("ShakeCamera").ignore_shake = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

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
	var progress = 0
	for scene_path in scenes:
		yield(get_tree(),"idle_frame")
		$Cover/Label/ProgressBar.max_value = len(scenes) - 1
		$Cover/Label/ProgressBar.value = progress
		progress += 1
		#
		var scene = scene_path.instance()
		if scene.is_in_group("enemies") or scene.is_in_group("bosses"):
			scene.initialize(1)
			if scene.is_in_group("enemies"): scene._on_LaserTimer_timeout()
			scene.explode_ship()
		if scene.is_in_group("players"):
			scene.fire_laser()
		if scene.is_in_group("explosions"):
			scene.explode()
		$Instances.add_child(scene)
	$ExitTimer.start()

func _on_ExitTimer_timeout():
	get_tree().paused = false
	CameraEquipment.get_node("ShakeCamera").ignore_shake = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	
	# Hides everything but still runs in the background so we can access scenes
	$Instances.queue_free()
	$AnimationPlayer.play("FadeOut")
	hide()

func access_scene(path):
	for scene_path in scenes:
		if scene_path.resource_path == path:
			return scene_path
	return load(path)
