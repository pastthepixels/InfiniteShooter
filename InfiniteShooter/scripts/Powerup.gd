extends Area


# Declare member variables here. Examples:
export var type = 0
export var ammo_increase = 10 # 10 bullets
export var health_increase = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	
	randomize()
	type = randi() % 3 + 1 # Generates either a 1, 2, or 3
	match type:
		
		1:
			$Ammo.show()
		
		2:
			$Medkit.show()
		
		3:
			$EnemyWipe.show()

func _on_Powerup_area_entered(area):
	
	if area.is_in_group( "players" ):
		
		match type:
			
			1:
				if area.ammo + ammo_increase <= area.max_ammo:
					
					area.set_ammo(area.ammo + ammo_increase)
				
				else:
					
					area.set_ammo(area.max_ammo)
			
			2:
				if area.health + health_increase <= area.max_health:
					
					area.set_health(area.health + health_increase)
				
				else:
					
					area.set_health(area.max_health)
					
			3:
				for enemy in get_tree().get_nodes_in_group( "enemies" ):
					
					enemy.health = 0
		
		$AnimationPlayer.play( "use" )
		$AudioStreamPlayer.play()
		$CollisionShape.set_deferred( "disabled", true )
	
func _on_AudioStreamPlayer_finished():
	
	queue_free()

func _on_CountdownTimer_timeout():
	
	$AnimationPlayer.play( "hide" )
	$CollisionShape.set_deferred( "disabled", true )
