.ONESHELL:

compile:
	# Compiles InfiniteShooter
	mkdir -p /tmp/infiniteshooter-compiled
	godot --path ../InfiniteShooter --export "Linux/X11" /tmp/infiniteshooter-compiled/InfiniteShooter.x86_64

	# Copies to the Flatpak folder
	cp /tmp/infiniteshooter-compiled/* ./Flatpak/infiniteshooter/

flatpak:

	cd Flatpak

	# Creates a "repo", whatever that means. Modified from https://github.com/scx/qalculate-flatpak#create-repo
	flatpak-builder --repo="repo" --force-clean "build" "com.pastthepixels.InfiniteShooter.yml"
		
	# Compiles InfiniteShooter into a .flatpak for installation
	flatpak build-bundle "repo" "InfiniteShooter.flatpak" "com.pastthepixels.InfiniteShooter" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

clean:

	cd Flatpak

	if [ -d "build" ]; then rm -r build; fi
	if [ -d "repo" ]; then rm -r repo; fi
	if [ -f "InfiniteShooter.flatpak" ]; then rm -r InfiniteShooter.flatpak; fi

test_flatpak:

	cd Flatpak

	flatpak-builder build-dir com.pastthepixels.InfiniteShooter.yml --force-clean
	flatpak-builder --user --install build-dir com.pastthepixels.InfiniteShooter.yml --force-clean
	flatpak run com.pastthepixels.InfiniteShooter