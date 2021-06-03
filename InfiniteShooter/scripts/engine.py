# I'm keeping this here because
# 1. If I remake this I want to know everything I did so I can port it to another engine.
# 2. I don't know

# TASKS
# - [.] Spritesheets
# - [.] Player on its side
# - [.] Enemies (lasers, movement, and death)
# - [.] EXPLOSIONS!
# - [.] Game logic (levels, ammo)
# - [.] Levels
# - [.] Graphics
# - [.] Game over (death screen)
# - [.] Leaderboards
# - [.] Egghead branding
# - [.] Polishing
# - [.] Sound effects
# - [.] Soundtrack
# - [.] Shop
# - [.] Polish (playtesting)
# - [.] User manual
# - [.] Better explosions (optional)

# Imports stuff
import pygame, math, os, threading, time, random

# Sets up audio
pygame.SONG_END = pygame.USEREVENT + 10
pygame.mixer.music.set_endevent( pygame.SONG_END )

# Smooth drawing of polygons with antialiasing
from pygame import gfxdraw
import pygame.locals

# Vector2
class Vector2:
    
    def __init__( self, x, y ):

        self.x = float( x )
        self.y = float( y )
    
    def clone( self ):
        
        return Vector2( self.x, self.y )
    
    def rotate( self, origin, angle ):

        #https://stackoverflow.com/questions/34372480/rotate-point-about-another-point-in-degrees-python
        angle = math.radians( angle )
        ox, oy = ( origin.x, origin.y )
        px, py = ( self.x, self.y )

        qx = ox + math.cos(angle) * (px - ox) - math.sin(angle) * (py - oy)
        qy = oy + math.sin(angle) * (px - ox) + math.cos(angle) * (py - oy)

        return Vector2( qx, qy )
    
    def toPyGame( self ): # Converts the position to a PyGame tuple.

        return ( int( self.x ), int( self.y ) )
    
    def add( self, otherVector ):

        return Vector2( self.x + otherVector.x, self.y + otherVector.y )

# setInterval (but a class) + setTimeout because python doesn't have it because python sucks
intervals = []
timeouts = []
intervalCounter = 0

def checkIntervals():

    while True:

        globals()[ "intervalCounter" ] += 1
        for interval in globals()[ "intervals" ]:

            if globals()[ "intervalCounter" ] % interval.time == 0: interval.ready = True; interval.run();
        
        time.sleep( 1 / 1000 )

intervalThread = threading.Thread( target=checkIntervals )
intervalThread.start()

class Interval:

    def __init__( self, function, time ):

        self.function = function
        self.time = time
        self.ready = True
        self.paused = False

        globals()[ "intervals" ].append( self )
    
    def run( self ):

        if self.paused == False: self.function()

    def kill( self ):
        
        if self in globals()[ "intervals" ]: globals()[ "intervals" ].remove( self )

def pauseAllIntervals():

    for interval in intervals: interval.paused = True

def resumeAllIntervals():

    for interval in intervals: interval.paused = False

def setTimeout( function, timeout ): # Parameters just like in JS.

    global timeouts
    def timeoutFunction( thread, stop ): # The function to run
    
        time.sleep( timeout / 1000 )
        if stop() == False: function()
        timeouts.remove( thread() )

    thread = threading.Thread( target=timeoutFunction, args = ( lambda: thread, lambda: thread.stopped ) ) # Creates a thread.
    thread.start() # Starts the thread.
    thread.stopped = False
    timeouts.append( thread )
    return thread # Returns the thread.


