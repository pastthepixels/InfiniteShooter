extends Node

signal loaded_game

onready var root = get_tree().get_root()

var game_scene = preload("res://scenes/game/Game.tscn")

var menu_scene = preload("res://scenes/menus/main/MainMenu.tscn")

func _ready():
	$CanvasLayer.hide()

func is_visible():
	return get_node("%SceneTransitionDoor/AnimationPlayer").is_playing() or get_node("%SceneTransitionDoor").visible


func open():
	Engine.time_scale = 1
	$CanvasLayer.show()
	$SoundEffect.pitch_scale = rand_range(0.9, 1.1)
	$SoundEffect.play()
	get_node("%SceneTransitionDoor/AnimationPlayer").play_backwards("Animation")

func close():
	get_node("%SceneTransitionDoor/AnimationPlayer").play("Animation")
	yield(get_node("%SceneTransitionDoor/AnimationPlayer"), "animation_finished")
	$CanvasLayer.hide()

func wait():
	yield(get_node("%SceneTransitionDoor/AnimationPlayer"), "animation_finished")
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
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
	close()
