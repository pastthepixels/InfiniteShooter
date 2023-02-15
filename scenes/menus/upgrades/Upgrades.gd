extends "res://scenes/ui-bits/Submenu.gd"

signal upgrade_health(amount)

signal upgrade_damage(amount)

signal subtract_coins(amount)

signal request_player_stats()

# Name generator
var name_generator = preload("res://scenes/menus/upgrades/NameGenerator.gd")

# Something that should NOT be saved but that is used at runtime
# {"label name": upgrade}
var upgrade_lookup_table = {}

# Upgrades
var upgrades = []

# Player/points
var _coins = 0

var _max_health = 0

var _damage = 0

# Template for an upgrade label
export(PackedScene) var upgrade_label

# Template for an enhancement label
export(PackedScene) var enhancement_label

# Sorting
export var use_ascending_sort = false # If this set to true then it assumes you want to sort by descending

# Shows and hides the menu with FADING
func show_animated():
	reset_labels()
	create_upgrades() # <-- Creates upgrades
	read_upgrades() # <--- turns them into labels
	emit_signal("request_player_stats") # <-/
	rect_pivot_offset = rect_size/2
	$AnimationPlayer.play("open")
	$ShowSound.play()
	$Music.play()
	$"Content/NavigationButtons/Back".grab_focus()


func _on_UpgradeLabel_button_pressed(label):
	var upgrade = upgrade_lookup_table[label.name]
	if upgrade.purchased == true:
		$Alert.error("You have already purchased this upgrade.")
	elif _coins - upgrade.cost >= 0:
		$Alert.alert("Upgrade purchased!")
		emit_signal("upgrade_health", upgrade.health)
		emit_signal("upgrade_damage", upgrade.damage)
		emit_signal("subtract_coins", upgrade.cost)
		emit_signal("request_player_stats")
		label.get_node("Button").disabled = true
		upgrade.purchased = true
	else:
		$Alert.error("$%s needed." % (upgrade.cost - _coins))
	reroll_upgrades() # <-- Creates a new set of upgrades if all are purchased.

func _on_QuitConfirm_confirmed():
	emit_signal("closed")
	$AnimationPlayer.play("close")
	$Music.stop()


func _on_Back_pressed():
	$QuitConfirm.alert()

func _on_SortCategory_item_selected(index):
	match(index):
		0: # Cost
			Utils.sort_container(get_node("%Upgrades"), self, "sort_cost")
		
		1: # Damage
			Utils.sort_container(get_node("%Upgrades"), self, "sort_damage")
		
		2: # Health
			Utils.sort_container(get_node("%Upgrades"), self, "sort_health")


func _on_SortMode_item_selected(index):
	match(index):
		0: # Ascending
			use_ascending_sort = true
		1: # Descending
			use_ascending_sort = false
	# Force update
	_on_SortCategory_item_selected(get_node("%Sorting/SortCategory").get_item_index(get_node("%Sorting/SortCategory").get_selected_id()))


# Creating an array of upgrades
func create_upgrades():
	upgrades = []
	for _i in range( 0, 10 ): # <-- Max upgrades available at a time is 10
		var upgrade_damage = stepify(rand_range(1.0, GameVariables.max_damage_per_upgrade), 0.01)
		var upgrade_health = randi() % GameVariables.max_health_per_upgrade
		upgrades.append( {
			"name": name_generator.new().generate_upgrade_name(),
			"cost": floor(GameVariables.get_cost_per_health() * upgrade_health + GameVariables.get_cost_per_damage() * upgrade_damage),
			"damage": upgrade_damage, # out of 100
			"health": upgrade_health, # out of 100
			"purchased": false
		} )


# Creates labels from the upgrades array
func read_upgrades():
	for upgrade in upgrades:
		var label = create_label(upgrade["name"], upgrade["cost"], upgrade["damage"], upgrade["health"])
		if upgrade["purchased"] == true: label.modulate = Color(1, 1, 1, .5)
		upgrade_lookup_table[label.name] = upgrade
		# Force resort
	_on_SortCategory_item_selected(get_node("%Sorting/SortCategory").get_item_index(get_node("%Sorting/SortCategory").get_selected_id()))

