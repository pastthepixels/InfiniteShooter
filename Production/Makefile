compile:
	# Compiles InfiniteShooter
	mkdir -p /tmp/infiniteshooter-compiled
	godot --path ../InfiniteShooter --export "Linux/X11" /tmp/infiniteshooter-compiled/InfiniteShooter.x86_64
	
	# Copies to the "sources" folder
	cp /tmp/infiniteshooter-compiled/* ./sources/infiniteshooter/
	tar -czvf sources.tar.gz ./sources
