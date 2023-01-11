extends Area

var cannon_alternation = false

var damage = 2

var max_health = 2900

var health

func _ready():
	match GameVariables.current_difficulty:
		GameVariables.DIFFICULTIES.easy:
			$LaserTimer.wait_time *= 1.4
			
		GameVariables.DIFFICULTIES.harder:
			$LaserTimer.wait_time *= 0.9
			
		GameVariables.DIFFICULTIES.hardest:
			for cannon in $Boss.get_children():
				if cannon.is_in_group("laserguns"):
					cannon.use_laser_modifiers = true
					cannon.laser_modifier = GameVariables.LASER_MODIFIERS.ice

func start():
	for cannon in $Boss.get_children():
		if cannon.is_in_group("laserguns"):
			cannon.damage = damage
	$LaserTimer.start()

func stop():
	$LaserTimer.stop()

func _on_LaserTimer_timeout():
	if health <= max_health/3: # Stage 3
		cannon_alternation = !cannon_alternation
		if cannon_alternation:
			$Boss/Cannon4.fire()
		else:
			$Boss/Cannon5.fire()
	
	if health <= 2 * max_health/3: # Stage 2
		$Boss/Cannon1.fire()
		$Boss/Cannon2.fire()
		$Boss/Cannon3.fire()
		$LaserTimer.wait_time = 1
	
	if health > max_health/3: # Stage 1
		cannon_alternation = !cannon_alternation
		if cannon_alternation:
			$Boss/Cannon1.fire()
		else:
			$Boss/Cannon2.fire()
		$Boss/Cannon3.fire()
