extends Spatial

export(NodePath) var ship

export var emission_radius = .8

var sender # The sender of the laser that hits `ship`

func _ready():
	$Fire.process_material.emission_sphere_radius = emission_radius
	$Corrosion.process_material.emission_sphere_radius = emission_radius
	$Ice.process_material.emission_sphere_radius = emission_radius

# Main functions
func bleed(wait_time, duration):
	$BleedTimer.wait_time = wait_time
	$BleedTimer.start()
	$Timer.wait_time = duration
	$Timer.start()

func freeze(duration):
	get_parent().freeze_movement = true
	$Timer.wait_time = duration
	$Timer.start()


# Particle effects
func start_fire():
	$Fire.emitting = true


func start_corrosion():
	$Corrosion.emitting = true

func start_ice():
	$Ice.emitting = true


# Timer stuff and resetting
func _on_BleedTimer_timeout():
	if get_node(ship).health > 0:
		get_node(ship).health -= 5
		if sender != null and get_node(ship).is_in_group("enemies"):
			get_node(ship).last_hit_from = sender
	if get_node(ship).is_in_group("players"):
		get_node(ship).update_hud()


func _on_Timer_timeout():
	$BleedTimer.stop()
	reset()

func reset():
	get_parent().freeze_movement = false
	$Fire.emitting = false
	$Corrosion.emitting = false
	$Ice.emitting = false
	sender = null
