# Code modified from https://kidscancode.org/godot_recipes/3d/healthbars/
# Quite an interesting read!

extends Sprite3D

export var health = 1
export var max_health = 1


func _ready():
	texture = $Viewport.get_texture()


func _process(_delta):
	$Viewport/HealthBar2D.value = health / max_health * 100
