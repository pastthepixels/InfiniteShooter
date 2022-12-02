extends Control

export(Array, String) var lines = []

func _ready():
	$CanvasLayer.hide()

func quit_game():
	$CanvasLayer.show()
	$CanvasLayer/FullAlert.alert(lines[rand_range(0, len(lines)-1)], true)

func _on_FullAlert_confirmed():
	SceneTransition.quit_game()

func _process(_delta):
	if $CanvasLayer.visible:
		$CanvasLayer.visible = $CanvasLayer/FullAlert.visible