# Scene
class Scene:
    
    def __init__( self, width=400, height=400 ):

        self.width = width # Width of the window (a constant variable)
        self.height = height # Height of the window (a constant variable)
        self.window = pygame.display.set_mode( ( self.width, self.height ), pygame.DOUBLEBUF ) # Creates the window
        self.window.set_alpha( None )
        self.objects = [] # All objects in the scene (an array; can have recursive arrays)
        self.eventListeners = [] # Functions that listen for events in PyGame
        self.extraFunctions = [] # Functions to be ran on each loop
        self.keys = [] # A list of all the currently pressed keys
        self.backgroundColor = "black" # The color of the scene's background
        self.clock = pygame.time.Clock() # Creates a clock to do stuff like get FPS
        self.fps = 60 # Max FPS value
        self.interval = threading.Thread( target=self.updateLoop )
        self.interval.running = True
        self.interval.start()
        self.originPoint = Vector2( 0, 0 )
        self.noEventLoop = False # For special cases where you don't want the game to check for input
        pygame.event.set_allowed( [ pygame.QUIT, pygame.KEYDOWN, pygame.KEYUP ] )

    def updateLoop( self ):

        while self.interval.running: self.update()
        
    def update( self ):

        if self.window == None: return

        # FPS
        self.clock.tick( self.fps ) # Updates the clock
        #print( str(int(self.clock. get_fps())) ) # A quick hack to get the fps

        # Rendering
        self.window.fill( self.backgroundColor ) # Fills the screen with a background color pre-specified
        for object in self.objects: # Goes through each object
            
            self.renderObject( object ) # and renders it (NOTE: Each object is rendered on top of another. This is why we may want to use lists (in case, for example, you want to have a background layer.))
        
        pygame.display.flip() # Updates the display

        # Events/Extra Functions
        self.keys = pygame.key.get_pressed() # Sets an array of all the currently pressed keys as self.keys
        if not self.noEventLoop: self.pygameEventLoop() # Checks for events
        for function in self.extraFunctions: # For every function that is to be ran per loop...

            function() # Well, run it.
    
    def pygameEventLoop( self ): # Code to be ran on every loop when you get python events

        for event in pygame.event.get(): # For every event that exists...

            if event.type == pygame.QUIT: # Checks for if the user presses the X button

                self.quit() # and quits the window.
            
            for eventListener in self.eventListeners: # For every event listener...

                eventListener( event ) # run it with the current event in this loop.

    def addEventListener( self, eventListener ): # Makes Python feel more friendly for my JS self.

        self.eventListeners.append( eventListener ) # Just adds the event listener to the list of event listeners.
    
    def quit( self ): # Exits the scene:
        
        self.interval.kill() # Stops regular scene updates
        pygame.quit() # Stops PyGame
    
    def renderObject( self, object ): # Renders an object:
        
        if type( object ) == list: # If the object is a list...
                
            for subObject in object: # For all objects in this list,

                self.renderObject( subObject ) # render it (or check if it's a list and voila... you have recursion!)
            
            return # And return the function (since you can't render a list.)
        
        # Doesn't render objects that cannot be seen (+making sure we have width and height attributes before checking)
        if hasattr( object, "height" ) and ( object.alpha == 0 or \
            ( object.position.x + object.width * object.scale.x / 2 ) <  0 or\
            ( object.position.y + object.height * object.scale.y / 2  ) < 0 or\
            ( object.position.x - object.width * object.scale.x / 2 ) > self.width or\
            ( object.position.y - object.height * object.scale.y / 2 ) > self.height ): return

        # Note for the below: I'd use a switch statement if I could. Unfortunately I cannot.
        if hasattr( object, "_shadow" ): # We will render a shadow first.
            
            # We don't need to rotate the shadow image because the image has rotational symmetry.
            if type( object ).__name__ == "Image":

                final = pygame.transform.scale( object._shadow, Vector2( object.width + object.shadowSize, object.height + object.shadowSize ).toPyGame() ) # <- Does the scaling stuffle BUT with the object's shadow image!
                self.window.blit( final, Vector2( object.position.x - object.width/2 - object.shadowSize/2, object.position.y - object.height/2 - object.shadowSize/2 ).add( self.originPoint ).toPyGame() )
            
            if type( object ).__name__ == "Polygon":
                
                object.calculateBoundingBox()
                final = pygame.transform.scale( object._shadow, Vector2( object.width + object.shadowSize, object.height + object.shadowSize ).toPyGame() ) # <- Does the scaling stuffle BUT with the object's shadow image!
                self.window.blit( final, Vector2( object._renderPosition.x - object.shadowSize/2, object._renderPosition.y - object.shadowSize/2 ).add( self.originPoint ).toPyGame() )

        if type( object ).__name__ == "Image": # If the object ia an image...
        
            scaled = pygame.transform.smoothscale( object._pygame, ( int( object._origWidth * object.scale.x ), int( object._origHeight * object.scale.y ) ) ) # <- Multiplies the UNSCALED/ROTATED width/height of the object by the scale (because the scale function scales to an absolute size in pixels)
            rotated = object.rotate( object.rotation, scaled ) # Rotates the scaled image
            rotated[ 0 ].set_alpha( 255 * object.alpha ) # Sets that image's transparency to whatever the object's alpha is (max is apparently 255 where object.alpha's max is 1, so we * 255 by object.alpha)
            self.window.blit( rotated[ 0 ], Vector2( rotated[ 1 ][ 0 ] - object.width/2, rotated[ 1 ][ 1 ] - object.height/2 ).add( self.originPoint ).toPyGame(), object.spritesheetParams  ) # <- Centres the object by adding half its width and subtracting half its height from the top left corner
        
        if type( object ).__name__ == "Polygon": # Otherwise, if it's a polygon...
        
            object.draw()
            self.window.blit( object._pygame, object._renderPosition.add( self.originPoint ).toPyGame() )
        
        if type( object ).__name__ == "Text": # Otherwise, if it's text drawn to an image...
        
            object.draw()
            # Same as above without centering
            scaled = pygame.transform.scale( object._pygame, ( int( object._origWidth * object.scale.x ), int( object._origHeight * object.scale.y ) ) ) # <- Multiplies the UNSCALED/ROTATED width/height of the object by the scale (because the scale function scales to an absolute size in pixels)
            rotated = object.rotate( object.rotation, scaled ) # Rotates the scaled image
            rotated[ 0 ].set_alpha( 255 * object.alpha ) # Sets that image's transparency to whatever the object's alpha is (max is apparently 255 where object.alpha's max is 1, so we * 255 by object.alpha)
            self.window.blit( rotated[ 0 ], Vector2( rotated[ 1 ][ 0 ], rotated[ 1 ][ 1 ] ).add( self.originPoint ).toPyGame(), object.spritesheetParams  ) # <- Doesn't center text for many reasons


    # Songs/soundtrack
    def setSong( self, url ):

        pygame.mixer.music.load( url )
    
    def playSong( self, loop = False ):

        if loop == False: pygame.mixer.music.play()
        if loop == True: pygame.mixer.music.play( -1 )
    
    def crossfadeSong( self, url, slownessFactor=1 ):

        def fadeOut():
            
            def loop( animationProgress ): pygame.mixer.music.set_volume( 1 - animationProgress )
            def callback(): self.setSong( url ); self.playSong(); fadeIn()
            crossfadeAnimation = Animation( slownessFactor )
            crossfadeAnimation.loop = loop
            crossfadeAnimation.callback = callback
            crossfadeAnimation.start()
        
        def fadeIn():
            
            crossfadeAnimation = Animation( slownessFactor )
            def loop( animationProgress ): pygame.mixer.music.set_volume( animationProgress )
            crossfadeAnimation.loop = loop
            crossfadeAnimation.start()
        
        fadeOut()
    
    def pauseSong( self ): pygame.mixer.music.pause()
    
    def unpauseSong( self ): pygame.mixer.music.unpause()

