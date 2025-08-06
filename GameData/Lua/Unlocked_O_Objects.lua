
--- Object Overrides -----------------------------------------------------------------

--{{{ Bathtub.lua --------------------------------------------------------------
Classes.Bathtub.interactionSet.TakeBath.menu_priority = 0
Classes.Bathtub.interactionSet.ForceNPCToUse = {
    name                    = "*Force NPC to take a bath",
    interactionClassName    = "Debug_Interaction_ForceNPCUse",
    actionKey               = "TakeBath",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 1,
}
--}}}


--{{{ Bed.lua --------------------------------------------------------------
Classes.Bed.interactionSet.Sleep.menu_priority          = 0
Classes.Bed.interactionSet.SleepTillDay.menu_priority   = 1
Classes.Bed.interactionSet.SleepTillNight.menu_priority = 2

Classes.Bed.interactionSet.ForceNPCToUse.menu_priority  = 3
Classes.Bed.interactionSet.ForceNPCToUse.name = "*Force NPC to Sleep"
Classes.Bed.interactionSet.ForceNPCToUse.icon = "uitexture-interaction-sleep"
--}}}


--{{{ Bookshelf.lua --------------------------------------------------------------
Classes.Bookshelf.interactionSet.Browse.menu_priority = 0

-- add cheat menu access
Classes.Bookshelf.interactionSet.OpenSpawnMenu = {
    name                    = "*Open Spawn Menu",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_spawn",
    icon                    = "uitexture-hud-relationships-on",
    menu_priority           = 1,
}
Classes.Bookshelf.interactionSet.OpenCheatsGeneral = {
    name                    = "*Open General Cheats",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_menu",
    icon                    = "uitexture-interaction-inspect",
    menu_priority           = 2,
}
Classes.Bookshelf.interactionSet.OpenCheatsClothing = {
    name                    = "*Open Clothing Cheats",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_clothing",
    icon                    = "uitexture-interaction-change",
    menu_priority           = 3,
}
Classes.Bookshelf.interactionSet.OpenCheatsIslands = {
    name                    = "*Open Island Cheats",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_menu_islands",
    icon                    = "uitexture-interaction-leave",
    menu_priority           = 4,
}
--}}}


--{{{ Campfire.lua --------------------------------------------------------------
-- interaction sets
Classes.Campfire.interactionSet.RoastMarshmallows.menu_priority = 0
Classes.Campfire.interactionSet.WarmHands.menu_priority         = 1

Classes.Campfire.interactionSet.ForceNPCUse.menu_priority       = 3
Classes.Campfire.interactionSet.ForceNPCUse.actionKey = { "RoastMarshmallows", "WarmHands" } -- random action

Classes.Campfire.interactionSet.TurnOn = {
    name                    = "STRING_INTERACTION_STEREO_TURNON",
    interactionClassName    = "Unlocked_I_Campfire_On",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 2,
}

Classes.Campfire.interactionSet.TurnOff = {
    name                    = "STRING_INTERACTION_STEREO_TURNOFF",
    interactionClassName    = "Unlocked_I_Campfire_Off",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 2,
}

-- functionality
Classes.Campfire._instanceVars.bInUse = false
Classes.Campfire._instanceVars.bWasOn = false

function Classes.Campfire:TurnOn( calledBySim )
    calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)
    self.bInUse = calledBySim

    if (not calledBySim) then
        self.bWasOn = true -- remember that it was before used by sim
    end

    if not self.bOn then
        self.bOn = true
        self.fxHandle = self:CreateFX(  "obj-camp-fire-effects",
                FXPriority.High,
                FXStart.Now,
                FXLifetime.Continuous,
                FXAttach.Rigid,
                0,
                0,0,0   )
    end
end

function Classes.Campfire:TurnOff( calledBySim )
    if self.bOn then
        calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)

        if (not calledBySim) then
            self.bWasOn = false -- player is turning it off
        end

        self.bInUse = false
        if (not self.bWasOn) then
            self.bOn = false
            if self.fxHandle then
                self:DestroyFX( self.fxHandle, FXTransition.Hard )
                self.fxHandle = nil
            end
        end
    end
end


-- Chair.lua --------------------------------------------------------------
Classes.Chair.interactionSet.Sit.menu_priority = 0
Classes.Chair.interactionSet.Nap.menu_priority = 1
Classes.Chair.interactionSet.ForceNPCToUse = {
    name = "*Force NPC to Use",
    interactionClassName = "Debug_Interaction_ForceNPCUse",
    actionKey = {"Sit", "Nap"},
    icon = "uitexture-interaction-sit",
    menu_priority = 2,
}
--}}}


