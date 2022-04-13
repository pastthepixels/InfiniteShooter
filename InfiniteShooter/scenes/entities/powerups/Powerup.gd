extends Area


var type = GameVariables.POWERUP_TYPES.values()[randi() % GameVariables.POWERUP_TYPES.size()]

export var ammo_increase = 10  # 10 bullets

export var health_increase = 40  # 40 HP

# Laser "modifiers"
var modifier = GameVariables.LASER_MODIFIERS.none


func _ready():
	randomize()
	if modifier == GameVariables.LASER_MODIFIERS.none:
		match type:
			GameVariables.POWERUP_TYPES.ammo:
				$Meshes/Ammo.show()

			GameVariables.POWERUP_TYPES.medkit:
				$Meshes/Medkit.show()

			GameVariables.POWERUP_TYPES.wipe:
				$Meshes/EnemyWipe.show()
	else:
		$Meshes/LaserTypes.show()
		match modifier:
			GameVariables.LASER_MODIFIERS.fire:
				$Meshes/LaserTypes/Fire.show()
			
			GameVariables.LASER_MODIFIERS.ice:
				$Meshes/LaserTypes/Ice.show()
			
			GameVariables.LASER_MODIFIERS.corrosion:
				$Meshes/LaserTypes/Corrosion.show()


func _on_Powerup_body_entered(body):
	if body.is_in_group("players"):
		if modifier == GameVariables.LASER_MODIFIERS.none:
			match type:
				GameVariables.POWERUP_TYPES.ammo:
					body.ammo_refills += 1

				GameVariables.POWERUP_TYPES.medkit:
					if body.health + health_increase <= body.max_health:
						body.health += health_increase

					else:
						body.health = body.max_health

				GameVariables.POWERUP_TYPES.wipe:
					body.modifier = GameVariables.LASER_MODIFIERS.none
					for enemy in get_tree().get_nodes_in_group("enemies"):
						enemy.last_hit_from = body
						enemy.health = 0
		else:
			body.modifier = modifier
			body.emit_signal("set_modifier")
	
		$CountdownTimer.stop()
		$MainAnimations.play("use")


func _on_CountdownTimer_timeout():
	$MainAnimations.play("hide")

func _process(_delta):
	if $CountdownTimer.time_left <= 4 and $MainAnimations.is_playing() == false:
		$Outline.hide()
		$WarningOutline.show()

func _on_MainAnimations_animation_finished(anim_name):
	if anim_name == "hide" or anim_name == "use": queue_free()
