extends Control

var upgrade_lookup_table = {} # <-- Something that should NOT be saved but that is used at runtime
var inactive_color = Color(.5,.5,.5) # <-- The color of inactive (already purchased) labels
export var upgrades = []
export var points = 0
export var health = 100 # See res://scripts/Player.gd for info
export var damage = 20

func show_animated():
	show()
	$AnimationPlayer.play("open")

func hide_animated():
	$AnimationPlayer.play_backwards("open")
	yield($AnimationPlayer, "animation_finished")
	hide()
	
# Loads and reads upgrades
func _ready():
	randomize()
	load_stats()
	load_upgrades()
	read_upgrades()
	reroll_upgrades()

# To handle when something is selected -- all input starts from the main menu but go over here for the upgrade screen
func handle_selection():
	match $VBoxContainer/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"Back":
			hide_animated()
			get_node("../SelectSquare").show()
		
		var name:
			var upgrade = upgrade_lookup_table[name]
			if upgrade.purchased == true:
				$Alert.error("You have already purchased this upgrade.")
			elif points - upgrade.cost > 0:
				$Alert.alert("Upgrade purchased!")
				set_health( health + upgrade.health )
				set_damage( damage + upgrade.damage )
				set_points( points - upgrade.cost )
				get_node("VBoxContainer/Options/" + name).set("custom_colors/font_color", inactive_color)
				upgrade.purchased = true
			else:
				$Alert.error( "%s points needed." % ( upgrade.cost - points ) )
			reroll_upgrades() # <-- Creates a new set of upgrades if all are purchased.
			save_upgrades() # <-- Saves upgrades in case we modified them by purchasing them.
			save_stats() # <-- Same as above but for stats (score, health, and damage)

# Creating a label (pretty straightforward)
func create_label( text, tooltip ):
	var label = Label.new()
	label.text = text
	label.hint_tooltip = tooltip
	label.mouse_filter = Control.MOUSE_FILTER_PASS # <-- In order for the tooltip to work
	label.set("custom_colors/font_color", Color(0,0,0))
	$VBoxContainer/Options.add_child( label )
	return label

# Creating an array of upgrades
func create_upgrades():
	
	upgrades = []
	for _i in range( 0, 10 ): # <-- Max upgrades available at a time is 10
		
		var upgrade_damage = randi() % 100
		var upgrade_health = randi() % 100
		upgrades.append( {
			"cost": int( ( float(upgrade_damage)/100 + 1 ) * ( float(upgrade_health)/100 + 1 ) * 175 ), # A complicated algorithm, I know, but it's the same formula as InfiniteShooter 1.0
			"damage": upgrade_damage, # out of 100
			"health": upgrade_health, # out of 100
			"purchased": false
		} )

# Creates labels from the upgrades array
func read_upgrades():
	for i in upgrades:
		var label = create_label( "+{damage} damage, +{health} health [{cost} PTS]".format( i ), "" )
		if i.purchased == true: label.set("custom_colors/font_color", inactive_color)
		upgrade_lookup_table[label.name] = i

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
			get_node( "VBoxContainer/Options/" + label_name ).queue_free()
		upgrade_lookup_table = {}
		# Creates new ones
		read_upgrades()
	
# Updates the labels
func set_health( value ):
	
	health = value
	$VBoxContainer/Stats/Health.text = "%s health" % health

func set_damage( value ):
	
	damage = value
	$VBoxContainer/Stats/Damage.text = "%s damage" % damage

func set_points( value ):
	
	points = value
	$VBoxContainer/Stats/Points.text = "%s points" % points
	if points == 1: $VBoxContainer/Stats/Points.text = "1 point"

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
