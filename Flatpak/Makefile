.ONESHELL:

# Variables
game_export_path=$(realpath ./build/game/)/InfiniteShooter.x86_64 # Relative to the same directory as the makefile

# First we want to set up everything. We will create a build directory which will house everything.
setup:
	mkdir -p build
	cp -r source/* build/

# Next, run `make compile`. This will compile the game through Godot.
compile:
	cd build

	mkdir -p game
	echo $(realpath ./game)/InfiniteShooter.x86_64

	if command -v godot &> /dev/null # if the command `godot` works
	then
		godot --no-window --path ../../InfiniteShooter --export "Linux/X11" $(game_export_path) # run it
	else
		flatpak run org.godotengine.Godot --no-window --path ../../InfiniteShooter --export "Linux/X11" $(game_export_path) # otherwise you have the flatpak
	fi # goodbye

# Now we build the Flatpak. First, we will install depenencies and then we will compile it into a flatpak (in the same directory).
flatpak:
	cd build

	# Installing dependences
	echo "Let's make sure you have the right Flatpaks installed to compile InfiniteShooter with flatpak-builder."
	flatpak install org.freedesktop.Sdk/x86_64/20.08
	
	# Creates a "repo", whatever that means. Modified from https://github.com/scx/qalculate-flatpak#create-repo
	flatpak-builder --repo="repo" --force-clean "build" "com.pastthepixels.InfiniteShooter.yml"

	# Compiles InfiniteShooter into a .flatpak for installation
	flatpak build-bundle "repo" "InfiniteShooter.flatpak" "com.pastthepixels.InfiniteShooter" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

# Testing/installing the flatpak without having to run `make flatpak`
test:
	cd build

	flatpak-builder build com.pastthepixels.InfiniteShooter.yml --force-clean
	flatpak-builder --user --install build com.pastthepixels.InfiniteShooter.yml --force-clean
	flatpak run com.pastthepixels.InfiniteShooter

# Cleaning up for next builds
clean:
	rm -r build/*