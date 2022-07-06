<p align="center">
  <img alt="InfiniteShooter" src="https://raw.githubusercontent.com/pastthepixels/InfiniteShooter-Assets/main/infiniteshooter-cover.png">
</p>

# Screenshots
<!-- Have to do some HTML wizardry to get these screenshots to not be completely large and not side-by-side -->
<p float="left">
  <img src="https://user-images.githubusercontent.com/52388215/177012474-99e630c2-848d-475d-9029-bf6e833774f7.png" width="300">
  <img src="https://user-images.githubusercontent.com/52388215/177012475-9d3886c6-79a1-4639-8996-4141a3e03748.png" width="300">
  <img src="https://user-images.githubusercontent.com/52388215/177012476-ec639c29-2f11-434c-8bf9-7161cfea66e3.png" width="300">
  <img src="https://user-images.githubusercontent.com/52388215/177012477-def09811-992b-45dd-b6be-2867da70f540.png" width="300">
  <img src="https://user-images.githubusercontent.com/52388215/177012478-89541ddf-ee69-49dc-a954-c6f5cac3fd68.png" width="300">
  <img src="https://user-images.githubusercontent.com/52388215/177012610-02c3edd4-6205-4d36-9a41-960d1dcb8aa1.png" width="300">
</p>

# Running the portable files
Anything that isn't `InfiniteShooter.flatpak` is a portable executable you can run on your system. (Don't worry about losing your data if you move/delete the executable though. It should persist on your system.) Here's how to download and run an executable for your system:
1. Have a 64-bit (x86_64, no Raspberry Pi's here) system. There are many ways to check for this, but if you're running a new-ish computer, you shouldn't have to worry about anything.
2. Go to the Releases page and look for a file with your operating system's name on it (ex. something like `InfiniteShooter-WINDOWS.exe` for Windows or `InfiniteShooter-LINUX` for Linux, but you should use the Flatpak!).
3. Download the file, then run it.
4. Profit

# Installing InfiniteShooter
## Linux (Flatpak)
1. Ensure you have Flatpak installed on your system. It's shipped by default in Fedora.
2. Enable Flathub if you haven't already
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```
3. Install InfiniteShooter!
```bash
flatpak install io.github.pastthepixels.InfiniteShooter
```

# Hardware/software requirements
| Requirement type              | Specifications                                                                   |
|-------------------------------|----------------------------------------------------------------------------------|
| **Minimum (tested) hardware** | AMD Ryzen 5 3500U with mobile graphics (essentially my laptop, a ThinkPad E595). |
| **Recommended hardware**      | Nvidia GeForce GTX 1050 or higher (essentially, my computer)                     |
| **Recommended (tested) OS**   | Anything Linux (tested on Fedora/EndeavourOS)                                    |

# Trivia
This game was my final project for my Computing Science 10 class! The first ever version (before 1.0) was made ~June of 2021 and since then the game's received a lot of improvements.

# Credits
EXTERNAL ASSETS FROM FREESOUND.ORG:
- Burning: https://freesound.org/people/midimagician/sounds/249418/
- Freezing/corrosion: https://freesound.org/people/td6d/sounds/184225/
- Firing lasers: https://freesound.org/people/Defunct3/sounds/77172/
- Transitioning between scenes (ex. from the main menu to the game): https://freesound.org/people/qubodup/sounds/60013/
All other assets are made by me using free software tools like Blender, Inkscape, GIMP, LMMS, and Audacity.
They're CC-0 and you can find them at https://github.com/pastthepixels/InfiniteShooter-Assets
