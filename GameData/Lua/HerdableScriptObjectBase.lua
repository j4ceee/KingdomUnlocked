-- HerdableScriptObjectBase
local HerdableScriptObjectBase = Classes.ScriptObjectBase:Inherit( "HerdableScriptObjectBase" )

HerdableScriptObjectBase._instanceVars = 
{
	bInTriggerVolume         = false,
	bHerded                  = false,
	bGroupHerdingType		 = false,
	bReverse				 = false,
	bUseSnorkel				 = false,
	SnorkelAttachBone		 = "mouth",
	bResourceRequiredHerding = false,
	state                    = 0,
	animJob                  = NIL,
    behaviorAlarm            = NIL, -- this is used to time out the random walk so they graze and idle and such
    interactionDelayTimer    = NIL,
    herdTypeSearchRefSpec    = NIL,
    hyaaTimer                = NIL, -- used for power herding interaction. See bottom of this file.
    defaultFleeSpeed         = NIL, -- used for power herding interaction. See bottom of this file.
    defaultAwarenessDistance = NIL, -- used for power herding interaction. See bottom of this file.
    defaultFleeSteerWeight   = NIL, -- used for power herding interaction. See bottom of this file.
    resourceRequiredRefSpec  = NIL, -- usef for herding when a resource triggers the herding.
    specifiedTaskToComplete  = NIL, -- this is the specific task the critter is being used to complete
    
    appearAnim               = NIL, -- first idle animation.
    target                   = NIL,
    
    bRouteToSlot			 = false,
    simPet 					 = "a2c-smallCritter-pet",
    critterPet				 = "c2a-smallCritter-pet",
    simPetE					 = "a2c-cow-soc-pet-e",
    critterPetE				 = "c2a-cow-soc-pet-e", 
    
    simFeed 				 = "a2c-smallCritter-feed",
    critterFeed				 = "c2a-smallCritter-feed",
    simFeedE				 = "a2c-cow-soc-feed-e",
    critterFeedE			 = "c2a-cow-soc-feed-e",
	bPetWhenNotHerded		 = false,
	distanceToBlocking		 = 1.0,
}


HerdableScriptObjectBase.states = 
{
	idle    = 0,
	walking = 1,
	fleeing = 2,
}

function HerdableScriptObjectBase:Destructor()
    if self.animJob ~= nil then
        self.animJob:Signal( BlockingResult.Failed, 0 )
        self.animJob = nil
    end
end

function HerdableScriptObjectBase:RunnableCallback()
	-- start the idles
	self:StartIdles()
	
	--read in the herding type
	self.bGroupHerdingType = self:GetAttribute( "GroupHerdingType" )
	
	self.herdTypeSearchRefSpec = self:GetAttribute( "HerdingObjectFilterRefSpec" )
	
	self.bReverse = self:GetAttribute( "HerdingReverseHerdable" )
	self.bResourceRequiredHerding = self:GetAttribute( "ResourceRequiredHerding" )
	if self.bResourceRequiredHerding then
		self.resourceRequiredRefSpec = self:GetAttribute( "ResourceRequiredRefSpec" )
	end
	
	self.bUseSnorkel = self:GetAttribute( "UseSnorkelInWater" )
	
	-- read in the trigger volume refspecs
	local triggerVolumeRefSpecs = self:GetAttribute( "HerdingTriggerVolume" )
    
    for i, triggerVolumeRefSpec in ipairs( triggerVolumeRefSpecs ) do
        local corralGO = self.containingWorld:FindGameObject( triggerVolumeRefSpec[1], triggerVolumeRefSpec[2] )
        if corralGO ~= nil then
            self:RegisterForTriggerCallback(self, corralGO)
        end
    end
	
	if ( not self.bHerded ) then
        local targetRefSpec = self:GetAttribute( "HerdingTargetRefSpec" )
        
        local target = self.containingWorld:FindGameObject( targetRefSpec[1], targetRefSpec[2] )
		
		if ( target ~= nil ) and ( target.isValid ) then
            self.target = target
			self:SetTarget( target )
			self:TurnOnAwareness()
			self:StopSteering()
		end
	end	
	-- set Stay in area
	local stayInRadius = self:GetAttribute("StayInRadius")
	if stayInRadius ~= nil then
    	local stayInPos = self:GetAttribute("StayInCenter")
    	if stayInPos ~= nil then
            self:SetStayinSphere(stayInPos.x, stayInPos.y, stayInPos.z, stayInRadius)
        end
	end
