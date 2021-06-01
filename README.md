![InfiniteShooter](InfiniteShooter/models/renders/logo.png)

Deps:
```
pip install pygame
```

Recommended hardware: ThinkPad E595 -- AMD Ryzen 5 3500U (no external GPU)  
Recommended software: Fedora 33/34
Note for Windows users: Launch the .lnk file to start InfiniteShooter. You may need to install Python from the Microsoft store (and then install PyGame with pip)
Note for those using Nvidia drivers for GNU/Linux: You'll also need to run game-windows.py. The install script should automatically do this for you.

# Installation
1. Download InfiniteShooter.zip from the Releases tab (or just clone this repository and cd to InfiniteShooter)
2. Run install.sh or install.ps1 depending on your operating system.
Note that on Windows InfiniteShooter is only copied to your home directory and not installed. .lnk files don't work like .desktop ones so I don't know how to make a desktop shortcut for InfiniteShooter.


# Notes
A cautionary tale: I have made a manual keyboard-focused GUI for this game. In the future, you should just use ``pygame_gui`` -- ``pip install pygame_gui``.  
It's FLOSS and it's on pygame's site.  
Also you can't get those sweet GTK4 rounded corners or even a dark title bar because blah blah blah SDL garbage.  
EDIT: Scratch that last part, I just did this:
```
xprop -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT "dark" -name "InfiniteShooter"
```

# Table of Contents (Use ctrl-f and enter "loc:$LOCATION_NUMBER" to access the location in InfiniteShooter/scripts/game.py)
| Location # | Title                                             |
| ---------- | ------------------------------------------------- |
| loc:0.5    | Upgrades                                          |
| loc:1      | Setting and Resetting The Game                    |
| loc:2      | Functions to Make Scene Things                    |
| loc:3      | Functions to Blow Up Scene Things                 |
| loc:4      | Just GUI Things                                   |
| loc:5      | Updates and Checks                                |
| loc:6      | The Challenge                                     |
| loc:7      | Pausing, resuming, initialization, and main menus |
| loc:8      | Music                                             |