# Creating a label (pretty straightforward)
func create_label(text, cost, damage, health):
	var label = upgrade_label.instance()
	label.set_name(text)
	label.set_stats(cost, damage, health)
	label.connect("button_pressed", self, "_on_UpgradeLabel_button_pressed")
	get_node("%Upgrades").add_child(label)
	return label


# Creating a new list of upgrades if all are purchased
func reroll_upgrades():
	var purchased_upgrades = 0
	for i in upgrades:
		purchased_upgrades += 1 if i.purchased == true else 0
	if purchased_upgrades == upgrades.size():
		$Alert.alert("All upgrades purchased! Creating a new set of upgrades...")
		create_upgrades()
		# Resets labels + variables related to them
		reset_labels()
		# Creates new ones
		read_upgrades()

func reset_labels():
	for label_name in upgrade_lookup_table.keys():
		if has_node("Content/ScrollContainer/Upgrades/" + label_name): get_node("Content/ScrollContainer/Upgrades/" + label_name).queue_free()
	upgrade_lookup_table.clear()

# Updates the labels
func update_player_information(max_health, damage, coins):
	_max_health = max_health
	_damage = damage
	_coins = coins
	update_gui()

func update_gui():
	$Content/Stats/Health.text = "%s health" % _max_health
	$Content/Stats/Damage.text = "%s damage/shot" % _damage
	$Content/Stats/Coins.text = "$%s" % _coins

# Sorting
func parse_float(string):
	var regex = RegEx.new()
	regex.compile("[+|$]")
	return float(regex.sub(string, ""))


func sort_generic(label_a, label_b, node_path:NodePath):
	if use_ascending_sort == true:
		return parse_float(label_a.get_node(node_path).text) > parse_float(label_b.get_node(node_path).text)
	else:
		return parse_float(label_a.get_node(node_path).text) < parse_float(label_b.get_node(node_path).text)


func sort_cost(label_a, label_b):
	return sort_generic(label_a, label_b, "Stats/Cost")


func sort_health(label_a, label_b):
	return sort_generic(label_a, label_b, "Stats/Health")


func sort_damage(label_a, label_b):
	return sort_generic(label_a, label_b, "Stats/Damage")

# Switching tabs
func _on_ChangeTab_pressed():
	if $Content/TabContainer.current_tab == $Content/TabContainer.get_child_count() -1:
		$Content/TabContainer.current_tab = 0
	else:
		$Content/TabContainer.current_tab += 1


func _on_TabContainer_tab_changed(tab):
	match tab:
		0:
			$"Content/NavigationButtons/ChangeTab".text = "Switch to loadout"
		
		1:
			$"Content/NavigationButtons/ChangeTab".text = "Switch to upgrades"

# Loads enhancements/loadout upgrades
func _on_LoadoutUpgrades_ready():
	for enhancement in Enhancements.laser_enhancements:
		var label = create_loadout_label(enhancement)
		get_node("%LoadoutUpgrades").move_child(label, get_node("%LoadoutUpgrades/Lasers").get_index() + Enhancements.laser_enhancements.find(enhancement) + 1)
	
	for enhancement in Enhancements.ship_enhancements:
		var label = create_loadout_label(enhancement)
		get_node("%LoadoutUpgrades").move_child(label, get_node("%LoadoutUpgrades/Ship").get_index() + Enhancements.ship_enhancements.find(enhancement) + 1)

func create_loadout_label(json):
	var label = enhancement_label.instance()
	label.load_from_json(json)
	get_node("%LoadoutUpgrades").add_child(label)
	label.connect("purchase_request", self, "_on_EnhancementLabel_purchase_request", [label])
	label.connect("equip_failed", self, "_on_EnhancementLabel_equip_failed")
	return label

func _on_EnhancementLabel_equip_failed():
	$Alert.error("Max number of upgrades of this type equipped.")

func _on_EnhancementLabel_purchase_request(cost, label):
	if _coins - cost >= 0:
		$Alert.alert("Enhancement purchased!")
		emit_signal("subtract_coins", cost)
		emit_signal("request_player_stats")
		label.complete_purchase()
	else:
		$Alert.error("$%s needed." % (cost - _coins))
