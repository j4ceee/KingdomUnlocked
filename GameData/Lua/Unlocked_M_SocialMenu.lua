
local Unlocked_SocialMenu = Classes.Job_InteractionBase:Inherit("Unlocked_SocialMenu")
Unlocked_SocialMenu._instanceVars = {}

function Unlocked_SocialMenu:Test( sim, npc, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject() and sim ~= npc
end

function Unlocked_SocialMenu:Destructor()
end

local TuningSpec =
{
    duration =  {   
                    minLoops    = 1,
                    maxLoops    = 1,
                },
}

function Unlocked_SocialMenu:Action( sim, npc )

    -- Disable autosave
    if GameManager:IsAutoSave() then
        GameManager:SetAutoSave( false )
    end

    local collection, name, face, home = self:GetNPC(npc.mType)

    local desc = "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).\n"
    local title = "Debug Menu (" .. "Sim" .. ")"
    --[[
    TODO: find a way to get the sim's name
        - "local name" & "npc:GetAttribute("ShortName")" all show memory addresses instead of names
        - "local face" does return a valid face icon for some reason
    --]]

    desc = desc .. "\n\n\n\n\n\n\n\n Debug Info: \n - mType: " .. npc.mType .. "\n - World: " .. Universe:GetWorld().mType

    local debugStr = npc:GetDebugString(Classes.Schedule.kDebugTextContextName)
    desc = desc .. "\n - Schedule: " .. (debugStr or "None")
    desc = desc .. "\n - NPC: " .. tostring(npc)

    local selection = UI:DisplayModalDialog( title, desc, face, 3, "Make Sim idle", "Exit", "Delete Sim" )

    if selection == 0 then
        npc:PushInteraction( npc, "Idle",
                { tuningSpec =
                  {
                      duration =  {
                          minSeconds  = 20,        --  duration is range of seconds and/or
                          maxSeconds  = 30,        --  loop counts to run the ANIMATE_LOOPS
                      },
                  },
                } )

    elseif selection == 1 then
        return

    elseif selection == 2 then
        local selection_conf = UI:DisplayModalDialog( "Sim Deletion", "This will delete the Sim. Are you sure you want to continue? \n\n\n You can spawn the Sim again anytime via the Sim Spawn Menu at a bookshelf.", nil, 2, "Yes", "No")
        if selection_conf == 0 then
            -- TODO: can be moved to a common function
            local npcX, npcY, npcZ, npcRotY = npc:GetPositionRotation()
            local vfxY = npcY + 1.0

            local override =
            {
                LifetimeInSeconds = 3.0,
                EffectName = "sim-magicTransport-poof-effects",
                EffectPriority = FXPriority.High,
            }

            local spawnJob = Classes.Job_SpawnObject:Spawn( "effect", "default", npc.containingWorld, npcX, vfxY, npcZ, npcRotY, override )
            spawnJob:Execute(self)

            npc:Destroy()
        end
    --[[
    elseif selection == 3 then
        local selection_conf = UI:DisplayModalDialog( "Skip Schedule", "This will advance the Sim's schedule (this will also start the next part of a Quest). Are you sure you want to continue?", nil, 2, "Yes", "No")
        if selection_conf == 0 then
            if (npc.schedule ~= nil) and (npc.schedule:GetCurrentScheduleBlock() ~= nil) then
                npc:PushInteraction( npc, "Idle", {tuningSpec = TuningSpec} )
                npc.schedule:AdvanceToNextBlock()
            end
        end
    --]]
    end
end

function Unlocked_SocialMenu:GetNPC(mType)
    local refSpecs = Luattrib:GetAllCollections( "character", nil )

    for i, collection in ipairs(refSpecs) do
        collection = collection[2] -- collection key

        local script = Luattrib:ReadAttribute( "character", collection, "ScriptName" )

        if script == mType then
            local homeIsland = Luattrib:ReadAttribute( "character", collection, "HomeIsland" )
            local home = nil

            if( homeIsland ~= nil ) then
                home = homeIsland[2]
            end

            local face = Luattrib:ReadAttribute( "character", collection, "FaceIcon" ) --get face icon
            local name = Luattrib:ReadAttribute( "character", collection, "FullName" ) --get name

            return collection, name, face, home
        end
    end
end