end

function HerdableScriptObjectBase:StartIdles( condition )
    if ( condition == nil or condition:GetReturnValues() == BlockingResult.Succeeded ) and self.state == self.states["idle"] then
        
        local anim = self.appearAnim or Common:SelectRandomWeighted( self.idles ).anim
        self.appearAnim = nil
                    
        self.animJob = self:GetPlayAnimationJob(anim, 1)

        self.animJob:RegisterForJobCompletedCallback( self, self.StartIdles )
            
        self.animJob:Execute(self)
    end
end

function HerdableScriptObjectBase:HandleStartWalking()
	-- Stop Idles
	if self.animJob ~= nil then
		self.animJob:Signal( BlockingResult.Canceled, 0 )
	end
	
	-- change the herdable objects state to walking
	self:StartRandomWalking()
	self.state = HerdableScriptObjectBase.states["walking"]
	
	-- setup the timer for when to stop the herdable object
	local walkMinutes = self:GetAttribute( "Tuning_RandomWalkMinTime" ) + math.random( self:GetAttribute( "Tuning_RandomWalkVariableTime" ) )
	self.behaviorAlarm = self:CreateTimer( Clock.Sim, 0, 0, walkMinutes, 0 )
end

function HerdableScriptObjectBase:HandleStopWalking()
	--stop the herdable object
	self:StopSteering()
	
	-- Restart Idles
	self.state = HerdableScriptObjectBase.states["idle"]
	self:StartIdles()
	
	-- set the timer for when to start walking again
	local idleMinutes = self:GetAttribute( "Tuning_IdleMinTime" ) + math.random( self:GetAttribute( "Tuning_IdleVariableTime" ) )
	self.behaviorAlarm = self:CreateTimer( Clock.Sim, 0, 0, idleMinutes, 0 ) 
end

function HerdableScriptObjectBase:TimerExpiredCallback( timerID )
	-- if the timer being signaled is nil then it's not valid and don't compare it to other timers.
	if timerID == nil then return end
	
    if timerID == self.behaviorAlarm then
    	if self.bHerded then		
			if self.state ~= HerdableScriptObjectBase.states["idle"] then
				--stop the herdable object
				self:StopSteering()
				self.state = HerdableScriptObjectBase.states["idle"]
				-- Restart Idles
				self:StartIdles()
			end
    		return
    	else
	    	if self.state == HerdableScriptObjectBase.states["walking"] then
				self:HandleStopWalking()
	    	elseif self.state == HerdableScriptObjectBase.states["idle"] then
	    		self:HandleStartWalking()
	    	end
		end
	end
	
	if timerID == self.interactionDelayTimer then
		self.interactionDelayTimer = nil
	end
end

function HerdableScriptObjectBase:ResourceHerdingCheck()
	if self.resourceRequiredRefSpec ~= nil then
		local player = Universe:GetPlayerGameObject()
		local count = player:GetResourceCount( self.resourceRequiredRefSpec[1], self.resourceRequiredRefSpec[2] )
		if count > 0 then return true end
	end
	
	return false
end

function HerdableScriptObjectBase:SpecifiedTaskRevealed()
	if self.specifiedTaskToComplete == nil then
		return true
	end
	
	if Task:IsTaskRevealed(self.specifiedTaskToComplete) then
		return true
	end		

	return false
end

function HerdableScriptObjectBase:SteeringTargetNearbyCallback()
	if self.bHerded or not self:SpecifiedTaskRevealed() then
		return
	else
		if self.bResourceRequiredHerding then
			-- if a resource is required and not present then ignore this callback
			if not self:ResourceHerdingCheck() then
				return
			end
		end
		-- Stop Idles
		if self.animJob ~= nil then
			self.animJob:Signal( BlockingResult.Canceled, 0 )
		end
		if self.bReverse then
			self:StartReverseSteering()
		else
			self:StartFleeing()
		end
		self.state = HerdableScriptObjectBase.states["fleeing"]
	end
end