# SurfaceObject --> Pygame uses "Surfaces" for drawing so this is the base of all images (and possibly other things)
class SurfaceObject:
    
    def __init__( self, size=Vector2( 64, 64 ), position=Vector2( 0, 0 ) ): # This function was copied over from the Image __init__ function. Nothing is different except we create a Surface with a predefined size.

        self.position = position
        self.rotation = 0
        self.scale = Vector2( 1, 1 )
        self.alpha = 1
        self._pygame = pygame.Surface( ( 64, 64 ) ) # Creates a pygame.Surface with a predefined size
        self._origWidth, self._origHeight = self._pygame.get_size()
        self.animating = False

    def calculateBoundingBox( self, object ):

        if not self.animating: self.width, self.height = object.get_size()
        return [ pygame.math.Vector2( position.toPyGame() ) for position in [ Vector2( 0, 0 ), Vector2( self.width, 0 ), Vector2( self.width, -self.height ), Vector2( 0, -self.height ) ] ]
        # ^ Returns a pygame Vector2 for a bounding box of an object. Adopted from the Internet for my usage.
        #   Positions represent (in order): Top left corner, top right corner, bottom right corner, bottom left corner
    
    def rotate( self, angle, object ):

        # I found this code on the Web and have no idea what it really does. However, I *do* know a bit of Python, so I should be able to tell you what it does.
        # I also edited the code to remove redundancies and spin it to my programming style and classes (like Vector2)
        boundingBox = self.calculateBoundingBox( object ) # Gets the bounding box of the object
        boundingBoxRotated = [ position.rotate( self.rotation ) for position in boundingBox ] # Gets each position already in the bounding box and rotates it
        bbMin = Vector2( min( boundingBoxRotated, key=lambda p: p[ 0 ] )[ 0 ], min( boundingBoxRotated, key=lambda p: p[ 1 ] )[ 1 ] )
        bbMax = Vector2( max( boundingBoxRotated, key=lambda p: p[ 0 ] )[ 0 ], max( boundingBoxRotated, key=lambda p: p[ 1 ] )[ 1 ] )
        # ^ For each x and y value it either gets the minimum value of [x] or the max value of [x], depending on if it is the minimum point on the bounding box (top left I think) or the maximum point (bottom right I think) 
        #   --> Looks like the min/max functions return a tuple which is a position. Hence the [0] and [1] after the functions
        #   What is in these min/max functions? "boundingBoxRotated, key=lambda p:p[0]". Probably saying: Get the lowest/highest position, and rank each position based on how big the X value on each position (p) is.
        #   --> Note: Although I don't know how they work, lambdas are apparently good for mini-functions so this is probably looking like a find function in JS where the condition is actually the return value of a function
        center = pygame.math.Vector2( self.width / 2 , -self.height / 2 ) # A pygame Vector2 which will be rotated using pygame's method.
        centerRotated = center.rotate( angle ) # Another variable which rotates the center of the object by the angle provided in the function
        centerMoved   = centerRotated - center # Then gets the difference between the rotated variable and the center of the object (Why? I don't know!)
        origin = [ self.position.x + bbMin.x - centerMoved[ 0 ], self.position.y - bbMax.y + centerMoved[ 1 ] ] # The "origin" of the object. Don't know what this does but it returns x and y values for rendering an object. These values actually represent the top left corner of an object like PyGame'd normally do.
        rotatedObject = pygame.transform.rotate( object, self.rotation )
        return ( rotatedObject, origin ) # Returns a tuple of the parameters you'd need to blit the rotated thing
    
    def collides( self, object ): # Creates a pygame rect for the bounding box of each image then uses its colliderect function.

        return pygame.Rect( self.position.x - self.width / 2, self.position.y - self.height / 2, self.width, self.height ).colliderect( pygame.Rect( object.position.x - object.width / 2, object.position.y - object.height / 2, object.width, object.height ) ) # We do subtraction here because we need to get the objects' top left corners from their centres.


