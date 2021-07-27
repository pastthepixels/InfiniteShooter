extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _input( event ):
	
	if event is InputEventKey and event.pressed:
		
		# Reparents the logo
		var target = get_parent() # <-- This is the node `MainMenu`.
		var logo = $LogoContainer # <-- This houses the logo, allowing it to be centered AND have an origin point in its middle.
		self.remove_child (logo ) # First we remove the logo from this object.
		target.add_child( logo ) # Then we put it in the parent node.
		logo.set_owner( target ) # Then we tell Godot that the logo's parent is `MainMenu`.
		
		# Gets rid of this background
		queue_free()
		
		# Slides the logo
		logo.get_node( "LogoSlide" ).play( "LogoSlide" )
