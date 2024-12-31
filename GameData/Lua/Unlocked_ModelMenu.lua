--- Class to change head & body models of NPCs
local Unlocked_ModelMenu = Classes.Job_InteractionBase:Inherit("Unlocked_ModelMenu")
Unlocked_ModelMenu._instanceVars = {}

function Unlocked_ModelMenu:Test( sim, npc, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject() and sim ~= npc
end

function Unlocked_ModelMenu:Destructor()
end

local TuningSpec =
{
    duration =  {   
                    minLoops    = 1,
                    maxLoops    = 1,
                },
}

function Unlocked_ModelMenu:Action( sim, npc )

    -- Disable autosave
    if GameManager:IsAutoSave() then
        GameManager:SetAutoSave( false )
    end

    local desc = "Here you can change the head and body models of the Sim. You can change this back at any time in this menu."
    local title = "Model Swap Menu"

    local selection = UI:DisplayModalDialog( title, desc, "uitexture-interaction-change", 2, "Change Body", "Change Head")

    if selection == 0 then
        UI:SpawnAndBlock( "UIRelationshipBook", "clothing_body", npc )

    elseif selection == 1 then
        UI:SpawnAndBlock( "UIRelationshipBook", "clothing_head", npc )
    end
end