function HerdableScriptObjectBase:SteeringTargetNotNearbyCallback()
	if self.behaviorAlarm ~= nil and self.behaviorAlarm.isValid then
		self.behaviorAlarm:Kill()
	end
	if self.bHerded or not self:SpecifiedTaskRevealed() then
			-- Restart Idles
		self:StopSteering()
		self.state = HerdableScriptObjectBase.states["idle"]
				-- Stop Idles
		if self.animJob ~= nil then
			self.animJob:Signal( BlockingResult.Canceled, 0 )
			self:StartIdles()
		end

	else
		if self.bReverse then
				-- Stop Idles
				if self.animJob ~= nil then
					self.animJob:Signal( BlockingResult.Canceled, 0 )
				end
				
				-- change the herdable objects state to walking
				self:StartRandomWalking()
				self.state = HerdableScriptObjectBase.states["walking"]
				
				self.behaviorAlarm = self:CreateTimer( Clock.Sim, 0, 0, 1, 0 )
		else
			self:HandleStartWalking()	
		end
	end
end

function HerdableScriptObjectBase:EnterTriggerCallback(go, trigger)
	self.bInTriggerVolume = true
	
	if self.herdTypeSearchRefSpec ~= nil and self.specifiedTaskToComplete and self:SpecifiedTaskRevealed() and ( not Task:IsTaskComplete(self.specifiedTaskToComplete) ) then
		local player = Universe:GetPlayerGameObject()
		player:PlaySound( "ui_task_gather_feedback" )
	end	

	if self.bGroupHerdingType and self.herdTypeSearchRefSpec ~= nil then

		if self:TestAllHerded() then
            
            local world = self.containingWorld	
            local herdableObjects = world:CreateArrayOfObjects( self.herdTypeSearchRefSpec[2] )
        
			for _, go in pairs( herdableObjects ) do
                
                if Class:MemberExists(go, "bHerded") then
                    go.bHerded = true
                end
			end
		end
	else
		if self.herdTypeSearchRefSpec == nil then
			if self.state == HerdableScriptObjectBase.states["walking"] then
				self:HandleStopWalking()
			else
				self:StopSteering()
				
				-- Start Idling
				if self.animJob ~= nil then
					self.animJob:Signal( BlockingResult.Canceled, 0 )
				end
				self.state = HerdableScriptObjectBase.states["idle"]
				self:StartIdles()				
			end
		end
		self.bHerded = true
	end
end

function HerdableScriptObjectBase:ExitTriggerCallback(go, trigger)
	self.bInTriggerVolume = false
	
	if self.herdTypeSearchRefSpec and self.bGroupHerdingType then

        
        local world = self.containingWorld	
        local herdableObjects = world:CreateArrayOfObjects( self.herdTypeSearchRefSpec[2] )
        
		for _, go in pairs( herdableObjects ) do
        	if Class:MemberExists(go, "bHerded") then
            	go.bHerded = false
            end
		end	
	else
		self.bHerded = false
	end
end

function HerdableScriptObjectBase:EnteredWaterCallback()
	if self.bUseSnorkel then
		self:AddProp("propSnorkelMask", self.SnorkelAttachBone )
	end
end

function HerdableScriptObjectBase:ExitedWaterCallback()
	if self.bUseSnorkel then
		self:RemoveProp( self.SnorkelAttachBone )
	end
end

function HerdableScriptObjectBase:TestAllHerded()
	-- if not a group type then return true
	if self.herdTypeSearchRefSpec == nil then return true end
	
    local total, found = self:GetInTriggerVolumeCount()
    
    return total == found
end

function HerdableScriptObjectBase:GetInTriggerVolumeCount()
    local total = 0
    local found = 0
    
    local world = self.containingWorld	
    local herdableObjects = world:CreateArrayOfObjects( self.herdTypeSearchRefSpec[2] )
    
    for _,go in pairs( herdableObjects ) do
    
        if Class:MemberExists(go, "bInTriggerVolume") then
            found = found + ((go.bInTriggerVolume and 1) or 0)
            total = total + 1
        end
    end
     
    return total, found
end


function HerdableScriptObjectBase:TouchCallback()
    local tooltip = self:GetAttribute("UITooltip")
    if tooltip ~= nil then
        UIUtility:AttachToolTipToCursor( tooltip )
    end
    return 0
end

function HerdableScriptObjectBase:LostTouchCallback()
	UIUtility:HideToolTips()
    return 0
end

function HerdableScriptObjectBase:GetBrokerTypeName()
	return "HerdableScriptObjectBase"
end

