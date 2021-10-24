extends Control

onready var root = get_tree().get_root()

enum CALLBACKS { quit_game, start_game, return_to_menu, restart_game }

var callback

var current_scene = null

func _ready():
	current_scene = root.get_child(root.get_child_count() - 1)
	hide()
	VisualServer.canvas_item_set_z_index(get_canvas_item(), 100)  # Tells Godot that this will be drawn over absolutely anything and everything else -- this is a transition, after all.


func animate():
	show()
	$SoundEffect.pitch_scale = rand_range(0.9, 1.1)
	$SoundEffect.play()
	$AnimationPlayer.play("In")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"In":
			match callback:
				CALLBACKS.start_game:
					call_deferred("_switch_scene", "res://scenes/game/Game.tscn")
				CALLBACKS.return_to_menu:
					call_deferred("_switch_scene", "res://scenes/menus/main/MainMenu.tscn")
				CALLBACKS.quit_game:
					get_tree().quit()
				CALLBACKS.restart_game:
					get_tree().reload_current_scene()
			$AnimationPlayer.play("Out")
		"Out":
			hide()

func _switch_scene(path):
	get_tree().change_scene(path)

# Functions to actually switch scenes and stuff
func quit_game():
	callback = CALLBACKS.quit_game
	animate()

func start_game():
	callback = CALLBACKS.start_game
	animate()

func restart_game():
	callback = CALLBACKS.restart_game
	animate()

func main_menu():
	callback = CALLBACKS.return_to_menu
	animate()
