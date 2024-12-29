--============================================================--
--  CharacterBase                                             --
--      Base class for all sim characters (including player)  --
--============================================================--

local CharacterBase = Classes.ScriptObjectBase:Inherit( "CharacterBase" )	

CharacterBase._inheritedSubTables = { "_talkData", "_neutralIdles", "_idleAnimations" }

--==============================
-- Inherited data tables
--==============================

-- MLAWSON REVISIT - using 'sim' tag so I can use the convenience mechanisms of the state machine interaction
CharacterBase._idleAnimations =
{
    {   sim = "a-idle-neutral",         weight = 80,  },
    {   sim = "a-idle-neutral-blink",   weight = 10,  },
    {   sim = "a-idle-lookAround",      weight = 5,  },
    {   sim = "a-idle-bop",             weight = 5,  },
}

CharacterBase._wanderSpecs =
{
}

CharacterBase._neutralIdles = 
{
    kStanding =
    {
        {   sim = "a-idle-neutral",         weight = 80,  },
        {   sim = "a-idle-neutral-blink",   weight = 20,  },
    },
}

CharacterBase._talkData = {} -- Data is initialized in post load init (due to dependency on SocialData)

CharacterBase.tuningConstants = 
{
    kSocialDispositionBias   = 0,    -- Bias of disposition meter.  Other factors include relationship, buffs
}

CharacterBase._instanceVars = 
{
    actionQueue                 = NIL,   -- Table of queued actions (as nuclei)
    
    action                      = NIL,   -- Instance of current job in control of sim
    actionNucleus               = NIL,   -- Current action nucleus (priority, etc...)
        
    schedule                    = NIL,   -- Reference to schedule component object
    
    talkTasks                   = NIL,  -- List of tasks to talk about.
    activeQuests                = NIL,  -- List of quests to talk about.
    
    socialAvailability          = Constants.SocialAvailability["kNoRestrictions"],
    
    socialProbabilityOverrides  = NIL,  -- per character type overrides of default social acceptance probability
    
    interests                   = NIL,
    
    autonomyEnabled             = true,
    
    idleCallbackEnabled         = true,
    idleCallbackOverrideAnim    = NIL,
        
    interest                    = NIL, -- See Constants.Interests
    
    controllingJob 				= NIL,
    requestControlJob			= NIL,
    returnControlJob			= NIL, -- the job we are sleeping on while somebody else is in control
    
    bRegisteredPlayerCollision  = false,
}


--===================--
-- Script Functions -- 
--===================--

--=============================
-- CharacterBase:Constructor()
--=============================
function CharacterBase:Constructor()
	self.actionQueue = {}
    
    self.schedule = Classes.Schedule:New( self, "ScheduleComponent")
    
    self.controllingJob = nil
    
end

--=============================
-- CharacterBase:Destructor()
--=============================
function CharacterBase:Destructor()
	if self.action ~= nil then
		self.action:Destroy()
        self.action = nil
	end
    
    if self.schedule ~= nil then
        self.schedule:Delete()
        self.schedule = nil
	end
	
	if ( self.bRegisteredPlayerCollision ) then
		local player = Universe:GetPlayerGameObject()
		if ( player ~= nil ) and ( player.isValid ) and ( player ~= self ) then
			self:UnregisterForCollisionWithGameObjectCallback( player )
			self.bRegisteredPlayerCollision = false
		end -- verify player
	end -- check bRegisteredPlayerCollision
end

function CharacterBase:GetBrokerTypeName()
	return "CharacterBase"
end

function CharacterBase:GetBrokerTypeDescription()
	-- inherit the scripters API from the base class.
	local scriptersAPI = Classes.ScriptObjectBase.GetBrokerTypeDescription(self)
	-- then add more brokers as neccessary
	scriptersAPI.Routing = true
	scriptersAPI.Input = true
	scriptersAPI.Sound = true
	scriptersAPI.Collision = true
    	
	return scriptersAPI

end

--============================================
-- CharacterBase:SaveCallback()
--============================================
function CharacterBase:SaveCallback()
    ------------------------------------
    -- Save schedule
    --
    if self.schedule then
        self.schedule:SaveScheduleData()
    end
            
    -------------------------------
    -- Get save collection key
    --
    local collectionKey = self.collectionKey
        
    local redirectRefSpec = Luattrib:ReadAttribute("character", collectionKey, "RedirectRefSpec")
    
    if redirectRefSpec then
        collectionKey = redirectRefSpec[2]
    end
    
    -------------------------------
    -- Save talk task list
    --
    local talkTaskList = {}
    if self.talkTasks then
        for i, taskId in ipairs(self.talkTasks) do
            local taskHash = Luattrib:ConvertStringToUserdataKey(taskId)
            talkTaskList[i] = taskHash
        end
    end
    Luattrib:WriteAttribute("character", collectionKey, "TalkTasks", talkTaskList, true)
    
    -------------------------------
    -- Save quest list
    --
    local questTaskList = {}
    if self.activeQuests then
        for i, taskId in ipairs(self.activeQuests) do
            local questHash = Luattrib:ConvertStringToUserdataKey(taskId)
            questTaskList[i] = questHash
        end
    end
    Luattrib:WriteAttribute("character", collectionKey, "TalkQuest", questTaskList, true)
