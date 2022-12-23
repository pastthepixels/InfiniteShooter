extends AudioStreamPlayer

export(Array, AudioStream) var game_songs

export(bool) var autoswitch = true

var previous_game_songs = []

func _ready(): # Ensuring that NO SONG loops the same
	randomize()
	for song in game_songs: song.set_loop(false)

# Ensures that each song has at least len(game_songs) before it can be heard again
func pick_game_song():
	# Clears previous_game_songs if full (every len(game_songs))
	if len(previous_game_songs) == len(game_songs):
		previous_game_songs = []
	
	var game_song = game_songs[randi() % game_songs.size()]
	
	# Calls the function (recursively) if the song already has been played before
	if game_song in previous_game_songs:
		return pick_game_song()
		
	# Otherwise adds the song to previous_game_songs
	previous_game_songs.append(game_song)
	
	return game_song


func start_game():
	crossfade(pick_game_song())



func switch_game():
	stop()
	var old_stream = stream
	var new_stream = pick_game_song()
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
