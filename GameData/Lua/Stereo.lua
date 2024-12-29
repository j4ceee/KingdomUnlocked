local Stereo = Classes.BlockObjectBase:Inherit( "Stereo" )

Stereo._instanceVars =
{
    bOn = false,
    hSound = NIL,
    fxObject = NIL,
    
    speakerList = NIL,
    maxSpeakers = 20,
            
    maxUseCount = 5,  -- Limits npc's ability to use an object (4 dancers + 1 turn off-er)
}


function Stereo:TurnOn()
    if not self.bOn then
        self.bOn = true
        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end
        self.hSound = self:PlaySound("stereo_music")
        self:TurnOnSpeakers("stereo_music")
        
        if self.fxObject then
            self.fxObject:Destroy()
            self.fxObject = nil
        end
        
        local initFunc =    function ( fxObject )
                                self.fxObject = fxObject
                            end
        
        Common:SpawnEffect( self, nil, "obj-stereo-notes", nil, nil, initFunc )
    end    
end

function Stereo:TurnOff()
    if self.bOn then
        self.bOn = false
        self:TurnOffSpeakers()
        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end
        if self.fxObject then
            self.fxObject:Destroy()
            self.fxObject = nil
        end
    end
end

--=================================================================== 
-- Speaker support
--===================================================================

function Stereo:GetSpeakerCount()
    local count = 0
    if self.speakerList then
        for _ in pairs(self.speakerList) do
            count = count+1
        end
    end
    return count
end

function Stereo:CanAddSpeaker()
    return (self:GetSpeakerCount() < self.maxSpeakers)
end


function Stereo:IsSpeakerUserAvailable()
    return self.bOn and self:CanAddSpeaker()
end

function Stereo:TurnOnSpeakers( soundAlias )
    local myBR = self:GetContainingBuildableRegion()

    if myBR then
        local speakers = Common:GetClosestObjectsOfTypeSorted( myBR, "speaker", self, Classes.Speaker.kMaxDistanceForSpeakerAdoption )
                
        for i, speaker in ipairs(speakers) do
        
            if self:CanAddSpeaker() then
                self:AddSpeaker( speaker, soundAlias )
            else
                break
            end
        end
    end    
end

function Stereo:ChangeSpeakerSong( soundAlias )
    if self.speakerList then
        for speaker in pairs(self.speakerList) do
            speaker:ChangeSong( soundAlias )
        end
    end
end

function Stereo:TurnOffSpeakers()
    if self.speakerList then
        for speaker in pairs(self.speakerList) do
            self:RemoveSpeaker(speaker)
        end
        self.speakerList = nil
    end
end

function Stereo:AddSpeaker( speaker, soundAlias )
    self.speakerList = self.speakerList or {}
    
    local bCanAdd = speaker:IsSpeakerAvailable()
    
    if bCanAdd then
        self.speakerList[speaker] = true
        speaker:AddParent(self)
        speaker:TurnOn(soundAlias)
    end    
end

function Stereo:RemoveSpeaker( speaker )
    if self.speakerList then
        self.speakerList[speaker] = nil
    end
    speaker:RemoveParent()
    speaker:TurnOff()
end

function Stereo:AdoptSpeaker( speaker )
    if speaker then
        self.speakerList = self.speakerList or {}
        self.speakerList[speaker] = true
        speaker:AddParent(self)
        speaker:ChangeSong("stereo_music")
    end
end


--=================================================================== 
-- Broker
--===================================================================
function Stereo:GetBrokerTypeName()
	return "Stereo"
end

function Stereo:GetBrokerTypeDescription()
	local scriptersAPI = Classes.BlockObjectBase:GetBrokerTypeDescription()
	scriptersAPI.Sound = true
	    
	return scriptersAPI

end

Stereo.interactionSet =
{
--|     TurnOnTest =    {   name                    = "*Turn On Test",
--|                     interactionClassName    = "Stereo_Interaction_TurnOnTest", },
                    
    TurnOn =    {   name                    = "STRING_INTERACTION_STEREO_TURNON",
                    interactionClassName    = "Stereo_Interaction_TurnOn",
                    icon = "uitexture-interaction-use", },
    
    TurnOff =   {   name                    = "STRING_INTERACTION_STEREO_TURNOFF",
                    interactionClassName    = "Stereo_Interaction_TurnOff",
                    icon = "uitexture-interaction-use", },
                    
    Dance =     {   name                    = "STRING_INTERACTION_STEREO_DANCE",
                    interactionClassName    = "Stereo_Interaction_Dance",
                    maxCount = 4,
                    icon = "uitexture-interaction-dance",
                    },                    
}
