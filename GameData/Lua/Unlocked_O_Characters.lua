
--- Character Overrides -----------------------------------------------------------------

--{{{ CharacterBase.lua --------------------------------------------------------------
Classes.CharacterBase._instanceVars.fVisScale = 1.0

function Classes.CharacterBase:SetMySpecificScale()
    self:SetScale( self.fVisScale )
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

