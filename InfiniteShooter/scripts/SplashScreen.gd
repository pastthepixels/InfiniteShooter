extends Control

export var wait_time = .5

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true
	yield( get_tree().create_timer( wait_time ), "timeout" )
	$AnimationPlayer.play( "fade" )

func _on_AnimationPlayer_animation_finished(_anim_name):
	yield( get_tree().create_timer( wait_time ), "timeout" )
	queue_free()
	get_tree().paused = false
