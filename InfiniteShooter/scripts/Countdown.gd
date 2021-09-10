signal finished
extends Control

export var starting_number = 3


func _ready():
	show()
	for i in range(0, starting_number + 1): # Counts like this: 1, 2, 3
		if i == starting_number: # so once i reaches 3 or the starting number, we finish the countdown
			$FinishedSound.play()
		else: # otherwise we play a sound signifying that we are still counting down
			$CountdownSound.play()

		$Label.text = str(starting_number - i) # Because we count up, we need to turn that into counting down by subtracting i from the starting number
		if $Label.text != "0":
			$AnimationPlayer.play("show") # Now we fade in the text
			yield($AnimationPlayer, "animation_finished") # wait until that's done
			yield(get_tree().create_timer(.5), "timeout")  # and then wait a bit for you to be able to read the text
		else: # Special flashing of text if we reach zero
			$BackgroundFade.play("fade-background") # We also fade out the background
			for a in range(0, 3): # number of flashes
				$AnimationPlayer.stop(true)
				$AnimationPlayer.play("show") # Now we fade in the text
				yield(get_tree().create_timer(.4), "timeout")  # and then wait a bit for you to be able to read the text
	emit_signal("finished") # Once we are done the loop, we signal that we are done the countdown
	queue_free() # and then remove the countdown node
