local FishingBucket = Classes.ScriptObjectBase:Inherit( "FishingBucket" )

FishingBucket._instanceVars = {}

function FishingBucket:Destructor()
end


function FishingBucket:GetBrokerTypeName()
	return "FishingBucket"
end

function FishingBucket:GetBrokerTypeDescription()
	local scriptersAPI = Classes.ScriptObjectBase:GetBrokerTypeDescription()
	
    scriptersAPI.Input = true
	
	return scriptersAPI
end



FishingBucket.interactionSet =
{
    FishingMiniGame =   {
                            name                    = "STRING_INTERACTION_FISHINGBUCKET_FISHINGMINIGAME",
                            interactionClassName    = "FishingBucket_Interaction_FishingMiniGame",
                            metaState               = MetaStates.Fishing,
                            icon = "uitexture-interaction-use",
                            menu_priority = 0,
                        },

    FishingSkip =   {
                            name                    = "Quick Fishing",
                            interactionClassName    = "Unlocked_I_Fishing_Skip",
                            metaState               = MetaStates.Fishing,
                            icon = "uitexture-interaction-use",
                            menu_priority = 1,
    },
}