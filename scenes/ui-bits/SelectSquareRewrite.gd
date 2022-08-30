extends Control

func _ready():
	$Content/ScrollContainer/VBoxContainer.get_child(0).grab_focus() # For keyboard navigation
	$AnimationPlayer.play("open")


func _on_Button_pressed():
	$AnimationPlayer.play("close")


func _on_UpgradeButton_pressed():
	$Alert.error("Insufficient points.")


func _on_AscendingSort_pressed():
	sort_box_container(get_node("%SortContainer"), "ascending_sort")


func _on_DescendingSort_pressed():
	sort_box_container(get_node("%SortContainer"), "descending_sort")


func ascending_sort(a, b): # Godot can't do lambda functions :(
	return alphabetize(a.text) > alphabetize(b.text)


func descending_sort(a, b): # it starts with one half life reference
	return alphabetize(a.text) < alphabetize(b.text)


#
# Hacked together functions to do some basic sorting
#
func sort_box_container(box_container, function): # Modified from https://godotengine.org/qa/28998/how-do-i-sort-a-scroll-containers-contents
	var child_list = box_container.get_children()
	var num_children = child_list.size()
	for ii in range(0, num_children):
		for i in range(0, num_children):
			if i+1 < num_children:
				if call(function, box_container.get_child(i), box_container.get_child(i+1)) == true:
					box_container.move_child(get_node("%SortContainer").get_child(i+1),i)


var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
func alphabetize(string):
	return alphabet.find(string[0].to_lower(), 0)