end

--============================================
-- CharacterBase:LoadCallback()
--============================================
function CharacterBase:LoadCallback()

    -------------------------------
    -- Get save collection key
    --
    local collectionKey = self.collectionKey
        
    local redirectRefSpec = Luattrib:ReadAttribute("character", collectionKey, "RedirectRefSpec")
    
    if redirectRefSpec then
        collectionKey = redirectRefSpec[2]
    end
    
    --------------------------
    -- Restore talk tasks
    --
    local taskTalkList = Luattrib:ReadAttribute("character", collectionKey, "TalkTasks")
    if taskTalkList then
        for i, hash in ipairs(taskTalkList) do
            taskTalkList[i] = Task.HashToTaskId[hash]
        end    
    end
    self.talkTasks = taskTalkList
    
    --------------------------
    -- Restore active Quest
    --
    local questTalkList = Luattrib:ReadAttribute("character", collectionKey, "TalkQuest")
    if questTalkList then
        for i, hash in ipairs(questTalkList) do
            questTalkList[i] = Task.HashToTaskId[hash]
        end
    end
    self.activeQuests = questTalkList
    
    Task:UpdateBobByState(self)
end


--=============================
-- CharacterBase:ResetCallback()
-- CharacterBase:ResetPositionCallback()
--=============================
function CharacterBase:ResetCallback()
	if self.action ~= nil then
		self.action:Destroy()
        self.action = nil
	end
    
    if self.schedule ~= nil then
        self.schedule:Delete()
        self.schedule = nil
	end
end

function CharacterBase:BeginIslandSimulationCallback(islandRefSpec)
--	EA:LogI("Steve", "CharacterBase:BeginIslandSimulationCallback ", tostring(islandRefSpec[1]), tostring(islandRefSpec[2])) 
    
    if self.containingObject ~= self.containingWorld then
        self:SnapToSafePosition( true )
    end

end

function CharacterBase:NotRunnableCallback()
	if self.action ~= nil then
		self.action:Destroy()
        self.action = nil
	end
    
	self:ClearControlRequest()
	
	self.actionNucleus = nil
end

--=============================
-- CharacterBase:Run()
--=============================
function CharacterBase:Run()
	if ( DebugMenu:GetValue("EnableNPCInterruptByPlayerJump") ) and ( not self.bRegisteredPlayerCollision ) then
		local player = Universe:GetPlayerGameObject()
		if ( player ~= nil ) and ( player.isValid ) and ( player ~= self ) then
			self:EnableCollisionWithGameObject( player )
			self:RegisterForCollisionWithGameObjectCallback( player )
			self.bRegisteredPlayerCollision = true
		end -- verify player
	end -- verify EnableNPCInterruptByPlayerJump
	
	while true do
		self:MainLoop()
	end
end

--========================================================
-- CharacterBase:SetIdleCallbackEnabledStatus( bStatus )
-- controller is an optional parameter. If nil, will use thread's owner as the controller
--========================================================
function CharacterBase:SetIdleCallbackEnabledStatus( bStatus, controller )
	EA:NotFinal(self:VerifyHasControl("CharacterBase:SetIdleCallbackEnabledStatus", controller))
    self.idleCallbackEnabled = bStatus
end

--========================================================
-- CharacterBase:SetIdleCallbackOverrideAnim( anim )
-- controller is an optional parameter. If nil, will use thread's owner as the controller
--========================================================
function CharacterBase:SetIdleCallbackOverrideAnim( anim, controller )
	EA:NotFinal(self:VerifyHasControl("CharacterBase:SetIdleCallbackOverrideAnim", controller))
    self.idleCallbackOverrideAnim = anim
end

--=============================
-- CharacterBase:IdleCallback()
-- Called by the engine if a character is about to be rendered while not playing any animation

--=============================
function CharacterBase:IdleCallback()
    if self.idleCallbackEnabled then
    	-- If there is a controlling job it is responsible for playing the idle animation
	    if ( self.controllingJob ~= nil ) then
	   		if Class:MemberExists(self.controllingJob, "IdleCallback") then
	    		return self.controllingJob:IdleCallback( self )
	    	else
	    		-- controllingJobs are required to have an IdleCallback
	    		if not _FINAL then
	    			EA:Fail("Controlling Job " .. tostring(self.controllingJob) .. " needs an IdleCallback")
	    		end
	    	end
	    	return
	    end
   		-- There is no controlling job, do the default behavior 
    	return self:IdleCallbackControlled(self)
    end
end