--{{{ Chair.lua --------------------------------------------------------------
Classes.Chair.interactionSet.Sit.menu_priority = 0
Classes.Chair.interactionSet.Nap.menu_priority = 1
Classes.Chair.interactionSet.ForceNPCToUse = {
    name = "*Force NPC to Use",
    interactionClassName = "Debug_Interaction_ForceNPCUse",
    actionKey = {"Sit", "Nap"},
    icon = "uitexture-interaction-sit",
    menu_priority = 2,
}
--}}}


--{{{ Couch.lua --------------------------------------------------------------
Classes.Couch.interactionSet.Sit.menu_priority              = 0
Classes.Couch.interactionSet.Sleep.menu_priority            = 1
Classes.Couch.interactionSet.SleepTillDay.menu_priority     = 2
Classes.Couch.interactionSet.SleepTillNight.menu_priority   = 2
Classes.Couch.interactionSet.JumpOn.menu_priority           = 3

Classes.Couch.interactionSet.ForceNPCToUse = {
    name                    = "*Force NPC to Use",
    interactionClassName    = "Debug_Interaction_ForceNPCUse",
    actionKey               = {"Sit", "Sleep", "JumpOn"},
    icon                    = "uitexture-interaction-use",
    menu_priority           = 4,
}
--}}}


--{{{ DanceFloor.lua --------------------------------------------------------------
Classes.DanceFloor.interactionSet.Dance.menu_priority = 0

Classes.DanceFloor.interactionSet.TurnOn = {
    name                    = "STRING_INTERACTION_STEREO_TURNON",
    interactionClassName    = "Unlocked_I_DanceFl_On",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 1,
}
Classes.DanceFloor.interactionSet.TurnOff = {
    name                    = "STRING_INTERACTION_STEREO_TURNOFF",
    interactionClassName    = "Unlocked_I_DanceFl_Off",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 2,
}
--}}}


--{{{ DJBooth.lua --------------------------------------------------------------
-- interaction sets
Classes.DJBooth.interactionSet.DJ.menu_priority             = 0
Classes.DJBooth.interactionSet.DJ_Uber.menu_priority        = 1
Classes.DJBooth.interactionSet.Dance.menu_priority          = 2

Classes.DJBooth.interactionSet.ForceNPCUse.menu_priority    = 4
Classes.DJBooth.interactionSet.ForceNPCUse.name = "*Force NPC to DJ"
Classes.DJBooth.interactionSet.ForceNPCUse.icon = "uitexture-interaction-DJ"

Classes.DJBooth.interactionSet.TurnOn = {
    name                    = "STRING_INTERACTION_STEREO_TURNON",
    interactionClassName    = "Unlocked_I_DJBooth_On",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 3,
}

Classes.DJBooth.interactionSet.TurnOff = {
    name                    = "STRING_INTERACTION_STEREO_TURNOFF",
    interactionClassName    = "Unlocked_I_DJBooth_Off",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 3,
}

-- functionality
Classes.DJBooth._instanceVars.bInUse = false -- is used by NPC
Classes.DJBooth._instanceVars.bWasOn = false -- was on before used by NPC
Classes.DJBooth._instanceVars.maxSpeakers = 30
Classes.DJBooth._instanceVars.maxSpeakersWithAudio = 30

Classes.DJBooth.SoundLoops =
{
    "djbooth_tracka",
    "djbooth_trackb",
    "djbooth_trackc",
    "djbooth_trackd",
    "djbooth_tracke",
    "djbooth_trackf",
    "stereo_music", --- new
}

function Classes.DJBooth:PowerChangedCallback( powerValue )
    if powerValue == 0 then
        self:TurnOff(false)
        self:SetMaterialIndex(0, "WidgetDJbooth_lightsOff", 0)
    else
        self:SetMaterialIndex(1, "WidgetDJbooth_lightsOn", 0)
    end
end

function Classes.DJBooth:TurnOn( trackIndex, calledBySim )
    --- custom code start
    calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)
    self.bInUse = calledBySim

    if (not calledBySim) then
        self.bWasOn = true -- remember that it was used by sim before
    end
    --- custom code end

    if not self.bOn then
        self.bOn = true
        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end

        self.soundIndex = trackIndex or math.random(#Classes.DJBooth.SoundLoops) --- added "Classes."
        local soundAlias =  Classes.DJBooth.SoundLoops[self.soundIndex] --- added "Classes."

        self.hSound = self:PlaySound( soundAlias )
        self:TurnOnSpeakers( soundAlias )

        if self.fxObject then
            self.fxObject:Destroy()
            self.fxObject = nil
        end

        local initFunc =    function ( fxObject )
            self.fxObject = fxObject
        end

        Common:SpawnEffect( self, nil, "Obj-DJBooth-effects", nil, nil, initFunc )
    end
end

function Classes.DJBooth:TurnOff( calledBySim )
    if self.bOn then
        --- custom code start
        calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)

        if (not calledBySim) then
            self.bWasOn = false -- player is turning it off
        end

        self.bInUse = false
        if (not self.bWasOn) then
        --- custom code end
            self.bOn = false
            self:TurnOffSpeakers()
            if self.hSound then
                self:StopSound( self.hSound )
                self.hSound = nil
            end
            if self.fxObject then
                self.fxObject:Destroy()
                self.fxObject = nil
            end
        end
    end
end
--}}}


