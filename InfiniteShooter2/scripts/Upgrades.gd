extends Control

var upgrades = []
var points = 0
var health = 0
var damage = 0

# Creates and reads upgrades (temp)
func _ready():
	create_upgrades()
	read_upgrades()

# To handle when something is selected -- all input starts from the main menu but go over here for the upgrade screen
func handle_selection():
	match $VBoxContainer/Options.get_child( $SelectSquare.index ).name: # Now we see which option has been selected...
		
		"Back":
			hide()
			get_node("../LogoContainer").show()
			get_node("../SelectSquare").show()
		
		var name:
			var node = get_node( "VBoxContainer/Options/" + name )
			print( node, node.get( "upgrade" ) )

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
	
	for i in range( 0, 10 ): # <-- Max upgrades available at a time is 10
		
		var damage = randi() % 100
		var health = randi() % 100
		upgrades.append( {
			"cost": int( ( float(damage)/100 + 1 ) * ( float(health)/100 + 1 ) * 175 ), # A complicated algorithm, I know, but it's the same formula as InfiniteShooter 1.0
			"damage": damage, # out of 100
			"health": health # out of 100
		} )

# Creates labels from the upgrades array
func read_upgrades():
	for i in upgrades:
		var label = create_label( "+{damage}% damage, +{health}% health [{cost} PTS]".format( i ), "" )
		label.name = "Upgrade%s" % upgrades.find( i, 0 )

# Updates the labels
func set_health( value ):
	
	health = value
	$VBoxContainer/Stats/Health.text = "{health}% health".format( { "health": health } )

func set_damage( value ):
	
	damage = value
	$VBoxContainer/Stats/Damage.text = "{damage}% damage".format( { "damage": damage } )

func set_points( value ):
	
	points = value
	$VBoxContainer/Stats/Points.text = "{points} points".format( { "points": points } )
	if points == 1: $VBoxContainer/Stats/Points.text = "1 point"
