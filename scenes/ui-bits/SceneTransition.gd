extends Control

signal loaded_game

onready var root = get_tree().get_root()

var game_scene = preload("res://scenes/game/Game.tscn")

var menu_scene = preload("res://scenes/menus/main/MainMenu.tscn")

func _ready():
	VisualServer.canvas_item_set_z_index(get_canvas_item(), 100)  # Tells Godot that this will be drawn over absolutely anything and everything else -- this is a transition, after all.
	hide()


func open():
	show()
	$SoundEffect.pitch_scale = rand_range(0.9, 1.1)
	$SoundEffect.play()
	$AnimationPlayer.play("In")

func close():
	$AnimationPlayer.play("Out")
	yield($AnimationPlayer, "animation_finished")
	hide()

func wait():
	yield($AnimationPlayer, "animation_finished")
	yield(get_tree(), "idle_frame")

func _deferred_goto_scene(scene):
	return get_tree().change_scene_to(scene)


# Functions to actually switch scenes and stuff
func quit_game():
	open()
	yield(wait(), "completed")
	get_tree().quit()

func start_game():
	open()
	yield(wait(), "completed")
	call_deferred("_deferred_goto_scene", game_scene)
	yield(get_tree(), "idle_frame") # Wait until the scene has been switched to close
	emit_signal("loaded_game")
	close()

func continue_game():
	start_game()
	yield(self, "loaded_game")
	Saving.load_game()

func restart_game():
	open()
	yield(wait(), "completed")
	var _shut_up_about_return_values = get_tree().reload_current_scene()
	close()

func main_menu():
	open()
	yield(wait(), "completed")
	call_deferred("_deferred_goto_scene", menu_scene)
	close()
