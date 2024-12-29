local Unlocked_I_DJBooth_On = Classes.Job_InteractionState:Inherit("Unlocked_I_DJBooth_On")
Unlocked_I_DJBooth_On._instanceVars = {}

function Unlocked_I_DJBooth_On:Test( sim, obj, autonomous )

    return (not obj.bOn) and (not obj.bIsUsed) and (obj:GetWidgetPowerValue() > 0)
end

function Unlocked_I_DJBooth_On:Destructor()
end

function Unlocked_I_DJBooth_On:RemoteAnimCallback(animJob, eventText)
    if #self.obj:GetInteractionJobList() == 1 then -- only if no sims are using the DJ booth
        self.obj:TurnOn(nil, false)
    end
end

Unlocked_I_DJBooth_On.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "distance", distance = 3.0, skipRouteIfClose = true,   },

    ANIM_LOOPS          =   {
        {
            sim = "a-toggleRemote",
            weight = 1,

            AnimEventCallback = Unlocked_I_DJBooth_On.RemoteAnimCallback,
        },
    },
}

Unlocked_I_DJBooth_On.DefaultTuningSpec =
{

    duration =  {   minLoops    = 1,        --  state.  ANIMATE_LOOPS will exit when
                    maxLoops    = 1,   },   --  _either_ condition is met.
}


local Unlocked_I_DJBooth_Off = Classes.Job_InteractionState:Inherit("Unlocked_I_DJBooth_Off")
Unlocked_I_DJBooth_Off._instanceVars = {}

function Unlocked_I_DJBooth_Off:Test( sim, obj, autonomous )

    return (obj.bOn) and (not obj.bIsUsed) and (obj:GetWidgetPowerValue() > 0)
end

function Unlocked_I_DJBooth_Off:Destructor()
end

function Unlocked_I_DJBooth_Off:RemoteAnimCallback(animJob, eventText)
    --if #self.obj:GetInteractionJobList() == 1 then -- only if no sims are using the DJ booth
        self.obj:TurnOff(false)
    --end
end

Unlocked_I_DJBooth_Off.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "distance", distance = 3.0, skipRouteIfClose = true,   },

    ANIM_LOOPS          =   {
        {
            sim = "a-toggleRemote",
            weight = 1,

            AnimEventCallback = Unlocked_I_DJBooth_Off.RemoteAnimCallback,
        },
    },
}

Unlocked_I_DJBooth_Off.DefaultTuningSpec =
{

    duration =  {   minLoops    = 1,        --  state.  ANIMATE_LOOPS will exit when
                    maxLoops    = 1,   },   --  _either_ condition is met.
}