extends AudioStreamPlayer

# Declare member variables here. Examples:
export (AudioStream) var main_menu_song
export (Array, AudioStream) var game_songs

func _ready(): # Ensuring that NO SONG loops
	main_menu_song.set_loop(false)
	for song in game_songs: song.set_loop(false)

func play_main():
	stream = main_menu_song
	play()


func play_game():
	randomize()
	crossfade(game_songs[randi() % game_songs.size()])


func switch_game():
	stop()
	var old_stream = stream
	var new_stream = game_songs[randi() % game_songs.size()]
	if old_stream == new_stream:# Preventing duplicate songs
		switch_game()
	else:
		stream = new_stream
		play()


func crossfade(audiostream):
	$AnimationPlayer.play_backwards("fade")
	yield($AnimationPlayer, "animation_finished")
	stop()
	stream = audiostream
	play()
	$AnimationPlayer.play("fade")
