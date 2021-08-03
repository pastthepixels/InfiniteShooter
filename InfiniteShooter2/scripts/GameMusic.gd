extends AudioStreamPlayer


# Declare member variables here. Examples:
export (AudioStream) var main_menu_song
export (Array, AudioStream) var game_songs

func _ready():
	play_game()

# Called when the node enters the scene tree for the first time.
func play_main_menu():
	
	stream = main_menu_song
	play()

func play_game():
	
	crossfade( game_songs[ randi() % game_songs.size() ] )

func crossfade( audiostream ):
	
	$AnimationPlayer.play_backwards("fade")
	yield($AnimationPlayer, "animation_finished")
	stop()
	stream = audiostream
	play()
	$AnimationPlayer.play("fade")
