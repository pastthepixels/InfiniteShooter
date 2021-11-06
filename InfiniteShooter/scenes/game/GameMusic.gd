extends AudioStreamPlayer

export (Array, AudioStream) var game_songs

func _ready(): # Ensuring that NO SONG loops the same
	randomize()
	for song in game_songs: song.set_loop(false)


func start_game():
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

# Switch game soundtrack (like looping for the game) if the user wants it
func _on_GameMusic_finished():
	switch_game()
