extends Control

signal finished

export var duration = 3 # In seconds

export var popup_duration = .5 # Amount of time to wait after each "popup"'s animation (in seconds)


func start():
	for i in range(0, duration + 1): # Counts like this: 1, 2, 3
		$Label.text = str(duration - i) # Because we count up, we need to turn that into counting down by subtracting i from the starting number
		if $Label.text != "0":
			$AnimationPlayer.play("show") # Now we fade in the text
			$CountdownSound.play()
			yield($AnimationPlayer, "animation_finished") # wait until that's done
			yield(get_tree().create_timer(popup_duration), "timeout")  # and then wait a bit for you to be able to read the text
		else: # Special flashing of text if we reach zero
			$BackgroundFade.play("fade")
			for _flash in range(0, 3): # number of flashes
				if _flash == 2:
					$BackgroundFade.play("fadeall")
				$FinishedSound.play()
				$AnimationPlayer.stop(true)
				$AnimationPlayer.play("show") # Now we fade in the text
				yield(get_tree().create_timer(popup_duration/2), "timeout")  # and then wait a bit for you to be able to read the text
	emit_signal("finished") # Once we are done the loop, we signal that we are done the countdown
	queue_free() # and then remove the countdown node