--=============================
-- CharacterBase:IdleCallbackControlled()
-- Plays idle animation under the auspices of the passed in controller.
-- Do not abuse this function by calling it when you are not the controller of the sim 
--=============================
function CharacterBase:IdleCallbackControlled(controller)

    local anim = "a-idle-neutral"
    
    if self.idleCallbackOverrideAnim ~= nil then
        if type(self.idleCallbackOverrideAnim) == 'string' then
            anim = self.idleCallbackOverrideAnim
        else
            anim = Common:SelectRandomWeighted( self.idleCallbackOverrideAnim ).sim
        end
    else
        -- if self:GetLocoState() == "kStanding" then
        anim = Common:SelectRandomWeighted( self._neutralIdles["kStanding"] ).sim

    end
    	    
    local animJob = self:GetPlayAnimationJob( anim, 1, nil )
    
    if animJob ~= nil then
        animJob:Execute(controller)
    end
    
    return animJob -- So it can be blocked on        
end


function CharacterBase:TouchCallback()
    UIUtility:AttachToolTipToCursor( self:GetAttribute("ShortName") )
    return 0
end

function CharacterBase:LostTouchCallback()
	UIUtility:HideToolTips()
    return 0
end

--================================
-- CollisionWithGameObjectCallback
-- Used for EnableNPCInterruptByPlayerJump
--================================
function CharacterBase:CollisionWithGameObjectCallback( collidedObj, velX, velY, velZ )
	if ( not DebugMenu:GetValue("EnableNPCInterruptByPlayerJump") ) then
		return
	end -- bail if feature disabled
	
	if ( self.controllingJob ~= nil ) or ( self.requestControlJob ~= nil ) then
		return
	end -- bail if controlling job
	
	local player = Universe:GetPlayerGameObject()
	
	if ( player ~= nil ) and ( player == collidedObj ) and ( player ~= self ) then
		if ( velY > -1 * DebugMenu:GetValue("NPCInterruptByPlayerJumpVel") ) and ( velY < DebugMenu:GetValue("NPCInterruptByPlayerJumpVel") ) then
			return
		end -- bail if vertical velocity is not fast enough
		
		local _,playerY = collidedObj:GetPositionRotation()
		local _,selfY = self:GetPositionRotation()
		
		if ( (playerY - selfY) > DebugMenu:GetValue("NPCInterruptByPlayerJumpHeight") ) then
			self:ClearInteractionQueue( self )
--			self:PushInteraction( self, "GetInterrupted", nil, false, true, Constants.InteractionPriorities["Reaction"] )
			self:PushInteraction( self, "GetInterrupted", nil, false, true, Constants.InteractionPriorities["Default"] )
		end -- check distance
	end -- veriyf player is collidedObj
end

--=============================
-- CharacterBase:MainLoop()
--=============================

function CharacterBase:MainLoop()
	
    
	while true do
		EA:ProfileEnterBlock("Lua__CharacterBase_MainLoop")
       	self:ProcessControlRequest() 

		local result = BlockingResult.Failed
		
		if self:GetQueuedInteractionCount() > 0 then
       		result = self:DoNextInteraction()
       		
       	elseif self.schedule ~= nil and DebugMenu:GetValue("EnableScheduleAutonomy") then

			result = self.schedule:ProcessSchedule()
			
        end 
        
		-- We can only guarantee that a blocking operation occurred if we got a succeeded result.
		-- In the absence of that we must yield to prevent an infinite loop
        if result ~= BlockingResult.Succeeded then
        	EA:ProfileLeaveBlock("Lua__CharacterBase_MainLoop", self.mType)
        	Yield()
        end      	
	
	end
end


--==============================
-- CharacterBase Primitive Jobs
--==============================
function CharacterBase:GetRouteToPositionJob(...)
    return Classes.Job_RouteToPosition:Spawn(self, ...)
end

function CharacterBase:GetRouteCloseToPositionJob(...)
    return Classes.Job_RouteCloseToPosition:Spawn(self, ...)
end

function CharacterBase:GetRouteToFootprintJob(...)
    return Classes.Job_RouteToFootprint:Spawn(self, ...)
end

function CharacterBase:GetRouteToObjectJob(...)
    return Classes.Job_RouteToObject:Spawn(self, ...)
end

function CharacterBase:GetRouteToSlotJob(...)
    return Classes.Job_RouteToSlot:Spawn(self, ...)
end

function CharacterBase:GetPlayAnimationJob(...)
    return Classes.Job_PlayAnimation:Spawn(self, ...)
end

function CharacterBase:GetRotateToFacePosJob(...)
    return Classes.Job_RotateToFacePos:Spawn(self, ...)
end

function CharacterBase:GetRotateToFaceObjectJob(...)
    return Classes.Job_RotateToFaceObject:Spawn(self, ...)
end



