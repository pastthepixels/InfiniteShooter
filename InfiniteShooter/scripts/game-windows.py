# Hacky method to get the game running on Windows (and GNU/Linux wi/ NVIDIA drivers) (tested on an HP Compaq 8100 running Windows 10)

# Refer to game.py:10 to see what the heck this means
import os
if 'DISPLAY' in os.environ and 'SDL_VIDEO_X11_WMCLASS' not in os.environ: os.environ['SDL_VIDEO_X11_WMCLASS'] = "InfiniteShooter"

# Imports the modules required
import threading
import pygame
import time

# We are going to import the game.py file (essentially running it as you would) and getting all the data from that and making it global
game = None

# as we are doing in this function
def runGame(): import game; globals()[ "game" ] = game

# but in another thread so it doesn't get affected by...
thread = threading.Thread( target=runGame )
thread.run()

# this while loop. We force the game to update on the main file so that Windows notices each time pygame gets the events. This will prevent "not responding" errors and won't come at much of a cost at all.
game.scene.interval.stopped = True
while True: game.scene.update()