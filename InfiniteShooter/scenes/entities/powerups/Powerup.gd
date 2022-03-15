extends Area

onready var type = randi() % 3 + 1  # Generates either a 1, 2, or 3

export var ammo_increase = 10  # 10 bullets

export var health_increase = 40  # 40 HP

# Laser "modifiers"
var MODIFIERS = GameVariables.LASER_MODIFIERS

var modifier = MODIFIERS.none


func _ready():
	randomize()
	if modifier == MODIFIERS.none:
		match type:
			1:
				$Meshes/Ammo.show()

			2:
				$Meshes/Medkit.show()

			3:
				$Meshes/EnemyWipe.show()
	else:
		$Meshes/LaserTypes.show()
		match modifier:
			MODIFIERS.fire:
				$Meshes/LaserTypes/Fire.show()
			
			MODIFIERS.ice:
				$Meshes/LaserTypes/Ice.show()
			
			MODIFIERS.corrosion:
				$Meshes/LaserTypes/Corrosion.show()


func _on_Powerup_body_entered(body):
	if body.is_in_group("players"):
		if modifier == MODIFIERS.none:
			match type:
				1:
					body.ammo_refills += 1

				2:
					if body.health + health_increase <= body.max_health:
						body.health += health_increase

					else:
						body.health = body.max_health

				3:
					body.modifier = MODIFIERS.none
					for enemy in get_tree().get_nodes_in_group("enemies"):
						enemy.last_hit_from = body
						enemy.health = 0
		else:
			body.modifier = modifier
	
		$CollisionShape.set_deferred("disabled", true)
		$MainAnimations.play("use")
		$AudioStreamPlayer.play()


func _on_CountdownTimer_timeout():
	$MainAnimations.play("hide")

func _process(_delta):
	if $CountdownTimer.time_left <= 4:
		$Outline.hide()
		$WarningOutline.show()


func _on_AudioStreamPlayer_finished():
	queue_free()


func _on_MainAnimations_animation_finished(anim_name):
	if anim_name == "hide": queue_free()
	if anim_name != "creation": hide()


func _on_VisibilityNotifier_screen_exited():
	hide()
