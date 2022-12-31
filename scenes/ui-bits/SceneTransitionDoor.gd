extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", self, "resize")

func resize():
	# Deletes all bottom/top door halves
	for child in $Bottom.get_children():
		if child != get_node("%Door001"): child.queue_free()
	for child in $Top.get_children():
		if child != get_node("%Door002"): child.queue_free()
	# Gets the size difference between the left end of Door001 and the left end of the screen
	# (it'll be the same for the right side since the doors are centered)
	var empty_space = abs(Utils.screen_to_local_custom_camera($Camera, Vector2()).x - (get_node("%Door001").mesh.get_aabb().get_longest_axis_size() / 2.00))
	var walls_to_duplicate = (ceil(empty_space / get_node("%Door001").mesh.get_aabb().get_longest_axis_size())) - 1
	if walls_to_duplicate > 0:
		for i in range(0, walls_to_duplicate):
			duplicate_doors(get_node("%Door001"), i)
			duplicate_doors(get_node("%Door002"), i)

func duplicate_doors(door, i):
	var duplicated_door_left = door.duplicate()
	duplicated_door_left.translation = Vector3(
		door.mesh.get_aabb().get_longest_axis_size() * (i+1),
		0,
		0
	)
	door.get_parent().add_child(duplicated_door_left)
	
	var duplicated_door_right = door.duplicate()
	duplicated_door_right.translation = Vector3(
		door.mesh.get_aabb().get_longest_axis_size() * -(i+1),
		0,
		0
	)
	door.get_parent().add_child(duplicated_door_right)
