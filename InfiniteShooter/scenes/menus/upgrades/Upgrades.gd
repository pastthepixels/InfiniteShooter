extends Control

# Something that should NOT be saved but that is used at runtime
var upgrade_lookup_table = {}

# The color of inactive (already purchased) labels
var inactive_color = Color(.5,.5,.5)

export var upgrades = []

# Points (accumulated score over games)
export var points = 0

# Health, in HP/100
export var health = 100

# Damage/bullet, in HP/100
export var damage = 20

# Template for an upgrade label
export(PackedScene) var upgrade_label

# Name generator
export(Script) var name_generator


# Shows and hides the menu with FADING
func show_animated():
	show()
	$AnimationPlayer.play("open")


func hide_animated():
	$AnimationPlayer.play("close")
	yield($AnimationPlayer, "animation_finished")
	hide()


# Loads and reads upgrades
func _ready():
	randomize()
	load_stats() # <-- Loads stats
	load_upgrades() # <-- Loads upgrades
	read_upgrades() # <-- turns them into labels
	reroll_upgrades() # <-- Does not nessecarilary reroll upgrades but checks first


func _on_SelectSquare_selected():
	match $Content/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"Back":
			hide_animated()
			get_node("../SelectSquare").show()
			get_node("../SelectSquare").ignore_hits += 1
		
		var name:
			var upgrade = upgrade_lookup_table[name]
			if upgrade.purchased == true:
				$Alert.error("You have already purchased this upgrade.")
			elif points - upgrade.cost >= 0:
				$Alert.alert("Upgrade purchased!")
				set_health( health + upgrade.health )
				set_damage( damage + upgrade.damage )
				set_points( points - upgrade.cost )
				get_node("Content/Options/" + name).modulate = Color(1, 1, 1, .5)
				upgrade.purchased = true
			else:
				$Alert.error( "%s points needed." % ( upgrade.cost - points ) )
			reroll_upgrades() # <-- Creates a new set of upgrades if all are purchased.
			save_upgrades() # <-- Saves upgrades in case we modified them by purchasing them.
			save_stats() # <-- Same as above but for stats (score, health, and damage)


# Creating a label (pretty straightforward)
func create_label(text, cost, damage, health):
	var label = upgrade_label.instance()
	label.get_node("Name").text = text
	label.get_node("Cost").text = str(cost)
	label.get_node("Damage").text = "+" + str(damage)
	label.get_node("Health").text = "+" + str(health)
	$Content/Options.add_child(label)
	return label


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

func random_name():
	pass


# Creates labels from the upgrades array
func read_upgrades():
	for upgrade in upgrades:
		var label = create_label(upgrade["name"], upgrade["cost"], upgrade["damage"], upgrade["health"])
		if upgrade["purchased"] == true: label.modulate = Color(1, 1, 1, .5)
		upgrade_lookup_table[label.name] = upgrade


# Creating a new list of upgrades if all are purchased
func reroll_upgrades():
	var purchased_upgrades = 0
	for i in upgrades:
		if i.purchased == true: purchased_upgrades += 1
	if purchased_upgrades == upgrades.size():
		$Alert.alert("All upgrades purchased! Creating a new set of upgrades...")
		create_upgrades()
		save_upgrades()
		# Resets labels + variables related to them
		$SelectSquare.index = 0
		for label_name in upgrade_lookup_table.keys():
			get_node( "Content/Options/" + label_name ).queue_free()
		upgrade_lookup_table = {}
		# Creates new ones
		read_upgrades()
	

# Updates the labels
func set_health( value ):
	health = value
	$Content/Stats/Health.text = "%s health" % health


func set_damage( value ):
	damage = value
	$Content/Stats/Damage.text = "%s damage" % damage


func set_points( value ):
	
	points = value
	$Content/Stats/Points.text = "%s points" % points
	if points == 1: $Content/Stats/Points.text = "1 point"


# Saving and loading upgrades/player stats onto a file
func save_upgrades():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://upgrades.txt", File.WRITE )
	file.store_var( upgrades )
	file.close()


func load_upgrades():
	
	var file = File.new() # Creates a new File object, for handling file operations
	if not file.file_exists("user://upgrades.txt"): # If the file `upgrades.txt` does not exist, create a batch of upgrades and save them. Then proceed to read them.
		create_upgrades()
		save_upgrades()
	file.open( "user://upgrades.txt", File.READ )
	upgrades = file.get_var( true )
	file.close()
	
func save_stats():
	
	var file = File.new() # Creates a new File object, for handling file operations
	file.open( "user://userdata.txt", File.WRITE )
	file.store_var( { "points": points, "health": health, "damage": damage } )
	file.close()


func load_stats():
	
	var file = File.new() # Creates a new File object, for handling file operations
	if not file.file_exists("user://userdata.txt"): return # If there is no file containing these stats, don't worry because we have defaults.
	file.open( "user://userdata.txt", File.READ ) # Opens the userdata file for reading
	var data = file.get_var( true )
	set_points(data.points)
	set_health(data.health)
	set_damage(data.damage)
	file.close()
