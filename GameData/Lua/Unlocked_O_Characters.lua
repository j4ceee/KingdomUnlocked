
--- Character Overrides -----------------------------------------------------------------

--{{{ CharacterBase.lua --------------------------------------------------------------
Classes.CharacterBase._instanceVars.fVisScale = 1.0
Classes.CharacterBase._instanceVars.bAutonomyRunning = false
Classes.CharacterBase._instanceVars.autoBR = nil -- the buildable region the character last routed to
Classes.CharacterBase._instanceVars.autoIntNo = 0 -- number of available interactions in search distance
Classes.CharacterBase._instanceVars.autoLastAction = nil -- last action performed by the character

Classes.CharacterBase._instanceVars.lastCoords = nil -- coordinates when constructed
Classes.CharacterBase._instanceVars.openAction = nil -- whether the spawned character has an outstanding action

function Classes.CharacterBase:SetMySpecificScale()
    self:SetScale( self.fVisScale )
end

--- safety margin for y coordinate when teleporting sims
local simTpSafety = 0.5
--- safety margin when checking for ground height (higher than highest point in-game, so that always highest point is returned)
local simGroundSafety = 8.0

-----------------------
-- Sim Spawning
---


--- Constructor for the CharacterBase class
function Classes.CharacterBase:Constructor()
    if EA.LogMod then
        EA:LogMod("Unlocked", "CharacterBase:Constructor ", tostring(self.mType))
    end
    self.actionQueue = {}

    self.schedule = Classes.Schedule:New( self, "ScheduleComponent")

    self.controllingJob = nil

    --- custom code start
    local mTypeString = tostring(self.mType)
    if mTypeString == "NPC_Linzey" or mTypeString == "NPC_Buddy" or mTypeString == "Player" then
        -- never teleport Lindsay, Buddy or the player; they are handled by the game engine
        return
    end
    --EA:LogMod("Unlocked", "CharacterBase Snapping to safe position ", mTypeString, tostring(self.containingObject), tostring(self.containingWorld))

    if self.containingObject ~= self.containingWorld then
        -- never teleport NPCs that are not currently wandering the world
        return
    end

    -- sometimes game crashes after Constructor() & before BeginIslandSimulationCallback() due to invalid position
    -- thus teleport all sims to world safe position here -> all positions are reset
    local x, y, z, rotY = self:GetPositionRotation()
    if (not (x == 0 and y == 0 and z == 0 and rotY == 0)) then -- sims has never been spawned before
        self.lastCoords = { x = x, y = y, z = z, rotY = rotY } -- store coordinates when constructed
        self:TeleportToSchedule()
    end
    --- custom code end
end

--- Callback for when the island simulation begins
function Classes.CharacterBase:BeginIslandSimulationCallback(islandRefSpec) --- custom code
    -- EA:LogI("Steve", "CharacterBase:BeginIslandSimulationCallback ", tostring(islandRefSpec[1]), tostring(islandRefSpec[2]))
    local mTypeString = tostring(self.mType)

    -- snap to safe position if the character was interacting with an object (prevents characters being teleported into objects)
    if self.containingObject ~= self.containingWorld then
        if EA.LogMod then
            EA:LogMod("Unlocked", "CharacterBase:BeginIslandSimulationCallback - Snapping to safe position ", mTypeString, tostring(self.containingObject), tostring(self.containingWorld))
        end
        self:SnapToSafePosition(true)
    end

    if mTypeString == "NPC_Linzey" or mTypeString == "NPC_Buddy" or mTypeString == "Player" then
        -- never teleport Lindsay, Buddy or the player; they are handled by the game engine
        return
    end

    if EA.LogMod then
        EA:LogMod("Unlocked", "CharacterBase:BeginIslandSimulationCallback ", mTypeString)
    end

    -- redistribute the sims around island
    -- if previous position is valid, place sims there
    -- otherwise find new spot (like from schedule block or random destination)
    if self.lastCoords == nil or self:IsAreaOutOfBounds(self.lastCoords.x, self.lastCoords.y, self.lastCoords.z) then
        if EA.LogMod then
            EA:LogMod("Unlocked", "CharacterBase:BeginIslandSimulationCallback - Old Position out of bounds", mTypeString)
        end
        -- do nothing, we already teleported the sim to a safe position in the constructor, so just keep the sim there
    else
        local groundY = self.containingWorld:GetGroundHeight(self.lastCoords.x, self.lastCoords.y + simGroundSafety, self.lastCoords.z)
        if EA.LogMod then
            EA:LogMod("Unlocked", "CharacterBase:BeginIslandSimulationCallback - Position within bounds, teleporting to", self.lastCoords.x, groundY + simTpSafety, self.lastCoords.z, mTypeString)
        end
        self:SetPositionRotation( self.lastCoords.x, groundY + simTpSafety, self.lastCoords.z, self.lastCoords.rotY )
    end
    self.lastCoords = nil -- reset lastCoords after teleporting
end


--- Check if an area around a center point is out of bounds
--- @param centerX number X coordinate of the center point
--- @param centerY number Y coordinate of the center point
--- @param centerZ number Z coordinate of the center point
--- @param radius number Radius around the center point to check (default is 2)
function Classes.CharacterBase:IsAreaOutOfBounds(centerX, centerY, centerZ, radius)
    radius = radius or 2 -- default 2-unit radius around the center point

    -- check corners of a square around the center point
    local checkPoints = {
        -- top row
        --{centerX - radius, centerY, centerZ + radius}, -- top-left
        {centerX,          centerY, centerZ + radius}, -- top-center
        --{centerX + radius, centerY, centerZ + radius}, -- top-right

        -- middle row
        {centerX - radius, centerY, centerZ},          -- middle-left
        {centerX,          centerY, centerZ},          -- center (original position)
        {centerX + radius, centerY, centerZ},          -- middle-right

        -- bottom row
        --{centerX - radius, centerY, centerZ - radius}, -- bottom-left
        {centerX,          centerY, centerZ - radius}, -- bottom-center
        --{centerX + radius, centerY, centerZ - radius}, -- bottom-right
    }

    for i, point in ipairs(checkPoints) do
        if self:IsPositionOutOfBounds(point[1], point[2], point[3]) then
            if EA.LogMod then
                EA:LogMod("Unlocked", "Corner", i, "out of bounds at", point[1], point[2], point[3])
            end
            return true
        end
    end

    -- all points are valid
    return false
end

--- Check if a given position is out of bounds
--- @param x number X coordinate
--- @param y number Y coordinate
--- @param z number Z coordinate
--- @return boolean true if the position is out of bounds, false otherwise
function Classes.CharacterBase:IsPositionOutOfBounds(x, y, z)
    local groundY = self.containingWorld:GetGroundHeight(x, y + simGroundSafety, z)
    local footprintType = self.containingWorld:GetFootPrintType( x, groundY, z, FootPrintType.FootPrintType_Impassable )
    return (
            footprintType == FootPrintType.FootPrintType_Impassable or
            groundY == nil
    ) -- position is out of bounds if it is impassable / not prospectable / ground height is nil
end

--- Teleport the character to the location of the current schedule block or a random destination if no block is available
function Classes.CharacterBase:TeleportToSchedule()
    local mTypeString = tostring(self.mType)
    local xS, yS, zS, rotY = self:GetPositionRotation()
    local x, y, z
    ---------------------
    -- Teleport to schedule block
    --
    if self.schedule ~= nil then
        local block = nil
        block = self.schedule:GetCurrentScheduleBlock()
        if block ~= nil then
            local worldName
            x, y, z, worldName = self.schedule:GetBlockCoords(block)
            if worldName ~= nil and not (x == -1 and y == -1 and z == -1) and not (x == xS and y == yS and z == zS) then
                -- if the block has a valid position and is not the same as the current position, teleport to it
                -- (sometimes schedules just use the current position, there is no sense in teleporting there -> go to random destination)
                y = y or self.containingWorld:GetGroundHeight(x, (y or 1) + simGroundSafety, z)
                if EA.LogMod then
                    EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - Teleporting to schedule block", block.name, "at", x, y, z, "in world", worldName, mTypeString)
                end
                self:SetPositionRotation( x, y + simTpSafety, z, rotY ) -- teleport the sim to the position of the schedule block
                return
            end
        end
    end

    ---------------------
    -- Teleport to any safe position
    --
    --EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - No valid schedule block, using random destination ", mTypeString)
    local destList = {}
    if self.containingWorld.mName ~= "reward_01" then -- everywhere except the reward island
        --EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - Getting all safe positions in world", self.containingWorld.mName, mTypeString)
        destList = Common:GetAllObjectsOfTypes({ "buildable_region", "fishing_bucket" }, self.containingWorld) -- include br safe positions and fishing buckets
    end

    -- check for manually defined extra safe positions
    local extraSafePos = Constants.ExtraSafePositions[tostring(self.containingWorld.mName)]
    if extraSafePos then
        --EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - Adding extra safe positions for world", self.containingWorld.mName, mTypeString)
        for _, pos in ipairs(extraSafePos) do
            -- add extra safe positions to the destination list
            pos.mType = "Coordinate"
            destList[#destList + 1] = pos
        end
    end

    local destNo = #destList
    if destNo > 0 then
        --EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - Found", destNo, "destinations in world", self.containingWorld.mName, mTypeString)
        -- if there valid destinations, choose one at random
        local destIndex = math.random(destNo)
        local dest = destList[destIndex]

        if dest.mType == "BuildableRegion" then -- buildable region
            x, y, z = dest:GetSafePosition()
            x = x + math.random(-1, 1) -- random offset to prevent all sims from spawning at the same position
            z = z + math.random(-1, 1)

        elseif dest.mType == "Coordinate" then -- manually defined coordinate
            --EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - Using coordinate destination")
            x = dest.x + math.random(-0.5, 0.5) -- random offset
            y = dest.y
            z = dest.z + math.random(-0.5, 0.5)

        else -- object
            x, y, z = dest:GetPositionRotation()
        end

        if EA.LogMod then
            EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - Using destination", destIndex, "of", destNo, "destinations ", mTypeString)
        end
    else
        -- if no buildable regions found, use the world safe position (should never happen)
        x, y, z = self:GetWorldSafePosition()
        x = x + math.random(-0.5, 0.5) -- random offset to prevent all sims from spawning at the same position
        z = z + math.random(-0.5, 0.5)
        y = y + math.random(2, 5) -- stack sims to prevent clipping into ground
        --EA:LogMod("Unlocked", "CharacterBase:TeleportToSchedule - No destinations found, using world safe position ", mTypeString)
    end

    self:SetPositionRotation( x, y + simGroundSafety, z, rotY )
end

-----------------------
-- Sim Autonomy
---

function Classes.CharacterBase:MainLoop()

    while true do
        --if self.openAction and self.containingObject ~= self.containingWorld then
        --    local mTypeString = tostring(self.mType)
        --    local obj = self.containingObject
        --    local firstKey = self.openAction
        --    EA:LogMod("Unlocked", "CharacterBase:BeginIslandSimulationCallback -", tostring(firstKey), "interaction set for", mTypeString)
        --
        --    local nucleus = InteractionNucleus:Create( obj, firstKey, nil, Constants.InteractionPriorities.UserDriven )
        --
        --    if nucleus.object ~= nil then
        --        nucleus.object:InUseAddRef()
        --    end
        --
        --    local job = nucleus:CreateInteractionInstance(self)
        --    job:Execute(self)
        --    local result, reason = job:BlockOn()
        --
        --    if self.schedule then
        --        self.schedule:RequestCancel()
        --    end
        --
        --    if self.action ~= nil and self.action.isValid then
        --        self.action:Kill( true )
        --    end
        --
        --    local result, reason = self:ProcessInteractionJob(job)
        --
        --    if nucleus.object ~= nil then
        --        nucleus.object:InUseDecRef()
        --    end
        --
        --    self.openAction = nil
        --end

        EA:ProfileEnterBlock("Lua__CharacterBase_MainLoop")
        self:ProcessControlRequest()

        local result

        if self:GetQueuedInteractionCount() > 0 then
            result = self:DoNextInteraction()

        elseif self.schedule ~= nil and DebugMenu:GetValue("EnableScheduleAutonomy") then

            result = self.schedule:ProcessSchedule()
        --- custom code start
            if result == nil and not self.bAutonomyRunning then
                -- if schedule is nil, execute real fake autonomy
                self:RealFakeAutonomy(true)
                result = BlockingResult.Failed
                self.bAutonomyRunning = false
            end
        elseif (not self.bAutonomyRunning) then
            self:RealFakeAutonomy(true)
            result = BlockingResult.Failed
            self.bAutonomyRunning = false
        else
            result = BlockingResult.Failed
        --- custom code end
        end

        -- We can only guarantee that a blocking operation occurred if we got a succeeded result.
        -- In the absence of that we must yield to prevent an infinite loop
        if result ~= BlockingResult.Succeeded then
            EA:ProfileLeaveBlock("Lua__CharacterBase_MainLoop", self.mType)
            Yield()
        end
    end
end

function Classes.CharacterBase:RealFakeAutonomy(bForceOn)
    --EA:LogMod("Autonomy", "RealFakeAutonomy called for " .. self.mType)
    bForceOn = bForceOn or false -- force autonomy on, even if disabled

    self.bAutonomyRunning = true

    if (DebugMenu:GetValue("EnableRealFakeAutonomy") and self.autonomyEnabled) or bForceOn then
        local bIsInterior = self.containingWorld:GetAttribute("InteriorWorld")

        local actionChance = math.random(1, 100)

        --PushInteraction( object, key, params, bDoNotCancelCurrent, bPushFront, priority )

        -------------
        -- just idle for a while - 15% chance
        --
        if actionChance <= 15 then
            self:PushInteraction(self, "Idle", {
                tuningSpec = {
                    duration = {
                        minSeconds = 3,
                        maxSeconds = 10,
                    },
                },
            }, true, nil, Constants.InteractionPriorities["Autonomy"] )
            return

        -------------
        -- 10% chance to exit building (interior)
        --
        elseif actionChance <= 25 and bIsInterior then
            --EA:LogMod("Autonomy", "RealFakeAutonomy: Sim " .. self.mType .. " is looking for a door to exit building")
            local world = self.containingWorld
            if not world then return end

            local searchDistance = 50 -- distance to search for doors in interior worlds

            -- TODO: inefficient, get all nearby doors instead of all objects
            local t = world:CreateTable(self, searchDistance)
            if not t then return end

            for go in pairs(t) do
                if InteractionUtils:IsObjectInteractable(go) then

                    for key in pairs(go.interactionSet) do

                        if go.mType == "DoorBase" and
                                InteractionUtils:InteractionTest( self, go, key, true ) then
                            self:PushInteraction( go, key, nil, false, nil, Constants.InteractionPriorities["Autonomy"] )
                            return
                        end
                    end
                end
            end

        -------------
        -- 15% chance to route to a buildable region (exterior)
        --
        elseif actionChance <= 30 and not bIsInterior and self.autoLastAction ~= "route" then
            local destList = Common:GetAllObjectsOfTypes({ "buildable_region", "fishing_bucket", "boat" })

            local extraPoi = Constants.ExtraPoi[tostring(self.containingWorld.mName)]
            if extraPoi then
                for _, pos in ipairs(extraPoi) do
                    -- add extra safe positions to the destination list
                    pos.mType = "Coordinate"
                    destList[#destList + 1] = pos
                end
            end

            if #destList < 3 then
                -- if there are not enough destinations, remove boats from the list (prevent cluttering)
                destList = Common:GetAllObjectsOfTypes({ "buildable_region", "fishing_bucket" })
            end

            if #destList > 1 then
                local dest = destList[math.random(#destList)]
                self.autoBR = nil -- set the autoBR to the destination

                local x, _, z, dist
                if dest.mType == "BuildableRegion" then
                    -- buildable region
                    x, _, z = dest:GetSafePosition()
                    dist = 2 -- distance to route to
                elseif dest.mType == "Coordinate" then
                    -- coordinate
                    x = dest.x
                    z = dest.z
                    dist = 3
                else
                    -- object
                    x, _, z = dest:GetPositionRotation()
                    dist = 3
                end

                local routeJob = self:GetRouteToPositionJob( x, z, dist )
                routeJob:SetAllowRouteFailure( false )
                local result, reason = self:ProcessInteractionJob(routeJob)

                if result == BlockingResult.Succeeded then
                    if dest.mType == "BuildableRegion" then
                        -- if we routed to a buildable region, set the autoBR to it
                        self.autoBR = dest
                    end
                    self.autoLastAction = "route"
                    return
                end
            end
            -- if no buildable region found or route failed, fall through to wander

        -------------
        -- chance to interact with objects
        -- near buildable region:
        -- 30% (exterior, near buildable region)
        -- 20% (exterior, not near buildable region)
        -- 35% (interior)
        elseif actionChance <= 50 or (actionChance <= 60 and (self.autoBR or bIsInterior)) then
            local world = self.containingWorld
            if not world then return end

            local searchDistance = 100 -- distance to search for interactable objects in exterior worlds
            if self.autoBR then
                searchDistance = 1000 -- distance to search for interactable objects in buildable regions
            elseif bIsInterior then
                searchDistance = 100 -- distance in interior worlds
            end

            local actionList = {}

            local t = world:CreateTable(self, searchDistance)

            for go in pairs(t) do
                if InteractionUtils:IsObjectInteractable(go) then -- check if the object is interactable
                    for key in pairs(go.interactionSet) do -- for each interaction of the interaction set of the object
                        if InteractionUtils:InteractionTest( self, go, key, true ) then -- test if sim can use the interaction
                            actionList[#actionList+1] = { object=go, key=key } -- add the object and key to the action list if test passed
                        end
                    end
                end
            end
            local actionCount = #actionList
            if actionCount > 0 then
                self.autoIntNo = actionCount -- store the number of available interactions in search distance
                local selection = actionList[math.random(actionCount)]
                self:PushInteraction( selection.object, selection.key, nil, nil, nil, Constants.InteractionPriorities["Autonomy"] )

                self.autoLastAction = "interact" -- set the last action to interact
                return
            else
                self.autoIntNo = 0 -- no interactable objects found, reset the counter
            end
            -- if no interactable objects found, fall through to wander
        end

        -------------
        -- 40% chance to wander OR fall through if-clause
        --
        local minDist = 34.0  -- long distance in exterior worlds
        local maxDist = 35.0

        if bIsInterior then
            -- shorter distance in buildings
            minDist = 5.0
            maxDist = 10.0
        end

        self:PushInteraction(self, "Wander", {
            distance = {min = minDist, max = maxDist},
        }, true, nil, Constants.InteractionPriorities["Autonomy"] )

        self.autoLastAction = "wander" -- set the last action to wander
        return
    end

    return
end

-----------------------
-- new interaction sets
---

Classes.CharacterBase.interactionSet.DebugUi =   {
    name                    = "Debug Menu",
    interactionClassName    = "Unlocked_SocialMenu",
    icon                    = "uitexture-interaction-use",
    menu_priority           = 30,
}

Classes.CharacterBase.interactionSet.ChangeOutfit =  {
    name                    = "STRING_INTERACTION_BOAT_CHANGEOUTFIT",
    interactionClassName    = "Unlocked_ModelMenu",
    icon                    = "uitexture-interaction-change",
    menu_priority           = 21,
}

Classes.CharacterBase.interactionSet.Chat =  {
    name                    = "STRING_INTERACTION_CHARACTERBASE_TALK",
    interactionClassName    = "Unlocked_I_Chat",
    icon                    = "uitexture-interaction-talk",
    menu_priority           = 22,
}

--[[
TODO: find a way to keep scale when interacting with objects & falling out of world
Classes.CharacterBase.interactionSet.ScaleSim = {
    name                    = "Scale Sim",
    interactionClassName    = "Unlocked_I_Scale_Object",
    icon                    = "uitexture-interaction-trade",
    menu_priority           = 29,
},
--]]

-- interaction set sorting
Classes.CharacterBase.interactionSet.Socialize.menu_priority    = 10;
Classes.CharacterBase.interactionSet.Move.menu_priority         = 20;
--Classes.CharacterBase.interactionSet.ChangeOutfit.menu_priority = 21;
Classes.CharacterBase.interactionSet.PushSim.menu_priority      = 22;
Classes.CharacterBase.interactionSet.Teleport.menu_priority     = 23;
--Classes.CharacterBase.interactionSet.ScaleSim.menu_priority     = 29;
--Classes.CharacterBase.interactionSet.DebugUi.menu_priority      = 30;

-- interaction set icons
Classes.CharacterBase.interactionSet.Move.icon      = "uitexture-interaction-herd"
Classes.CharacterBase.interactionSet.PushSim.icon   = "uitexture-interaction-warmhands"

-- remove unneeded sets
Classes.CharacterBase.interactionSet.AdvanceSchedule = nil
Classes.CharacterBase.interactionSet.ForceNPCIdle = nil
--}}}


--{{{ NPC_Declarations.lua --------------------------------------------------------------
-- Lyndsay gets modified in NPC_Declarations.lua, undo this here
Classes.NPC_Linzey.interactionSet = nil
-- copy changes to CharacterBase from above
Classes.NPC_Linzey.interactionSet = System:CopyShallow(Classes.CharacterBase.interactionSet)
Classes.NPC_Linzey.interactionSet.Trade =
{
    name                    = "STRING_INTERACTION_NPCLINZEY_BUYSELL",
    interactionClassName    = "CharacterBase_Interaction_Social",
    socialClassName         = "Social_BuySell",
    menu_priority           = 2,
    icon                    = "uitexture-interaction-trade",
}

-- add shipwreck cove npcs
Classes.CharacterBase:Inherit("NPC_Morgan")
Classes.CharacterBase:Inherit("NPC_Neema")
Classes.CharacterBase:Inherit("NPC_Mira")
Classes.CharacterBase:Inherit("NPC_Theodore")
--}}}


--{{{ NPC_IdleData.lua --------------------------------------------------------------
Classes.NPC_Morgan._idleAnimations =
{
    {   sim = "a-idle-neutral",         weight = 20,  },
    {   sim = "a-idle-neutral-blink",   weight = 10,  },
    {   sim = "a-idle-lookAround",      weight = 10,  },
    {   sim = "a-idle-searchAround",    weight = 5,  },

    {   sim = "a-idle-strongSurvey",    weight = 5,  },
    {   sim = "a-idle-studyMap",        weight = 5,  },
    {   sim = "a-idle-evilPlan",        weight = 5,  },
}

Classes.NPC_Neema._idleAnimations =
{
    {   sim = "a-idle-neutral",         weight = 20,  },
    {   sim = "a-idle-neutral-blink",   weight = 10,  },
    {   sim = "a-idle-lookAround",      weight = 10,  },

    {   sim = "a-idle-waterInEar",      weight = 5,  },
    {   sim = "a-idle-castSpell",       weight = 5,  },
    {   sim = "a-idle-checkClothes",    weight = 5,  },
}

Classes.NPC_Mira._idleAnimations =
{
    {   sim = "a-idle-neutral",         weight = 20,  },
    {   sim = "a-idle-neutral-blink",   weight = 10,  },
    {   sim = "a-idle-bop",             weight = 5,  },
    {   sim = "a-idle-searchAround",    weight = 10,  },

    {   sim = "a-idle-pullOutFish",     weight = 5,  },
    {   sim = "a-idle-studyMap",        weight = 5,  },
}

Classes.NPC_Theodore._idleAnimations =
{
    {   sim = "a-idle-neutral",             weight = 20,  },
    {   sim = "a-idle-neutral-blink",       weight = 10,  },
    {   sim = "a-idle-bop",                 weight = 5,  },
    {   sim = "a-idle-searchAround",        weight = 10,  },

    {   sim = "a-idle-paranoidLookAbout",   weight = 10,  },
    {   sim = "a-idle-pullOutFish",         weight = 5,  },
    {   sim = "a-idle-waterInEar",          weight = 5,  },
    {   sim = "a-idle-sneeze",              weight = 10,  }
}
--}}}


--{{{ CharacterBase_Debug_PushSim.lua --------------------------------------------------------------
function Classes.CharacterBase_Debug_PushSim:Action( sim, npc )
    local angle = sim:GetAngle( npc )

    local x, y, z, rotY = npc:GetPositionRotation()

    x, z = Common:GetRelativePosition( 0, 2, x, z, angle )

    npc:SetPositionRotation( x, y+2.0, z, rotY )

    -- check if sim has function SetMySpecificScale()
    if npc.SetMySpecificScale then
        npc:SetMySpecificScale()
    end
end
--}}}


--{{{ CharacterBase_Debug_AdvanceSchedule.lua --------------------------------------------------------------
function Classes.CharacterBase_Debug_AdvanceSchedule:Test( sim, npc, autonomous )
    return false -- never display interaction
end
--}}}


--{{{ CharacterBase_Interaction_Move.lua --------------------------------------------------------------
function Classes.CharacterBase_Interaction_Move:Test( sim, obj, autonomous )
    if sim == Universe:GetPlayerGameObject() and sim ~= obj then
        return true
    end
end
--}}}


--{{{ CharacterBase_Interaction_TeleportToSafePosition.lua --------------------------------------------------------------
function Classes.CharacterBase_Interaction_TeleportToSafePosition:Test( sim, npc, autonomous )
    local bIsPlayer = sim == Universe:GetPlayerGameObject()

    -- Player -> NPC only
    local bIsPlayerToSim = bIsPlayer and sim ~= npc

    if (bIsPlayerToSim == false) then
        return false
    end

    --return npc:IsCharacterStuck() == true -- new C++ function to check if NPC is stuck
    return true
end

function Classes.CharacterBase_Interaction_TeleportToSafePosition:Action( sim, npc )

    local npcX, npcY, npcZ, npcRotY = npc:GetPositionRotation()

    local x, y, z, bValidPosition
    local bIsAnimal

    -- check if npc has GetWorldSafePosition function
    -- only Sims have this function, animals do not
    if npc.GetWorldSafePosition == nil then
        --for animals, get the closest buildable region and teleport to its safe position
        local player = Universe:GetPlayerGameObject()
        local br = player:GetClosestBuildableRegion(10000)
        x, y, z = br:GetSafePosition()
        bValidPosition = true
        bIsAnimal = true
    else
        --for sims, get the safe position of the world
        x, y, z, bValidPosition = npc:GetWorldSafePosition()
        bIsAnimal = false
    end

    if bValidPosition == true then
        npc:SetPositionRotation( x, y, z, npcRotY )

        -- check if sim has function SetMySpecificScale()
        if npc.SetMySpecificScale then
            npc:SetMySpecificScale()
        end

        -- TODO: can be moved to a common function
        local vfxY

        if bIsAnimal then
            vfxY = npcY
        else
            vfxY = npcY + 1.0
        end

        local override =
        {
            LifetimeInSeconds = 3.0,
            EffectName = "sim-magicTransport-poof-effects",
            EffectPriority = FXPriority.High,
        }

        local spawnJob = Classes.Job_SpawnObject:Spawn( "effect", "default", Universe:GetWorld(), npcX, vfxY, npcZ, npcRotY, override )
        spawnJob:Execute(self)
    end

    return BlockingResult.Succeeded, 0
end
--}}}


--{{{ Debug_Interaction_ForceNPCUse.lua --------------------------------------------------------------
function Classes.Debug_Interaction_ForceNPCUse:Test( sim, obj, autonomous ) --- custom code
    -- DEBUG ONLY
    if not DebugMenu:GetValue("EnableDebugInteractions") or sim ~= Universe:GetPlayerGameObject() then
        return false
    end

    local anyAvailable = false
    for key, set in pairs(obj.interactionSet) do
        if set.interactionClassName ~= "Debug_Interaction_ForceNPCUse" then -- prevent recursion
            if InteractionUtils:InteractionTest( sim, obj, key, false ) then
                anyAvailable = true
                break
            end
        end
    end

    if not anyAvailable then
        return false
    end

    return true
end

function Classes.Debug_Interaction_ForceNPCUse:Action( player, obj )

    if self.params and self.params.actionKey then

        --- custom code start
        local actionToUse
        -- Check if actionKey is a table (array) or a string
        if type(self.params.actionKey) == "table" then
            -- If it's an array, pick a random action from it
            actionToUse = self.params.actionKey[math.random(#self.params.actionKey)]
        else
            -- If it's a string, use it directly
            actionToUse = self.params.actionKey
        end
        --- custom code end

        local simArray = Universe:GetWorld():CreateArrayOfObjects( "character" )

        local closest
        local closestDistance

        for i, sim in ipairs(simArray) do

            if sim ~= player then
                local distance = obj:GetXZDist(sim)
                if closest == nil or distance < closestDistance then
                    closest = sim
                    closestDistance = distance
                end
            end
        end

        local params = System:CopyShallow( self.params )

        if closest ~= nil then
            closest:PushInteraction( obj, actionToUse, params ) --- custom code
        end

    end

    return
end
--}}}


--{{{ Schedule.lua --------------------------------------------------------------
function Classes.Schedule:GetBlockCoords(block)

    block = block or self:GetCurrentScheduleBlock()

    local x, y, z, worldName, rotY

    if type(block.location) == 'string' then

        local br = Universe:GetWorld():FindGameObject("buildable_region", block.location)

        --- custom code start
        if br == nil then
            EA:LogE("Schedule:GetBlockCoords", "Could not find buildable region with name:", block.location)
            return -1, -1, -1, nil, 0
        end
        --- custom code end

        x,y,z = br:GetSafePosition()
        worldName = tostring(br.containingWorld)

        ---[[
        --Can force defaults for interiors
        if Luattrib:ReadAttribute( "world", worldName, "InteriorWorld" ) then
            block.maxDistance = 1000
            block.targetDistance = 1
        else
            block.maxDistance = 1000
            block.targetDistance = 5
        end
        --]]

    else
        x = block.location["x"]
        y = block.location["y"]
        z = block.location["z"]
        worldName = block.location["worldName"]
        rotY = block.location["rotY"]
    end

    if x == nil then
        if block.location["npcType"] ~= nil then
            local npc = Common:FindSim( block.location["npcType"] )

            if npc ~= nil then
                local _

                x,y,z = npc:GetPositionRotation()
                worldName = tostring(npc.containingWorld)
            end
        end
    end
    return x, y, z, worldName, rotY
end
--}}}