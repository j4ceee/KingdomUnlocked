local Speaker = Classes.BlockObjectBase:Inherit( "Speaker" )

Speaker._instanceVars =
{
    bOn = false,
    hSound = NIL,
    fxObject = NIL,
    
    parentSoundObject = NIL,
}

Speaker.kMaxDistanceForSpeakerAdoption = 4000

function Speaker:PowerChangedCallback( powerValue )
    if powerValue == 0 then
        self:TurnOff()
        self:SetMaterialIndex(0, "WidgetSpeaker_lightsOff", 0)
    else
    	self:AdoptParent()
    	self:SetMaterialIndex(1, "WidgetSpeaker_lightsOn", 0) 
    end
end

function Speaker:Destructor()
    self:TurnOff()
end


--=================================================================== 
-- Communimucation 
--===================================================================


function Speaker:IsSpeakerAvailable()
    return (self.parentSoundObject == nil) and (not self.bOn) and (self:GetWidgetPowerValue() > 0) 
end

function Speaker:AddParent( parentSoundObject )
    self.parentSoundObject = parentSoundObject
end

function Speaker:RemoveParent()
    local parent = self.parentSoundObject 
    self.parentSoundObject = nil
    
    if parent then
        parent:RemoveSpeaker(self)
    end    
end


function Speaker:AdoptParent()

	if self.parentSoundObject == nil and (not self.bOn) then

	    local myBR = self:GetContainingBuildableRegion()
	
	    if myBR then
	        local speakerusers = Common:GetClosestObjectsOfTypeSorted( myBR, "speakeruser", self, Speaker.kMaxDistanceForSpeakerAdoption )
	                
	        for i, speakeruser in ipairs(speakerusers) do
	        
	            if speakeruser:IsSpeakerUserAvailable() then
	                
	                self:TurnOn()
	                speakeruser:AdoptSpeaker(self )                
	                break
	            end            
	        end
	    end
	end
    
end







--=================================================================== 
-- On/Off 
--===================================================================


function Speaker:TurnOn( soundAlias )
    if not self.bOn then
        self.bOn = true
        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end
        
        if soundAlias then
            self.hSound = self:PlaySound(soundAlias)
        end
        
        if self.fxObject then
            self.fxObject:Destroy()
            self.fxObject = nil
        end
        
        local initFunc =    function ( fxObject )
                                self.fxObject = fxObject
                            end
        
        Common:SpawnEffect( self, nil, "Obj-Speaker-effects", nil, nil, initFunc )
    end    
end

function Speaker:TurnOff()
    if self.bOn then
        self.bOn = false
        self:RemoveParent()
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

function Speaker:ChangeSong( soundAlias )
    if self.bOn then
        if self.hSound then
            self:StopSound( self.hSound )
            self.hSound = nil
        end
        
        if soundAlias then
            self.hSound = self:PlaySound( soundAlias )
        end
    end
end


--=================================================================== 
-- Broker
--===================================================================
function Speaker:GetBrokerTypeName()
	return "Speaker"
end

function Speaker:GetBrokerTypeDescription()
	local scriptersAPI = Classes.BlockObjectBase:GetBrokerTypeDescription()
	scriptersAPI.Sound = true
	    
	return scriptersAPI

end
