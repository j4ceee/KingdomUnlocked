<p align="center">
  <img width="50%" align="center" src="https://jacee.dev/img/mods/unlocked-logo.png" alt="">
</p>
  <h1 align="center">
  KingdomUnlocked
</h1>
<p align="center">
  A mod for MySims Kingdom on the Nintendo Switch & PC, enabling debug interactions & cheat menus
</p>
<br>

_Note: All features listed here exist in the latest mod version. Some features may be missing when using previous mod versions. You can download the latest version [here](https://github.com/j4ceee/KingdomUnlocked/releases/latest)._

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

- 🟢 Press the "Map" button to *fly*
- 🟢 "*Harvest All*" for trees: shakes all trees on the island at the same time
- 🟢 "*Quick Mine*": skips the searching part of the mining mini-game, just mine away indefinitely!
- 🟢 "*Quick Fishing*": the location of the fish is marked with game objects. Also, you can't fail this mini-game, just press A as soon as bobber is inside the marked area
- 🟢 On/Off Toggling of some objects (Campfire, DJ Booth, Dance Floor)



## Installation

- Continue from here with your platform (**PC**, **Nintendo Switch** with CFW or **[Ryujinx](https://ryujinx.app/)**):
---
### PC

- [Download the _Steam version of the mod under "Assets"](https://github.com/j4ceee/KingdomUnlocked/releases/latest) & extract the ZIP file (on Windows: right click -> Extract All.. -> Extract).
- You should now see a folder name like this `KingdomUnlocked_vX.Y.Z_Steam`
- Move the `data` folder inside your `KingdomUnlocked_vX.Y.Z_Steam` folder to your game installation folder (e.g. `C:\Program Files (x86)\Steam\steamapps\common\MySims Kingdom`)

---

### Switch

- [Download the _Switch version of the mod under "Assets"](https://github.com/j4ceee/KingdomUnlocked/releases/latest) & extract the ZIP file (on Windows: right click -> Extract All.. -> Extract).
- You should now see a folder name like this "KingdomUnlocked_vX.Y.Z_Switch"
- You can now install the mod manually (not recommended) or with **[SimpleModManager](https://github.com/nadrino/SimpleModManager)** (recommended)
- Connect your Switch to your PC and copy the mod files to the SD Card of your Switch depending on your preferred method:

<br>

- **[SimpleModManager](https://github.com/nadrino/SimpleModManager)** (recommended): put the entire "KingdomUnlocked_..._Switch" folder from the ZIP file on your SD Card into "mods/MySims Kingdom"
  - the final folder structure should look like this:
      ```
      mods\
          └───MySims Kingdom\
              └───KingdomUnlocked_..._Switch\
                  └───contents\
                      └───010015401ffe0000\
                          └───romfs\
                              └───GameData\
                                  └───Lua
      ```
  - enable the mod in SimpleModManager. Make sure that only 1 version is enabled at any time and disable any existing version before enabling a new one!

<br>

- **Manual**: put the "contents" folder (located inside the "KingdomUnlocked_..._Switch" folder) on your SD Card (overwrite if asked)

---

### Ryujinx
- [Download the _Ryujinx version of the mod under "Assets"](https://github.com/j4ceee/KingdomUnlocked/releases/latest) & extract the ZIP file (on Windows: right click -> Extract All.. -> Extract).
- You should now see a folder name like this "KingdomUnlocked_vX.Y.Z_Ryujinx"
- right click on MySims Kingdom -> "Manage Mods" -> "Add" -> now go to where you extracted the ZIP file & select the folder "KingdomUnlocked"
- the mod should now appear as "KingdomUnlocked_vX.Y.Z_Ryujinx" in the mod manager



## Colour Codes
- 🟢**Safe** = you really have to try hard to break things
- 🔵**Generally Safe** = there is a possibility you may break something, although very slim
- 🟠**Potentially Unsafe** = no game breaking bugs were found during testing, these options may have unexpected side effects
- 🔴**Dangerous** = don't mindlessly use this, this may break your save game permanently
