extends Control

func _ready():
	$Content/ScrollContainer/VBoxContainer.get_child(0).grab_focus() # For keyboard navigation
	$AnimationPlayer.play("open")


func _on_Button_pressed():
	$AnimationPlayer.play("close")


func _on_UpgradeButton_pressed():
	$Alert.error("Insufficient points.")


func _on_AscendingSort_pressed():
	Utils.sort_container(get_node("%SortContainer"), self, "ascending_sort")


func _on_DescendingSort_pressed():
	Utils.sort_container(get_node("%SortContainer"), self, "descending_sort")

# Sorting
var alphabet = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
func alphabetize(string):
	return alphabet.find(string[0].to_lower(), 0)


func ascending_sort(a, b): # Godot can't do lambda functions :(
	return alphabetize(a.text) > alphabetize(b.text)


func descending_sort(a, b): # it starts with one half life reference
	return alphabetize(a.text) < alphabetize(b.text)
