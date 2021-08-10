extends Control

signal settings_changed
var settings = {"antialiasing": true, "bloom": true}

func show_animated():
	show()
	$AnimationPlayer.play("open")

func hide_animated():
	$AnimationPlayer.play_backwards("open")
	yield($AnimationPlayer, "animation_finished")
	hide()

# To handle when something is selected -- all input starts from the main menu but go over here for the [OPTIONS] screen
func handle_selection():
	match $VBoxContainer/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"Back":
			hide_animated()
			get_node("../SelectSquare").show()

# To handle percentage inputs/save settings on input
func _input(event):
	if visible == true: set_settings()
	match $VBoxContainer/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"MusicVolume":
			if event.is_action_pressed( "ui_left" ):
				$VBoxContainer/Options/MusicVolume/TextureProgress.value -= 10
				$SelectSquare/AcceptSound.play()
			if event.is_action_pressed( "ui_right" ):
				$VBoxContainer/Options/MusicVolume/TextureProgress.value += 10
				$SelectSquare/AcceptSound.play()
		
		"SFXVolume":
			if event.is_action_pressed( "ui_left" ):
				$VBoxContainer/Options/SFXVolume/TextureProgress.value -= 10
				$SelectSquare/AcceptSound.play()
			if event.is_action_pressed( "ui_right" ):
				$VBoxContainer/Options/SFXVolume/TextureProgress.value += 10
				$SelectSquare/AcceptSound.play()

# To save/set settings
func set_settings():
	
	emit_signal( "settings_changed", {
		"musicvol": $VBoxContainer/Options/MusicVolume/TextureProgress.value,
		"sfxvol": $VBoxContainer/Options/SFXVolume/TextureProgress.value,
		"antialiasing": settings["antialiasing"],
		"bloom": settings["bloom"]
	} )
