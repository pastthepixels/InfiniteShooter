extends Control

signal closed

# Something that should NOT be saved but that is used at runtime
# {"label name": upgrade}
var upgrade_lookup_table = {}

# Something that SHOULD be saved -- upgrades
var upgrades = []

# Userdata (points, health, and damage)
onready var userdata = Saving.load_userdata()

# Template for an upgrade label
export(PackedScene) var upgrade_label

# Name generator
export(Script) var name_generator


# Loads and reads upgrades
func _ready():
	update_gui()
	load_upgrades() # <-- Loads upgrades
	read_upgrades() # <-- turns them into labels
	reroll_upgrades() # <-- Does not nessecarilary reroll upgrades but checks first


# Shows and hides the menu with FADING
func show_animated():
	$AnimationPlayer.play("open")


func _on_SelectSquare_selected():
	match $Content/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		"Back":
			emit_signal("closed")
			$AnimationPlayer.play("close")
		
		var name:
			var upgrade = upgrade_lookup_table[name]
			if upgrade.purchased == true:
				$Alert.error("You have already purchased this upgrade.")
			elif userdata.points - upgrade.cost >= 0:
				$Alert.alert("Upgrade purchased!")
				userdata.health += upgrade.health
				userdata.damage += upgrade.damage
				userdata.points -= upgrade.cost
				update_gui()
				get_node("Content/Options/" + name).modulate = Color(1, 1, 1, .5)
				upgrade.purchased = true
			else:
				$Alert.error( "%s points needed." % ( upgrade.cost - userdata.points ) )
			reroll_upgrades() # <-- Creates a new set of upgrades if all are purchased.
			Saving.save_upgrades(upgrades) # <-- Saves upgrades in case we modified them by purchasing them.
			Saving.save_userdata(userdata) # <-- Same as above but for stats (score, health, and damage)


# Creating an array of upgrades
func create_upgrades():
	upgrades = []
	for _i in range( 0, 10 ): # <-- Max upgrades available at a time is 10
		var upgrade_damage = randi() % 100
		var upgrade_health = randi() % 100
		upgrades.append( {
			"name": name_generator.new().generate_upgrade_name(),
			"cost": 10 * (upgrade_damage + upgrade_health),
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
		Saving.save_upgrades(upgrades)
		# Resets labels + variables related to them
		$SelectSquare.index = 0
		for label_name in upgrade_lookup_table.keys():
			get_node("Content/Options/" + label_name).queue_free()
		upgrade_lookup_table = {}
		# Creates new ones
		read_upgrades()
	

# Updates the labels
func update_gui():
	$Content/Stats/Health.text = "%s health" % userdata.health
	$Content/Stats/Damage.text = "%s damage" % userdata.damage
	$Content/Stats/Points.text = "%s points" % userdata.points
	if userdata.points == 1: $Content/Stats/Points.text = "1 point"


# Loading upgrades
func load_upgrades():
	upgrades = Saving.load_upgrades()
	if upgrades == []:
		create_upgrades()
		Saving.save_upgrades(upgrades)


func _on_AnimationPlayer_animation_started(_anim_name):
	show()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"close":
			hide()