# Image
class Image( SurfaceObject ):
    
    def __init__( self, url, position=Vector2( 0, 0 ), pygameObject=None ):

        self.url = url # Sets the "url" for the object so the user can see where the image was from
        self.position = position # The position value for the object. A Vector2.
        self.rotation = 0 # The rotation value for the object, in degrees.
        self.scale = Vector2( 1, 1 ) # The scale for the object; a Vector2.
        self.alpha = 1 # The alpha value for the object (0-1)
        self.spritesheetParams = None
        self.animating = False
        if pygameObject == None:

            self._pygame = pygame.image.load( os.path.join( self.url ) ).convert_alpha() # Makes the image
        
        else:

            self._pygame = pygameObject.copy() # or uses a pre-loaded one
        
        self._origWidth, self._origHeight = self._pygame.get_size() # Gets the size of that image and sets that as the "original" width and height (since .width and .height are calculated from calculateBoundingBox)
        self.calculateBoundingBox( self._pygame )

    def addShadow( self, url ): # Adds a shadow image to the object

        self._shadow = pygame.image.load( os.path.join( url ) ).convert_alpha() # Makes the image
        self.shadowSize = 40 # How much bigger the shadow is than the object, in pixels
        return self # So you can go image = Image(...).addShadow(...)

    def changeURL( self, url ): # "Recompiles" the image with a new url

        self.url = url
        self.change( pygame.image.load( os.path.join( self.url ) ).convert_alpha() )
    
    def change( self, pygameImage ): # Sets a new image

        self._pygame = pygameImage # Sets the image
        self._origWidth, self._origHeight = self._pygame.get_size() # Gets the size of that image and sets that as the NEW "original" width and height
    
    def spritesheet( self, x, y, width, height ):

        self.spritesheetParams = pygame.Rect( x, y, width, height )
        self.origWidth = width; self.origHeight = height # If a new height/width for the image is defined, it must be more accurate than the currently defined 'original' (without rotation applied) width and height
    
    def animateSpritesheet( self, rows, columns, width, height, speed=100, callback=None, maxFrames=None, loop=False ): # Animates a spreadsheet. This has not been tested with rotated images.

        self._row = 0 # First we set a row and column counter
        self._column = 0
        self.loopAnimation = loop
        self.animating = True
        width *= self.scale.x # Then we multiply the frame width/height by the scale of the image
        height *= self.scale.y
        self.width = width
        self.height = height

        def intervalFunction(): # Then we create an interval

            if ( self._column >= columns and self._row >= rows ) or ( maxFrames != None and ( self._column * self._row >= maxFrames ) ) or self.animating == False:
                
                if callback != None: callback()
                interval.kill()
                self.animating = False
                if self.loopAnimation == True: self.animateSpritesheet( rows, columns, width, height, speed, callback, maxFrames, loop )
                return # If we've reached the total number of rows and columns, quit the interval

            if self._column == columns: self._column = 0; self._row += 1 # If we've just reached the end of the total number of columns, reset that number and move down a row
            self.spritesheet( self._column * width, self._row * height, width, height ) # "Crops" the image to z
            self._column += 1 # Now just move up the counter for a column by one. (So we read right to left and then down.)
        
        intervalFunction()
        interval = Interval( intervalFunction, speed )
        return interval

