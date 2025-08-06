local Unlocked_I_DanceFl_On = Classes.Job_InteractionState:Inherit("Unlocked_I_DanceFl_On")
Unlocked_I_DanceFl_On._instanceVars = {}

function Unlocked_I_DanceFl_On:Test( sim, obj, autonomous )
    if obj.bOn then
        return false
    end

    if obj:GetWidgetPowerValue() <= 0 then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() then
        return false
    end

    return true
end

function Unlocked_I_DanceFl_On:Destructor()
end

function Unlocked_I_DanceFl_On:RemoteAnimCallback(animJob, eventText)
    self.obj:TurnOn()
end

Unlocked_I_DanceFl_On.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "distance", distance = 3.0, skipRouteIfClose = true,   },

    ANIM_LOOPS          =   {
        {
            sim = "a-toggleRemote",
            weight = 1,

            AnimEventCallback = Unlocked_I_DanceFl_On.RemoteAnimCallback,
        },
    },
}

Unlocked_I_DanceFl_On.DefaultTuningSpec =
{

    duration =  {   minLoops    = 1,        --  state.  ANIMATE_LOOPS will exit when
                    maxLoops    = 1,   },   --  _either_ condition is met.
}


local Unlocked_I_DanceFl_Off = Classes.Job_InteractionState:Inherit("Unlocked_I_DanceFl_Off")
Unlocked_I_DanceFl_Off._instanceVars = {}

function Unlocked_I_DanceFl_Off:Test( sim, obj, autonomous )
    if not obj.bOn then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() then
        return false
    end

    return true
end

function Unlocked_I_DanceFl_Off:Destructor()
end

function Unlocked_I_DanceFl_Off:RemoteAnimCallback(animJob, eventText)
    self.obj:TurnOff()
end

Unlocked_I_DanceFl_Off.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "distance", distance = 3.0, skipRouteIfClose = true,   },

    ANIM_LOOPS          =   {
        {
            sim = "a-toggleRemote",
            weight = 1,

            AnimEventCallback = Unlocked_I_DanceFl_Off.RemoteAnimCallback,
        },
    },
}

Unlocked_I_DanceFl_Off.DefaultTuningSpec =
{

    duration =  {   minLoops    = 1,        --  state.  ANIMATE_LOOPS will exit when
                    maxLoops    = 1,   },   --  _either_ condition is met.
}