# NOTE: I consider this code very messy because of the following:
# 1) Because python doesn't have this thing where you can seamlessly update the screen AND run code (setTimeout), I have to use the threading module
# 2) The module leads to delays in delcaring variables:
#    For instance, you can get a powerup right as it diappears, and two functions are called. Both say to remove the powerup from the array "powerups".
#    Thus for one function you would get an "x not in list" error because the powerup has already been removed before the next function could get to it.
#    (Don't worry, I fixed this particular bug. You have to do a lot of "if x in y" sort of statements to fix all of them, at which point Python is
#    cclearly not working out for you.)

# Modules
from pathlib import Path # For setting BASEPATH
import getpass # for getting the user's name
import json # for saving lists to files
import sys, os # For quitting the game

# Quick! Before we do anything else!
# This is copied from PyGame's code --> [Line 38] https://github.com/pygame/pygame/blob/6746053d1cda4c194a617e696b6eca06414e80b7/src_py/__init__.py
# except we are switching wm_class to InfiniteShooter.
# Look at the top bar in GNOME when playing InfiniteShooter.
# Does it say "InfiniteShooter" or "game.py"? That's basically what we're doing.
if "DISPLAY" in os.environ and "SDL_VIDEO_X11_WMCLASS" not in os.environ:
        os.environ[ "SDL_VIDEO_X11_WMCLASS" ] = "InfiniteShooter"

# OK, now we import PyGame (and the engine)
from engine import *

# Global variables / constants
BASEPATH = str( Path(__file__).parent.parent.absolute() ) # Gets directory "[...]/InfiniteShooter"
IMAGE_CACHE = {}
MUSIC_VOL = 1
SFX_VOL = 1
ROUNDED_RECT_VERTS = [
    [
        [ -1.0 , 0.4 ], # Top left
        [ -0.9 , 0.7 ],
        [ -0.7 , 0.9 ],
        [ -0.4 , 1.0 ],
    ],
    [
        [ 0.4 , 1.0 ], # Top right
        [ 0.7 , 0.9 ],
        [ 0.9 , 0.7 ],
        [ 1.0 , 0.4 ],
    ],
    [
        [ 1.0 , -0.4 ], # Bottom right
        [ 0.9 , -0.7 ],
        [ 0.7 , -0.9 ],
        [ 0.4 , -1.0 ],
    ],
    [
        [ -0.4 , -1.0 ], # Bottom left
        [ -0.7 , -0.9 ],
        [ -0.9 , -0.7 ],
        [ -1.0 , -0.4 ]
    ]

]
alertString = ""
terminalOut = ""
mayhem = False # Mayhem mode. You have very powerful bullets, but regular health, and enemies spawn every second. Your ammo capacity will also be reduced to 20 bullets.

# Command-line parameters
if len( sys.argv ) > 0:

    for argument in sys.argv:
       
        if argument.split( "=" )[ 0 ] == "music_vol":
            
            globals()[ "MUSIC_VOL" ] = float( argument.split( "=" )[ 1 ] )
            print( "Music volume is set to {0}%".format( MUSIC_VOL * 100 ) )
        
        if argument.split( "=" )[ 0 ] == "sfx_vol":
            
            globals()[ "SFX_VOL" ] = float( argument.split( "=" )[ 1 ] )
            print( "Sound effect volume is set to {0}%".format( SFX_VOL * 100 ) )

# Kinda fits here -- Creating a rounded rectangle
def roundedRectangle( height, width, cornerSize=1 ):

    height -= ( 2 * cornerSize ) # First we subtract the width/height of the original plane to get the distance needed to add between corners to get the width to equal the width specified.
    width -= ( 2 * cornerSize )
    height /= cornerSize # Then we divide the height/width by the corner size (scale of the object) so that it fits in the original small scale of the object. We will scale it back up at the end of the function
    width /= cornerSize
    final = [] # This is the "final" geometry of the rectangle
    for vertex in ROUNDED_RECT_VERTS[ 0 ]: final.append( [ vertex[ 1 ] + height / 2, vertex[ 0 ] - width / 2 ] ) # Top left corner
    for vertex in ROUNDED_RECT_VERTS[ 1 ]: final.append( [ vertex[ 1 ] + height / 2, vertex[ 0 ] + width / 2 ] ) # Top right corner
    for vertex in ROUNDED_RECT_VERTS[ 2 ]: final.append( [ vertex[ 1 ] - height / 2, vertex[ 0 ] + width / 2 ] ) # Bottom right corner
    for vertex in ROUNDED_RECT_VERTS[ 3 ]: final.append( [ vertex[ 1 ] - height / 2, vertex[ 0 ] - width / 2 ] ) # Bottom left corner
    return [ [ v[ 0 ] * cornerSize, v[ 1 ] * cornerSize ] for v in final ] # Applies the scale at the end. We are done!

#
# loc:0.5 -- Upgrades
#
UPGRADES = []
POINTS = 0
PLAYER_HEALTH = 1
PLAYER_DAMAGE = .2
def addUpgradeOption( damage=0, health=0, cost=0 ):
    
    name = ""
    if damage > 0: name += "DMG +{0}".format( damage )
    if damage > 0 and health > 0: name += ", "
    if health > 0: name += "HP +{0}".format( health )
    name += " ({0} pts)".format( cost )
    UPGRADES.append( {
        "name": name,
        "damage": damage,
        "health": health,
        "cost": cost,
        "bought": False
    } )

def createUpgradeOptions( number ):

    for upgrade in range( 1, number ):

        dmg = random.randint( 1, 10 ) / 10
        health = random.randint( 1, 10 ) / 10
        addUpgradeOption( dmg, health, int( ( dmg + 1 ) * ( health + 1 ) * 175 ) )

# Adds default upgrade options
createUpgradeOptions( 11 )

def saveData():

    dataFile = open( BASEPATH + "/userdata/userdata.txt", "a" ) # Opens/creates a file under the folder userdata containing points, damage, and health
    dataFile.truncate( 0 ) # Clears the file
    dataFile.write( "{0} {1} {2}".format( POINTS, PLAYER_DAMAGE, PLAYER_HEALTH ) ) # Writes a new line with the points, damage, and health
    dataFile.close() # Closes the file (?)
    with open( BASEPATH + "/userdata/upgrades.json", "w" ) as upgradesFile: upgradesFile.truncate( 0 ); json.dump( globals()[ "UPGRADES" ], upgradesFile ) # Saves list of possible upgrades to a JSON

def loadData():

    try: # Uses try/except to catch any errors that would arise if any of these files did not exist (which is something we don't care about).

        globals()[ "POINTS" ], globals()[ "PLAYER_DAMAGE" ], globals()[ "PLAYER_HEALTH" ] = [ float( n ) for n in open( BASEPATH + "/userdata/userdata.txt", "r" ).read().strip( "[]" ).split( " " ) ] # Reads the userdata file and splits each space. Converts each number to a float and sets the points, damage, and health variables to these values
        with open( BASEPATH + "/userdata/upgrades.json", "r" ) as upgradesFile: globals()[ "UPGRADES" ] = json.load( upgradesFile ) # Gets list of possible upgrades and sets the local variable to that list

    except:

        pass