# Polygon
class Polygon:

    def __init__( self, points, scene, position=Vector2( 0, 0 ) ):

        self.points = points # List of tuples (positions)
        self.color = "white" # The color of the object
        self.scene = scene # The scene which the object will be drawn to.
        self.scale = Vector2( 1, 1 ) # The scale of the object (a Vector2)
        self._renderPosition = Vector2( 0, 0 )
        self.alpha = 1 # The alpha value of the object (max 1)
        self.position = position # The position of the object (a Vector2)
        self.calculateBoundingBox()

    def addShadow( self, url ): # Adds a shadow image to the object

        self._shadow = pygame.image.load( os.path.join( url ) ).convert_alpha() # Makes the image
        self.shadowSize = 40 # How much bigger the shadow is than the object, in pixels
        return self # So you can go image = Polygon(...).addShadow(...)

    def calculateBoundingBox( self ):

        # "Compiles points": applies scale + position
        self.compiledPoints = [ [ ( pos[ 0 ] * self.scale.x ) + self.position.x, ( pos[ 1 ] * self.scale.y ) + self.position.y ] for pos in self.points ]
        
        # Separates every point into x and y coords
        xCoords, yCoords = zip( *self.compiledPoints )
        
        # Creates a bounding box, one position with the minimum of the x and y coords and one position with the x maximum x and y coordinates.
        self.boundingBox = [ ( min( xCoords ), min( yCoords ) ), ( max( xCoords ), max( yCoords ) ) ]

        # Gets the width and height from the difference between the minimum point and the maximum point
        self.width = self.boundingBox[ 1 ][ 0 ] - self.boundingBox[ 0 ][ 0 ] + 1
        self.height = self.boundingBox[ 1 ][ 1 ] - self.boundingBox[ 0 ][ 1 ] + 1

        # Sets the object's "render position" and creates a pygame.Surface with the bounding box's width and height
        self._renderPosition = Vector2( self.boundingBox[ 0 ][ 0 ], self.boundingBox[ 0 ][ 1 ] )
        self._pygame = pygame.Surface( ( int( self.width ), int( self.height ) ), pygame.SRCALPHA ).convert_alpha()

    def draw( self ): # Draws a polygon with applied scale and add the position of the object to that to get "absolute" positions.

        self.calculateBoundingBox()
        self._pygame.set_alpha( 255 * self.alpha )
        self._pygame.fill( ( 0, 0, 0, 0 ) )
        pygame.draw.polygon( self._pygame, pygame.Color( self.color ), [ [ point[ 0 ] - self.boundingBox[ 0 ][ 0 ], point[ 1 ] - self.boundingBox[ 0 ][ 1 ] ] for point in self.compiledPoints ] )

