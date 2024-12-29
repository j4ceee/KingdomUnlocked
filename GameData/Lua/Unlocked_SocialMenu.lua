
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

    if npc and npc ~= nil then

    end

    --desc = npc:GetDebugString(Classes.Schedule.kDebugTextContextName) .. "\n Spawned NPC: " .. tostring(npc) .. "\n NPC Type: " .. npc:GetTypeName() .. "\n Has Schedule: " .. tostring(npc.schedule ~= nil) .. "\n Current World: " .. Universe:GetWorld().mType
    desc = desc .. "-\nDebug Info: \n mType: " .. npc.mType
    --- mName = e.g. NPC_Linzey_userdata:0x0000000000000000
    --- mType = e.g. NPC_Linzey

    local debugStr = npc:GetDebugString(Classes.Schedule.kDebugTextContextName)
    if debugStr then
        desc = desc .. " | Schedule: " .. debugStr
    else
        desc = desc .. " | Schedule: Undefined"
    end

    local selection = UI:DisplayModalDialog( title, desc, face, 4, "Make Sim idle", "Exit", "Delete Sim", "Advance Schedule" )

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
        local selection_conf = UI:DisplayModalDialog( "Sim Deletion", "This will delete the Sim. Are you sure you want to continue? \n-\nYou can spawn the Sim again anytime via the Sim Spawn Menu at a bookshelf.", nil, 2, "Yes", "No")
        if selection_conf == 0 then
            npc:Destroy()
        end

    elseif selection == 3 then
        local selection_conf = UI:DisplayModalDialog( "Skip Schedule", "This will advance the Sim's schedule (this will also start the next part of a Quest). Are you sure you want to continue?", nil, 2, "Yes", "No")
        if selection_conf == 0 then
            if (npc.schedule ~= nil) and (npc.schedule:GetCurrentScheduleBlock() ~= nil) then
                npc:PushInteraction( npc, "Idle", {tuningSpec = TuningSpec} )
                npc.schedule:AdvanceToNextBlock()
            end
        end
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