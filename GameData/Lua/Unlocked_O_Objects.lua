
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
Classes.Bookshelf.interactionSet.OpenCheatsGeneral = {
    name                    = "*Open General Cheats",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_menu",
    icon                    = "uitexture-interaction-inspect",
    menu_priority           = 1,
}
Classes.Bookshelf.interactionSet.OpenCheatsIslands = {
    name                    = "*Open Island Cheats",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_menu_islands",
    icon                    = "uitexture-interaction-leave",
    menu_priority           = 2,
}
Classes.Bookshelf.interactionSet.OpenSpawnMenu = {
    name                    = "*Open Spawn Menu",
    interactionClassName    = "Unlocked_CheatMenu",
    actionKey               = "db_spawn",
    icon                    = "uitexture-hud-relationships-on",
    menu_priority           = 3,
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


--{{{ DanceFloor_Interaction_Dance.lua --------------------------------------------------------------
function Classes.DanceFloor_Interaction_Dance:Pre_ANIM_LOOPS( sim, obj )
    if not self.bOn then
        obj:TurnOn()
    end
end

function Classes.DanceFloor_Interaction_Dance:ANIMATE_LOOPS_CONTINUE( sim, obj )
    --return (obj.bOn)
    return true -- npcs should keep on dancing when the player turns off the dance floor
end

function Classes.DanceFloor_Interaction_Dance:Post_ANIM_LOOPS( sim, obj )
    return -- don't turn off the dance floor
end

function Classes.DanceFloor_Interaction_Dance:Shutdown( sim, obj )
    return -- don't turn off the dance floor
end
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


--{{{ DJBooth_Interaction_DJ.lua --------------------------------------------------------------
function Classes.DJBooth_Interaction_DJ:Test( sim, obj, autonomous )

    if obj.bInUse or obj:GetWidgetPowerValue() == 0 then --- custom code
        return false
    end

    if autonomous == true and GameManager:IsDuringTaskTime() then
        if obj.collectionKey == Luattrib:ConvertStringToUserdataKey("djbooth_00031") then
            if sim.mType ~= "NPC_DJCandy" and Task:IsTaskComplete("Cutscene_Candy_RoadieSoundCheck") then
                return false
            end
        end
    end

    return true
end

function Classes.DJBooth_Interaction_DJ_Uber:Test( sim, obj, autonomous, interactionData )
    local powerRequirement = interactionData.powerRequirement or 2.0

    if sim == Universe:GetPlayerGameObject() then
        --- custom code
        return (not obj.bInUse) and DebugMenu:GetValue("EnableDebugInteractions") and obj:GetWidgetPowerValue() > 0
    end

    return (not obj.bInUse) and obj:GetWidgetPowerValue() >= powerRequirement --- custom code
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
    name                    = "Harvest All",
    interactionClassName    = "Unlocked_I_Tree_PickAll",
    icon                    = "uitexture-interaction-harvest",
    menu_priority           = 0
}
Classes.Tree.interactionSet.WaterAll = {
    name                    = "Water All",
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


--{{{ Boat_Interaction_ChangeOutfit.lua --------------------------------------------------------------
function Classes.Boat_Interaction_ChangeOutfit:Test( sim, obj, autonomous )
    return sim == Universe:GetPlayerGameObject() -- and Unlocks:IsUnlocked("lock", "boat_cas") -- skip unlock check
end

function Classes.Boat_Interaction_ChangeOutfit:Action()
    local gender = nil
    if self.params and self.params.actionKey then
        if self.params.actionKey == "m" then
            gender = Constants.Gender.Male
        elseif self.params.actionKey == "f" then
            gender = Constants.Gender.Female
        end
    end

    -- due to PostSpawn() call in UICASContextPicker:Constructor() we need a different approach
    -- (no idea why PostSpawn() is called in UICASContextPicker:Constructor())
    -- instead: set a pendingGender variable in the class & access inside UICASContextPicker:SetParams()
    Classes.UICASContextPicker.pendingGender = gender

    local reason, context = UI:SpawnAndBlock( "UICASContextPicker" )

    if( reason == 1 ) then
        GameManager:EnterCAS( "cas_context", context )
    end
end
--}}}
