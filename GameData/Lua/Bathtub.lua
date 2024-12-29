local Bathtub = Classes.BlockObjectBase:Inherit( "Bathtub" )

Bathtub._instanceVars =
{
    soundHandle = NIL,
}

function Bathtub:PowerChangedCallback( powerValue )
    if powerValue == 0 then
       -- self:SetMaterialIndex(0, "WidgetBathtub_WaterOff", 0)
    else
       -- self:SetMaterialIndex(1, "WidgetBathtub_WaterOn", 0)
    end
end

function Bathtub:StartAmbience()
    if self.soundHandle == nil then
        self.soundHandle = self:PlaySound("bath_ambience")
    end
end

function Bathtub:StopAmbience()
    if self.soundHandle ~= nil then
        self:StopSound( self.soundHandle )
        self.soundHandle = nil
    end
    
    self:PlaySound("bath_getout")
end

--==============--
-- Broker stuff --
--==============--
function Bathtub:GetBrokerTypeName()
	return "Bathtub"
end

function Bathtub:GetBrokerTypeDescription()
	local scriptersAPI = Classes.BlockObjectBase:GetBrokerTypeDescription()
    scriptersAPI.Sound = true
    	
	return scriptersAPI
end


Bathtub.interactionSet =
{
    TakeBath =  {
                    name = "STRING_INTERACTION_BATHTUB_TAKEBATH",
                    interactionClassName = "Bathtub_Interaction_TakeBath",
                    icon = "uitexture-interaction-use",
                },

    ForceNPCToUse =     {
        name = "*Force NPC to take a bath",
        interactionClassName = "Debug_Interaction_ForceNPCUse",
        actionKey = "TakeBath",
        icon = "uitexture-interaction-use",
    },

}