function HerdableScriptObjectBase:GetBrokerTypeDescription()
	local scriptersAPI = Classes.ScriptObjectBase.GetBrokerTypeDescription(self)
	scriptersAPI.steering = true
	scriptersAPI.TriggerListener = true
	scriptersAPI.Input = true
	
	return scriptersAPI
end

function HerdableScriptObjectBase:SaveCallback()
	self:SetAttribute( "bHerded", self.bHerded )
end

function HerdableScriptObjectBase:LoadCallback()
	self.bHerded = self:GetAttribute( "bHerded" )
	
	if self.bHerded == nil then
		self.bHerded = false
	end
	
	if self.bHerded == false and Class:MemberExists(self, "bAllowPositionReset") == true then

		if self.bAllowPositionReset == true then

			if Class:MemberExists(self, "herdSpawnX") == true then
				-- If spawned by cutscene, grab cutscene position and orientation
				self:SetPositionRotation( self.herdSpawnX, self.herdSpawnY, self.herdSpawnZ, self.herdSpawnRotY )
			else
				-- If not spawned by cutscene, use attributes from entity on attribulator
				local position = self:GetDefaultAttribute( "Position" )
				local orientation = self:GetDefaultAttribute( "Orientation" )

				if position ~= nil and orientation ~= nil then
					self:SetPositionRotation( position.x, position.y, position.z, orientation.y )
				end
			end

		end
	end
end

--=========================================--
-- HerdableScriptObjectBase:KillInteractions( bSnapToSafePositionOnly ) --
--=========================================--
function HerdableScriptObjectBase:KillInteractions( bSnapToSafePositionOnly )

	if self.interactionJobList ~= nil and #self.interactionJobList > 0 then
		for i, job in ipairs(self.interactionJobList) do
			job:Cancel()
		end
	end

	self:SnapToSafePosition( bSnapToSafePositionOnly )

end


HerdableScriptObjectBase.interactionSet =
{
	Hyaa =  {   name                    = "STRING_INTERACTION_HERDABLESCRIPTOBJECTBASE_HYAA",
				interactionClassName    = "HerdableScriptObjectBase_Interaction_Hyaa",
				icon = "uitexture-interaction-herd",
				menu_priority = 0,},
	Pet  =  {   name                    = "STRING_INTERACTION_COW_PET",
				interactionClassName    = "HerdableScriptObjectBase_Interaction_Pet",
				icon = "uitexture-interaction-pet",
				menu_priority = 1,},
	Feed  = {   name                    = "STRING_INTERACTION_COW_FEED",
				interactionClassName    = "HerdableScriptObjectBase_Interaction_Feed",
				icon = "uitexture-interaction-feed",
				menu_priority = 2,},

	PushSim =           {
		name                    = "STRING_INTERACTION_CHARACTERBASE_PushSim",
		interactionClassName    = "CharacterBase_Debug_PushSim",
		icon = "uitexture-interaction-warmhands",
		menu_priority = 21,
	},

	Teleport =      {
		name                    = "STRING_INTERACTION_CHARACTERBASE_TELEPORT",
		interactionClassName    = "CharacterBase_Interaction_TeleportToSafePosition",
		menu_priority           = 22,
		icon = "uitexture-interaction-teleport",
	},

	DebugUi =   {
		name                    = "Debug Menu",
		interactionClassName    = "Unlocked_AnimalMenu",
		icon = "uitexture-interaction-use",
		menu_priority = 30,
	},
}

-------------------------------------------------------------------------------
--
-- Hyaa Power Herding interaction on herdable objects.
--
-------------------------------------------------------------------------------


local HerdableScriptObjectBase_Interaction_Hyaa = Classes.Job_InteractionBase:Inherit("HerdableScriptObjectBase_Interaction_Hyaa")

function HerdableScriptObjectBase_Interaction_Hyaa:Test( sim, obj, autonomous )
	-- if the herdable requires a task then only have the hyaa interaction available when the task is available.
	if obj.specifiedTaskToComplete ~= nil then
		if not obj:SpecifiedTaskRevealed() then
			return false
		end
	end
	
    return not obj.bHerded and ( obj:GetAttribute( "PowerHerdable" ) == true ) and obj.interactionDelayTimer == nil
end

function HerdableScriptObjectBase_Interaction_Hyaa:Destructor()
end

