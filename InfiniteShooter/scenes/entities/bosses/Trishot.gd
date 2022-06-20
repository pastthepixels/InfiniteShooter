extends Area

var cannon_alternation = false

var damage = 5

var max_health = 2400

var health

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
