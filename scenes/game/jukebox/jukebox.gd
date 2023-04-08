extends Spatial

export var beat_high_threshold = 0.5

export var beat_low_threshold = 0.4

var spectrum

var low_beat = false

var MIN_DB = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	spectrum = AudioServer.get_bus_effect_instance(0,0)
	get_node("WarpPlane/AnimationPlayer").play("Make visible")
	$GameMusic.start_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $GameMusic.stream != null: $Label.text = $GameMusic.stream.resource_path.get_file().get_basename()
	
	# Rotates the title
	$title.rotation.x += 1 * delta
	$title.rotation.y += 0.5 * delta
	$title.rotation.z += 2 * delta
	
	# Shakes the camera when there's a kick
	var f = spectrum.get_magnitude_for_frequency_range(0, 60)
	var energy = clamp((MIN_DB + linear2db(f.length()))/MIN_DB,0,1)
	if energy > beat_high_threshold and low_beat == false:
		low_beat = true
		animate_kick()
	if energy < beat_low_threshold and low_beat == true:
		low_beat = false

func animate_kick():
	CameraEquipment.get_node("ShakeCamera").add_trauma(.15)

func _input(event):
	if event.is_action_pressed("shoot_laser"):
		_on_ChangeSong_pressed()


func _on_Back_pressed():
	SceneTransition.main_menu()


func _on_ChangeSong_pressed():
	$GameMusic.switch_game()
