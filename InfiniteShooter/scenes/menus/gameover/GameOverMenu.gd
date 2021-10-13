extends Control

onready var game = get_parent()
onready var game_space = get_node("." + game.game_space)
onready var main = get_node("/root/Main")


# Called when the node enters the scene tree for the first time.
func fade_show():
	show()
	$AnimationPlayer.play("FadeAll")
	$SelectSquare.update()


func _on_SelectSquare_selected():
	match $Options.get_child($SelectSquare.index).name:  # Now we see which option has been selected...
		"Retry":  # If it is the one named "play", play the game.
			SceneTransition.play(self, "restart_game")

		"Quit":  # Otherwise, quit the game
			SceneTransition.play(self, "quit_game")

		"MainMenu":  # or return to the main menu
			SceneTransition.play(self, "main_menu")


func restart_game():
	game.queue_free()
	main.remove_child(game)  # Removes the node "Game" from the main menu
	main.add_child(load("res://scenes/Game.tscn").instance())  # adds a new game node


func quit_game():
	get_tree().quit()


func main_menu():
	game.queue_free()
	main.remove_child(game)  # Removes the node "Game" from the main menu
	main.add_child(load("res://scenes/menus/main/MainMenu.tscn").instance())  # adds a new menu node
