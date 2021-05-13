# !/bin/bash

# Copies over everything
rm -rf ~/InfiniteShooter
mkdir ~/InfiniteShooter
cp * ~/InfiniteShooter -r

# CD's to that directory
cd ~/InfiniteShooter

# Edits the infiniteshooter file
sed -i "s|BASEPATH|$(pwd)|g" ~/InfiniteShooter/infiniteshooter.desktop

# Removes the install file
rm -rf ~/InfiniteShooter/install*

# and the .lnk file (for Windows)
rm ~/InfiniteShooter/*.lnk

# Creates an uninstall file
echo "rm -rf ~/InfiniteShooter; rm -rf ~/.local/share/applications/infiniteshooter.desktop; rm -rf ~/.icons/infiniteshooter.png; echo 'Done!'" > uninstall.sh
chmod +x uninstall.sh

# Moves over infiniteshooter.desktop to ~/.local/share/applications
mv ~/InfiniteShooter/infiniteshooter.desktop ~/.local/share/applications/
mkdir ~/.icons
cp ~/InfiniteShooter/assets/icon-large.png ~/.icons/infiniteshooter.png

# Done!
echo "Done!"
