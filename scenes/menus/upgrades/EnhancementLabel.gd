extends PanelContainer

export(String) var upgrade_name : String setget set_name

export(String, MULTILINE) var description : String

export(int) var upgrade_cost = 0 setget set_cost

export(bool) var active = false setget set_active

export(bool) var purchased = false setget set_purchased

export(int) var id

signal purchase_request(coins)

signal equip_failed()

func _ready():
	set_purchased(purchased)
	set_active(active)
	set_name(upgrade_name)
	set_cost(upgrade_cost)

# Modifed from https://godotengine.org/qa/26785/exporting-a-child-property
func set_name(new_name):
	upgrade_name = new_name
	$HBoxContainer/Label.text = new_name

func set_cost(new_cost):
	upgrade_cost = new_cost
	$HBoxContainer/Cost.text = "$%d" % new_cost

func set_active(is_active):
	active = is_active
	$HBoxContainer/Equip.pressed = is_active

func set_purchased(is_purchased):
	purchased = is_purchased
	$HBoxContainer/Equip.disabled = !is_purchased
	$HBoxContainer/Purchase.disabled = is_purchased

func load_from_json(json):
	id = int(json["id"])
	set_purchased(bool(json["purchased"]) if "purchased" in json else false)
	set_active(bool(json["active"]) if "active" in json else false)
	set_cost(int(json["cost"]) if "cost" in json else 0)
	if "name" in json: set_name(str(json["name"]))
	if "description" in json: description = str(json["description"])


func _on_Info_pressed():
	$Description.alert(description)


func _on_Purchase_pressed():
	$PurchaseDialog.alert()


func _on_PurchaseDialog_confirmed():
	emit_signal("purchase_request", upgrade_cost)

func complete_purchase():
	# Sets the label to being purchased
	set_purchased(true)
	# Purchases an upgrade with Enhancements.gd
	Enhancements.purchase_enhancement(id)


func _on_Equip_toggled(button_pressed):
	if button_pressed == true and Enhancements.check_equipped_enhancements(id) == true:
		Enhancements.set_enhancement_active(id, true)
	else:
		if button_pressed == true: emit_signal("equip_failed")
		$HBoxContainer/Equip.pressed = false
		Enhancements.set_enhancement_active(id, false)
