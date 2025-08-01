
--- Character Overrides -----------------------------------------------------------------

--{{{ CharacterBase.lua --------------------------------------------------------------
Classes.CharacterBase._instanceVars.fVisScale = 1.0
Classes.CharacterBase._instanceVars.bAutonomyRunning = false
Classes.CharacterBase._instanceVars.autoBR = nil -- the buildable region the character last routed to
Classes.CharacterBase._instanceVars.autoIntNo = 0 -- number of available interactions in search distance
Classes.CharacterBase._instanceVars.autoLastAction = nil -- last action performed by the character

function Classes.CharacterBase:SetMySpecificScale()
    self:SetScale( self.fVisScale )
end

function Classes.CharacterBase:MainLoop()

    while true do
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

            if #destList < 3 then
                -- if there are not enough destinations, remove boats from the list (prevent cluttering)
                destList = Common:GetAllObjectsOfTypes({ "buildable_region", "fishing_bucket" })
            end

            if #destList > 1 then
                local dest = destList[math.random(#destList)]
                self.autoBR = nil -- set the autoBR to the destination

                local x, y, z, dist
                if dest.mType == "BuildableRegion" then
                    -- buildable region
                    x, y, z = dest:GetSafePosition()
                    dist = 2
                else
                    -- object
                    x, y, z, _ = dest:GetPositionRotation()
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


-- new interaction sets
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

