extends Node

# Variables!
# Screen positions
var top_left
var top_right
var bottom_left
var bottom_right
# Viewport meaningless stuff
var screen_size
var viewport
# Random number generation
var last_random_number = 0

# Sets some variables when the class is made
func init( theViewport ):
	
	viewport = theViewport
	screen_size = viewport.get_visible_rect().size
	top_left = screen_to_local( Vector2( 0, 0 ) )
	top_right = screen_to_local( Vector2( screen_size.x, 0) )
	bottom_left = screen_to_local( Vector2( 0, screen_size.y ) )
	bottom_right = screen_to_local( Vector2( screen_size.x, screen_size.y ) )

# Converts a screen coordinate to a local one (e.g., Vector2( 0, 0 ) == top left of screen, so it gets the camera and gives the relative position in global 3d coordinates.
func screen_to_local( vector2 ):
	
	return viewport.get_camera().project_position( vector2, viewport.get_camera().transform.origin.y )

func random_screen_point():
	
	var screenPoint = Vector2( rand_range( screen_size.x, 0 ), rand_range( 0, screen_size.y ) )
	return screen_to_local( screenPoint )

func randint( minval, maxval ):
	
	var random_number = int( rand_range( minval, maxval + 1 ) )
	if last_random_number == random_number: # If 2 numbers appear in a row, re-roll a random number.
		
		return randint( minval, maxval )
		
	else:
	
		last_random_number = random_number
		return random_number
