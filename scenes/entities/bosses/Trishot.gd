extends Area

var cannon_alternation = false

var damage = 5

var max_health = 2800

var health

func _ready():
	match GameVariables.current_difficulty:
		GameVariables.DIFFICULTIES.easy:
			$LaserTimer.wait_time *= 1.2
			
		GameVariables.DIFFICULTIES.hard:
			$LaserTimer.wait_time *= 0.8
			
		GameVariables.DIFFICULTIES.ultranightmare:
			$LaserTimer.wait_time *= 0.8
			for cannon in $Boss.get_children():
				if cannon.is_in_group("laserguns"):
					cannon.use_laser_modifiers = true
					cannon.laser_modifier = GameVariables.LASER_MODIFIERS.corrosion

func start():
	$Boss/Cannon1.damage = damage
	$Boss/Cannon2.damage = damage
	$Boss/Cannon3.damage = damage
	$Boss/Cannon2.damage = damage
	$Boss/Cannon3.damage = damage
	$LaserTimer.start()

func stop():
	$LaserTimer.stop()

func _on_LaserTimer_timeout():
	if health <= max_health/3: # Stage 3
		$Boss/Cannon1.fire()
		$Boss/Cannon2.fire()
		$Boss/Cannon3.fire()
	
	if health <= 2 * max_health/3: # Stage 2
		$Boss/Cannon1.fire()
		$Boss/Cannon2.fire()
	
	if health > max_health/3: # Stage 1
		cannon_alternation = !cannon_alternation
		if cannon_alternation:
			$Boss/Cannon1.fire()
		else:
			$Boss/Cannon2.fire()
		$Boss/Cannon3.fire()