function HerdableScriptObjectBase_Interaction_Hyaa:Action( sim, obj )
	-- play the hyaa sound
	sim:PlaySound("cow_herding_vox")
	
	-- setup the default variables so we can go back to the default when the timer runs out
	if obj.defaultFleeSpeed == nil then
		obj.defaultFleeSpeed = obj:GetAttribute( "FleeSpeed" )
	end
	
	if obj.defaultAwarenessDistance == nil then
		obj.defaultAwarenessDistance = obj:GetAttribute( "FleeAwarenessDistance" )
	end
	
	if obj.defaultFleeSteerWeight == nil then
		obj.defaultFleeSteerWeight = obj:GetAttribute( "RandomFleeSteerWeight" )
	end
	
	-- get all the values we are going to work with to create the change in behavior
	local interactionDelay = obj:GetAttribute( "PowerHerdInteractionDelay" )
	local speedIncrement   = obj:GetAttribute( "PowerHerdFleeIncrease" )
	local currentSpeed     = obj:GetAttribute( "FleeSpeed" )
	local maxSpeed         = obj:GetAttribute( "PowerHerdFleeMaxSpeed" ) 	
	local newAwarenessDist = obj:GetAttribute( "PowerHerdFleeAwarenessDistance" )
	local newSpeed         = currentSpeed + speedIncrement	
	
	-- if the max speed has been crossed we add the MaxSpeedRandomSteerWeight to the normal RandomFleeSteerWeight
	-- if the value in attribulator is positive the herdable object will get more erratic
	-- if the value is negative they will get less erratic.
	if newSpeed > maxSpeed then
		newSpeed = maxSpeed
		local maxSpeedSteerWeight = obj:GetAttribute( "PowerHerdMaxSpeedSteerWeightMod" )
		obj:SetAttribute( "RandomFleeSteerWeight", obj.defaultFleeSteerWeight + maxSpeedSteerWeight )
	end
	
	-- whenever a herdable object has been "hyaa"ed it's awareness will increase so it can sense the player from farther off.
	obj:SetAttribute( "FleeAwarenessDistance", newAwarenessDist )
	obj:SetAttribute( "FleeSpeed", newSpeed )
	
	-- kill the old timer so we don't have a bunch of timers going off for no reason
	if obj.hyaaTimer ~= nil and obj.hyaaTimer.isValid then
		obj.hyaaTimer:Kill()
	end
	
	-- create a new timer with the full duration
	local increaseDuration = obj:GetAttribute( "PowerHerdIncreaseDuration" )
	obj.hyaaTimer = obj:CreateTimer( Clock.Sim, 0, 0, increaseDuration, 0 )
	
	-- kill the old timer so we don't have a bunch of timers going off for no reason
	if obj.interactionDelayTimer ~= nil and obj.interactionDelayTimer.isValid then
		obj.interactionDelayTimer:Kill()
	end
	obj.interactionDelayTimer = obj:CreateTimer( Clock.Sim, 0, 0, interactionDelay, 0 )
end

--=============================================================================
-- Herdable Critter  - Pet Interaction
--=============================================================================
local HerdableScriptObjectBase_Interaction_Pet = Classes.Job_InteractionBase:Inherit("HerdableScriptObjectBase_Interaction_Pet")

function HerdableScriptObjectBase_Interaction_Pet:Test( sim, obj, autonomous )	
    return obj.bHerded or obj.bPetWhenNotHerded
end

function HerdableScriptObjectBase_Interaction_Pet:Destructor()
end

function HerdableScriptObjectBase_Interaction_Pet:Action( sim, obj )
	if obj.bPetWhenNotHerded then
		obj:StopSteering()
		if obj.behaviorAlarm ~= nil and obj.behaviorAlarm.isValid then
			obj.behaviorAlarm:Kill()
		end
	end

	local result, reason, slotNum
	if obj.bRouteToSlot then
		local routeJob = Classes.Job_RouteToMultiSlot:Spawn( sim, obj, {0,1} )
		result, reason, slotNum = self:BlockingJob( routeJob )
	else
		result, reason = self:RouteToObjectBlocking(sim,obj, obj.distanceToBlocking)
	end
	
	if result ~= BlockingResult.Succeeded then
		return result, reason
	end
    
