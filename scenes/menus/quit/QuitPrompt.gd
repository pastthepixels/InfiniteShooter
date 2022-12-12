extends Control

export(Array, String) var lines = []

export(String) var default_line

func _ready():
	$CanvasLayer.hide()

func quit_game():
	$CanvasLayer.show()
	if Saving.load_settings()["quit_dialog_lines"]:
		$CanvasLayer/FullAlert.alert(lines[rand_range(0, len(lines)-1)] + " (Press 'Yes' to quit.)", true)
	else:
		$CanvasLayer/FullAlert.alert(default_line, true)

func _on_FullAlert_confirmed():
	SceneTransition.quit_game()

func _process(_delta):
	if $CanvasLayer.visible:
		$CanvasLayer.visible = $CanvasLayer/FullAlert.visible
