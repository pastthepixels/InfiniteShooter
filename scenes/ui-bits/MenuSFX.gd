# Thanks StackOverflow, very cool!
# Modified from https://gamedev.stackexchange.com/questions/184354/add-a-sound-to-all-the-buttons-in-a-project
extends Control

func _ready():
	connect_existing_nodes(get_tree().root)
	get_tree().connect("node_added", self, "_on_SceneTree_node_added")


func _on_SceneTree_node_added(node):
	if node is Button:
		add_button_sounds(node)
	if node is HSlider or node is VSlider:
		add_slider_sounds(node)

func _on_Button_pressed():
	$UseSound.play()

func _on_Button_button_down():
	$DownSound.play()

func _on_Slider_drag_ended(_value_changed):
	$UseSound.play()

func _on_Slider_gui_input(event):
	if event is InputEventKey:
		if event.pressed == true and (Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")):
			_on_Slider_drag_ended(null)

func _on_Slider_drag_started():
	$DownSound.play()

func connect_existing_nodes(root):
	for child in root.get_children():
		if child is BaseButton:
			add_button_sounds(child)
		if (child is HSlider) or (child is VSlider):
			add_slider_sounds(child)
		connect_existing_nodes(child)

func add_button_sounds(button):
	button.connect("pressed", self, "_on_Button_pressed")
	button.connect("button_down", self, "_on_Button_button_down")

func add_slider_sounds(slider):
	slider.connect("drag_ended", self, "_on_Slider_drag_ended")
	slider.connect("drag_started", self, "_on_Slider_drag_started")
	slider.connect("gui_input", self, "_on_Slider_gui_input")
