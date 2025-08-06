
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

    local collection, name, face, home = Common:GetNPC(npc.mType)

    local desc = "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).\n"
    --local title = "Debug Menu (" .. "Sim" .. ")"
    local title = npc:GetAttribute("FullName")

    if EA.LogMod then
        EA:LogMod("KingdomUnlocked", "Opened Social Menu for NPC: " .. tostring(npc) .. " (" .. npc.mType .. ")")
    end

    desc = desc .. "\n\n\n\n\n\n\n\n Debug Info:"

    desc = desc .. "\n - mType: " .. npc.mType
    desc = desc .. "\n - World: " .. Universe:GetWorld().mName
    local debugStr = npc:GetDebugString(Classes.Schedule.kDebugTextContextName)
    desc = desc .. "\n - Schedule: " .. tostring(debugStr)
    desc = desc .. "\n - NPC: " .. tostring(npc)
    desc = desc .. "\n - AutonomyEnabled: " .. tostring(npc.autonomyEnabled)
    desc = desc .. "\n - ControllingJob: " .. tostring(npc.controllingJob)
    desc = desc .. "\n - ActionQueue Length: " .. tostring(#npc.actionQueue)
    desc = desc .. "\n - Current Action: " .. tostring(npc.action)

    local interest = npc:GetAttribute("InterestCharacter")[1]
    desc = desc .. "\n - Interest No: " .. tostring(interest)
    desc = desc .. "\n - Interest: " .. Constants.InterestNames[interest]

    local socialAvailability = npc.socialAvailability
    if socialAvailability == 0 then
        socialAvailability = "No Restrictions"
    elseif socialAvailability == 1 then
        socialAvailability = "Disable Autonomy"
    elseif socialAvailability == 2 then
        socialAvailability = "Disable User Picking"
    elseif socialAvailability == 3 then
        socialAvailability = "Disable All Socials"
    end
    desc = desc .. "\n - Social Availability: " .. tostring(socialAvailability)

    desc = desc .. "\n"

    desc = desc .. "\n Autonomous Info:"
    desc = desc .. "\n - Last action: " .. tostring(npc.autoLastAction)
    desc = desc .. "\n - Last No of actions: " .. tostring(npc.autoIntNo)
    desc = desc .. "\n - Current BR: " .. tostring(npc.autoBR)

    desc = desc .. "\n"

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