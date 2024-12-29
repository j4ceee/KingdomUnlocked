
local CharacterBase_Debug_PushSim = Classes.Job_InteractionBase:Inherit("CharacterBase_Debug_PushSim")
CharacterBase_Debug_PushSim._instanceVars = {}

function CharacterBase_Debug_PushSim:Test( sim, npc, autonomous )

    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject() and sim ~= npc
end

function CharacterBase_Debug_PushSim:Destructor()
end


function CharacterBase_Debug_PushSim:Action( sim, npc )

    local angle = sim:GetAngle( npc )
    
    local x, y, z, rotY = npc:GetPositionRotation()
    
    local x, z = Common:GetRelativePosition( 0, 2, x, z, angle )
    
    npc:SetPositionRotation( x, y+2.0, z, rotY )

    -- check if sim has function SetMySpecificScale()
    if npc.SetMySpecificScale then
        npc:SetMySpecificScale()
    end

end