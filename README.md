<p align="center">
  <img width="50%" align="center" src="https://jacee.dev/img/mods/unlocked-logo.png" alt="">
</p>
  <h1 align="center">
  KingdomUnlocked
</h1>
<p align="center">
  A mod for MySims Kingdom on the Nintendo Switch, enabling debug interactions & cheat menus
</p>
<br>

_Note: All features listed here exist in the latest mod version. Some features may be missing when using previous mod versions._

### Debug Interactions
...for Sims from the Wii game:

- 🟢 Teleport Sims & animals to safe position
- 🟢 Tell Sims to move
- 🔵 Push Sims
- 🟠 Delete Sims (Sims can be respawned using the **Spawn Menu**)
- 🔴 Advance Sims schedule (starts next quest if available)
- 🟢 Force Sims to idle (will interrupt any ongoing interactions & makes the sim idle for a couple of seconds)
- 🟢 Force Sims to interact with some objects (for objects that have multiple interactions one will be selected randomly)

### Cheat Menus
...when interacting with bookshelves!

- 🟢 "*Unlock bonus clothing*": usually unlocked with button combinations in the pause menu (see [MySims Fandom](https://mysims.fandom.com/wiki/Cheat_Codes_(MySims_Kingdom))﻿)
- 🟢 "*Give all resources*": will give you 999 of every single resource & item
- 🟢 "*Unlock post-game blocks*": unlocks all post-game blocks (like the DJ Booth and Dance Floors)
- 🟠 "*Unlock all story islands*": unlocks all story islands except [Reward Island](https://mysims.fandom.com/wiki/Reward_Island)
- 🟠 "*Unlock reward island*"
- 🟠 "*Lock all islands*": locks all islands except [Capital Island](https://mysims.fandom.com/wiki/Capital_Island)


### Model Swap Menu:

- 🟢 give any Sim a makeover! You can mix and match any outfits & heads from existing Sims.
- 🟢 also gives you access to the models of the [Shipwreck Cove crew](https://mysims.fandom.com/wiki/Shipwreck_Cove#Island_Residents) and [Beebee](https://mysims.fandom.com/wiki/Beebee)﻿


### Spawn Menu:

- 🟠 spawn any Sim on any island!
- 🟠 spawn most animals anywhere you want!

> **Limitations:** Sims that are spawned outside their home island will not have a schedule. This means they will not walk around & interact with anything. I'll fix this as soon as I figure out a solution.


### Custom interactions:

- 🟢 "*Harvest All*" for trees: shakes all trees on the island at the same time
- 🟢 "*Quick Mine*": skips the searching part of the mining mini-game, just mine away indefinitely!
- 🟢 "*Quick Fishing*": the location of the fish is marked with game objects. Also, you can't fail this mini-game, just press A as soon as bobber is inside the marked area
- 🟢 On/Off Toggling of some objects (Campfire, DJ Booth, Dance Floor)



## Installation

Download the mod & extract the ZIP file into a "KingdomUnlocked" folder.

Continue from here with your platform (Nintendo Switch with CFW or [Ryujinx](https://github.com/GreemDev/Ryujinx)):

### Switch

1. **[SimpleModManager](https://github.com/nadrino/SimpleModManager)** (recommended): put the entire "KingdomUnlocked" folder from the ZIP file on your SD Card into "mods/MySims Kingdom"
2. the final folder structure should look like this:
    ```
    mods\
        └───MySims Kingdom\
            └───KingdomUnlocked\
                └───contents\
                    └───010015401ffe0000\
                        └───romfs\
                            └───GameData\
                                └───Lua
    ```
---
- **Manual**: put the "contents" folder (located inside the "KingdomUnlocked" folder) on your SD Card (overwrite if asked)


### Ryujinx

- right click on MySims Kingdom -> "Manage Mods" -> "Add" -> now go to where you extracted the ZIP file & select the folder "KingdomUnlocked"
- the mod should now appear as "010015401ffe0000" in the mod manager



## Colour Codes
- 🟢**Safe** = you really have to try hard to break things
- 🔵**Generally Safe** = there is a possibility you may break something, although very slim
- 🟠**Potentially Unsafe** = no game breaking bugs were found during testing, these options may have unexpected side effects
- 🔴**Dangerous** = don't mindlessly use this, this may break your save game permanently
