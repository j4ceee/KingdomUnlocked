local DJBooth = Classes.BlockObjectBase:Inherit( "DJBooth" )

DJBooth._instanceVars =
{
    bOn = false,
    bIsUsed = false, -- is used by NPC
    bWasOn = false, -- was on before used by NPC
    hSound = NIL,
    fxObject = NIL,
    soundIndex = NIL,
    
    speakerList = NIL,
    maxSpeakers = 20,
    
    maxSpeakersWithAudio = 6,
            
    maxUseCount = 5,  -- Limits npc's ability to use an object
}

DJBooth.SoundLoops =
{
    "djbooth_tracka",
    "djbooth_trackb",
    "djbooth_trackc",
    "djbooth_trackd",
    "djbooth_tracke",
    "djbooth_trackf",
    "stereo_music",
}

function DJBooth:ResetCallback()
    if self.bOn then
        self:TurnOff()
    end
end

function DJBooth:PowerChangedCallback( powerValue )
    if powerValue == 0 then
        self:TurnOff()    
        self:SetMaterialIndex(0, "WidgetDJbooth_lightsOff", 0)
    else
        self:SetMaterialIndex(1, "WidgetDJbooth_lightsOn", 0)
    end
end

function DJBooth:TurnOn( trackIndex, calledBySim )
    calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)
    self.bIsUsed = calledBySim

    if (not calledBySim) then
        self.bWasOn = true -- remember that it was before used by sim
    end

    if not self.bOn then
        self.bOn = true
        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end
        
        self.soundIndex = trackIndex or math.random(#DJBooth.SoundLoops)
        local soundAlias =  DJBooth.SoundLoops[self.soundIndex]
        
        self.hSound = self:PlaySound( soundAlias )
        self:TurnOnSpeakers( soundAlias )
                
        if self.fxObject then
            self.fxObject:Destroy()
            self.fxObject = nil
        end
        
        local initFunc =    function ( fxObject )
                                self.fxObject = fxObject
                            end
        
        Common:SpawnEffect( self, nil, "Obj-DJBooth-effects", nil, nil, initFunc )
    end    
end

function DJBooth:TurnOff( calledBySim )
    if self.bOn then
        calledBySim = (calledBySim == nil) and true or calledBySim -- defaults to true (must be explicitly set to false)

        if (not calledBySim) then
            self.bWasOn = false -- player is turning it off
        end

        self.bIsUsed = false
        if (not self.bWasOn) then
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
end


function DJBooth:ChangeSong()

    if self.bOn then

        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end
        
        local index = math.random(#DJBooth.SoundLoops)
        
        if index == self.soundIndex then
            index = ((index < #DJBooth.SoundLoops) and (index + 1)) or 1
        end
        
        self.soundIndex = index
        local soundAlias =  DJBooth.SoundLoops[self.soundIndex]
        
        self.hSound = self:PlaySound( soundAlias )
        self:ChangeSpeakerSong( soundAlias )
    end
end

--=================================================================== 
-- Speaker support
--===================================================================

function DJBooth:GetSpeakerCount()
    local count = 0
    if self.speakerList then
        for _ in pairs(self.speakerList) do
            count = count+1
        end
    end
    return count
end

function DJBooth:CanAddSpeaker()
    return (self:GetSpeakerCount() < self.maxSpeakers)
end

function DJBooth:IsSpeakerUserAvailable()
    return self.bOn and self:CanAddSpeaker()
end


function DJBooth:TurnOnSpeakers( soundAlias )
    local myBR = self:GetContainingBuildableRegion()

    if myBR then
        local speakers = Common:GetClosestObjectsOfTypeSorted( myBR, "speaker", self, Classes.Speaker.kMaxDistanceForSpeakerAdoption )
        
        for i, speaker in ipairs(speakers) do
            if self:CanAddSpeaker() then
                local alias = soundAlias
                if i > self.maxSpeakersWithAudio then
                    alias = nil
                end
                self:AddSpeaker( speaker, alias )
            else
                break
            end
        end
    end    
end

function DJBooth:ChangeSpeakerSong( soundAlias )
    if self.speakerList then
        for i,speaker in ipairs(self.speakerList) do
            local alias = soundAlias
            if i > self.maxSpeakersWithAudio then
                alias = nil
            end
            speaker:ChangeSong( alias )
        end
    end
end

function DJBooth:TurnOffSpeakers()
    if self.speakerList then
        while( #self.speakerList > 0 ) do
            self:RemoveSpeaker(self.speakerList[#self.speakerList])
        end
        self.speakerList = nil
    end
end

function DJBooth:AddSpeaker( speaker, soundAlias )
    self.speakerList = self.speakerList or {}
    
    local bCanAdd = speaker:IsSpeakerAvailable()
    
    if bCanAdd then
        self.speakerList[#self.speakerList+1] = speaker
        speaker:AddParent(self)
        speaker:TurnOn(soundAlias)
    end    
end

function DJBooth:RemoveSpeaker( speaker )
    if self.speakerList then
        for i, spkr in ipairs(self.speakerList) do
            if spkr == speaker then
                table.remove(self.speakerList,i)
                break
            end
        end
    end
    speaker:RemoveParent()
    speaker:TurnOff()
end

function DJBooth:AdoptSpeaker( speaker )
    if speaker then
        self.speakerList = self.speakerList or {}
        
        self.speakerList[#self.speakerList+1] = speaker
        speaker:AddParent(self)
        -- Waits for song change
    end
end





--=================================================================== 
-- Broker
--===================================================================

function DJBooth:GetBrokerTypeName()
	return "DJBooth"
end

function DJBooth:GetBrokerTypeDescription()
	local scriptersAPI = Classes.BlockObjectBase:GetBrokerTypeDescription()
	scriptersAPI.Sound = true
	scriptersAPI.Visual = true
    	
	return scriptersAPI
end


DJBooth.interactionSet =
{
    DJ =        {
                    name = "STRING_INTERACTION_DJBOOTH_DJ",
                    interactionClassName = "DJBooth_Interaction_DJ",
                    icon = "uitexture-interaction-DJ",
                    menu_priority = 1,
                },
                
    DJ_Uber =   {
                    name = "STRING_INTERACTION_DJBOOTH_DJ_UBER",
                    interactionClassName = "DJBooth_Interaction_DJ_Uber",
                    powerRequirement = 3.0,
                    icon = "uitexture-interaction-DJ",
                    menu_priority = 0,
                },                
                
    Dance =     {
                    name = "STRING_INTERACTION_DJBOOTH_DANCE",
                    interactionClassName = "DJBooth_Interaction_Dance",
                    maxCount = 4,
                    icon = "uitexture-interaction-dance",
                    menu_priority = 2,
                },
                
    ForceNPCUse =   {
                        name = "*Force NPC to DJ",
                        interactionClassName = "Debug_Interaction_ForceNPCUse",
                        actionKey = "DJ",
                        tuningSpec =
                        {
                            duration =  
                            {   
                                minSeconds    = 1,      
                                maxSeconds    = 1,
                                parkablenpc = true,
                            },
                        },
                        icon = "uitexture-interaction-DJ",
                        menu_priority = 4,
                    },

    TurnOn =    {
        name                    = "STRING_INTERACTION_STEREO_TURNON",
        interactionClassName    = "Unlocked_I_DJBooth_On",
        icon = "uitexture-interaction-use",
        menu_priority = 3,
    },

    TurnOff =   {
        name                    = "STRING_INTERACTION_STEREO_TURNOFF",
        interactionClassName    = "Unlocked_I_DJBooth_Off",
        icon = "uitexture-interaction-use",
        menu_priority = 3,
    },
                
    
}
