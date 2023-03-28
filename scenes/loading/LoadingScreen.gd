extends Spatial

export var file_path = "res://scenes/entities/" # Has to have that forward slash

var scenes = []

func _ready():
	# Auto-disabling
	if has_node("/root/MainMenu") == false and has_node("/root/Game") == false:
		disable()
		return
	disable_settings()
	$InitTimer.start()

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
				print_to_gui("Loaded scene %s/%s" % [path, file_name])
			file_name = dir.get_next()
	else:
		print_to_gui(
			"An error occurred when trying to access the path '%s'." % path,
			"[color=#FF0000]An error occurred when trying to access the path '%s'.[/color]" % path
			)

func instance_scenes_then_quit():
	var progress = 0
	for scene_path in scenes:
		yield(get_tree(), "idle_frame")
		$Cover/Label/ProgressBar.max_value = len(scenes) - 1
		$Cover/Label/ProgressBar.value = progress
		progress += 1
		#
		var scene = scene_path.instance()
		if scene.is_in_group("lasers"):
			scene.sender = self
		$Instances.add_child(scene)
		if scene.is_in_group("enemies") or scene.is_in_group("bosses"):
			scene.initialize(1)
			if scene.is_in_group("enemies"): scene._on_LaserTimer_timeout()
			#scene.explode_ship()
		if scene.is_in_group("players"):
			scene.fire_laser()
		if scene.is_in_group("explosions"):
			scene.explode()
		print_to_gui(
			"Cached scene %s" % scene_path.resource_path,
			"[b]Cached scene %s[/b]" % scene_path.resource_path
			)
	$ExitTimer.start()

func _on_ExitTimer_timeout():
	# Hides everything but still runs in the background so we can access scenes
	$Instances.queue_free()
	$AnimationPlayer.play("FadeOut")
	hide()

func disable_settings():
	$Cover/Label/ProgressBar.value = 0
	get_node("%Stats").visible = Saving.load_settings(File.new())["load_screen_live_log"]
	get_tree().paused = true
	CameraEquipment.get_node("ShakeCamera").ignore_shake = true
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func restore_settings(): # Retore settings we disabled
	get_tree().paused = false
	CameraEquipment.get_node("ShakeCamera").ignore_shake = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

func disable():
	get_tree().paused = false
	CameraEquipment.get_node("ShakeCamera").ignore_shake = false
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	queue_free()

func access_scene(path):
	for scene_path in scenes:
		if scene_path.resource_path == path:
			return scene_path
	return load(path)

func print_to_gui(string, bbcode_text=null): # Prints to stdout and to the GUI
	print(string)
	if bbcode_text == null:
		get_node("%Stats").bbcode_text += ("\n" if get_node("%Stats").text != "" else "") + string
	else:
		get_node("%Stats").bbcode_text += ("\n" if get_node("%Stats").bbcode_text != "" else "") + bbcode_text