#
# loc:1 -- Setting and Resetting The Game
#
def setGame( setScene = True ): # Sets variables for the game

    # Loads upgrades + points
    loadData()

    # Global variables for the game
    globals()[ "player" ] = {}
    globals()[ "enemies" ] = []
    globals()[ "powerups" ] = []
    if setScene == True: globals()[ "scene" ] = None
    globals()[ "mainObjects" ] = []
    globals()[ "laserSpace" ] = []
    globals()[ "healthSpace" ] = []
    globals()[ "explosionIntervals" ] = []
    globals()[ "gui" ] = {}
    globals()[ "score" ] = 0
    globals()[ "paused" ] = False
    globals()[ "ended" ] = False
    globals()[ "gameStarted" ] = False
    globals()[ "levelProgress" ] = 0 # max 1
    globals()[ "enemyInterval" ] = None

    # Controllable variables for the game
    globals()[ "enemy1LaserInt" ] = 5000
    globals()[ "enemy2LaserInt" ] = 6000
    globals()[ "enemy3LaserInt" ] = 7000
    globals()[ "enemy1MaxHealth" ] = 1
    globals()[ "enemy2MaxHealth" ] = .6
    globals()[ "enemy3MaxHealth" ] = 1.4
    globals()[ "enemy1Damage" ] = .005
    globals()[ "enemy2Damage" ] = .007
    globals()[ "enemy3Damage" ] = .010
    globals()[ "level" ] = 1

def resetGame( init=True ):

    # Resets variables (but not the scene)
    setGame( False )
    
    # Resets intervals + timeouts
    for i in intervals: i.kill()
    for i in timeouts: i.kill()
    scene.extraFunctions = []
    scene.eventListeners = []
    scene.objects = []

    # Inits the game
    if init == True: initGame()

#
# loc:2 -- Functions to Make Scene Things
#
def makeBackground():

    # Makes 2 backgrounds and appends them to the scene.
    global scene
    background1 = Image( BASEPATH + "/models/renders/spaaace.png", Vector2( scene.width / 2, scene.height / 2 ) )
    background2 = Image( BASEPATH + "/models/renders/spaaace2.png", Vector2( scene.width / 2, -scene.height / 2 ) )
    scene.objects.append( background1 )
    scene.objects.append( background2 )

    def moveBackgrounds(): # Moves the backgrounds downwards. If a background reaches the bottom of the screen, bring it around to the top of the screen.

        if background1.position.y > scene.height * 1.5: background1.position.y = scene.height * -.5
        if background2.position.y > scene.height * 1.5: background2.position.y = scene.height * -.5
        background1.position.y += 10
        background2.position.y += 10
    
    Interval( moveBackgrounds, 10 )

def makePlayer():

    global player
    # Makes the player (an Image) and appends it to the scene
    player = Image( BASEPATH + "/models/renders/player.png", Vector2( globals()[ "scene" ].width / 2, globals()[ "scene" ].height - globals()[ "scene" ].height / 4 ) ).addShadow( BASEPATH + "/assets/shadow.png" )
    globals()[ "mainObjects" ].append( player )
    player.speed = 10 # Sets the player's speed
    player.health = PLAYER_HEALTH # and health 
    player.maxHealth = PLAYER_HEALTH
    player.ammo = 1 # and ammunition capacity (max 1)
    player.maxAmmo = .5
    player.damage = PLAYER_DAMAGE # and damage
    player.reloading = False # This is a variable that determines if the player is reloading or not and should not be changed by the user.
    if globals()[ "mayhem" ] == True: player.health = 1; player.maxHealth = 1; player.damage = math.inf; player.ammo = .2; player.maxAmmo = .2

