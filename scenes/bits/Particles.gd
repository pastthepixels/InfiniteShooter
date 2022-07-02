extends Particles

# Basically just adds a new event for when one-shot particle systems are done emitting.
signal finished
var already_emitted_signal = false

func _process(_delta):
	if one_shot == true and emitting == false and already_emitted_signal == false:
		emit_signal("finished")
		already_emitted_signal = false
	if emitting == true and already_emitted_signal == true:
		already_emitted_signal = false
