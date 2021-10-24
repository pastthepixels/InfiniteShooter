extends Control

onready var game = get_parent()

onready var game_space = NodePath("../GameSpace")

onready var main = get_node("/root/Main")

export var disabled = false


func _ready():
	$SelectSquare.update()


func _input(event):
	if get_node(game_space).has_node("Player") == false or get_node(game_space).get_node("Player").health <= 0 or disabled == true:
		return
	
	if event.is_action_pressed("pause"):
		toggle_pause(true)

func _on_SelectSquare_selected():
	if is_visible():
		get_node(game_space).get_node("Player").ammo = 0  # To prevent the player from firing right as we unpause (since we are unpausing with the space bar)
		toggle_pause(false)
		disabled = true
		match $Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
			"Retry":  # If it is the one named "play", play the game.
				SceneTransition.restart_game()

			"Quit":  # Otherwise, quit the game
				SceneTransition.quit_game()

			"MainMenu":  # or return to the main menu
				SceneTransition.main_menu()


func toggle_pause(toggle_smoothly):
	if visible == true and toggle_smoothly == true:
		$Title.text = "not paused"
		$AnimationPlayer.play("FadeOut")
		yield($AnimationPlayer, "animation_finished")
	elif visible == false and toggle_smoothly == true:
		$AnimationPlayer.play("FadeIn")
		$Title.text = "paused"
	
	visible = !visible
	get_tree().paused = visible

	# If the screen isn't visible, you have resumed the game and thus a sound should be played. If it is, play a pause sound.
	if toggle_smoothly == true:
		if visible == false:
			$ResumeSound.play()
		if visible == true:
			$PauseSound.play()
