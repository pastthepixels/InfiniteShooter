# Copies over everything
rm ~/InfiniteShooter
mkdir ~/InfiniteShooter
cp * ~/InfiniteShooter

# CD's to that directory
cd ~/InfiniteShooter

# Removes the install file
rm ~/InfiniteShooter/install*

# and the .desktop file (for Linux)
rm ~/InfiniteShooter/*.desktop

# Creates an uninstall file
echo "rm ~/InfiniteShooter \n echo 'Done!'" > uninstall.ps1

# Done!
echo "Done!"