--{{{ Dresser.lua --------------------------------------------------------------
Classes.Dresser.interactionSet.RifleThroughClothes.menu_priority = 0
Classes.Dresser.interactionSet.ChangeOutfitM = {
    name                    = "Change Outfit (Male)",
    interactionClassName    = "Boat_Interaction_ChangeOutfit",
    actionKey               = "m",
    menu_priority			= 1,
    icon                    = "uitexture-interaction-change",
}
Classes.Dresser.interactionSet.ChangeOutfitF = {
    name                    = "Change Outfit (Female)",
    interactionClassName    = "Boat_Interaction_ChangeOutfit",
    actionKey               = "f",
    menu_priority			= 2,
    icon                    = "uitexture-interaction-change",
}
--}}}


--{{{ FishingBucket.lua --------------------------------------------------------------
Classes.FishingBucket.interactionSet.FishingMiniGame.menu_priority = 0
Classes.FishingBucket.interactionSet.FishingSkip = {
    name                    = "Quick Fishing",
    interactionClassName    = "Unlocked_I_Fishing_Skip",
    metaState               = MetaStates.Fishing,
    icon                    = "uitexture-interaction-use",
    menu_priority           = 1,
}
Classes.FishingBucket.interactionSet.Fish = {
    name                    = "Fish",
    actionKey               = "fish",
    interactionClassName    = "Unlocked_I_FishingBucket_Fish",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 3,
}
Classes.FishingBucket.interactionSet.ForceNPCToUse = {
    name                    = "*Force NPC to Use",
    actionKey               = "fish",
    interactionClassName    = "Debug_Interaction_ForceNPCUse",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 4,
}
--}}}


--{{{ MiningRock.lua --------------------------------------------------------------
Classes.MiningRock.interactionSet.Mine.menu_priority = 0
Classes.MiningRock.interactionSet.MineSkip = {
    name                    = "Quick Mine",
    interactionClassName    = "Unlocked_I_Mine_Skip",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 1,
}
--}}}


--{{{ Stereo.lua --------------------------------------------------------------
Classes.Stereo._instanceVars.maxSpeakers = 30
--}}}


--{{{ Tree.lua --------------------------------------------------------------
Classes.Tree.interactionSet.Plant.menu_priority = 0
Classes.Tree.interactionSet.Stomp.menu_priority = 0
Classes.Tree.interactionSet.Chop.menu_priority = 4
Classes.Tree.interactionSet.Water.menu_priority = 3
Classes.Tree.interactionSet.Harvest.menu_priority = 1

Classes.Tree.interactionSet.HarvestAll = {
    name                    = "STRING_INTERACTION_TREE_HARVEST", -- Harvest All
    interactionClassName    = "Unlocked_I_Tree_PickAll",
    icon                    = "uitexture-interaction-harvest",
    menu_priority           = 0
}
Classes.Tree.interactionSet.WaterAll = {
    name                    = "STRING_INTERACTION_TREE_WATER", -- Water All
    interactionClassName    = "Unlocked_I_Tree_WaterAll",
    icon                    = "uitexture-interaction-water",
    menu_priority           = 2
}
Classes.Tree.interactionSet.ScaleTree = {
    name                    = "Scale Tree",
    interactionClassName    = "Unlocked_I_Scale_Object",
    icon                    = "uitexture-interaction-trade",
    menu_priority           = 5
}
--}}}


--{{{ Boat.lua --------------------------------------------------------------
Classes.Boat.interactionSet.LeaveIsland.menu_priority   = 0
Classes.Boat.interactionSet.WatchCredits.menu_priority  = 3
Classes.Boat.interactionSet.ChangeOutfit = nil

Classes.Boat.interactionSet.ChangeOutfitM = {
    name                    = "Change Outfit (Male)",
    interactionClassName    = "Boat_Interaction_ChangeOutfit",
    actionKey               = "m",
    menu_priority			= 1,
    icon                    = "uitexture-interaction-change",
}
Classes.Boat.interactionSet.ChangeOutfitF = {
    name                    = "Change Outfit (Female)",
    interactionClassName    = "Boat_Interaction_ChangeOutfit",
    actionKey               = "f",
    menu_priority			= 2,
    icon                    = "uitexture-interaction-change",
}
--}}}

