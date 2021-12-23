InfiniteShooter "Production" files
==================================
This contains all the files required to create packages for InfiniteShooter. I am currently supplying Flatpaks because they are WAY easier than compiling disto-specific packages. If more people use InfiniteShooter I might publish it to Steam, mitigating the need for compiling it... or I could publish it to Flathub, or both. Also publishing InfiniteShooter to Steam will enable better Windows support.
  
The main reason for having this folder though was because Godot _exports_ InfiniteShooter, but doesn't make it "deployable" as an installable program on other systems.  
  
--> Note: Type `make compile` to compile InfiniteShooter from Godot to the folder "sources".

## Prerequisites
- Godot (flatpak/native)
- flatpak-builder
- Export templates for Godot 

## To fully compile a new package...
1. Ensure Godot has the correct libraries to compile releases
2. Clone this repository somewhere.
3. Open up a console. Type "make compile".
4. Once this has finished, ensure you have `flatpak-builder` installed.
5. Type "make flatpak".
6. Type "flatpak install Flatpak/InfiniteShooter.flatpak" to install InfiniteShooter or "make clean" to clean up everything.
