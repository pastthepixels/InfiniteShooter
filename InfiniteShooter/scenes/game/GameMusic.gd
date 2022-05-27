extends AudioStreamPlayer

export(Array, AudioStream) var game_songs

export(bool) var autoswitch = true

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
	fade_out()
	yield($Tween, "tween_all_completed")
	stop()
	stream = audiostream
	play()
	fade_in()

# Switch game soundtrack (like looping for the game) if the user wants it
func _on_GameMusic_finished():
	if autoswitch == true: switch_game()

func fade_in(time=0.2):
	$Tween.interpolate_property(self, "volume_db",
		-20, 0, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func fade_out(time=0.2):
	$Tween.interpolate_property(self, "volume_db",
		0, -20, time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
