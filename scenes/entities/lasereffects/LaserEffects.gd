extends Spatial

export(NodePath) var ship

var resetting = false

export var emission_radius = .8

export var disabled = false

signal finished_reset

var sender # The sender of the laser that hits `ship`

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
	if disabled == true or get_parent().health <= 0: return
	$FireSound.play()
	$Fire.emitting = true


func start_corrosion():
	if disabled == true or get_parent().health <= 0: return
	$CorrosionSound.play()
	$Corrosion.emitting = true

func start_ice():
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
	$IceSound.stop()
	$FireSound.stop()
	$CorrosionSound.stop()
	emit_signal("finished_reset")
	resetting = false
