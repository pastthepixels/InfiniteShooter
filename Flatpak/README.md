InfiniteShooter Flatpak stuff
=============================
This contains all the files required to create a Flatpak for InfiniteShooter.

## Prerequisites
- Godot (flatpak/native)
- flatpak-builder
- Export templates for Godot 
- Linux

## The Steps
1. Open a terminal in this folder.
2. Type `make setup`
3. Type `make compile`
4. OPTIONAL: Type `make test` to install the flatpak without fully building it yet. Once you are happy with this, move on to step 5.
5. Type `make flatpak` and install any dependencies.
6. Done! The compiled file should be in `build/`. Optionally, you can type `make clean` to clean up that folder.
