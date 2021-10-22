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
				$Ammo.show()

			2:
				$Medkit.show()

			3:
				$EnemyWipe.show()
	else:
		$LaserTypes.show()
		match modifier:
			MODIFIERS.fire:
				$LaserTypes/Fire.show()
			
			MODIFIERS.ice:
				$LaserTypes/Ice.show()
			
			MODIFIERS.corrosion:
				$LaserTypes/Corrosion.show()


func _on_Powerup_area_entered(area):
	if area.is_in_group("players"):
		if modifier == MODIFIERS.none:
			match type:
				1:
					area.ammo_refills += 1
					area.update_hud()

				2:
					if area.health + health_increase <= area.max_health:
						area.set_health(area.health + health_increase)

					else:
						area.set_health(area.max_health)

				3:
					area.modifier = MODIFIERS.none
					for enemy in get_tree().get_nodes_in_group("enemies"):
						enemy.last_hit_from = area
						enemy.health = 0
		else:
			area.modifier = modifier

		$MainAnimations.play("use")
		$AudioStreamPlayer.pitch_scale = rand_range(1, 1.1)
		$AudioStreamPlayer.play()
		$CollisionShape.set_deferred("disabled", true)


func _on_CountdownTimer_timeout():
	$MainAnimations.play("hide")

func _process(_delta):
	$Outline.visible = $CountdownTimer.time_left < 3


func _on_AudioStreamPlayer_finished():
	queue_free()


func _on_MainAnimations_animation_finished(anim_name):
	if anim_name == "hide": queue_free()
