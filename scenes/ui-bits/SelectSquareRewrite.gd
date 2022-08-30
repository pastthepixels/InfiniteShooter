extends Control

func _ready():
	$Content/ScrollContainer/VBoxContainer.get_child(0).grab_focus() # For keyboard navigation
	$AnimationPlayer.play("open")


func _on_Button_pressed():
	$AnimationPlayer.play("close")


func _on_UpgradeButton_pressed():
	$Alert.error("Insufficient points.")
