--[[
   @@@@@    @@@@            @@@                       @@@                          @@@
    @@@     @@@             @@@                       @@@                          @@@
    @@@     @@@ @@@@@@@@@   @@@    @@@@@@      @@@@@  @@@   @@@   @@@@@@     @@@@@ @@@
    @@@     @@@  @@@   @@@@ @@@  @@@    @@@  @@@      @@@  @@   @@@   @@@  @@@@   @@@@
    @@@     @@@  @@@    @@@ @@@ @@@      @@@@@@       @@@@@@    @@@@@@@@@@ @@@     @@@
    @@@     @@@  @@@    @@@ @@@  @@@    @@@  @@@      @@@  @@@  @@@        @@@     @@@
     @@@@@@@@@   @@@    @@@ @@@   @@@@@@@@    @@@@@@@ @@@   @@@  @@@@@@@@    @@@@@ @@@
--]]

-- This file is part of the Unlocked Mod for the game.
-- Here you can modify mod settings to your liking.
-- Possible values are true or false.

--- Enable all debug options and cheat menus (default: true)
--- If false, only Quality of Life options will be available
local enableDebugInteractions = true

--- Enable model swap menu for sims (default: true)
--- If true, you can swap the clothes of any sim
local enableModelSwap = true

--- Enable skipping cutscenes (default: true)
local enableSkippingCutscenes = true

--- Enable Flying (default: false)
local enableFlying = false



















----------------------- !! DO NOT MODIFY BELOW THIS LINE !! ----------------------- !!

local function InitializeUnlockedMod()
    -- add new debug menu items
    DebugMenu:AddValueItem("UnlockedFlying", enableFlying, DebugMenuItemTypes.kTypeBool)
    DebugMenu:AddValueItem("UnlockedModelSwap", enableModelSwap, DebugMenuItemTypes.kTypeBool)

    -- modify existing debug menu values
    DebugMenu:ModifyValue("EnableDebugInteractions", enableDebugInteractions)
    DebugMenu:ModifyValue("EnableSkippingCutscenes", enableSkippingCutscenes)

    -- modify existing Debug_Settings values
    Debug_Settings.EnableDebugInteractions = enableDebugInteractions
    Debug_Settings.EnableSkippingCutscenes = enableSkippingCutscenes

    -- add new Debug_Settings values
    Debug_Settings.UnlockedFlying = enableFlying
    Debug_Settings.UnlockedModelSwap = enableModelSwap
end

-- Register the initialization function to run after the system is loaded
System:RegisterSystemPostLoadInit(InitializeUnlockedMod)