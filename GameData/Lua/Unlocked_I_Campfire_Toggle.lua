local Unlocked_I_Campfire_On = Classes.Job_InteractionState:Inherit("Unlocked_I_Campfire_On")
Unlocked_I_Campfire_On._instanceVars = {}

function Unlocked_I_Campfire_On:Test( sim, obj, autonomous )
    if obj.bOn then
        return false
    end

    if obj.bInUse then
        return false
    end

    return true
end

function Unlocked_I_Campfire_On:Destructor()
end

function Unlocked_I_Campfire_On:Post_ROUTE( sim, obj )
    if #obj:GetInteractionJobList() == 1 then -- only if no sims (other than player) are using it
        obj:TurnOn(false)
    end
end

Unlocked_I_Campfire_On.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "distance", distance = 1.0 },
}


local Unlocked_I_Campfire_Off = Classes.Job_InteractionState:Inherit("Unlocked_I_Campfire_Off")
Unlocked_I_Campfire_Off._instanceVars = {}

function Unlocked_I_Campfire_Off:Test( sim, obj, autonomous )
    if not obj.bOn then
        return false
    end

    if obj.bInUse then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() then
        return false
    end

    return true
end

function Unlocked_I_Campfire_Off:Destructor()
end

function Unlocked_I_Campfire_Off:Post_ROUTE( sim, obj )
    if #obj:GetInteractionJobList() == 1 then -- only if no sims are using it
        obj:TurnOff(false)
    end
end

Unlocked_I_Campfire_Off.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "distance", distance = 1.0 },
}