extends Control

signal closed

# Something that should NOT be saved but that is used at runtime
# {"label name": upgrade}
var upgrade_lookup_table = {}

# Upgrades
var upgrades = []

# Player/points
onready var player = get_node("/root/Game/GameSpace/Player")

onready var game = get_node("/root/Game")

# Template for an upgrade label
export(PackedScene) var upgrade_label

# Name generator
export(Script) var name_generator

# Shows and hides the menu with FADING
func show_animated():
	reset_labels()
	create_upgrades() # <-- Creates upgrades
	read_upgrades() # <--- turns them into labels
	update_gui()	# <-/
	rect_pivot_offset = rect_size/2
	$AnimationPlayer.play("open")
	$ShowSound.play()
	$Music.play()


func _on_SelectSquare_selected():
	match $Content/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		"Back":
			emit_signal("closed")
			$AnimationPlayer.play("close")
			$Music.stop() 
		
		var name:
			var upgrade = upgrade_lookup_table[name]
			if upgrade.purchased == true:
				$Alert.error("You have already purchased this upgrade.")
			elif game.points - upgrade.cost >= 0:
				$Alert.alert("Upgrade purchased!")
				player.max_health += upgrade.health
				player.damage += upgrade.damage
				game.points -= upgrade.cost
				update_gui()
				get_node("Content/Options/" + name).modulate = Color(1, 1, 1, .5)
				upgrade.purchased = true
			else:
				$Alert.error( "%s points needed." % ( upgrade.cost - game.points ) )
			game.get_node("HUD").update_points(game.points) # <-- Updates the game HUD with the new points
			reroll_upgrades() # <-- Creates a new set of upgrades if all are purchased.


# Creating an array of upgrades
func create_upgrades():
	upgrades = []
	for _i in range( 0, 10 ): # <-- Max upgrades available at a time is 10
		var upgrade_damage = randi() % int(GameVariables.max_points_per_upgrade/2)
		var upgrade_health = randi() % GameVariables.max_points_per_upgrade
		upgrades.append( {
			"name": name_generator.new().generate_upgrade_name(),
			"cost": floor(GameVariables.get_cost_per_point(get_node("/root/Game").level) * (upgrade_damage + upgrade_health)),
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
	label.get_node("Name").text = text
	label.get_node("Cost").text = str(cost)
	label.get_node("Damage").text = "+" + str(damage)
	label.get_node("Health").text = "+" + str(health)
	$Content/Options.add_child(label)
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
		$SelectSquare.index = 0
		reset_labels()
		# Creates new ones
		read_upgrades()

func reset_labels():
	for label_name in upgrade_lookup_table.keys():
		get_node("Content/Options/" + label_name).queue_free()
	upgrade_lookup_table.clear()

# Updates the labels
func update_gui():
	$Content/Stats/Health.text = "%s health" % player.max_health
	$Content/Stats/Damage.text = "%s damage/shot" % player.damage
	$Content/Stats/Points.text = "%s points" % game.points
	if game.points == 1: $Content/Stats/Points.text = "1 point"
