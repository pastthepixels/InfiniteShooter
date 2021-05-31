# !/bin/bash
BASEPATH="$HOME/.infiniteshooter"
APPPATH="$HOME/.local/share/applications"
ICONPATH="$HOME/.icons"

# Asks whether you want to install InfiniteShooter to the system or just for you.
while true; do
    read -p "Do you want to install InfiniteShooter for all users? [y/n]: " yn
    case $yn in
        [Yy]* ) $BASEPATH="/usr/share/infiniteshooter"; $APPPATH="/usr/share/applications"; $ICONPATH="/usr/share/icons"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

if [ "$EUID" -ne 0 ] && [ $BASEPATH = "/usr/share/infiniteshooter" ]
    then echo "Please run as root (e.g. sudo install.sh)"
    exit
fi

# Copies over everything
echo "Copying over files..."
mkdir $BASEPATH
rm -rf $BASEPATH
mkdir $BASEPATH
cp * $BASEPATH -r
echo "...done"

# CD's to that directory
cd $BASEPATH

# Edits the infiniteshooter.desktop file
echo "Editing some files..."
sed -i "s|BASEPATH|$(pwd)|g" $BASEPATH/infiniteshooter.desktop
echo "...done"

# Edits it some more if you use Nvidia drivers
if [ -x "$(command -v nvidia-smi)" ]; then
    echo "Nvidia drivers detected. Switching to game-windows.py..."
    sed -i "s|game.py|game-windows.py|g" $BASEPATH/infiniteshooter.desktop
    echo "...done"
fi

# Removes the install file
echo "Removing excess files..."
rm -rf $BASEPATH/install*

# and the .lnk file (for Windows)
rm $BASEPATH/*.lnk
echo "...done"

# Creates an uninstall file
echo "Creating an uninstall file..."
echo "rm -rf $BASEPATH; rm -rf $APPPATH/infiniteshooter.desktop; rm -rf $ICONPATH/infiniteshooter.png; echo 'Done!'" > uninstall.sh
chmod +x uninstall.sh
echo "...done"

# Moves over infiniteshooter.desktop to ~/.local/share/applications
echo "Creating a desktop entry..."
mv $BASEPATH/infiniteshooter.desktop $APPPATH
mkdir ~/.icons
cp $BASEPATH/assets/icon.png $ICONPATH/infiniteshooter.png
echo "...done"

# Done!
echo "All done!"
echo "To uninstall InfiniteShooter, run $BASEPATH/uninstall.sh"