InfiniteShooter Godot Port
==========================
A "port" of InfiniteShooter to the Godot engine because I want to have some experience with making games in this engine. Because this is now a full port that is better than InfiniteShooter 1.x I will make this InfiniteShooter 2.0. This game: 
- has way less bugs compared to InfiniteShooter 1.x
- has the ability to be exported to almost all platforms
- has better controller support
- renders everything in real-time with OpenGL
- is the successor to InfiniteShooter; InfiniteShooter (version) 2.0

The repository now just has to have the original README copied over and modified slightly.
* I also have to move the `models` folder as well.

--> "swooshy" sound effect from user qubodup on freesound.org: https://freesound.org/people/qubodup/sounds/60013/

## DONE
- [x] Enemies can shoot lasers
- [x] The player can shoot lasers
- [x] The health and ammunition bars for the player
- [x] The player can kill enemies
- [x] Enemies can die by falling out of the screen
- [x] Controller support for in-game actions
- [x] Ammo can recharge
- [x] Player movement (and screen wrapping)
- [x] The player can die
- [x] Game over screen
- [x] Pausing screen
- [x] Main menu
- [x] Bottom stats bar (level, score, frame rate)
- [x] Enemy difficulty based on ship type
- [x] Game "levels"
- [x] Scrolling background
- [x] Powerups
- [x] Leaderboard
- [x] Egghead Productions branding
- [x] Upgrades
- [x] Sounds (sound effects+music)
- [x] Options menu with volume settings and graphics settings
- [x] Clean up the code

## Roadmap for the future
- [ ] Improve gameplay (somehow)
- [ ] Release on Steam, possibly using: https://gramps.github.io/GodotSteam
    - [ ] Achievements handled on Steam's server side (no in-game menu makes programming easier)
    - [ ] Up to 4 person multiplayer