# Text
class Text( Image ):

    def __init__( self, text, scene, position=Vector2( 0, 0 ) ):

        self.text = text # List of tuples (positions)
        self.color = "white" # The color of the object
        self.size = 20 # The object's font size
        self.scene = scene # The scene which the object will be drawn to.
        self.scale = Vector2( 1, 1 ) # The scale of the object (a Vector2)
        self.position = position # The position of the object (a Vector2)
        self.rotation = 0 # The rotation value for the object, in degrees.

        # Image stuff
        self.alpha = 1 # The alpha value for the object (0-1)
        self.spritesheetParams = None
        self.animating = False
    
    def draw( self ): # Draws a polygon with applied scale and add the position of the object to that to get "absolute" positions.

        font = pygame.font.SysFont( None, self.size )
        self._pygame = font.render( str( self.text ), True, self.color )
        self._origWidth, self._origHeight = self._pygame.get_size()
        self.calculateBoundingBox( self._pygame )

# Sounds
class Sound:

    def __init__( self, url, volume=1 ):

        self.url = url
        self._pygame = pygame.mixer.Sound( url )
        self._pygame.set_volume( volume )
    
    def play( self ):

        pygame.mixer.Sound.play( self._pygame )

# Animations
class Animation:

    def __init__( self, slownessFactor=1 ):

        self.keyframe = 0
        self.slownessFactor = slownessFactor
        self.callback = None
    
    def start( self ):

        self.interval = Interval( self.animateFunction, 16 )
    
    def animateFunction( self ):

        # If the keyframe has reached 1 (max keyframe), stop.
        if self.keyframe > 1:
            
            self.keyframe = 1
            self.interval.kill()
            if self.callback != None: self.callback()

        # Sets the "animation progress", the multiplier in an animation. Say you want to get from # A to # B: currNumber = a - animationProgress * ( a - b )
        animationProgress = 1 - math.pow( 1 - self.keyframe, 3 )
        # Does a callback function that runs every loop, passing the animationProgress variable to that function
        self.loop( animationProgress )
        # Increases the keyframe number by a small amount
        self.keyframe += .02 / self.slownessFactor

# Generating random numbers that don't repeat
previousNumber = None
def trueRandom( min, max ):

    number = random.randint( min, max )
    if number == globals()[ "previousNumber" ]: return trueRandom( min, max )
    globals()[ "previousNumber" ] = number
    return number
