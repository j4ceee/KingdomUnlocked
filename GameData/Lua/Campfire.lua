local Campfire = Classes.BlockObjectBase:Inherit( "Campfire" )

Campfire._instanceVars =
{
    bOn = false,
    bInUse = false,
    bWasOn = false,
    fxHandle = NIL,
    
    maxUseCount = 6,  -- Limits npc's ability to use an object
}

function Campfire:Destructor()
    self:TurnOff()
end

function Campfire:TurnOn( calledBySim )
    calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)
    self.bInUse = calledBySim

    if (not calledBySim) then
        self.bWasOn = true -- remember that it was before used by sim
    end

    if not self.bOn then
        self.bOn = true
        self.fxHandle = self:CreateFX(  "obj-camp-fire-effects",
                FXPriority.High,
                FXStart.Now,
                FXLifetime.Continuous,
                FXAttach.Rigid,
                0,
                0,0,0   )
    end
end

function Campfire:TurnOff( calledBySim )
    if self.bOn then
        calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)

        if (not calledBySim) then
            self.bWasOn = false -- player is turning it off
        end

        self.bInUse = false
        if (not self.bWasOn) then
            self.bOn = false
            if self.fxHandle then
                self:DestroyFX( self.fxHandle, FXTransition.Hard )
                self.fxHandle = nil
            end
        end
    end
end


--=================================================================== 
-- Broker
--===================================================================
function Campfire:GetBrokerTypeName()
	return "Campfire"
end

function Campfire:GetBrokerTypeDescription()
	local scriptersAPI = Classes.BlockObjectBase:GetBrokerTypeDescription()
	scriptersAPI.FX = true
    	
	return scriptersAPI
end

--===================================================================
-- Action set
--===================================================================
Campfire.interactionSet =
{
    RoastMarshmallows = {
                            name = "STRING_INTERACTION_CAMPFIRE_ROASTMARSHMALLOWS",
                            interactionClassName = "Campfire_Interaction_RoastMarshmallows",
                            maxCount = 6,
                            icon = "uitexture-interaction-roastmarshmellows",
                            menu_priority = 0,
                        },
                
    WarmHands = {
                    name = "STRING_INTERACTION_CAMPFIRE_WARMHANDS",
                    interactionClassName = "Campfire_Interaction_WarmHands",
                    maxCount = 6,
                    icon = "uitexture-interaction-warmhands",
                    menu_priority = 1,
                },
                
    ForceNPCUse =   {
                        name = "*Force NPC to Use",
                        interactionClassName = "Debug_Interaction_ForceNPCUse",
                        actionKey = { "RoastMarshmallows", "WarmHands" },
                        icon = "uitexture-interaction-use",
                        menu_priority = 3,
                    },

    TurnOn =    {
                    name = "STRING_INTERACTION_STEREO_TURNON",
                    interactionClassName = "Unlocked_I_Campfire_On",
                    icon = "uitexture-interaction-use",
                    menu_priority = 2,
                },
    TurnOff =   {
                    name = "STRING_INTERACTION_STEREO_TURNOFF",
                    interactionClassName = "Unlocked_I_Campfire_Off",
                    icon = "uitexture-interaction-use",
                    menu_priority = 2,
                },
}


