extends Control

signal closed

signal upgrade_health(amount)

signal upgrade_damage(amount)

signal subtract_coins(amount)

signal request_player_stats()

# Something that should NOT be saved but that is used at runtime
# {"label name": upgrade}
var upgrade_lookup_table = {}

# Upgrades
var upgrades = []

# Player/points
var _coins

var _max_health

var _damage

# Template for an upgrade label
export(PackedScene) var upgrade_label

# Name generator
export(Script) var name_generator

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
	$QuitConfirm.alert("Are you sure you would like to go back to the game?", true)

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

# Creating a label (pretty straightforward)
func create_label(text, cost, damage, health):
	var label = upgrade_label.instance()
	label.set_name(text)
	label.set_stats(cost, damage, health)
	label.connect("button_pressed", self, "_on_UpgradeLabel_button_pressed")
	$Content/ScrollContainer/Upgrades.add_child(label)
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
		get_node("Content/ScrollContainer/Upgrades/" + label_name).queue_free()
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
