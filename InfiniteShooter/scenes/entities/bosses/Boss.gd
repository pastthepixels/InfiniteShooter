extends Spatial

# Damage, health, and enemy type
var speed

var boss_type = GameVariables.BOSS_TYPES.values()[randi() % GameVariables.BOSS_TYPES.size()]

var health = 0 setget ,get_health

# Dying

signal died(current_ship)

# Moving around

export(Array, Curve3D) var paths

# mechanics (LaserEffects)

var freeze_movement = false

# Scenes used

var enemy_model

func _ready():
	randomize()
	# Sets the path to follow
	$Path.curve = paths[randi() % len(paths)]
	$Path/PathFollow.unit_offset = 0

func initialize(difficulty):
	# Sets up enemy types
	match boss_type:
		GameVariables.BOSS_TYPES.normal:
			enemy_model = $Normal
			speed = .05
		
		GameVariables.BOSS_TYPES.trishot:
			enemy_model = $Trishot
			speed = .06
		
		GameVariables.BOSS_TYPES.multishot:
			enemy_model = $Multishot
			speed = .04
	
	enemy_model.show()
	
	# Multiplies everything by the difficulty number for added difficulty (same as we would for Enemy.gd)
	enemy_model.max_health *= difficulty
	enemy_model.damage *= difficulty
	
	# Sets the current health as the new max health
	enemy_model.health = enemy_model.max_health
	
	# Some more stuff
	enemy_model.connect("body_entered", self, "_on_ship_body_entered")
	
	# Mini-cutscene
	$Tween.interpolate_property(self, "translation:z", translation.z, 0, 4, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")

	$Tween.interpolate_property(self, "translation", translation, $Path/PathFollow.translation, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	
	# Begins shooting fter the cutscene
	$AnimationPlayer.play("RemoveInvincibility")
	enemy_model.start()


# Called to process health and movement
func _process(delta):
	# Looking at the player
	if has_node("/root/Game/GameSpace/Player") and get_node("/root/Game/GameSpace/Player").health > 0 and enemy_model.health > 0:
		smooth_look_at(delta, 3)
	elif enemy_model.health > 0 and rotation.y != 0 and $Tween.is_active() == false:
		$Tween.interpolate_property(self, "rotation:y", rotation.y, (deg2rad(0) if rotation.y < deg2rad(180) else deg2rad(360)), 5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		$Tween.start()
		enemy_model.stop()

	# If the health is between 100% and 0%, show the health bar.
	if enemy_model.health < enemy_model.max_health and enemy_model.health > 0:
		$HealthBar.show()
		$HealthBar.health = enemy_model.health
		$HealthBar.max_health = enemy_model.max_health
	elif enemy_model.health <= 0:
		set_process(false)
		$HealthBar.hide()
		explode_ship() # otherwise, explode the ship
		return

	# Moving around
	if (freeze_movement or $Tween.is_active()) == false:
		translation = $Path/PathFollow.translation
		$Path/PathFollow.unit_offset += speed * delta

func smooth_look_at(delta, weight):
	# A. Creates a new Transform that is facing the player
	var new_transform = global_transform.looking_at(get_node("/root/Game/GameSpace/Player").translation, Vector3(0, 1, 0))
	# B. Rotates it 180 degrees
	new_transform = new_transform.rotated(Vector3(0, 1, 0), deg2rad(180))
	# C. Creates a quaternion to slerp between rotations, then applies it
	var new_quaternion = Quat(global_transform.basis).slerp(Quat(new_transform.basis), delta * weight)
	global_transform = Transform(Basis(new_quaternion), global_transform.origin)


func explode_ship():
	emit_signal("died", self)
	remove_from_group("bosses")
	enemy_model.stop()
	enemy_model.hide()
	$LaserEffects.disabled = true
	$LaserEffects.reset()
	yield($LaserEffects, "finished_reset")
	$Explosions.show()
	$Tween.stop_all()
	for explosion in $Explosions.get_children():
		explosion.explode()
		yield(Utils.timeout(0.15), "timeout")

func hurt(damage):
	enemy_model.health -= damage

func get_health():
	return enemy_model.health

func _on_ship_body_entered(body):
	if body.is_in_group("players"):
		body.on_enemy_collision(self)


func _on_FinalExplosion_exploded():
	queue_free()