--=============================
-- CharacterBase Real Fake Autonomy
--=============================
function CharacterBase:RealFakeAutonomy()

    if DebugMenu:GetValue("EnableRealFakeAutonomy") and self.autonomyEnabled then

        local world = self.containingWorld
        local t = world:CreateTable(self, DebugMenu:GetValue("RealFakeAutonomyDistance") )
        
        local obj = nil
        local count = 0
        
        local actionList = {}
        
        for go in pairs(t) do
            if InteractionUtils:IsObjectInteractable(go) then
            
                for key in pairs(go.interactionSet) do
                
                    if InteractionUtils:InteractionTest( self, go, key, true ) then
                        actionList[#actionList+1] = { object=go, key=key }
                    end
                end
            end
        end
        
        if #actionList > 0 then
            local selection = actionList[math.random(#actionList)]
            self:PushInteraction( selection.object, selection.key, nil, nil, nil, Constants.InteractionPriorities["Autonomy"] )
            
            EA:LogI("Autonomy", "Fake Autonomy: " .. self.mName .. " - " .. selection.object.mName .. " - " .. selection.key)
        
            return true
        end
    end
    
    return false    
end


--=============================
-- CharacterBase:GetName()
--  return localized string for character name
--=============================
function CharacterBase:GetName()
	return UIEngineUtils:DebugLocalize("STRING_NPC_NAME_" .. self:GetTypeName())
end


--=======================================
--
--  Interaction support
--
--=======================================

--=============================
-- CharacterBase:CancelCurrentInteraction()
--=============================
function CharacterBase:CancelCurrentInteraction()
	EA:LogI("Mutex", "CharacterBase:CancelCurrentInteraction ", tostring(self), tostring(self.action), FOR_LOGGING_ONLY_GOSchedulerTick)
	if ( self.action ~= nil ) and ( self.action.isValid ) then
		EA:LogI("Mutex", "CharacterBase:CancelCurrentInteraction ReturnValues", self.action:GetReturnValues(), FOR_LOGGING_ONLY_GOSchedulerTick)
		self.action:Cancel()
	end	
end

--=============================
-- CharacterBase:PreInteraction()
-- Note: This function is called from the derived player class
--=============================
function CharacterBase:PreInteraction(interactionJob)
	return true
end

--=============================
-- CharacterBase:PostInteraction()
-- Note: This function is called from the derived player class.
--=============================
function CharacterBase:PostInteraction( nucleus, result )
end

--=============================
-- CharacterBase:ProcessInteractions()
--=============================
function CharacterBase:ProcessInteractions()
	EA:ProfileEnterBlock("Lua__CharacterBase_ProcessInteraction")
    local nucleus = self:GetNextInteraction()
    
    if nucleus ~= nil then
    
        while nucleus ~= nil do
        
            self:ProcessInteractionNucleus( nucleus )
                                
            nucleus = self:GetNextInteraction()
            
        end
    	EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessInteraction", self.mType)
        return true
    end
    EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessInteraction", self.mType)    
    return false    
end

--=============================
-- CharacterBase:DoNextInteraction()
--=============================
function CharacterBase:DoNextInteraction()
	EA:ProfileEnterBlock("Lua__CharacterBase_ProcessInteraction")
    local nucleus = self:GetNextInteraction()
    
    if nucleus ~= nil then
    	EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessInteraction", self.mType)
        return self:ProcessInteractionNucleus( nucleus )    
    end
    EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessInteraction", self.mType) 
    return BlockingResult.Failed
end


--==========================================--
-- CharacterBase:ProcessInteractionJob(job) --
--==========================================--
function CharacterBase:ProcessInteractionJob(job)
	EA:ProfileEnterBlock("Lua__CharacterBase_ProcessInteractionJob")
    EA:Assert(self.action == nil, "Trying to process two interactions at the same time")
	EA:LogI("Mutex", "CharacterBase:ProcessInteractionJob ", tostring(self), tostring(job), FOR_LOGGING_ONLY_GOSchedulerTick)    
	local result, reason
    
    if job ~= nil then
        local bPreInteractionSuccess = self:PreInteraction(job)
        
        self.action = job
        
        if ( bPreInteractionSuccess ) then
            self.action:Execute(self.controllingJob or self)
            result, reason = self.action:BlockOn()
			EA:LogI("Mutex", "CharacterBase:ProcessInteractionJob end interaction ", tostring(self), tostring(job), result, FOR_LOGGING_ONLY_GOSchedulerTick)               
            self:PostInteraction()
        else
        	self.action:Destroy()
        end -- check bPreInteractionSuccess
        
        self.action = nil
    end
    EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessInteractionJob", self.mType)
    return result, reason
end

--==================================================--
-- CharacterBase:ProcessInteractionNucleus(nucleus) --
--==================================================--
function CharacterBase:ProcessInteractionNucleus(nucleus)
	EA:ProfileEnterBlock("Lua__CharacterBase_ProcessInteractionNucleus")
    EA:Assert(self.actionNucleus == nil, "Trying to process two interactions at the same time")
    
    self.actionNucleus = nucleus
    
    --=========================================================
    -- Lockout objects from getting picked up in construction
    --=========================================================
    if nucleus.object ~= nil then
        nucleus.object:InUseAddRef()
    end
    
    local job = nucleus:CreateInteractionInstance(self)

    
    local result, reason = self:ProcessInteractionJob( job )

    --=========================================================
    -- Unlock objects so they can be picked up in construction
    --=========================================================    
    if nucleus.object ~= nil then
        nucleus.object:InUseDecRef()
    end
    
    nucleus.result = result
    
    self.actionNucleus = nil
	EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessInteractionNucleus", "!")
    return result, reason
end


--=============================
-- CharacterBase:GetNextInteractionPriorityIndex()
--=============================
function CharacterBase:GetNextInteractionPriorityIndex()
    local lowIndex, lowPriority
    
    for i,nucleus in ipairs(self.actionQueue) do
        
        if lowIndex == nil or nucleus.priority < lowPriority then
            lowIndex    = i
            lowPriority = nucleus.priority
        end
    end
    return lowIndex
end

function CharacterBase:GetQueuedInteractionCount()
    return #self.actionQueue
end

--=============================
-- CharacterBase:GetNextInteraction()
--=============================
function CharacterBase:GetNextInteraction( bNoRemove )
    local lowIndex = self:GetNextInteractionPriorityIndex()
       
    if lowIndex ~= nil then
        
        if bNoRemove then
            return self.actionQueue[lowIndex], lowIndex
        end
        
        return table.remove( self.actionQueue, lowIndex )
    end
end

--=============================
-- CharacterBase:GetNextInteractionNoRemove()
--=============================
function CharacterBase:GetNextInteractionNoRemove()
	return self:GetNextInteraction( true )
end

--=============================
-- CharacterBase:PushInteractionNucleus()
--=============================
function CharacterBase:PushInteractionNucleus( nucleus, bDoNotCancelCurrent, bPushFront )
    if not bDoNotCancelCurrent then
        if self.action then
            
            local current = (self.actionNucleus and self.actionNucleus.priority) or Constants.InteractionPriorities["Default"]
            local new = nucleus.priority
            
            if current == Constants.InteractionPriorities["Default"] then
                if new > Constants.InteractionPriorities["Default"] then
                    
                    bDoNotCancelCurrent = true
                end
            else
                if current <= new then
                    
                    bDoNotCancelCurrent = true
                end
            end
        end
    end
  
    if not bDoNotCancelCurrent then
        self:CancelCurrentInteraction()
    end
    
    if not bPushFront then
        table.insert( self.actionQueue, 1, nucleus )
    else
        self.actionQueue[#self.actionQueue+1] = nucleus
    end

    return nucleus
end

--=============================
-- CharacterBase:PushInteraction()
--=============================
function CharacterBase:PushInteraction( object, key, params, bDoNotCancelCurrent, bPushFront, priority )
	local bPush = true
    if ( self.controllingJob ~= nil ) then
   		if Class:MemberExists(self.controllingJob, "PushInteraction") then
    		bPush = self.controllingJob:PushInteraction( self, object, key, params, bDoNotCancelCurrent, bPushFront, priority  )
    	end
    end

	if not bPush then
		return nil
	end
	
	return self:PushInteractionNucleus( InteractionNucleus:Create(object, key, params, priority), bDoNotCancelCurrent, bPushFront )
end

--=============================
-- CharacterBase:ClearInteractionQueue()
--=============================
function CharacterBase:ClearInteractionQueue(controller)
	EA:NotFinal(self:VerifyHasControl("CharacterBase:ClearInteractionQueue", controller))
	self.actionQueue = {}
end


--======================================--
-- CharacterBase:TimerExpiredCallback() --
--======================================--
function CharacterBase:TimerExpiredCallback( timerID )
    if self.schedule then
    	EA:ProfileEnterBlock("Lua__CharacterBase_ProcessSchedule")
        self.schedule:ProcessScheduleTimers( timerID )
        EA:ProfileLeaveBlock("Lua__CharacterBase_ProcessSchedule", self.mType)
    end
end


--==================================================--
-- CharacterBase:OverrideLocoAnims( locoOverrides ) --
--==================================================--
function CharacterBase:OverrideLocoAnims( locoOverrides )
    if locoOverrides ~= nil then
        
        for locoType, anim in pairs( locoOverrides ) do
            if tonumber(locoType) then
                self:OverrideLocoAnimation( locoType, anim )
            end
        end
    
    end
end
--========================================--
-- CharacterBase:ClearLocoAnimOverrides() --
--========================================--
function CharacterBase:ClearLocoAnimOverrides()

    self:OverrideLocoAnimation( LocoAnimTypes.kFall )
    self:OverrideLocoAnimation( LocoAnimTypes.kFallLand )
    self:OverrideLocoAnimation( LocoAnimTypes.kLand )
    self:OverrideLocoAnimation( LocoAnimTypes.kPop )
    self:OverrideLocoAnimation( LocoAnimTypes.kIdle )
    self:OverrideLocoAnimation( LocoAnimTypes.kWalk )
    self:OverrideLocoAnimation( LocoAnimTypes.kRun )
    self:OverrideLocoAnimation( LocoAnimTypes.kJump )
    self:OverrideLocoAnimation( LocoAnimTypes.kJumpForward )
end

--========================================--
-- CharacterBase:RequestControl( ) --
-- Return job that will be signaled when the controller has been granted control
--========================================--
function CharacterBase:RequestControl( requestingController )
	
	EA:LogI("Mutex", "CharacterBase:RequestControl", tostring(self), tostring(requestingController), FOR_LOGGING_ONLY_GOSchedulerTick)	
	
	local newRequestJob = Classes.Job_RequestCharacterControl:Spawn(requestingController, self)
	newRequestJob:ExecuteAsIs()

	-- Duke it out with any pending request
	-- Loser gets signaled failed
	-- Winner goes into or remains in requestControlJob
	if self.requestControlJob ~= nil then
		local pendingController = self.requestControlJob:GetRequester()
		if pendingController:WillConcedeToController(requestingController) then
			self.requestControlJob:Signal(BlockingResult.Failed, 0)
			self.requestControlJob = newRequestJob
		else
			newRequestJob:Signal(BlockingResult.Failed, 0)
		end
	else
		self.requestControlJob = newRequestJob
	end
	
	-- If we have a new requestControlJob then
	-- 	Duke it out with the current controller
	-- 	We don't actually care who wins, we are in a sense asking the current controller to 
	-- 	hurry up and exit, but it does not have to comply
	-- Regardless the new guy waits
	if newRequestJob == self.requestControlJob then
		local currentBoss = self.controllingJob or self
		currentBoss:WillConcedeToController(requestingController)
	end
	
	return newRequestJob
end

function CharacterBase:RemoveRequestControl( jobToRemove )
	if self.requestControlJob == jobToRemove then
		EA:LogI("Mutex", "CharacterBase:RemoveRequestControl", tostring(self), tostring(jobToRemove), FOR_LOGGING_ONLY_GOSchedulerTick)		
		jobToRemove:Destroy()
		self.requestControlJob = nil
	end
end


--========================================--
-- CharacterBase:TransferControl( ) --
-- Transfers control from the current controller to the recipient.
-- This cannot be used if the Sim is currently in control of itself. 
--========================================--
function CharacterBase:TransferControl( controller, recipient)
	EA:Assert(self.controllingJob == controller, "CharacterBase:TransferControl ", tostring(controller), " is not in control of ", self)
	self.controllingJob = recipient
	recipient:NotifyTransferControl(self, controller, self.returnControlJob)
end

--========================================--
-- CharacterBase:ProcessControlRequest( ) --
-- Hand off control to queued controllers
--========================================--
function CharacterBase:ProcessControlRequest()
	EA:Assert(self.controllingJob == nil, "CharacterBase:ProcessControlRequest controlling job is not nil")
	
	if self.requestControlJob ~= nil then
	
		local requestControlJob = self.requestControlJob
		
		-- Being extra paranoid
		if requestControlJob.isValid and requestControlJob:RequestIsValid() then
	
			-- Make a job for us to block on. The controller will signal it when done
			self.returnControlJob = Classes.Job_ReturnCharacterControl:Spawn(requestControlJob:GetRequester(), self)
			self.returnControlJob:ExecuteAsIs()
			
			self.controllingJob = requestControlJob:GetRequester()
			EA:LogI("Mutex", "CharacterBase:ProcessControlRequest passing control", tostring(self), tostring(self.controllingJob), FOR_LOGGING_ONLY_GOSchedulerTick)	
				
			-- Wake the controller, passing the returnControlJob for it to signal when done.
			requestControlJob:Signal(BlockingResult.Succeeded, 0, self.returnControlJob)
			self.requestControlJob = nil	
			
			-- Block until controller is done
			self.returnControlJob:BlockOn()
		
			EA:LogI("Mutex", "CharacterBase:ProcessControlRequest returned control", tostring(self), tostring(self.controllingJob), FOR_LOGGING_ONLY_GOSchedulerTick)
			self.controllingJob = nil
			self.returnControlJob = nil		
		else
			self.requestControlJob = nil
		end
	end

end

-- Call when the character is being deleted to unblock any waiters
function CharacterBase:ClearControlRequest()
	if self.requestControlJob then
		self.requestControlJob:Signal(BlockingResult.Failed, 0)
		self.requestControlJob = nil	
	end
end


--=====================================--
--  CharacterBase:WillConcedeToController() --
--
-- Another controller wants control
-- For now we always concede and do our best to cancel any current operations
-- Will have to consider priorities or situational rules things get more complicated 
--=====================================--
function CharacterBase:WillConcedeToController(controller)
	self:CancelCurrentInteraction()
	if self.schedule then
		self.schedule:RequestCancel()
	end
	return true
end

--========================================--
-- CharacterBase:HasControl( ) --
-- Does the instance have permission to operate on the character.
--  i.e. animate, route.
-- The instance or one of its parents must be the character's controllingJob or the character
-- If the instance is nil, will use the owner of the executing thread 
--========================================--
function CharacterBase:VerifyHasControl(message, instance)
	local boss = self.controllingJob or self

	instance = instance or GetThreadsOwnerInstance(GetThisLuaThread()) 	
	local testObj = instance
	EA:Assert(message .. "unknown instance does not have permissions on " .. tostring(self))

	repeat
	
		if testObj == boss then
			return true
		end
		
		if not Class:MemberExists(testObj, "controlOwner") then
			break
		end
		testObj = testObj.controlOwner
	until testObj == nil
	
    --On the boat the a2o-seat-breathe-loop clip is breaking lua attempting to get control of character and failing.
    --We could find why and could not see any issues from it.
	--EA:Fail(message .. tostring(instance) .. "does not have permissions on " .. tostring(self))
    EA:LogE("Animation", "Verify control error, permission error! ########")
	return false

end


--=========================================--
-- CharacterBase:GetDebugString( context ) --
--=========================================--
function CharacterBase:GetDebugString( context )

    if context == Classes.Schedule.kDebugTextContextName then
        if self.schedule ~= nil then
            return self.schedule:GetDebugString( context )
        end
    end

end

--=========================================--
-- CharacterBase:KillInteractions( bSnapToSafePositionOnly ) --
--=========================================--
function CharacterBase:KillInteractions( bSnapToSafePositionOnly )

	if self.schedule then
		self.schedule:RequestCancel()
	end

	if self.action ~= nil and self.action.isValid then
		self.action:Kill( bSnapToSafePositionOnly )
	else
		self:SnapToSafePosition( bSnapToSafePositionOnly )
	end
    
    self:PushInteraction(self, "Wander", {distance = { min = 1.0, max = 2.0 },} )

end


--=============================
-- CharacterBase:OverrideSchedule()
-- Use the schedule for this npc from worldName
-- worldName does not have to be a real world, just one used to register a schedule
--=============================
function CharacterBase:OverrideSchedule(worldName, controller)
	EA:NotFinal(self:VerifyHasControl("CharacterBase:OverrideSchedule", controller))
    self.schedule = Classes.Schedule:New( self, "ScheduleComponent", worldName)
    
end


--=============================
-- CharacterBase:UnoverrideSchedule()
-- Set the schedule to what it would normally be for this world
--=============================
function CharacterBase:UnoverrideSchedule(controller)
	EA:NotFinal(self:VerifyHasControl("CharacterBase:UnoverrideSchedule", controller))
	self.schedule:ReinitializeSchedule()
end


--==================================================================--
-- CharacterBase.interactionSet
--==================================================================--

CharacterBase.interactionSet =
{
    ------------------
    -- Social Socials (One-offs)
    ------------------
    
    --------------------------------------------
    -- BeNice   
    --------------------------------------------
    BeNice =    {
                    name                    = "STRING_INTERACTION_CHARACTERBASE_BENICE",
                    interactionClassName    = "CharacterBase_Interaction_Social",
                    socialClassName         = "Social_BeNice",
                    menu_priority           = 4,
                    icon = "uitexture-interaction-benice",
                },
                
    --------------------------------------------
    -- BeMean   
    --------------------------------------------
    BeMean =    {
                    name                    = "STRING_INTERACTION_CHARACTERBASE_BEMEAN",
                    interactionClassName    = "CharacterBase_Interaction_Social",
                    socialClassName         = "Social_BeMean",
                    menu_priority           = 5,
                    icon = "uitexture-interaction-bemean",
                },                
    
    --------------------------------------------
    -- Trade
    --  Exchange goods with a sim.
    --------------------------------------------
    Trade =     {
                    name                    = "STRING_INTERACTION_CHARACTERBASE_TRADE",
                    interactionClassName    = "CharacterBase_Interaction_Social",
                    socialClassName         = "Social_Trade",
                    menu_priority           = 2,
                    icon = "uitexture-interaction-trade",
                },
                
--[[ Removed - Wii-4159
    --------------------------------------------
    -- AskForHelp
    --  Show blueprints related to current task
    --------------------------------------------
    AskForHelp =    {
                        name                    = "STRING_INTERACTION_CHARACTERBASE_ASKFORHELP",
                        interactionClassName    = "CharacterBase_Interaction_Social",
                        socialClassName         = "Social_AskForHelp",
                        menu_priority           = 3,
                    },                
--]]
                
    ------------------
    -- Idle
    ------------------
    Idle =  {
                name                    = "Idle",
                interactionClassName    = "CharacterBase_Interaction_Idle",
                icon = "uitexture-interaction-use",
            },
            
    ------------------
    -- Wander
    ------------------
    Wander =    {
                    name                    = "Wander",
                    interactionClassName    = "CharacterBase_Interaction_Wander",
                    icon = "uitexture-interaction-use",
                },            
            
    ------------------
    -- Get Interrupted by Player Jump
    ------------------
    GetInterrupted = {
                         name                    = "GetInterrupted",
                         interactionClassName    = "CharacterBase_Interaction_Interrupted",
                         icon = "uitexture-interaction-use",
                     },            
            
    ------------------
    -- Socialize
    ------------------
    Socialize = {
                    name                    = "STRING_INTERACTION_CHARACTERBASE_SOCIALIZE",
                    interactionClassName    = "CharacterBase_Interaction_Social",
                    socialClassName         = "Social_Socialize",
                    icon = "uitexture-interaction-socialize",
                },
                
    ----------------------------------
    -- SequenceProcessor
    --  Used for reactions and other
    --  simple runtime interactions.
    ----------------------------------
    SequenceProcessor = {
                            name                    = "Sequence",
                            interactionClassName    = "CharacterBase_Interaction_SequenceProcessor",
                            icon = "uitexture-interaction-use",
                        },                

    --------------------------------------------
    -- Talk  
    --  Advance the story/task/clockwork etc...
    --------------------------------------------
    Talk =      {
                    name                    = "STRING_INTERACTION_CHARACTERBASE_TALK",
                    interactionClassName    = "CharacterBase_Interaction_Talk",
                    menu_priority           = 0,
                    icon = "uitexture-interaction-talk",
                },
                
    -----------------------------------------   
    -- TaskPendingComplain
    --  Triggers initial reveal of a task.
    -----------------------------------------
    TaskPendingComplain =   {
                                name                    = "TaskPendingComplain",
                                interactionClassName    = "CharacterBase_Interaction_TaskPendingComplain",
                                icon = "uitexture-interaction-use",
                            },
                            
                            
    ------------------------------------------
    -- TaskRewardAdvertise
    --  NPC communicates they have a reward
    ------------------------------------------
    TaskRewardAdvertise =   {
                                name                    = "TaskRewardAdvertise",
                                interactionClassName    = "CharacterBase_Interaction_TaskRewardAdvertise",
                                icon = "uitexture-interaction-use",
                            },
                            
    FacePlayer =   {
                                name                    = "FacePlayer",
                                interactionClassName    = "CharacterBase_Interaction_FacePlayer",
                                icon = "uitexture-interaction-use",
                            },


-------------------------------------------
                            
    
    -- TEMPORARY
    FollowWaypoints =   {
                            name                    = "Pace",
                            interactionClassName    = "CharacterBase_Interaction_FollowWaypoints",
                            icon = "uitexture-interaction-use",
                        },
                        
                        
    -----------------------------------------   
    -- DEBUG INTERACTIONS
    -----------------------------------------                        

    PushSim =           {
        name                    = "STRING_INTERACTION_CHARACTERBASE_PushSim",
        interactionClassName    = "CharacterBase_Debug_PushSim",
        icon = "uitexture-interaction-warmhands",
    },

    DebugUi =   {
                            name                    = "Debug Menu",
                            interactionClassName    = "CharacterBase_Debug_AdvanceSchedule",
                            icon = "uitexture-interaction-use",
                        },

    Move =              {
        name                    = "Move!",
        interactionClassName    = "CharacterBase_Interaction_Move",
        icon = "uitexture-interaction-herd",
    },

    --[[
    ForceNPCIdle =      {
                            name                    = "STRING_INTERACTION_CHARACTERBASE_ForceIdle",
                            interactionClassName    = "Debug_Interaction_ForceNPCUse",
                            actionKey               = "Idle",
                            tuningSpec              =
                            {
                                duration =  {
                                                minSeconds  = 20,        --  duration is range of seconds and/or
                                                maxSeconds  = 30,        --  loop counts to run the ANIMATE_LOOPS
                                            },
                            },
                            icon = "uitexture-interaction-use",
                        },
    --]]

}



function CharacterBase:PostLoadInit()

self._talkData["kDefaultTalk"] =
{
    {
        SocialAnims     = {"talkthoughtful", "idle"},
        bReverseAnims   = true,

        DIALOG_MESSAGE  = "STRING_DIALOG_TALK_CHARACTERBASE_01",
    },
}

self._talkData["kDefaultRouteFailureTalk"] =
{
    SocialAnims     = {"chatsad", "idle"},
    bReverseAnims   = true,

    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_ROUTE_FAILURE",
}

self._talkData["KingPointLevel01"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_KINGPOINTS01",
}

self._talkData["KingPointLevel02"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_KINGPOINTS02",
}

self._talkData["KingPointLevel03"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_KINGPOINTS03",
}

self._talkData["KingPointLevel04"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_KINGPOINTS04",
}

self._talkData["KingPointLevel05"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_KINGPOINTS05",
}

self._talkData["RelationshipLevel01"] =
{
    SocialAnims     = {"chatangry", "chatsad", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP01",
}

self._talkData["RelationshipLevel02"] =
{
    SocialAnims     = {"chatgrumpy", "chatgrumpy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP02",
}

self._talkData["RelationshipLevel03"] =
{
    SocialAnims     = {"chatneutral", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP03",
}

self._talkData["RelationshipLevel04"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP04",
}

self._talkData["RelationshipLevel05"] =
{
    SocialAnims     = {"chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP05",
}

self._talkData["RelationshipLevel06"] =
{
    SocialAnims     = {"chathappy", "chathappy", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP06",
}

self._talkData["RelationshipLevel07"] =
{
    SocialAnims     = {"excited", "idle"},
    bReverseAnims   = true,
    DIALOG_MESSAGE  = "STRING_DIALOG_TASKTALK_CHARACTERBASE_RELATIONSHIP07",
}


end


System:RegisterGeneralPostLoadInit( CharacterBase.PostLoadInit, CharacterBase )
