# Dungeon Echoes

**Dungeon Echoes** is a 2D action game made in Godot Engine. The player fights through enemy waves, collects coins, buys upgrades in the shop, unlocks new weapons, and tries to survive for as long as possible.

The project was created as a school/university assignment and combines elements of a platformer, arena survival game, and lightweight roguelite-style progression.

## Table of Contents

- [Game Overview](#game-overview)
- [Main Features](#main-features)
- [Controls](#controls)
- [Requirements](#requirements)
- [Running the Project](#running-the-project)
- [Exporting the Game](#exporting-the-game)
- [Project Structure](#project-structure)
- [Project Status](#project-status)
- [Authors and Assets](#authors-and-assets)
- [License](#license)

## Game Overview

In **Dungeon Echoes**, you control a hero fighting inside a dark arena. Your goal is to survive increasingly difficult waves of enemies. Defeated enemies can drop coins, which can be spent on new weapons and stat upgrades in the shop.

The gameplay focuses on fast movement, dashing, weapon switching, and keeping up a combo streak. The better you perform in combat, the stronger your temporary damage and speed bonuses become.

## Main Features

- Enemy wave system with increasing difficulty.
- Multiple enemy types, including slime, skeleton, blob enemy, cacodemon, and boss enemies.
- Player character with movement, jumping, dash, animation states, and low-health feedback.
- Weapon system with:
  - fireball,
  - electric weapon,
  - self-guiding missile,
  - gravity grenade.
- Shop with randomized items and upgrades.
- Coin system and saved player progress.
- Combo system with `FLOW`, `HOT STREAK`, `RAMPAGE`, and `OVERDRIVE` milestones.
- Main menu with new game, continue, and audio settings.
- Pause menu with save-and-exit functionality.
- Short tutorial introducing the basic controls.
- Sound effects, music, particles, camera shake, and hit feedback.

## Controls

| Action | Key / Button |
| --- | --- |
| Move left | `A` |
| Move right | `D` |
| Jump | `Space` |
| Dash | `Shift` |
| Attack | `E` or left mouse button |
| Interact | `F` |
| Weapon 1 | `1` |
| Weapon 2 | `2` |
| Weapon 3 | `3` |
| Weapon 4 | `4` |
| Pause | `Esc` |

## Requirements

- Godot Engine `4.6` or a compatible newer version.
- Windows, Linux, or macOS for running the project in the Godot editor.
- Godot export templates are required for exporting the game.

The project includes a ready export preset for **Windows Desktop**.

## Running the Project

1. Clone the repository:

   ```bash
   git clone <repository-url>
   ```

2. Open Godot Engine.

3. Import the project by selecting:

   ```text
   project.godot
   ```

4. After importing the project, press **Play** in the Godot editor.

The main scene is already configured in the Godot project settings, so the game should start from the main menu.

## Exporting the Game

The project contains an export preset with the following settings:

- name: `Dungeon Echoes`
- platform: `Windows Desktop`
- architecture: `x86_64`
- embedded PCK file

To export the game:

1. Open the project in Godot.
2. Go to **Project > Export**.
3. Select the `Dungeon Echoes` preset.
4. Choose the output location for the `.exe` file.
5. Click **Export Project**.

## Project Structure

```text
.
+-- project.godot
+-- export_presets.cfg
+-- wave_manager.gd
+-- scenes
|   +-- main_menu
|   +-- main_map
|   +-- shop_map
|   +-- tutorial
|   +-- test_map
|   +-- entities
|       +-- main_character
|       +-- enemies
|       +-- collectables
|       +-- universal
+-- tools
```

Key directories:

- `scenes/main_menu` - main menu, buttons, audio settings, and scene transitions.
- `scenes/main_map` - main arena, pause menu, platforms, and map logic.
- `scenes/shop_map` - shop, items, upgrades, and weapon purchases.
- `scenes/entities/main_character` - player character, HUD, player data, movement, and weapon system.
- `scenes/entities/enemies` - enemies and their behavior states.
- `scenes/entities/collectables` - coins, collectibles, and health drops.
- `scenes/entities/universal` - shared elements such as health bars, explosions, and visual effects.
- `scenes/tutorial` - basic control tutorial.

## Project Status

The project is a playable prototype / assignment project. It includes the core gameplay loop:

1. starting from the main menu,
2. fighting on the arena map,
3. collecting coins,
4. buying shop upgrades,
5. saving and continuing progress.

Possible future improvements:

- improve enemy wave balance,
- add more maps,
- expand boss fights,
- add a controls settings screen,
- organize audio and graphics licensing,
- prepare downloadable builds through GitHub Releases.

## Authors and Assets

This project was created in Godot Engine as an assignment project.

The repository contains graphics, audio files, fonts, and music used in the game. Before distributing the game publicly outside an educational context, all third-party asset licenses should be reviewed.

## License

No license file is currently included in the repository. By default, this means that all rights to the code and assets remain with the project authors.