--|     result, reason = self:RotateToFaceObjectBlocking( sim, obj )
--|     if result ~= BlockingResult.Succeeded then
--| 		return result, reason
--| 	end

    -- Stop Idles
    if obj.animJob ~= nil then
        obj.animJob:Signal( BlockingResult.Canceled, 0 )
    end
    
    if obj.bRouteToSlot then
	    if slotNum == 0 then
			result, reason = self:PlaySyncedAnimationBlocking(sim, obj, self.obj.simPet, self.obj.critterPet, 1)
		else
			result, reason = self:PlaySyncedAnimationBlocking(sim, obj, self.obj.simPetE, self.obj.critterPetE, 1)
		end
	else
		result, reason = self:RotateToFaceObjectBlocking( sim, obj )
    	if result ~= BlockingResult.Succeeded then
			return result, reason
		end
		
		local _, _, _, simRot = sim:GetPositionRotation()
    	local x, y, z, _ = obj:GetPositionRotation()
   		obj:SetPositionRotation(x,y,z,simRot+180)
            
    	result, reason = self:PlaySyncedAnimationBlocking(sim, obj, obj.simPet, obj.critterPet, 1)
    end    

    -- Restart Idles
    obj:StartIdles()	

	if result ~= BlockingResult.Succeeded then
        
		return result, reason
	end
	
	if ( math.random() < 0.8 ) then
		local numSpawn = math.random(5)
		Common:StandardResourceSpawn( { {{"resource", "interaction_wandpower_small"}, numSpawn}, }, sim, obj, 360, { x=0, y=1.1, z=0, rotY=0 } )
	end
    	
	return result, reason
end


--=============================================================================
-- Herdable Critter  - Feed Interaction
--=============================================================================
local HerdableScriptObjectBase_Interaction_Feed = Classes.Job_InteractionBase:Inherit("HerdableScriptObjectBase_Interaction_Feed")

function HerdableScriptObjectBase_Interaction_Feed:Test( sim, obj, autonomous )
    return obj.bHerded or obj.bPetWhenNotHerded
end

function HerdableScriptObjectBase_Interaction_Feed:Destructor()
end

function HerdableScriptObjectBase_Interaction_Feed:Action( sim, obj )
	if obj.bPetWhenNotHerded then
		obj:StopSteering()
		if obj.behaviorAlarm ~= nil and obj.behaviorAlarm.isValid then
			obj.behaviorAlarm:Kill()
		end
	end

	local result, reason, slotNum
	if obj.bRouteToSlot then
		local routeJob = Classes.Job_RouteToMultiSlot:Spawn( sim, obj, {0,1} )
		result, reason, slotNum = self:BlockingJob( routeJob )
	else
		result, reason = self:RouteToObjectBlocking(sim,obj, obj.distanceToBlocking)
	end
	
	if result ~= BlockingResult.Succeeded then
		return result, reason
	end
	
--|     result, reason = self:RotateToFaceObjectBlocking( sim, obj )
--|     if result ~= BlockingResult.Succeeded then
--| 		return result, reason
--| 	end

    -- Stop Idles
    if obj.animJob ~= nil then
        obj.animJob:Signal( BlockingResult.Canceled, 0 )
    end
    
    if obj.bRouteToSlot then
		if slotNum == 0 then
			result, reason = self:PlaySyncedAnimationBlocking(sim, obj, self.obj.simFeed, self.obj.critterFeed, 1)
		else
			result, reason = self:PlaySyncedAnimationBlocking(sim, obj, self.obj.simFeedE, self.obj.critterFeedE, 1)
		end
	else
		result, reason = self:RotateToFaceObjectBlocking( sim, obj )
    	if result ~= BlockingResult.Succeeded then
			return result, reason
		end
		
		local _, _, _, simRot = sim:GetPositionRotation()
    	local x, y, z, _ = obj:GetPositionRotation()
   		obj:SetPositionRotation(x,y,z,simRot+180)
            
    	result, reason = self:PlaySyncedAnimationBlocking(sim, obj, obj.simFeed, obj.critterFeed, 1)
    end		
    
    -- Restart Idles
    obj:StartIdles()
    
	if result ~= BlockingResult.Succeeded then
        
		return result, reason
	end
	
	Common:StandardResourceSpawn( { {{"resource", "interaction_organic"}, 1}, }, sim, obj, 360, { x=0, y=1.1, z=0, rotY=0 } )

	return result, reason
end