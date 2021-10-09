extends Spatial

export (NodePath) var ship

export var emission_radius = .8

func _ready():
	$Fire.process_material.emission_sphere_radius = emission_radius

func bleed(wait_time, duration):
	$BleedTimer.wait_time = wait_time
	$BleedTimer.start()
	$Timer.wait_time = duration
	$Timer.start()
	$Fire.emitting = true


func _on_BleedTimer_timeout():
	if get_node(ship).health > 0:
		get_node(ship).health -= 5
	else:
		$Fire.emitting = false


func _on_Timer_timeout():
	$Fire.emitting = false
	$BleedTimer.stop()
