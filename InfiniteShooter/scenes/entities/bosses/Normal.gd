extends Area

var cannon_alternation = false
 
var damage = 15

var max_health = 2000

var health

func start():
	$Boss/Cannon1.damage = damage
	$Boss/Cannon2.damage = damage
	$LaserTimer.start()

func stop():
	$LaserTimer.stop()

func _on_LaserTimer_timeout():
	if health <= max_health/3: # Stage 3
		$LaserTimer.wait_time = 0.4
	
	if health <= 2 * max_health/3: # Stage 2
		$Boss/Cannon1.fire()
		$Boss/Cannon2.fire()
		$LaserTimer.wait_time = 0.6
	
	if health > max_health/3: # Stage 1 (this applies to both stages 1&2)
		cannon_alternation = !cannon_alternation
		if cannon_alternation:
			$Boss/Cannon1.fire()
		else:
			$Boss/Cannon2.fire()
