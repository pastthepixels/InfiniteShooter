extends Spatial

export var health = 100

export var max_health = 100

func _ready():
	$Node2D.visible = visible

func _process(_delta):
	$Node2D.visible = visible
	$Node2D.position = Utils.local_to_screen(global_transform.origin)
	$Node2D/ProgressBar.value = health
	$Node2D/ProgressBar.max_value = max_health
