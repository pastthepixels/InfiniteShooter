# Code modified from https://kidscancode.org/godot_recipes/3d/healthbars/
# Quite an interesting read!

extends Sprite3D

export var health = 1
export var max_health = 1


func _process(_delta):
	$Viewport/EnemyHealth2D/HealthBar.value = health
	$Viewport/EnemyHealth2D/HealthBar.max_value = max_health
