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
	if $FireSound.playing == false: $FireSound.play()
	$Fire.emitting = true


func start_corrosion():
	if $CorrosionSound.playing == false: $CorrosionSound.play()
	$Corrosion.emitting = true

func start_ice():
	if $IceSound.playing == false: $IceSound.play()
	$Ice.emitting = true


# Timer stuff and resetting
func _on_BleedTimer_timeout():
	if get_node(ship).health > 0:
		get_node(ship).health -= 5
	else:
		$AnimationPlayer.play("fade_sounds")


func _on_Timer_timeout():
	$BleedTimer.stop()
	reset()

func reset():
	get_parent().freeze_movement = false
	$Fire.emitting = false
	$Corrosion.emitting = false
	$Ice.emitting = false
	$FireSound.stop()
	$IceSound.stop()
	$CorrosionSound.stop()
	sender = null
