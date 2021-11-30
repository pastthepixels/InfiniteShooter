extends Control

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
	get_tree().change_scene_to(scene)


# Functions to actually switch scenes and stuff
func quit_game():
	open()
	yield(wait(), "completed")
	get_tree().quit()

func start_game():
	open()
	yield(wait(), "completed")
	call_deferred("_deferred_goto_scene", game_scene)
	close()

func restart_game():
	open()
	yield(wait(), "completed")
	get_tree().reload_current_scene()
	close()

func main_menu():
	open()
	yield(wait(), "completed")
	call_deferred("_deferred_goto_scene", menu_scene)
	close()
