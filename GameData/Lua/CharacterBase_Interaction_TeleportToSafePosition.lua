--==========================================================================--
--  CharacterBase_Interaction_TeleportToSafePosition:                                         --
--      Player->NPC social trigger.
--==========================================================================--
local CharacterBase_Interaction_TeleportToSafePosition = Classes.Job_InteractionBase:Inherit("CharacterBase_Interaction_TeleportToSafePosition")

CharacterBase_Interaction_TeleportToSafePosition._instanceVars = {}

function CharacterBase_Interaction_TeleportToSafePosition:Test( sim, npc, autonomous )
    local bIsPlayer = sim == Universe:GetPlayerGameObject()
    
    -- Player -> NPC only
    local bIsPlayerToSim = bIsPlayer and sim ~= npc

    if (bIsPlayerToSim == false) then
        return false
    end

    --return npc:IsCharacterStuck() == true -- new C++ function to check if NPC is stuck
    return true
end

function CharacterBase_Interaction_TeleportToSafePosition:Destructor()
end

function CharacterBase_Interaction_TeleportToSafePosition:Action( sim, npc )

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
