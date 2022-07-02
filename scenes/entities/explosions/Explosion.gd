extends Spatial

export var auto_explode = false

export var auto_delete = true

export var shockwave = true

export var sound = true

export var particles = true


export(float, 0, 1) var opacity = 1

onready var original_transform = get_global_transform()

signal exploded

func _ready():
	$ExplosionAnimation.opacity = opacity
	if auto_explode == true:
		explode()

func explode():
	$AnimationPlayer.stop()
	# Vibrates the first controller and shakes the screen
	if sound == true:
		if CameraEquipment.get_node("ShakeCamera").ignore_shake == false: Input.start_joy_vibration(0, 0.5, 0.7, .2)
		CameraEquipment.get_node("ShakeCamera").add_trauma(.4)
	else:
		$ExplosionSound.volume_db = -100
	if shockwave == false:
		$Shockwave.hide()
	else:
		$Shockwave.show()
	
	# Explodes the shockwave/starts particles/starts the animation
	$ExplosionSound.pitch_scale = rand_range(0.8, 1.2)
	if particles == true: $Particles.emitting = true
	$AnimationPlayer.play("explode")

func _on_AnimationPlayer_animation_finished(_anim_name):
	# Waits for particles to finish (if they are active)
	if $Particles.emitting == true:
		yield($Particles, "finished")
	emit_signal("exploded")
	if auto_delete == true: queue_free()

# Repositions the shockwave if visible
func _process(_delta):
	if visible == true and shockwave == true:
		$Shockwave.position = Utils.local_to_screen(global_transform.origin)
		$Shockwave.visible = visible
