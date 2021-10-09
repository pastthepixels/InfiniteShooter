signal finished
extends Control

export var starting_number = 3


func _ready():
	get_node("../PauseMenu").disabled = true
	show()
	for i in range(0, starting_number + 1): # Counts like this: 1, 2, 3
		$Label.text = str(starting_number - i) # Because we count up, we need to turn that into counting down by subtracting i from the starting number
		if $Label.text != "0":
			$AnimationPlayer.play("show") # Now we fade in the text
			$CountdownSound.play()
			yield($AnimationPlayer, "animation_finished") # wait until that's done
			yield(get_tree().create_timer(.5), "timeout")  # and then wait a bit for you to be able to read the text
		else: # Special flashing of text if we reach zero
			$BackgroundFade.play("fade-background") # We also fade out the background
			for _flash in range(0, 3): # number of flashes
				$FinishedSound.play()
				$AnimationPlayer.stop(true)
				$AnimationPlayer.play("show") # Now we fade in the text
				yield(get_tree().create_timer(.3), "timeout")  # and then wait a bit for you to be able to read the text
	get_node("../PauseMenu").disabled = false
	emit_signal("finished") # Once we are done the loop, we signal that we are done the countdown
	queue_free() # and then remove the countdown node
