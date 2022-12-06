extends Spatial

enum EFFECTS { corrosion, fire, ice }

export(NodePath) var ship

export var emission_radius = .8

export var disabled = false

signal finished_reset

var current_effect : int = -1

var resetting = false

var sender # The sender of the laser that hits `ship`

# Saving/loading
func save():
	return {
		"current_effect": current_effect,
		"duration": $Timer.time_left,
		"wait_time": $BleedTimer.wait_time
	}

func load_save(save): # See the above function for what "save" is exactly
	match(int(save["current_effect"])):
		EFFECTS.corrosion:
			bleed(save["wait_time"], save["duration"])
			start_corrosion()
		
		EFFECTS.fire:
			bleed(save["wait_time"], save["duration"])
			start_fire()
		
		EFFECTS.ice:
			freeze(save["wait_time"])
			start_ice()

func _ready():
	$Fire.process_material.emission_sphere_radius = emission_radius
	$Corrosion.process_material.emission_sphere_radius = emission_radius
	$Ice.process_material.emission_sphere_radius = emission_radius

# Main functions
func bleed(wait_time, duration):
	if disabled == true or get_parent().health <= 0: return
	$BleedTimer.wait_time = wait_time
	$BleedTimer.start()
	$Timer.wait_time = duration
	$Timer.start()

func freeze(duration):
	if disabled == true or get_parent().health <= 0: return
	get_parent().freeze_movement = true
	$Timer.wait_time = duration
	$Timer.start()


# Particle effects
func start_fire():
	current_effect = EFFECTS.fire
	print(current_effect)
	if disabled == true or get_parent().health <= 0: return
	$FireSound.play()
	$Fire.emitting = true


func start_corrosion():
	current_effect = EFFECTS.corrosion
	print(current_effect)
	if disabled == true or get_parent().health <= 0: return
	$CorrosionSound.play()
	$Corrosion.emitting = true

func start_ice():
	current_effect = EFFECTS.ice
	if disabled == true or get_parent().health <= 0: return
	$IceSound.play()
	$Ice.emitting = true


# Timer stuff and resetting
func _on_BleedTimer_timeout():
	if get_node(ship).health > 0:
		if get_node(ship).is_in_group("bosses"):
			get_node(ship).health -= (get_node(ship).max_health * .01)
		else:
			get_node(ship).health -= (get_node(ship).max_health * .05)
	else:
		$AnimationPlayer.play("fade_sounds")


func _on_Timer_timeout():
	$BleedTimer.stop()
	reset()

func reset():
	resetting = true
	current_effect = -1
	if "freeze_movement" in get_parent(): get_parent().freeze_movement = false
	$ResetMaxTimer.start()
	$Fire.emitting = false
	$Corrosion.emitting = false
	$Ice.emitting = false
	if $AnimationPlayer.is_playing() == false and $IceSound.playing == true or $FireSound.playing == true or $CorrosionSound.playing == true:
		$AnimationPlayer.play("fade_sounds")
		yield($AnimationPlayer, "animation_finished")
	if get_tree() != null: yield(get_tree(), "idle_frame")
	emit_signal("finished_reset")
	resetting = false


func _on_ResetMaxTimer_timeout():
	current_effect = -1
	$IceSound.stop()
	$FireSound.stop()
	$CorrosionSound.stop()
	emit_signal("finished_reset")
	resetting = false