def makeEnemy():

    enemyType = random.randint( 1, 3 ) # Sets the enemy type to a random integer between 1 and 3 (there are 3 enemy types)

    # Makes the enemy (an Image)
    enemy = Image( "...", Vector2( random.randint( 50, scene.width - 50 ), -30 ), globals()[ "IMAGE_CACHE" ][ "enemyship" + str( enemyType ) ]._pygame ).addShadow( BASEPATH + "/assets/shadow.png" )
    enemy.scale = Vector2( .7, .7 ) # Sets the scale of the enemy image to be a bit small (player ship size)
    enemy.rotation = 180 # Rotates the enemy to face down
    enemy.type = enemyType
    globals()[ "mainObjects" ].append( enemy ) # Adds it to the scene
    globals()[ "enemies" ].append( enemy ) # and to the enemy list
    enemy.intervals = [] # An array for all intervals that the enemy uses

    # Dynamically sets game attributes based on the enemy type.
    if enemyType == 1: enemy.speed = .5; enemy.maxHealth = globals()[ "enemy1MaxHealth" ]; enemy.damage = globals()[ "enemy1Damage" ]; enemy.laserFrequency = random.randint( globals()[ "enemy1LaserInt" ], globals()[ "enemy1LaserInt" ] + 3000 )
    if enemyType == 2: enemy.speed = .7; enemy.maxHealth = globals()[ "enemy2MaxHealth" ]; enemy.damage = globals()[ "enemy2Damage" ]; enemy.laserFrequency = random.randint( globals()[ "enemy2LaserInt" ], globals()[ "enemy2LaserInt" ] + 4000 )
    if enemyType == 3: enemy.speed = .4; enemy.maxHealth = globals()[ "enemy3MaxHealth" ]; enemy.damage = globals()[ "enemy3Damage" ]; enemy.laserFrequency = random.randint( globals()[ "enemy3LaserInt" ], globals()[ "enemy3LaserInt" ] + 5000 )

    # Sets enemy.health, after its max health has been set, to have full health.
    enemy.health = enemy.maxHealth

    # Sets a health bar
    # Background <- Note: it will be "locked on" to the enemy's position so we have to move it up (hence the for loop)
    enemy.healthBG = Polygon( [ [ point[ 0 ], point[ 1 ] - enemy.height / 2 ] for point in [ [-20, -5], [-20, 0], [20, 0], [20, -5] ] ], scene, enemy.position ).addShadow( BASEPATH + "/assets/shadow-red.png" )
    enemy.healthBG.color = "#333333"
    globals()[ "healthSpace" ].append( enemy.healthBG )
    # Foreground
    enemy.healthFG = Polygon( [ [ point[ 0 ], point[ 1 ] ] for point in enemy.healthBG.points ], scene, enemy.position )
    enemy.healthFG.color = "red"
    globals()[ "healthSpace" ].append( enemy.healthFG )

    # Updating the health bars
    def updateEnemyHealth():
        
        global score
        global level
        if enemy.health < 0: enemy.health = 0 # Prevents negative health bars
        enemy.healthFG.points[ 2 ][ 0 ] = enemy.healthFG.points[ 3 ][ 0 ] = 40 * ( enemy.health / enemy.maxHealth ) - 20 # We use the "-20" to center the vertices
        if enemy.health <= 0: killShip( enemy ); # If the enemy is supposed to be dead, kill it.
    
    # Firing a laser
    enemy.updateHealth = updateEnemyHealth
    enemy.updateHealth() # Updates the health bars for good measure
    enemy.intervals.append( Interval( lambda: fireLaser( enemy ), enemy.laserFrequency ) ) # Starts firing lasers

    # Moves the enemy
    def moveEnemy():
        
        enemy.position.y += enemy.speed
        if enemy.position.y > scene.height + enemy.height / 20 - 20: # If it is at the bottom of the screen
            
            player.health -= abs( enemy.health / 4 ) # Hurt the player for not having good gamer skills (makes sure the # is positive so we don't help the player by taking away - health)
            updateHealth() # Updates the player health bars
            killShip( enemy ) # and THEN remove le ship

    enemy.intervals.append( Interval( moveEnemy, 6 ) ) # Starts moving the ship downward

    # Makes the game harder if you find each level easy
    globals()[ "enemyInterval" ].interval = 3000
    if enemy.health == 0: return # Fixing a bug where the enemy is killed faster than python can do these calculations.
    if globals()[ "mayhem" ] == False:
        
        # Arbitrary equation
        intervalTime = ( enemy.health // globals()[ "player" ].damage ) + 1 # finds out how much bullets it takes to kill an enemy
        if intervalTime > 4: intervalTime += 2
        intervalTime /= 10
        intervalTime *= 4000

        # Minimum/maxiumum values
        if intervalTime < 1000: intervalTime = 1000
        if intervalTime > 3200: intervalTime = 3200

        # Changing the interval time
        globals()[ "enemyInterval" ].interval = intervalTime 

def fireLaser( enemy = None ):

    if enemy != None and ( not enemy in globals()[ "mainObjects" ] ): return # If an enemy has been killed, it cannot fire a laser (contrary to popular belief).
    # Creates a laser
    laser = Image( "...", globals()[ "player" ].position.clone(), globals()[ "IMAGE_CACHE" ][ "laser" ]._pygame ) 
    globals()[ "laserSpace" ].append( laser )
    laser.enemy = enemy
    if enemy != None:
        
        laser.position = enemy.position.clone()
        laser.changeURL( BASEPATH + "/models/renders/enemylaser.png" )
        Sound( BASEPATH + "/sounds/enemylaser" + str( enemy.type ) + ".wav", globals()[ "SFX_VOL" ] ).play()
    
    else:

        Sound( BASEPATH + "/sounds/playerlaser.wav", globals()[ "SFX_VOL" ] ).play()

    # Sets an interval to preiodically move up the laser / check if it collides with an enemy
    def moveLaser():
        
        if laser.enemy == None: # If the laser doesn't have an enemy attached to it...

            laser.position.y -= 1 # ...it's from the player, so move it up and check for collisions with enemy ships
            for enemy in globals()[ "enemies" ]:
                
                if laser.collides( enemy ):
                    
                    Sound( BASEPATH + "/sounds/hit" + str( random.randint( 1, 3 ) ) + ".wav", globals()[ "SFX_VOL" ] ).play() # Plays a random "hitting" sound (out of 3 choices)
                    enemy.health -= player.damage
                    if hasattr( enemy, "updateHealth" ): enemy.updateHealth() # The if statements prevents some random issue
                    if random.randint( 1, 5 ) == 1 and enemy.health <= 0: createEnemyDrop( enemy ) # Creates an enemy drop if the player kills a ship
                    endLaser()
        
        else: # Otherwise, it's from an enemy ship and do the opposite

            laser.position.y += 1 # as in moving it down and checking for collisions with the player
            if laser.collides( globals()[ "player" ] ):
                    
                Sound( BASEPATH + "/sounds/hit" + str( random.randint( 1, 3 ) ) + ".wav", globals()[ "SFX_VOL" ] ).play() # Plays a random "hitting" sound (out of 3 choices)
                globals()[ "player" ].health -= laser.enemy.damage
                updateHealth()
                endLaser()

        if laser.position.y < -50 or laser.position.y > scene.height + laser.height: # If it is at the top/bottom of the screen
            
            endLaser() # End the laser.
    
    def endLaser():

        try: # Sometimes the laser is to end before the interval is declared! So we use a try/catch statement to ward off any errors (by the next cycle this function should be called again and "interval" would be declared)

            globals()[ "laserSpace" ].remove( laser ) # Removes the laser
            interval.kill() # and ends the "moving" interval.
        
        except:
            
            pass
    
    interval = Interval( moveLaser, 1 ) # Still in the function!

#
# loc:3 -- Functions to Blow Up Scene Things
#
def shakeScreen( duration, jank=10 ):

    def shaking(): scene.originPoint = Vector2( random.randint( 0, jank ) / 10 - ( jank / 20 ), random.randint( 0, jank ) / 10 - ( jank / 20 ) )
    def stopShaking(): interval.kill(); scene.originPoint = Vector2( 0, 0 )
    interval = Interval( shaking, 40 )
    setTimeout( stopShaking, duration )

def explosion( position, scale=Vector2( 1, 1 ) ):
   
    # Creates an explosion at a  position
    image = Image( BASEPATH + "/models/renders/explosion.png", position )
    image.scale = scale
    def callback(): globals()[ "healthSpace" ].remove( image ); globals()[ "explosionIntervals" ].remove( animationInterval ) # Removes the image when finished
    animationInterval = image.animateSpritesheet( 5, 5, 128, 128, 15, callback ) # Animates the image
    globals()[ "explosionIntervals" ].append( animationInterval ) # Animates the image
    globals()[ "healthSpace" ].append( image ) # Adds it to the scene (it's about at the same z position as healthSpace)

def createEnemyDrop( ship ):

    # Generates a drop type
    dropType = random.randint( 1, 3 )
    imagePath = ""
    
    # Loads an image
    if dropType == 1: imagePath = "health_animation"
    if dropType == 2: imagePath = "ammo_animation"
    if dropType == 3: imagePath = "enemy_kill_animation"

    # Creates an image at the ship's position
    image = Image( BASEPATH + "/models/renders/" + imagePath + ".png", ship.position )
    image.animation = image.animateSpritesheet( 6, 7, 64, 64, 20, None, 40, True ) # Animates it indefinately
    image.type = dropType
    globals()[ "powerups" ].append( image )
    globals()[ "mainObjects" ].append( image ) # Adds it to the scene

    # Explodes the image after some time (also handles removing when the player picks up the powerup)
    def removeImage():
    
        if image in globals()[ "powerups" ]: globals()[ "powerups" ].remove( image ); image.loopAnimation = False; image.animation.kill(); globals()[ "mainObjects" ].remove( image )
    
    image.removeSelf = removeImage

    def explodeImage():
        
        if image in globals()[ "powerups" ]: explosion( image.position, Vector2( .6, .6 ) ); removeImage()
    
    setTimeout( explodeImage, 5000 )

def wipeEnemies(): # Wipes enemies from the face of the earth

    # Kills enemies
    # Note: Because the "enemies" variable can change to add a new enemy just as this is called, we make sure NOTHING IS LIVING by running this a couple of times.
    # I bet on another programming language we wouldn't have this problem where a variable changes before a function called before the variable change can do anything about it.
    def wiping():
        
        for enemy in globals()[ "enemies" ]: killShip( enemy ); enemy.position = Vector2( -100, -100 ) # Kills all ships (and moves them out of the way for collision intervals that have not stopped yet)
    
    interval = Interval( wiping, 50 ) # Runs this on an interval

    # Then we stop the wiping interval after 300 milliseconds -- letting the previous interval not ending too soon, and not looping for too long.
    def stopWipe(): interval.kill()
    setTimeout( stopWipe, 300 )
    
def killShip( ship ):

    if ship not in globals()[ "mainObjects" ]: return # If the ship's already been removed/blown up, what's the point of removing it/blowing it up again?

    # Creates an explosion at the ship's position
    explosion( ship.position )
    if ship in globals()[ "mainObjects" ]: globals()[ "mainObjects" ].remove( ship ) # Removes the ship
    shakeScreen( 500, 20 )

    # Plays a cool sound! (at random with 3 explosions to choose from)
    Sound( BASEPATH + "/sounds/explosion" + str( random.randint( 1, 3 ) ) + ".wav", globals()[ "SFX_VOL" ] ).play()

    if ship in globals()[ "enemies" ]: # If the ship is an enemy ship

        globals()[ "healthSpace" ].remove( ship.healthBG ) # and its background/foreground health bars
        globals()[ "healthSpace" ].remove( ship.healthFG )
        globals()[ "enemies" ].remove( ship ) # and remove it from the enemy list
        for interval in ship.intervals: interval.kill() # Stops all intervals
    
    elif ship == globals()[ "player" ] and globals()[ "ended" ] == False and checkKeys in scene.extraFunctions: # Otherwise, if it's the player who is to be dead... (Note: that last part of this line makes sure that the game doesn't run the end screen twice.)

        scene.extraFunctions.remove( checkKeys )
        scene.extraFunctions.remove( gameChecks )
        pauseAllIntervals() # Pauses every interval
        scene.interval.paused = False # except the updating one
        for interval in globals()[ "explosionIntervals" ]: interval.paused = False # okay, and any animations.
        globals()[ "POINTS" ] += score # Adds up the "points" variable for purchasing stuff
        setTimeout( showGameOverScreen, 256 ) # Loads the game over screen
        saveData() # Saves the game data
        globals()[ "ended" ] = True # and tells the program that the game ended.
#
# loc:4 -- Just GUI Things
#
def makeHUD():

    global scene
    global player
    global gui
    
    # Creates the background for the health bar
    healthBG = Polygon( [ [20, 0], [0, 50], [170, 50], [190, 0] ], scene, Vector2( 40, 40 ) ).addShadow( BASEPATH + "/assets/shadow.png" )
    healthBG.color = "#222222"
    scene.objects.append( healthBG )

    # Creates the foreground for the health bar
    health = Polygon( [ [20, 0], [0, 50], [170, 50], [190, 0] ], scene, Vector2( 40, 40 ) )
    health.color = "#44dd44"
    scene.objects.append( health )

    # Creates the background for the ammunition bar
    ammoBG = Polygon( [ [0, 50], [8, 30], [178, 30], [170, 50] ], scene, Vector2( 40, 40 ) )
    ammoBG.color = "#222222"
    scene.objects.append( ammoBG )

    # Creates the foreground for the ammunition bar
    ammo = Polygon( [ [0, 50], [8, 30], [178, 30], [170, 50] ], scene, Vector2( 40, 40 ) )
    ammo.color = "#5e5c64"
    scene.objects.append( ammo )

    # Creates the bottom statistics bar
    statsBG = Polygon( [ [0, 20], [0, 0], [scene.width, 0], [scene.width, 20] ], scene, Vector2( 0, scene.height - 20 ) ).addShadow( BASEPATH + "/assets/shadow.png" )
    statsBG.color = "#e01b24"
    scene.objects.append( statsBG )

    stats = Text( "If you can see this, something has gone horribly wrong.", scene, Vector2( 20, scene.height - 14 ) )
    stats.color = "#f6f5f4"
    stats.size = 16
    scene.objects.append( stats )

    # Adds these variables to the "gui" dictionary
    gui[ "healthBackground" ] = healthBG
    gui[ "health" ] = health
    gui[ "ammoBackground" ] = ammoBG
    gui[ "ammo" ] = ammo
    gui[ "statsBackground" ] = statsBG
    gui[ "stats" ] = stats

def showGameOverScreen():

    # Dims volume a bit
    pygame.mixer.music.set_volume( .4 )

    # Creates/fades in the game over image
    image = Image( BASEPATH + "/models/renders/gameover.png", Vector2( scene.width / 2, 300 ) )
    image.scale = Vector2( .6, .6 )
    image.alpha = 0
    scene.objects.append( image )
    animation = Animation( 10 )
    def __anim( progress ): image.alpha = progress
    animation.loop = __anim
    animation.start()
    def makeFirstText():

        text = Text( "press Q to quit", scene, Vector2( scene.width / 2, 350 ) ) # Makes some text
        text.alpha = 0
        text.draw()
        text.position.x -= text.width / 2
        scene.objects.append( text )

        animation = Animation( 5 ) # and fades it in
        def __anim( progress ): text.alpha = progress
        animation.loop = __anim
        animation.start()

    def makeSecondText():

        text = Text( "press R to restart", scene, Vector2( scene.width / 2, 375 ) ) # Makes some MORE text
        text.alpha = 0
        text.draw()
        text.position.x -= text.width / 2
        scene.objects.append( text )

        animation = Animation( 5 ) # and fades that in too
        def __anim( progress ): text.alpha = progress
        animation.loop = __anim
        animation.start()
    
    def makeThirdText():

        text = Text( "press M to go back to the main menu", scene, Vector2( scene.width / 2, 400 ) ) # Makes some MORE text
        text.alpha = 0
        text.draw()
        text.position.x -= text.width / 2
        scene.objects.append( text )

        animation = Animation( 5 ) # and fades that in too
        def __anim( progress ): text.alpha = progress
        animation.loop = __anim
        animation.start()
    
    # Writes a score to the scores.txt file
    scoreFile = open( BASEPATH + "/userdata/scores.txt", "a" ) # Opens/creates a file under the folder userdata containing scores
    scoreFile.write( "{0} --> {1}\n".format( getpass.getuser(), str( int( score ) ) ) ) # Writes a new line with the username, an arrow, their score, and then space for a new line.
    # Note: Why bother to type in a username when you already have one? This also allows others to play on their own accounts and still have different named entries.
    scoreFile.close() # Closes the file (?)

    setTimeout( makeFirstText, 1024 )
    setTimeout( makeSecondText, 2048 )
    setTimeout( makeThirdText, 3072 )

def alert( string, duration=2000 ): # Lets you alert something to the player via a prompt.

    # Makes text
    text = Text( string, scene, Vector2( scene.width / 2, scene.height - 100 ) )
    text.draw()
    text.position.x -= text.width / 2
    text.position.y -= text.height / 2

    # Makes a background
    background = Polygon( roundedRectangle( text.width + 30, 50, 20 ), scene, Vector2( scene.width / 2, scene.height - 100 ) )
    background.color = "#3d3846"
    background.alpha = .95
    scene.objects.append( background )

    # Scaling in
    openAnimation = Animation( .4 )
    def __loop( animProgress ):  background.scale.x = background.scale.y = text.scale.x = text.scale.y = animProgress
    openAnimation.loop = __loop
    openAnimation.start()

    # Fading out
    animation = Animation()
    def __loop( animProgress ): background.alpha = text.alpha = 1 - animProgress
    def __finished(): scene.objects.remove( background ); scene.objects.remove( text )
    animation.loop = __loop
    animation.callback = __finished
    setTimeout( animation.start, duration )

    # Adds text
    scene.objects.append( text )

#
# loc:5 -- Updates and Checks
#
def updateHealth():

    global gui
    if player.health < 0: player.health = 0;
    if player.health <= 0: killShip( player ); # If the player is dead, the player is dead.
    if player.health <= 0 and gui[ "health" ] in scene.objects: scene.objects.remove( gui[ "health" ] )
    gui[ "health" ].points[ 2 ][ 0 ] = 170 * ( player.health / player.maxHealth )
    gui[ "health" ].points[ 3 ][ 0 ] = 170 * ( player.health / player.maxHealth ) + 20 # The +20 adds the skew we need

def updateAmmo():

    globals()[ "gui" ][ "ammo" ].points[ 2 ][ 0 ] = 170 * ( player.ammo / player.maxAmmo ) + 8 # The +8 adds the skew we need
    globals()[ "gui" ][ "ammo" ].points[ 3 ][ 0 ] = 170 * ( player.ammo / player.maxAmmo )

def updateStats(): globals()[ "gui" ][ "stats" ].text = "Level {0}   Score {1}   FPS: {2:02d}   {3}".format( level, int( score ), int( scene.clock.get_fps() ), alertString ) # Code golf

def updateTerminal():

    global levelProgress
    print("\033c") # Clears everything
    print( "InfiniteShooter\n---------------" )
    print( ( "Level {0}: [" + ( "█" * int( levelProgress * 20 ) ).ljust( 20 ) + "]" ).format( level ) ) # Does some fancy formatting to show a progress bar for the current level.
    print( terminalOut )

def setTerminalOut( stuff ): globals()[ "terminalOut" ] = str( stuff )

def checkKeys():

    global scene
    if paused == True: return # This function will be executed even though the game is paused. This is bad.

    # Moving left and right
    if scene.keys[ pygame.K_LEFT ]:
        
        player.position.x -= player.speed
        if player.position.x <= -1: player.position.x = 600 # If the player hits the left side, wrap it around to the right side.

    if scene.keys[ pygame.K_RIGHT ]:
        
        player.position.x += player.speed
        if player.position.x >= scene.width: player.position.x = 0 # If the player hits the right side, wrap it around to the left side.
    
    # Moving up and down
    if scene.keys[ pygame.K_UP ]:
        
        player.position.y -= player.speed
        if player.position.y <= -1: player.position.y = 0 # If the player hits the top, make it so that it can't go further up
    
    if scene.keys[ pygame.K_DOWN ]:
        
        player.position.y += player.speed
        if player.position.y >= scene.height - player.height / 2 - 20: player.position.y = scene.height - player.height / 2 - 20 # If the player hits the bottom, make it so that the player can't go further down.

    # Setting player images
    # Changes the player image based on keys. Below we just make sure we don't inaccurately think the player is on its side when they are pressing the right and left keys at the same time.
    
    # Fist we reset it to the default value
    player.changeURL( BASEPATH + "/models/renders/player.png" )
    
    # Left and right
    if scene.keys[ pygame.K_LEFT ] and not scene.keys[ pygame.K_RIGHT ]: player.changeURL( BASEPATH + "/models/renders/player-left.png" )
    if scene.keys[ pygame.K_RIGHT ] and not scene.keys[ pygame.K_LEFT ]: player.changeURL( BASEPATH + "/models/renders/player-right.png" )
    
    # Up and down
    if scene.keys[ pygame.K_UP ] and not scene.keys[ pygame.K_DOWN ]: player.changeURL( BASEPATH + "/models/renders/player-up.png" )
    if scene.keys[ pygame.K_DOWN ] and not scene.keys[ pygame.K_UP ]: player.changeURL( BASEPATH + "/models/renders/player-down.png" )

    # Diagonal left
    if scene.keys[ pygame.K_LEFT ] and scene.keys[ pygame.K_DOWN ]: player.changeURL( BASEPATH + "/models/renders/player-down-left.png" )
    if scene.keys[ pygame.K_LEFT ] and scene.keys[ pygame.K_UP ]: player.changeURL( BASEPATH + "/models/renders/player-up-left.png" )
    
    # Diagonal right
    if scene.keys[ pygame.K_RIGHT ] and scene.keys[ pygame.K_DOWN ]: player.changeURL( BASEPATH + "/models/renders/player-down-right.png" )
    if scene.keys[ pygame.K_RIGHT ] and scene.keys[ pygame.K_UP ]: player.changeURL( BASEPATH + "/models/renders/player-up-right.png" )
    

def checkKeyTaps( event ):

    if event.type == pygame.KEYDOWN and event.key == pygame.K_q and ( globals()[ "paused" ] == True or globals()[ "ended" ] == True ): quitGame() # If the game is paused and the "Q" key is pressed, quit the game.
    if event.type == pygame.KEYDOWN and event.key == pygame.K_r and globals()[ "ended" ] == True: resetGame(); Sound( BASEPATH + "/sounds/gui-use.wav", globals()[ "SFX_VOL" ] ).play()
    if event.type == pygame.KEYDOWN and event.key == pygame.K_m and ( globals()[ "paused" ] == True or globals()[ "ended" ] == True ): # GOing back to the main menu
        
        resetGame( False ) # Resets the game without restarting it
        scene.interval.running = False;
        setGame() # Does everything at the start of the game (but skips the Egghead screen)
        initScene()
        startScreen()
    
    if event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE and globals()[ "gameStarted" ] == True: # With the last part we have to make sure the game is paused BY the user and not by freezing the game for UI

        globals()[ "paused" ] = not globals()[ "paused" ]
        if globals()[ "paused" ] == False: resumeAllIntervals(); resume(); Sound( BASEPATH + "/sounds/unpause.wav", globals()[ "SFX_VOL" ] ).play()
        if globals()[ "paused" ] == True: pauseAllIntervals(); scene.interval.paused = False; pause(); Sound( BASEPATH + "/sounds/pause.wav", globals()[ "SFX_VOL" ] ).play() # Doesn't pause the scene updating interval so we can do these checks
    
    if globals()[ "paused" ] == True or globals()[ "ended" ] == True: return # The rest of this function will be executed even though the game is paused/ended. This is bad.

    if event.type == pygame.KEYDOWN and event.key == pygame.K_SPACE and player.ammo > 0 and player.reloading == False: # If the space key is CLICKED (not pressed) + the player has ammunition left and isn't reloading
        
        fireLaser() # fire a laser!
        player.ammo -= .01 # take away some of the player's ammunition!
        updateAmmo() # and update the bar in the hud!

# Typical game checks
def gameChecks():

    global score
    if paused == True: return # This function will normally be executed even though the game is paused. This is bad.

    # -car- Ship crashes
    for enemy in enemies:

        if player.collides( enemy ): # If the player runs into an enemy...
            
            killShip( enemy ) # kill that ship
            player.health -= player.speed / 20 # and deduct points for the player's clumsiness (based on their speed on impact)
            updateHealth()

    # Health
    if player.health < player.maxHealth: player.health += .0005; updateHealth() # Slow regeneration

    # Ammo
    if player.ammo < .01: player.reloading = True; Sound( BASEPATH + "/sounds/ammo-beginreload.wav", globals()[ "SFX_VOL" ] ).play() # If the ammo is below a number, reload it.
    if player.reloading:
        
        player.ammo += .005 # Adds some ammo
        updateAmmo() # Updates the ammo-stats bar
        Sound( BASEPATH + "/sounds/ammo-reloadboop.wav", globals()[ "SFX_VOL" ] ).play() # Plays a cool sound
    
    if player.ammo >= player.maxAmmo: player.reloading = False; player.ammo = player.maxAmmo # If the ammo is reloaded, stop reloading it.

    # Updating stats
    score += .06 # The score is increased based on the amount of time you spend in-game.
    updateStats()

    # Checking to see if a player rolls over powerups
    for powerup in globals()[ "powerups" ]:

        if player.collides( powerup ): 
            
            if powerup.type == 1: # Health upgrade
            
                if ( player.health + .3 ) < player.maxHealth:
                    
                    player.health += .3 # Add health

                else:

                    player.health = player.maxHealth # Or sets it to the maximum value
                
                updateHealth()
        
            if powerup.type == 2: # Ammunition upgrade

                if ( player.ammo + .2 ) < player.maxAmmo:
                    
                    player.ammo += .2 # Add ammo
                
                else:

                    player.ammo = player.maxAmmo # Or sets it to the maximum value
                
                updateAmmo()

            if powerup.type == 3:
                
                wipeEnemies() # Wipes all enemies on-screen.
            
            powerup.removeSelf() # Removes the powerup
            Sound( BASEPATH + "/sounds/powerup.wav", globals()[ "SFX_VOL" ] ).play() # and plays a cool sound

def checkMainMenuKeys( event ):

    # If a key is pressed and the start screen still exists, switch it to the main menu.
    if event.type == pygame.KEYDOWN and globals()[ "gui" ][ "startScreen" ] != None: switchToMainMenu(); return

    # If a key is pressed and you are in the leaderboard screen, close that screen
    if event.type == pygame.KEYDOWN and globals()[ "gui" ][ "leaderboardElements" ] != None: hideLeaderboard(); Sound( BASEPATH + "/sounds/gui-use.wav", globals()[ "SFX_VOL" ] ).play(); return

    # If a key is pressed and you are in the upgrades screen, do the following...
    if event.type == pygame.KEYDOWN and globals()[ "gui" ][ "upgradeElements" ] != None: selectGUIElement( event, globals()[ "gui" ][ "upgradeTextElements" ] ); return

    # If the spacebar is pressed, run the code under "onUse" of the text element highlighted.
    if event.type == pygame.KEYDOWN and globals()[ "gui" ][ "textElements" ] != None: selectGUIElement( event, globals()[ "gui" ][ "textElements" ] )

def selectGUIElement( event, textElements ):

    global gui
    if event.key == pygame.K_SPACE: textElements[ gui[ "selectSquare" ].index ].onUse(); Sound( BASEPATH + "/sounds/gui-use.wav", globals()[ "SFX_VOL" ] ).play(); return # "Uses" an element if it is selected and the spacebar is pressed.
    if event.key == pygame.K_DOWN or event.key == pygame.K_UP: # If the up or down keys are pressed...
    
        if event.key == pygame.K_DOWN: gui[ "selectSquare" ].index += 1 # If the down key is pressed, move down the list of text elements
        if event.key == pygame.K_UP: gui[ "selectSquare" ].index -= 1 # If the up key is pressed, move up the list of text elements
        if gui[ "selectSquare" ].index < 0: gui[ "selectSquare" ].index = len( textElements ) - 1 # If the selected index is below zero (we can't have that), we wrap it around to the end of the list of text elements.
        if gui[ "selectSquare" ].index > len( textElements ) - 1: gui[ "selectSquare" ].index = 0 # If the selected index is at the end of the list (we can't have that), we set it to zero (the start of the list).
        Sound( BASEPATH + "/sounds/gui-select.wav", globals()[ "SFX_VOL" ] ).play() # Plays a sound
        
    setSelectSquarePosition( textElements[ gui[ "selectSquare" ].index ] )

def setSelectSquarePosition( textElement ): globals()[ "gui" ][ "selectSquare" ].position = Vector2( textElement.position.x - 20, textElement.position.y + textElement.height / 2 ) # Positioning the select square on the left side of the text element it is selecting

#
# loc:6 -- The Challenge
#
def levelUp():

    global level
    level += 1

    # Shortens laser intervals
    if globals()[ "enemy1LaserInt" ] > 3000: globals()[ "enemy1LaserInt" ] = int( globals()[ "enemy1LaserInt" ] * ( 1 - level * .1 ) )
    if globals()[ "enemy1LaserInt" ] > 3200: globals()[ "enemy2LaserInt" ] = int( globals()[ "enemy2LaserInt" ] * ( 1 - level * .1 ) )
    if globals()[ "enemy1LaserInt" ] > 3400: globals()[ "enemy3LaserInt" ] = int( globals()[ "enemy3LaserInt" ] * ( 1 - level * .1 ) )

    # Increases max health of enemies
    globals()[ "enemy1MaxHealth" ] *= 1 + level * .1
    globals()[ "enemy2MaxHealth" ] *= 1 + level * .1
    globals()[ "enemy3MaxHealth" ] *= 1 + level * .1

    # Increases damage of enemies
    globals()[ "enemy1Damage" ] *= 1 + level * .1
    globals()[ "enemy2Damage" ] *= 1 + level * .1
    globals()[ "enemy3Damage" ] *= 1 + level * .1

    # Plays a cool sound
    Sound( BASEPATH + "/sounds/levelup.wav", globals()[ "SFX_VOL" ] ).play()

#
# loc:7 -- Pausing, resuming, initialization, and main menus
#
def initScene():

    global scene
    pygame.init() # Initializes PyGame

    # Makes a scene
    scene = Scene( 600, 800 )

    # Sets music volume
    pygame.mixer.music.set_volume( globals()[ "MUSIC_VOL" ] )
    
    # Sets the title of the window
    pygame.display.set_caption( "InfiniteShooter" )

    # Sets the window's icon
    icon = Image( BASEPATH + "/assets/icon-large.png", Vector2( 0, 0 ) )
    pygame.display.set_icon( icon._pygame )

    # Pre-loads some images
    globals()[ "IMAGE_CACHE" ] = {
        "enemyship1": Image( BASEPATH + "/models/renders/enemyship1.png" ),
        "enemyship2": Image( BASEPATH + "/models/renders/enemyship2.png" ),
        "enemyship3": Image( BASEPATH + "/models/renders/enemyship3.png" ),
        "laser": Image( BASEPATH + "/models/renders/laser.png" )
    }

    try:

        # DARK TITLE BAR (GNOME on GNU/Linux only!)
        os.system( 'xprop -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT "dark" -name "InfiniteShooter"' )
        # I've waited YEARS for this. Okay, maybe not that long...
    
    except:

        pass # try/except in case thou art a Windows normie/don't have Xorg
    
def initGame():

    global scene

    # Makes a background
    makeBackground()
    scene.objects.append( globals()[ "laserSpace" ] ) # Appends other layers like laserSpace so that lasers don't go on top of other things
    scene.objects.append( globals()[ "mainObjects" ] ) # <- Speaks for itself -- contains the main objects in the scene, like ships.
    scene.objects.append( globals()[ "healthSpace" ] ) # <- Like laserSpace but for enemy health bars

    # Makes a player and a HUD
    makePlayer()
    makeHUD()

    # Adds extraFunctions and event listeners
    scene.extraFunctions.append( checkKeys )
    scene.extraFunctions.append( gameChecks )
    scene.addEventListener( checkKeyTaps )

    # Creates a new enemy every 3 seconds
    if globals()[ "mayhem" ] == False: globals()[ "enemyInterval" ] = Interval( makeEnemy, 3000 )

    # or every second?
    if globals()[ "mayhem" ] == True: globals()[ "enemyInterval" ] = Interval( makeEnemy, 1200 )

    # Increases the level every 20 seconds
    Interval( levelUp, 20000 )

    # Increases the level progress bar every .2 seconds
    def __increaseProgress():
        
        globals()[ "levelProgress" ] += .01
        if globals()[ "levelProgress" ] > 1: globals()[ "levelProgress" ] = 0
        updateTerminal() # Updates the terminal indicator
    
    Interval( __increaseProgress, 200 )

    # Plays some music (and switches to another song when the current one ends)
    switchGameSong()
    def gameSongSwitcher( event ):

        if event.type == pygame.SONG_END and globals()[ "ended" ] == False: switchGameSong()

    scene.addEventListener( gameSongSwitcher )

    # Starts the game
    globals()[ "gameStarted" ] = True

def quitGame():

    quitSound = Sound( BASEPATH + "/sounds/explosion" + str( random.randint( 1, 3 ) ) + ".wav" ) # Plays an explosion sound
    quitSound.play()
    saveData()
    setTimeout( lambda: os._exit( 1 ), 700 )

def pause():

    global gui

    # Dim background
    background = Polygon( [ [0, 0], [0, scene.height], [scene.width, scene.height], [scene.width, 0] ], scene, Vector2( 0, 0 ) )
    background.color = ( 0, 0, 0, 160 )
    scene.objects.append( background )

    # Pausing icon
    icon = Image( BASEPATH + "/assets/paused.png", Vector2( scene.width / 2, scene.height / 2 ) )
    scene.objects.append( icon )

    # Text
    # Resuming
    resumeText = Text( "press ESC to resume", scene, Vector2( scene.width / 2, scene.height / 2 + 130 ) )
    resumeText.draw()
    resumeText.position.x -= resumeText.width / 2
    scene.objects.append( resumeText )
    # Quitting
    quitText = Text( "press Q to quit", scene, Vector2( scene.width / 2, scene.height / 2 + 160 ) )
    quitText.draw()
    quitText.position.x -= quitText.width / 2
    scene.objects.append( quitText )
    # Going to the main menu
    menuText = Text( "press M to go back to the main menu", scene, Vector2( scene.width / 2, scene.height / 2 + 190 ) )
    menuText.draw()
    menuText.position.x -= menuText.width / 2
    scene.objects.append( menuText )

    # Adds the stuff to the "gui" variable
    gui[ "pauseBG" ] = background
    gui[ "pauseIcon" ] = icon
    gui[ "pauseText" ] = [ resumeText, quitText, menuText ]

def resume():
 
    scene.objects.remove( globals()[ "gui" ][ "pauseBG" ] ) # Removes all the pausing stuff
    scene.objects.remove( globals()[ "gui" ][ "pauseIcon" ] )
    for text in globals()[ "gui" ][ "pauseText" ]: scene.objects.remove( text )

def eggheadStartScreen(): # The start screen but with the Egghead Productions splash screen

    # Logo
    logo = Image( BASEPATH + "/assets/egghead.png", Vector2( scene.width / 2, scene.height / 2 ) )
    logo.alpha = 0
    logo.scale = Vector2( .25, .25 )
    scene.objects.append( logo )

    # Text
    text = Text( "presents", scene, Vector2( scene.width / 2, ( scene.height / 2 ) + 200 ) )
    text.alpha = 0
    text.draw()
    text.position.x -= text.width / 2
    scene.objects.append( text )

    # Fading
    def fadeIn():

        animation = Animation( 3 )
        def __loop( value ): logo.alpha = text.alpha = value;
        animation.loop = __loop
        animation.callback = fadeOut
        animation.start()

    def fadeOut():

        animation = Animation( 3 )
        def __loop( value ): logo.alpha = text.alpha = 1 - value
        def __callback(): scene.objects.remove( logo ); scene.objects.remove( text ); startScreen()
        animation.callback = __callback
        animation.loop = __loop
        animation.start()
    
    fadeIn()
    globals()[ "gui" ][ "startScreen" ] = None

def startScreen():

    # Song!
    mainMenuSong()

    # Logo
    logo = Image( BASEPATH + "/models/renders/logo.png", Vector2( scene.width / 2, scene.height / 2 ) )
    logo.scale = Vector2( .8, .8 )
    scene.objects.append( logo )

    # Text
    text = Text( "press any key to start", scene, Vector2( scene.width / 2, ( scene.height / 2 ) + 60 ) )
    text.draw()
    text.position.x -= text.width / 2
    scene.objects.append( text )

    # Checking key presses
    scene.addEventListener( checkMainMenuKeys )

    # Adds elements to the "gui" variable
    globals()[ "gui" ][ "leaderboardElements" ] = None # This variable will soon be full if you call showLeaderboard.
    globals()[ "gui" ][ "upgradeElements" ] = None # Same as above but with showUpgradeScreen
    globals()[ "gui" ][ "upgradeTextElements" ] = None
    globals()[ "gui" ][ "startScreen" ] = [ text ]
    globals()[ "gui" ][ "logo" ] = logo

def showLeaderboard( scores ): # Shows the top scores saved (that can fit on the screen. This number equates to a nice 10)

    # Makes a background
    background = Polygon( roundedRectangle( 400, 600, 60 ), scene, Vector2( scene.width / 2, scene.height / 2 ) )
    background.color = "#242424"
    scene.objects.append( background )

    # a title
    leaderboardImage = Image( BASEPATH + "/models/renders/leaderboard.png", Vector2( scene.width / 2, scene.height / 2 - 250 ) )
    leaderboardImage.scale = Vector2( .6, .6 )
    scene.objects.append( leaderboardImage )

    # and shows the scores (but only the top 10 since they fit)
    position = Vector2( scene.width / 2  - 150, scene.height / 2 - 200 )
    globals()[ "gui" ][ "leaderboardElements" ] = [ background, leaderboardImage ]
    for index, score in enumerate( scores ):
    
        text = Text( "{0}. {1} with a score of {2}".format( index + 1, score[ 0 ][ :13 ] + ( score[ 0 ][ 13: ] and "[...]" ), score[ 1 ] ), scene, position.clone() ) # Note: We are limiting the length of a username by 13 characters.
        position.y += 50
        text.color = "white"
        scene.objects.append( text )
        globals()[ "gui" ][ "leaderboardElements" ].append( text )

def hideLeaderboard():

    for element in globals()[ "gui" ][ "leaderboardElements" ]: scene.objects.remove( element )
    globals()[ "gui" ][ "leaderboardElements" ] = None

def showUpgradeScreen():

    global scene
    textElements = []

    # Makes a background
    background = Polygon( roundedRectangle( 400, 600, 60 ), scene, Vector2( scene.width / 2, scene.height / 2 ) )
    background.color = "#242424"
    scene.objects.append( background )

    # a title
    upgradesImage = Image( BASEPATH + "/models/renders/upgrades.png", Vector2( scene.width / 2, scene.height / 2 - 250 ) )
    upgradesImage.scale = Vector2( .6, .6 )
    scene.objects.append( upgradesImage )

    # Making text options
    class TextOption:

        def __init__( self, text, onuse, textIndex ):

            # Creates a new text element
            self.text = Text( text, scene, Vector2( 200, upgradesImage.position.y + 40 * ( textIndex + 1 ) ) )
            self.text.onUse = onuse
            self.text.draw() # So that other functions can get the height/width of the text
            scene.objects.append( self.text )
            textElements.append( self.text )
        
        def setAsUpgradeText( self, upgrade ):

            def __onuse():
                
                # If the upgrade has already been bought, alert the user of this
                if self.upgrade[ "bought" ] == True:

                    Sound( BASEPATH + "/sounds/error.wav", globals()[ "SFX_VOL" ] ).play()
                    alert( "You cannot purchase this upgrade again." )
                    return
                
                # If you have enough points to purchase the upgrade, this is where either you purchase it or you are told you are too poor.
                if globals()[ "POINTS" ] - self.cost >= 0:

                    globals()[ "POINTS" ] -= self.cost
                
                else:

                    alert( "You cannot purchase this upgrade due to an insufficient number of points." )
                    Sound( BASEPATH + "/sounds/error.wav", globals()[ "SFX_VOL" ] ).play()
                    return

                self.text.color = "#666666" # Sets the color to grey because you already bought the upgrade
                self.activateUpgrade()
            
            # Sets some meaningless variables (except for onUse)
            self.cost = upgrade[ "cost" ]
            self.upgrade = upgrade
            self.text.onUse = __onuse

            if upgrade[ "bought" ] == True: self.text.color = "#666666" # Sets the color to grey because you already bought the upgrade
        
        def activateUpgrade( self ):

            # Adds the damage and health of the upgrade to the player's damage and health.
            globals()[ "PLAYER_HEALTH" ] += self.upgrade[ "health" ]
            globals()[ "PLAYER_DAMAGE" ] += self.upgrade[ "damage" ]
            self.upgrade[ "bought" ] = True # Tells the code that the upgrade has been bought\
            statsText.text =  "PTS: {0:.5}  DMG: {1:.5}  HP: {2:.5}".format( float( globals()[ "POINTS" ] ), float( globals()[ "PLAYER_DAMAGE" ] ), float( globals()[ "PLAYER_HEALTH" ] ) ) # Updates stats with new information
            
            # Checks if all upgrades have been bought.
            alreadyUpgradedCount = 0
            for upgrade in UPGRADES:

                if upgrade[ "bought" ] == True: alreadyUpgradedCount += 1

            # If so, then reload upgrades
            if alreadyUpgradedCount == len( UPGRADES ):

                globals()[ "UPGRADES" ] = [] # Empties the UPGRADES variable
                createUpgradeOptions( 11 ) # and creates 9 new options
                hideUpgradeScreen(); showUpgradeScreen() # Re-shows the screen to update the list of upgrades
                alert( "All upgrades have been purchased! Reloading upgrades..." )

    # Displaying scores, damage, and health
    statsText = Text( "If you can read this text, something has gone horribly wrong.", scene, Vector2( 200, upgradesImage.position.y + 40 ) )
    statsText.text =  "PTS: {0:.5}  DMG: {1:.5}  HP: {2:.5}".format( float( globals()[ "POINTS" ] ), float( globals()[ "PLAYER_DAMAGE" ] ), float( globals()[ "PLAYER_HEALTH" ] ) )
    statsText.color = "#aaaaee"
    scene.objects.append( statsText )

    # Making an "exit screen" button
    textIndex = 1
    exitText = TextOption( "exit", hideUpgradeScreen, textIndex )
    exitText.text.color = "#eeaaaa"
    textIndex += 1

    # Making text entries for each upgrade
    for upgrade in UPGRADES:

        text = TextOption( upgrade[ "name" ], lambda: print( "Something has gone wrong." ), textIndex )
        text.setAsUpgradeText( upgrade )
        textIndex += 1
    
    # Moves the selection square to the top of the screen
    scene.objects.remove( globals()[ "gui" ][ "selectSquare" ] )
    scene.objects.append( globals()[ "gui" ][ "selectSquare" ] )
    globals()[ "gui" ][ "selectSquare" ].index = 0
    setSelectSquarePosition( textElements[ 0 ] )

    # Makes a list of objects that are in this dialog
    globals()[ "gui" ][ "upgradeElements" ] = [ background, upgradesImage, statsText ]
    globals()[ "gui" ][ "upgradeTextElements" ] = textElements

def hideUpgradeScreen():

    for element in globals()[ "gui" ][ "upgradeElements" ]: scene.objects.remove( element ) # Removes main elements
    for element in globals()[ "gui" ][ "upgradeTextElements" ]: scene.objects.remove( element ) # Removes text elements
    globals()[ "gui" ][ "upgradeElements" ] = globals()[ "gui" ][ "upgradeTextElements" ] = None # Resets these variables
    globals()[ "gui" ][ "selectSquare" ].index = 0 # and moves the select square to the "START" button
    setSelectSquarePosition( globals()[ "gui" ][ "textElements" ][ 0 ] )
    
def switchToMainMenu():

    # Plays a sound
    Sound( BASEPATH + "/sounds/gui-use.wav", globals()[ "SFX_VOL" ] ).play()

    # Removes excess objects
    for obj in globals()[ "gui" ][ "startScreen" ]: scene.objects.remove( obj )
    globals()[ "gui" ][ "startScreen" ] = None

    # Background
    background = Image( BASEPATH + "/models/renders/spaaace.png", Vector2( scene.width / 2, scene.height / 2 ) )
    scene.objects.append( background )

    # GUI elements
    # Start
    startText = Text( "start", scene, Vector2( scene.width / 2, scene.height / 2 ) )
    startText.draw()
    startText.position.x -= startText.width / 2
    scene.objects.append( startText )
    def startGame():

        scene.eventListeners.remove( checkMainMenuKeys )
        # Fades everything out then starts the game
        animation = Animation()
        def __anim( animationProgress ):
            
            for element in globals()[ "gui" ][ "mainMenuElements" ]: element.alpha = 1 - animationProgress

        def __complete():

            for element in globals()[ "gui" ][ "mainMenuElements" ]: scene.objects.remove( element )
            scene.objects.remove( globals()[ "gui" ][ "background" ] )
            initGame()
        # Starts the animation
        animation.loop = __anim
        animation.callback = __complete
        animation.start()
    
    startText.onUse = startGame

    # Leaderboard
    leaderboardText = Text( "leaderboard", scene, Vector2( scene.width / 2, ( scene.height / 2 ) + 40 ) )
    leaderboardText.draw()
    leaderboardText.position.x -= leaderboardText.width / 2
    scene.objects.append( leaderboardText )
    def __leaderboardOnUse():

        scores = open( BASEPATH + "/userdata/scores.txt", "r" ).read().strip( "[]" ).split( "\n" ) # Reads the score file and splits each line
        scores = [ x.strip( "[]" ).split( " --> " ) for x in scores ][ :-1 ] # Takes everything in the scores value and splits by name and score. Then removes the excess ["" ]
        scores = sorted( scores, key = lambda x: -int( x[ 1 ] ) )[ 0:10 ] # Sorts descending and then takes the top 10 scores (what can fit on the screen)
        showLeaderboard( scores )

    leaderboardText.onUse = __leaderboardOnUse

    # Shop
    upgradesText = Text( "upgrades", scene, Vector2( scene.width / 2, ( scene.height / 2 ) + 80 ) )
    upgradesText.draw() # We use [text].draw() because that calculates the text's width+height
    upgradesText.position.x -= upgradesText.width / 2
    scene.objects.append( upgradesText )
    upgradesText.onUse = showUpgradeScreen

    # Quitting the game before you even started (shameful)
    quitText = Text( "quit", scene, Vector2( scene.width / 2, ( scene.height / 2 ) + 120 ) )
    quitText.draw()
    quitText.position.x -= quitText.width / 2
    quitText.onUse = quitGame
    scene.objects.append( quitText )

    # Selector square
    selectSquare = Polygon( [ [-5, -5 ], [ -5, 5 ], [ 5, 5 ], [ 5, -5 ] ], scene, Vector2( startText.position.x - 20, startText.position.y + startText.height / 2 ) ) # Positions the square behind the startText variable
    selectSquare.index = 0 # selectSquare.index determines the position of the selection square
    scene.objects.append( selectSquare ) # Adds it to the scene

    # Animates the logo and re-appends it to the scene (so it is now on top of everything else)
    logo = globals()[ "gui" ][ "logo" ]
    animation = Animation()
    def __anim( animationProgress ): logo.position.y = ( scene.height / 2 ) - animationProgress * 100; logo.scale = Vector2( .8 - animationProgress * .2, .8 - animationProgress * .2 )
    animation.loop = __anim
    animation.start()
    scene.objects.append( logo )

    # Adds stuff to the "gui" variable
    globals()[ "gui" ][ "selectSquare" ] = selectSquare
    globals()[ "gui" ][ "textElements" ] = [ startText, leaderboardText, upgradesText, quitText ]
    globals()[ "gui" ][ "background" ] = background
    globals()[ "gui" ][ "mainMenuElements" ] = [ selectSquare, startText, leaderboardText, upgradesText, quitText, gui[ "logo" ] ]

# loc:8 -- Music!
def mainMenuSong():
    
    global scene
    scene.setSong( BASEPATH + "/sounds/mainmenu.wav" )
    scene.playSong()

def switchGameSong():
    
    global scene
    scene.crossfadeSong( BASEPATH + "/sounds/game" + str( trueRandom( 1, 4 ) ) + ".wav" )

# Starting the game
setGame()
initScene()
eggheadStartScreen() # You can replace this with startScreen if you are fed up with the time it takes to show the Egghead logo.