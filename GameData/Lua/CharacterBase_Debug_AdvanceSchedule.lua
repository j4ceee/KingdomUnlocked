
local CharacterBase_Debug_AdvanceSchedule = Classes.Job_InteractionBase:Inherit("CharacterBase_Debug_AdvanceSchedule")
CharacterBase_Debug_AdvanceSchedule._instanceVars = {}

function CharacterBase_Debug_AdvanceSchedule:Test( sim, npc, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject() and sim ~= npc
end

function CharacterBase_Debug_AdvanceSchedule:Destructor()
end

local TuningSpec =
{
    duration =  {   
                    minLoops    = 1,
                    maxLoops    = 1,
                },
}

function CharacterBase_Debug_AdvanceSchedule:Action( sim, npc )

    local selection = UI:DisplayModalDialog( "Debug Sim Menu", "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).", nil, 4, "Make Sim idle", "Exit", "Delete Sim", "Advance Schedule" )

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
        local selection_conf = UI:DisplayModalDialog( "Sim Deletion", "This will delete the Sim. Are you sure you want to continue? \n-\nWARNING: If you save the game after the Sim is deleted, it will be permanently deleted from your save.", nil, 2, "Yes", "No")
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