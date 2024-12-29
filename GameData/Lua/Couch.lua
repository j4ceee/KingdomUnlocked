local Couch = Classes.BlockObjectBase:Inherit( "Couch" )

Couch._instanceVars = 
{
    bSlot0Available = true,
    bSlot1Available = true,
    
    maxUseCount = 2,  -- Limits npc's ability to use an object
}

function Couch:GetBrokerTypeName()
	return "Couch"
end

function Couch:GetBrokerTypeDescription()
	return Classes.BlockObjectBase:GetBrokerTypeDescription()
end

function Couch:SetAvailableSlots( sim, bSleep )
    if bSleep or (self:GetGameObjectInSlot( Slot.Containment, 0 ) == sim) then
        self.bSlot0Available = false
    end
    if bSleep or (self:GetGameObjectInSlot( Slot.Containment, 1 ) == sim) then
        self.bSlot1Available = false
    end
end

function Couch:ClearAvailableSlots( sim, bSleep )
    if bSleep or (self:GetGameObjectInSlot( Slot.Containment, 0 ) == sim) then
        self.bSlot0Available = true
    end    
    if bSleep or (self:GetGameObjectInSlot( Slot.Containment, 1 ) == sim) then
        self.bSlot1Available = true
    end 
end



Couch.interactionSet =
{
    Sit =           {   
                        name                    = "STRING_INTERACTION_COUCH_SIT",
                        interactionClassName    = "Couch_Interaction_Sit",
                        maxCount = 2,                          
                        icon = "uitexture-interaction-sit",
                    },
                          
    Sleep =          {   name                    = "STRING_INTERACTION_COUCH_SLEEP",
                          interactionClassName    = "Couch_Interaction_Sleep",
                          icon = "uitexture-interaction-sleep", },

    SleepTillDay =   {   name                    = "STRING_INTERACTION_COUCH_SLEEPTILLDAY",
                          interactionClassName    = "Couch_Interaction_SleepTillDay",
                          icon = "uitexture-interaction-sleep", },

    SleepTillNight = {   name                    = "STRING_INTERACTION_COUCH_SLEEPTILLNIGHT",
                          interactionClassName    = "Couch_Interaction_SleepTillNight",
                          icon = "uitexture-interaction-sleep", },

    JumpOn =            {      
                            name                    = "STRING_INTERACTION_COUCH_JUMPON",
                            interactionClassName    = "Couch_Interaction_JumpOn",
                            maxCount = 2,
                            icon = "uitexture-interaction-use",
                        },

    -- Force random interaction
    ForceNPCToUse = {
        name = "*Force NPC to Use",
        interactionClassName = "Debug_Interaction_ForceNPCUse",
        actionKey = {"Sit", "Sleep", "JumpOn"},
        icon = "uitexture-interaction-use",
    },
}