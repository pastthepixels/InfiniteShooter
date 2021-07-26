<p align="center">
  <img alt="InfiniteShooter" src="InfiniteShooter/assets/renders/logo.png">
</p>

# Screenshots
<!-- Have to do some HTML wizardry to get these screenshots to not be completely large and not side-by-side -->
<p float="left">
  <img src="https://user-images.githubusercontent.com/52388215/125573351-8dd2fa69-0596-4b5b-8bcf-0424ac417492.png" width="200">
  <img src="https://user-images.githubusercontent.com/52388215/125573764-2b002dc0-6b78-4e51-87e4-8563904fc351.png" width="200">
  <img src="https://user-images.githubusercontent.com/52388215/125573659-9caa6f7c-d15c-4f99-aae1-3ba94a64fc24.png" width="200">
</p>

# Installation
1. Install Python and `pip`. It's shipped by default in Fedora.
2. Install PyGame from `pip`. To do this, open up a terminal (yes, even on Windows!) and run `pip install pygame`.
3. Clone this repository to a tempoary directory. I typically would go `cd /tmp; git clone https://github.com/pastthepixels/InfiniteShooter; cd InfiniteShooter` on my Fedora system
4. `cd` (change directory) to the `InfiniteShooter` subfolder
5. Installation:
5a. On GNU/Linux systems, run `./install.sh` from a terminal.
5b. On Windows systems, run `./install.ps1` (a PowerShell script). It should be noted that this simply copies InfiniteShooter to your home directory, and it does not create a shortcut.

> **NOTE:** Technical details for step 5b: The installation script copies a template `.desktop` file to `~/.local/share/applications` and then replaces a filler for the base path of InfiniteShooter for the actual path it was installed to. If I publish this game to, say, Steam (which I want to do in the near future), all installation stuff will be mitigated so you can just play InfiniteShooter without worrying about all this.

# Uninstallation

## GNU/Linux

1. `cd` to `~/.infiniteshooter` or `/usr/share/infiniteshooter` depending on if you installed InfiniteShooter system-wide.
2. Run `./uninstall.sh`.

## Windows

1. Go to your home folder. On Windows it looks something like this: `C:/Users/$YOURNAME/`
2. Change directory to `InfiniteShooter`.
3. Run `./uninstall.ps1`, a PowerShell script.

# Hardware/software requirements

**Minimum hardware**: I tested this generally on an Intel Pentium processor. Unfortunately, since I don't know which, I can only garuntee that it works within this range. I'm guessing since there are many performance optimizations and that there is no heavy rendering going on that you can run this on any Pentium, but beware.  
**Tested hardware**: AMD Ryzen 5 3500U with mobile graphics (Lenovo ThinkPad E595)  
**Recommended hardware**: The very best you can muster. I don't know, RTX or something. But there's a GPU shortage right now so yeah.  
**Recommended OS**: GNU/Linux  
**Tested OS**: Fedora 34

# Notes
- A cautionary tale: I have made a manual keyboard-focused GUI for this game. In the future, you should just use ``pygame_gui`` -- ``pip install pygame_gui``. It's FLOSS and it's on pygame's site.  
- Also you can't get those sweet GTK4 rounded corners or even a dark title bar because blah blah blah SDL garbage.  
- EDIT: Scratch that last part about dark themes, I just did this:
```
xprop -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT "dark" -name "InfiniteShooter"
```

# Contributing
You actually want to contribute to InfiniteShooter? It'll be great to have you!  
Only thing is I only have experience to create repositories to store my software and I've never had any experience with contributing with others!  
If you have any idea on how this works, please contact me (my address is somewhere in my GitHub profile) and let me know!

# Trivia
This game was my final project for my Computing Science 10 class! The first ever version (before 1.0) was made ~June of 2021 and since then the game's received a lot of improvements.  
But expect more changes to come! You can see my port of InfiniteShooter to the Godot engine in the `godotengine-port` branch.

# Table of contents
> What is this? --> This is a way to naviagate `./InfiniteShooter/game.py`. Simply hit <kbd>Ctrl</kbd> + <kbd>F</kbd> and type in `loc:` followed by the location number to reach different locations. I hope this can be simplified in the future through the use of some kind of bookmarking.

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

# Credits
All assets are made by me using Blender/Illustrator/Inkscape/GIMP/LMMS/Audacity.  
Except for one... The laser sounds are from user Defunct3 right [here](https://freesound.org/people/Defunct3/sounds/77172/) on freesound.org.
