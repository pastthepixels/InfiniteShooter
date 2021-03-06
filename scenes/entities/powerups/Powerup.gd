extends Area


var type = GameVariables.POWERUP_TYPES.values()[randi() % GameVariables.POWERUP_TYPES.size()]

export var ammo_increase = 10  # 10 bullets

export var health_increase_percent = .40  # 40% HP

export(float) var SCREEN_EDGE_MARGIN # Can be same as what's set for Player.gd or larger

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
					body.health = min(body.health + (health_increase_percent*body.max_health), body.max_health)

				GameVariables.POWERUP_TYPES.wipe:
					body.modifier = GameVariables.LASER_MODIFIERS.none
					body.emit_signal("set_modifier")
					for enemy in get_tree().get_nodes_in_group("enemies"):
						enemy.health = 0
		else:
			body.modifier = modifier
			body.emit_signal("set_modifier")
	
		$CountdownTimer.stop()
		$MainAnimations.play("use")


func _on_CountdownTimer_timeout():
	$MainAnimations.play("hide")

func _process(_delta):
	translation.z = clamp(translation.z, Utils.top_left.z + SCREEN_EDGE_MARGIN, Utils.bottom_left.z - SCREEN_EDGE_MARGIN)
	if $CountdownTimer.time_left <= 4 and $MainAnimations.is_playing() == false:
		$Outline.hide()
		$WarningOutline.show()

func _on_MainAnimations_animation_finished(anim_name):
	if anim_name == "hide" or anim_name == "use": queue_free()
