InfiniteShooter "Production" files
==================================
This contains all the files required to create packages for InfiniteShooter. I am currently supplying RPMs because I don't think anybody else will be using InfiniteShooter. Also you can use `alien` to install the resulting RPM files on Debian-based distributions. If more people use InfiniteShooter I might publish it to Steam, mitigating the need for compiling it... or I could publish it to Flathub, or both. Also publishing InfiniteShooter to Steam will enable Windows support.
  
The main reason for having this folder though was because Godot _exports_ InfiniteShooter, but doesn't make it "deployable" as an installable program on other systems.  
  
--> Note: Type `make compile` to compile InfiniteShooter from Godot to the folder "sources".

## To fully compile a new package...
1. Ensure Godot has the correct libraries to compile releases
2. Clone this repository somewhere.
3. Open up a console. Type "make compile".
4. Once this has finished, `cd` into the folder for your disto-of-choice. (There's currently only one folder.)
5. Follow the instructions for that distro in the README of that folder
