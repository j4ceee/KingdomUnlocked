
local Unlocked_AnimalMenu = Classes.Job_InteractionBase:Inherit("Unlocked_AnimalMenu")
Unlocked_AnimalMenu._instanceVars = {}

function Unlocked_AnimalMenu:Test( sim, npc, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject() and sim ~= npc
end

function Unlocked_AnimalMenu:Destructor()
end

local TuningSpec =
{
    duration =  {   
                    minLoops    = 1,
                    maxLoops    = 1,
                },
}

function Unlocked_AnimalMenu:Action( sim, npc )

    -- Disable autosave
    if GameManager:IsAutoSave() then
        GameManager:SetAutoSave( false )
    end

    local desc = "Choose an action. Use A or B.\n"
    local title = "Debug Menu (" .. npc.mType .. ")"

    desc = desc .. "-\nDebug Info: \n mType: " .. npc.mType
    --- mName = e.g. NPC_Linzey_userdata:0x0000000000000000
    --- mType = e.g. NPC_Linzey

    local selection = UI:DisplayModalDialog( title, desc, face, 2, "Delete animal", "Exit")

    if selection == 0 then
        local selection_conf = UI:DisplayModalDialog( "Animal Deletion", "This will delete the animal. Are you sure you want to continue? \n-\nYou can spawn the animal again anytime via the Sim Spawn Menu at a bookshelf.", nil, 2, "Yes", "No")
        if selection_conf == 0 then
            -- TODO: can be moved to a common function
            local npcX, npcY, npcZ, npcRotY = npc:GetPositionRotation()

            local override =
            {
                LifetimeInSeconds = 3.0,
                EffectName = "sim-magicTransport-poof-effects",
                EffectPriority = FXPriority.High,
            }

            local spawnJob = Classes.Job_SpawnObject:Spawn( "effect", "default", npc.containingWorld, npcX, npcY, npcZ, npcRotY, override )
            spawnJob:Execute(self)

            npc:Destroy()
        end

    elseif selection == 1 then
        return
    end
end