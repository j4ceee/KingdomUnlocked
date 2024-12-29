local Tree = Classes.ScriptObjectBase:Inherit( "Tree" )

Tree._instanceVars = 
{
	runEvents = NIL,
	
    iShakeCount = 0,
	bShaking = false,
	fShakeBlend = 0,
	bGrabbed = false,
	
	timerGrowth = NIL,
	timerFruitDrop = NIL,
	timerWater = NIL,
	
	jobAnimDynamic = NIL,
	jobAnimStatic = NIL,
	jobChop = NIL,
	
	bChopForceStop = false,
	
	fScaleCurrent = 1.0,
	fScaleIncrement = 0.0,
	fScaleMaximum = 1.0,
	
	fxWater = NIL,
	fxTransition = NIL,
	fxLeaves = NIL,
	
	shakeSoundID = NIL,
	
	bGrowthTransitionPending = false,
}

Tree._animations =
{
	PLANT           = { sim = "a2o-gardening-plant" },
	WATER           = { sim = "a2o-gardening-water" },
	STOMP           = { sim = "a2o-gardening-tree-stomp", obj = "o2a-gardening-tree-stomp" },
	SHAKEDYNAMIC    = { sim = "a-react-clapHappy", obj = "o-treeMature-react-harvest" },
	SHAKESTATIC     = {                                   obj = "o-treeMature-react-static" },
	CHOPSTART       = { sim = "a2o-gardening-chop-start" },
	CHOPSTOP        = { sim = "a2o-gardening-chop-stop" },
	CHOPBREATHE     = { sim = "a2o-gardening-chop-breathe" },
	CHOPSWING       = { sim = "a2o-gardening-chop-swing", obj = "o2a-gardening-chop-swing" },
	CHOPSTOPSUCCEED = { sim = "a2o-gardening-chop-stop-succeed" },
}

Tree.GrowthStages =
{
	TREE_GROWTH_STAGE_EMPTY   = 1,
	TREE_GROWTH_STAGE_SPROUT  = 2,
	TREE_GROWTH_STAGE_SAPLING = 3,
	TREE_GROWTH_STAGE_MATURE  = 4,
	TREE_GROWTH_STAGE_DYING   = 5,
	TREE_GROWTH_STAGE_STUMP   = 6,
}

Tree.FXInfo =
{
	leaves = "Obj-tree-shake-leaves-effects",
	water = "Lev-tree-water-feedback",
	fruitAttach = "magic_explosion_large",
	woodAppear  = "magic_explosion_small",
}

Tree.TransitionFXInfo =
{
	[Tree.GrowthStages.TREE_GROWTH_STAGE_SPROUT] = "Obj-treeGrow-effects-sprout",
	[Tree.GrowthStages.TREE_GROWTH_STAGE_SAPLING] = "Obj-treeGrow-effects-sapling",
	[Tree.GrowthStages.TREE_GROWTH_STAGE_MATURE] = "Obj-treeGrow-effects-mature",
	[Tree.GrowthStages.TREE_GROWTH_STAGE_DYING] = "Obj-treeGrow-effects-dying",
	[Tree.GrowthStages.TREE_GROWTH_STAGE_STUMP] = "Obj-treeGrow-effects-dying",
}

Tree.TransitionSimSecondsInfo =
{
	[Tree.GrowthStages.TREE_GROWTH_STAGE_SPROUT] = 36,
	[Tree.GrowthStages.TREE_GROWTH_STAGE_SAPLING] = 48,
	[Tree.GrowthStages.TREE_GROWTH_STAGE_MATURE] = 60,
	[Tree.GrowthStages.TREE_GROWTH_STAGE_DYING] = 60,
	[Tree.GrowthStages.TREE_GROWTH_STAGE_STUMP] = 60,
}

Tree.SoundInfo =
{
	shake = "tree_shake_loop",
	fruitDrop = "ui_essence_falling",
	fruitSpawn = "",
}

--=========--
-- Brokers --
--=========--
function Tree:GetBrokerTypeName()
	return "Tree"
end

function Tree:GetBrokerTypeDescription()
	local scriptersAPI = Classes.ScriptObjectBase.GetBrokerTypeDescription(self)
	scriptersAPI.FX = true
	scriptersAPI.Input = true
	scriptersAPI.Slot = true
	scriptersAPI.Sound = true
	scriptersAPI.Spawn = true
	return scriptersAPI
end


--====================--
-- Accessor Functions --
--====================--
function Tree:Plant( treeCollectionKey )
	self:RunEventAdd( self.PlantProcess, {treeCollectionKey} )
end

function Tree:Empty()
	self:RunEventAdd( self.EmptyProcess )
end

function Tree:FruitPicked()
	self:TimerFruitDropKill()
	self:TimerGrowthStart()
end

function Tree:Water()
	self:RunEventAdd( self.WaterProcess )
end

--=====================--
-- Interface Functions --
--=====================--
function Tree:Constructor()
	EA:LogI("Tree", "Tree:Constructor test value = ", self:GetAttribute("SavedStage"))
	
	self.runEvents = {}
	self.fxLeaves = {}
end

function Tree:Destructor()
end

function Tree:Run()
	self:RunBegin()
	
	while true do
		self:RunEventsProcess()
		
		if ( self.bGrabbed == true ) then
			Yield()
		else
			self:WaitForNotify()
		end -- grabbed?
	end -- while loop
end

--===========--
-- Callbacks --
--===========--
function Tree:TimerExpiredCallback( timerID )
	if ( timerID == self.timerGrowth ) then
		self.timerGrowth = nil
		
		if ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_EMPTY"] ) then
--			self:RunEventAdd( self.SpawnRandom )
		
		elseif ( self:GetAttribute("SavedStage") < self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) then
			self:RunEventAdd( self.GrowthStageAdvance )
			self:TimerGrowthStart()
		
		elseif ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) or 
		       ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
			self:RunEventAdd( self.FruitSpawn )
			self:TimerGrowthStart()
			
		end -- check self:GetAttribute("SavedStage")
		
	elseif ( timerID == self.timerFruitDrop ) then
		self.timerFruitDrop = nil
		self:RunEventAdd( self.FruitDrop )
		self:TimerGrowthStart()
		
	elseif ( timerID == self.timerWater ) then
		self.timerWater = nil
		
		if ( self.fxWater ~= nil ) then
			self:DestroyFX( self.fxWater, FXTransition.Soft )
			self.fxWater = nil
		end -- verify self.fxWater
		
	end -- check timerID
end


function Tree:SaveCallback(refSpec)

	-- Write to the collection

end

function Tree:ResetCallback()
end

function Tree:TouchCallback()
    if ( self:CanGrab() == true ) then
		return TouchType.Interactable  -- DPD can grab me
	end
	
    return TouchType.NoTouch
end

function Tree:SelectCallback()
	if ( self:CanGrab() == true ) then
		self:RunEventAdd( self.ShakeLoop )
		self:Notify()
		return true -- accepted grab
	end
	
	return false
end

function Tree:LostGrabCallback()
	self:RunEventAdd( self.ShakeStop )
end

--===================--
-- Interface Helpers --
--===================--
function Tree:RunBegin()
	self:TimerGrowthStart()
	
--	self:ScaleRestore()
end

function Tree:CanGrab()
	if ( self.jobChop ~= nil ) then
		return false
	end -- verify self.jobChop
	 
	if ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) or 
	   ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		return true
	end -- verify growth stage
	
	return false
end

--============--
-- Run Events --
--============--
function Tree:RunEventAdd( func, params )
	self.runEvents[ #self.runEvents + 1 ] = { func = func, params = params }
	self:Notify()
end

function Tree:RunEventsProcess()
	EA:ProfileEnterBlock("Lua__Tree_RunEventsProcess")
	while ( #self.runEvents > 0 ) do
		local thisRunEvent = table.remove( self.runEvents, 1 )
		
		if ( thisRunEvent.params ~= nil ) then
			thisRunEvent.func( self, unpack(thisRunEvent.params) )
		else
			thisRunEvent.func( self )
		end -- verify thisRunEvent.params
	end -- while loop
	EA:ProfileLeaveBlock("Lua__Tree_RunEventsProcess", self.mType)
end

--========--
-- Timers --
--========--
function Tree:TimerCreateVariance( interval, intervalVariance )
	intervalVariance = intervalVariance or 0
	local variance = interval * intervalVariance
	local rand = math.random()
	interval = interval + rand*(variance*2) - variance
	
	local timer = self:CreateTimer(Clock.Sim, 0, 0, interval, 0)
	return timer
end

function Tree:TimerGrowthStart()
	if ( self.timerGrowth == nil ) then
		local treeType = self:GetAttribute( "SavedTreeType" )
		
		if ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_EMPTY"] ) then
--			self.timerGrowth = self:TimerCreateVariance( Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_kEmptyRandomSpawnTimerMinSimMinutes"),  
--			                                             Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_kEmptyRandomSpawnTimerVariance") )
			
		elseif ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_SPROUT"] ) then
			self.timerGrowth = self:TimerCreateVariance( Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_GROWTH_STAGE_SIM_MINUTES_SPROUT"),  
			                                             Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_GROWTH_STAGE_VARIANCE_SPROUT") )
			
		elseif ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_SAPLING"] ) then
			self.timerGrowth = self:TimerCreateVariance( Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_GROWTH_STAGE_SIM_MINUTES_SAPLING"), 
			                                             Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_GROWTH_STAGE_VARIANCE_SAPLING") )
			
		elseif ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) or 
		       ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
			local timerLength = Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SPAWN_TIME_SIM_MINUTES")
			if ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
				timerLength = timerLength * Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SPAWN_TIME_MULTIPLIER_DYING")
			end
			if ( self.timerWater ~= nil ) then
				timerLength = timerLength * Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SPAWN_TIME_MULTIPLIER_WATER")
			end
			
			self.timerGrowth = self:TimerCreateVariance( timerLength, Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SPAWN_TIME_VARIANCE") )
			
		end -- check self:GetAttribute("SavedStage")
	end -- no growth timer?
end

function Tree:TimerFruitDropStart()
	self:TimerGrowthKill()
	local treeType = self:GetAttribute( "SavedTreeType" )
	self.timerFruitDrop = self:TimerCreateVariance( Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_AUTO_DROP_SIM_MINUTES"),  
	                                                Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_AUTO_DROP_VARIANCE") )
end

function Tree:TimerWaterStart()
	self:TimerWaterKill()
	local treeType = self:GetAttribute( "SavedTreeType" )
	self.timerWater = self:CreateTimer( Clock.Sim, 0, 0, Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_WATER_TIME_SIM_MINUTES"), 0 )
end

function Tree:TimerGrowthKill()
	if ( self.timerGrowth ~= nil ) then
		self.timerGrowth:Kill()
		self.timerGrowth = nil
	end
end

function Tree:TimerFruitDropKill()
	if ( self.timerFruitDrop ~= nil ) then
		self.timerFruitDrop:Kill()
		self.timerFruitDrop = nil
	end
end
	
function Tree:TimerWaterKill()
	if ( self.timerWater ~= nil ) then
		self.timerWater:Kill()
		self.timerWater = nil
	end -- verify self.timerWater
end

--==============--
-- Growth Scale --
--==============--
function Tree:ScaleSetByState( previous )
	if ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_SPROUT"] ) then
	elseif ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_SAPLING"] ) then
	elseif ( self:GetAttribute("SavedStage") == self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) and ( previous == self.GrowthStages["TREE_GROWTH_STAGE_SAPLING"] ) then
	elseif ( self:GetAttribute("SavedStage") >= self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
	end
end

function Tree:ScaleStore()
	self.fScaleCurrent, self.fScaleMaximum, self.fScaleIncrement = CodeGetObjectScale(self)
end

function Tree:ScaleRestore()
	CodeSetObjectScale( self, "self", self.fScaleCurrent, self.fScaleMaximum, self.fScaleIncrement, 0 )
end

function Tree:ScaleReset()
	CodeSetObjectScale( self, "self", 1.0, 1.0, 0.0, 0 )
	self.fScaleCurrent = 1.0
	self.fScaleMaximum = 1.0
	self.fScaleIncrement = 0.0
end

function Tree:ScaleFreeze()
	local currentScale = CodeGetObjectScale(self)
	CodeSetObjectScale( self, "self", currentScale, currentScale, 0.0, 0 )
end

--=======--
-- Shake --
--=======--
function Tree:ShakeStart()
	self.bGrabbed = true
	self.iShakeCount = 0
    self:RegisterGesture("GestureShake") -- register gesture from shake setting
	
	self.jobAnimDynamic = nil
	self.jobAnimStatic = nil
	
	self.jobAnimStatic = self:GetPlayAnimationJob( self._animations.SHAKESTATIC.obj, 0 )
	self.jobAnimStatic:SetTrackID(1) -- 2nd track
	self.jobAnimStatic:Execute( self )
end

function Tree:ShakeStop()
	if ( self.bGrabbed ) then
		self:SetLoopCount( 1 ) -- finish current animation then stop
		self.jobAnimDynamic = nil
		
		if ( self.jobAnimStatic ~= nil ) and ( self.jobAnimStatic.isValid ) then
			self.jobAnimStatic:Stop( false )
			self.jobAnimStatic = nil
		end -- verify self.jobAnimStatic
		
		if ( self.shakeSoundID ~= nil ) then
			self:StopSound( self.shakeSoundID )
			self.shakeSoundID = nil
		end -- verify self.shakeSoundID
		
	    self:UnregisterGesture("GestureShake")
		self.bGrabbed = false
        
        -- See devTrack fro bug description
        local bug1375FixJob = self:GetPlayAnimationJob( self._animations.SHAKESTATIC.obj, 1 )
        bug1375FixJob:Execute(self)
        
	end -- check self.bGrabbed
end

function Tree:ShakeLoop()
	local fShakeBlend = 0.7
	
	self.bShaking = true
	
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	if ( self.jobAnimDynamic == nil ) or ( not self.jobAnimDynamic.isValid ) then
		self.jobAnimDynamic = self:GetPlayAnimationJob( self._animations.SHAKEDYNAMIC.obj, 2 )
		
		if ( self.jobAnimDynamic ~= nil ) then
			self.shakeSoundID = self:PlaySound( self.SoundInfo["shake"] )
			self.jobAnimDynamic:RegisterForJobCompletedCallback( self, self.ShakeAnimDynamicEndCallback )
			self.jobAnimDynamic:Execute( self )
			self.fShakeBlend = Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_ShakeBlendInitial")
		end -- verify self.jobAnimDynamic
	else
		self:SetLoopCount( 2 )
		
		if ( self.fShakeBlend < fShakeBlend ) then
			self.fShakeBlend = self.fShakeBlend + Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_ShakeBlendIncForHarderShake")
			if ( self.fShakeBlend > 1.0 ) then
				self.fShakeBlend = 1.0
			end -- max bounds
		else
			self.fShakeBlend = self.fShakeBlend - Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_ShakeBlendDecForLighterShake")
			-- until jason gets back setting it so that the tree shake never goes below 10% blending as a result of slower shaking.
			if ( self.fShakeBlend < .1 ) then
				self.fShakeBlend = .1
			end -- max bounds
		end -- check self.fShakeBlend < fShakeBlend
	end -- check if self.jobAnimDynamic does not exist
	
	self:SetBlendValue( self.fShakeBlend )
	
	if ( math.mod(self.iShakeCount, Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_LeavesFXNumShakes")) == 0 ) then
		if ( #self.fxLeaves > 4 ) then
			local fxToDestroy = table.remove( self.fxLeaves, 1 )
			self:DestroyFX( fxToDestroy, FXTransition.Soft )
		end -- check self.fxLeaves has too many entries
		
		self.fxLeaves[#self.fxLeaves + 1] = self:CreateFX( self.FXInfo["leaves"], FXPriority.Low, FXStart.Now, FXLifetime.Continuous, FXAttach.Rigid )
	end -- check self.iShakeCount == 0
	
	self.iShakeCount = self.iShakeCount + 1
	self:RunEventAdd( self.FruitDropAll )
end

function Tree:ShakeAnimDynamicEndCallback( job )
	 local result, reason = job:GetReturnValues()
	
	if ( self.shakeSoundID ~= nil ) then
		self:StopSound( self.shakeSoundID )
		self.shakeSoundID = nil
	end -- verify self.shakeSoundID
end

--==============--
-- Growth Stage --
--==============--
function Tree:SetGraphic( bBlock )
	local i = self:GetAttribute( "SavedStage" )
	
	if ( self.fxTransition ~= nil ) then
		self:DestroyFX( self.fxTransition, FXTransition.Hard )
		self.fxTransition = nil
	end -- verify self.fxWater
	
	if ( self.TransitionFXInfo[i] ~= nil ) then
		self.fxTransition = self:CreateFX( self.TransitionFXInfo[i], FXPriority.High, FXStart.Now, FXLifetime.Continuous, FXAttach.Rigid )
	end -- verify self.TransitionFXInfo[i]
	
	if ( self.TransitionSimSecondsInfo[i] ~= nil ) and ( self.TransitionSimSecondsInfo[i] > 0 ) then
		-- yield for FX to start
		local jobSleep = Classes.Job_Sleep:Spawn( Clock.Sim, 0, 0, 0, self.TransitionSimSecondsInfo[i] )
		if ( jobSleep ~= nil ) then
			jobSleep:Execute( self )
			jobSleep:BlockOn()
		end -- verify jobSleep
	end -- verify not empty
	
	local treeType = self:GetAttribute( "SavedTreeType" )
	local modelInfo = Luattrib:ReadAttribute( treeType[1], treeType[2], "ModelByStage" )
	local rigInfo = Luattrib:ReadAttribute( treeType[1], treeType[2], "RigByStage" )
	
	self:ReplaceModelAndRig( bBlock, modelInfo[i], rigInfo[i] )
end

function Tree:GrowthStageAdvance()
	if ( self:GetAttribute("SavedStage") >= self.GrowthStages["TREE_GROWTH_STAGE_STUMP"] ) then
		return
	end
	
	self:GrowthStageSet( self:GetAttribute("SavedStage") + 1 )
end

function Tree:GrowthStageSet( newStage )
	self:TimerGrowthKill()
	
	self.bGrowthTransitionPending = true
	
	if ( newStage == self.GrowthStages["TREE_GROWTH_STAGE_STUMP"] ) and
	   ( self:GetAttribute("SavedStage") <= self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) and
	   ( self:GetAttribute("SavedStage") >= self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) then
		self:FruitDropAll()
		self:PlaySound("ui_tree_health_decay")
		self:SetForceDisableFade(true)
	else
		self:SetForceDisableFade(false)
	end -- drop all fruit if transitioning from Mature/Dying to Stump
	
	-- sounds for tree growth stages
	if ( self:GetAttribute("SavedStage") >= self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) and
		   ( newStage < self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		self:PlaySound("ui_tree_health_restore")
	end
	
	self:SetAttribute("SavedStage", newStage)
	
	self:SetGraphic( true )
	
	self.bGrowthTransitionPending = false
	
	self:TimerGrowthStart()
end

function Tree:PlantProcess( treeCollectionKey )
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	self:SetAttribute( "SavedStage", self.GrowthStages["TREE_GROWTH_STAGE_EMPTY"] )
	self:SetAttribute( "SavedTreeType", { self.classKey, treeCollectionKey } )
	self:SetAttribute( "SavedHealth", Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_INIT") )
	
	self:GrowthStageAdvance()
end

function Tree:EmptyProcess()
	self:TimerGrowthKill()
	
	self:SetAttribute("SavedStage", self.GrowthStages["TREE_GROWTH_STAGE_EMPTY"])
	
--	self:ScaleReset()
	self:SetGraphic( true )
	
	self:TimerGrowthStart()
end

function Tree:WaterProcess()
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	if ( self:GetAttribute("SavedStage") >= self.GrowthStages["TREE_GROWTH_STAGE_SPROUT"] ) and ( self:GetAttribute("SavedStage") <= self.GrowthStages["TREE_GROWTH_STAGE_SAPLING"] ) then
		if ( self.timerGrowth ~= nil ) then
			self.timerGrowth:AddTime(0, 0, -1 * Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_WATER_GROWTH_ACCEL_SIM_MINUTES"), 0 )
		end -- verify timerGrowth
	elseif ( self:GetAttribute("SavedStage") >= self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) and ( self:GetAttribute("SavedStage") <= self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		if ( self.timerGrowth ~= nil ) then
			self.timerGrowth:Trigger()
		end -- verify timerGrowth
	end -- check self:GetAttribute("SavedStage")
	
	self:HealthDelta( Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_WATER_HEALTH_INC") )
	
	if ( self.fxWater == nil ) then
		self.fxWater = self:CreateFX( self.FXInfo["water"], FXPriority.High, FXStart.Now, FXLifetime.Continuous, FXAttach.Rigid )
	end -- verify self.fxWater
	
	self:TimerWaterStart()
end

--=======--
-- Fruit --
--=======--
function Tree:FruitSpawn()
	EA:ProfileEnterBlock("Lua__Tree_FruitSpawn")
	if ( self:GetAttribute("SavedStage") < self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) or ( self:GetAttribute("SavedStage") > self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		return
	end -- verify valid self:GetAttribute("SavedStage")
	
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	local availableSlots = {}
	local availableSlots = self:GetAvailableSlotsTable()
				
	if ( #availableSlots > 0 ) then
		local iSlot = availableSlots[ math.random( #availableSlots ) ]
		self:TimerGrowthKill()
		local fruitWeights = Luattrib:ReadAttribute( treeType[1], treeType[2], "Tuning_FruitWeights" )
		local fruitTypes   = Luattrib:ReadAttribute( treeType[1], treeType[2], "Tuning_FruitTypes" )
		local weightTotal = 0

		weightTotal, fruitWeights, fruitTypes = Classes.ResourceBase:CreateTableOfValidResourcesAndWeights( fruitWeights, fruitTypes )
		
		local weightedRand = math.random( weightTotal )
		
		weightTotal = 0
		local winningIdx = #fruitWeights
		for i,v in ipairs(fruitWeights) do
			weightTotal = weightTotal + v
			if ( weightedRand <= weightTotal ) then
				winningIdx = i
				break
			end -- check weightedRand <= weightTotal
		end -- for fruitWeights
		
		local fruitToSpawn = fruitTypes[winningIdx]
		
		-- this is a bit hacky but quest items and unlocks can spawn other places than trees and need magnetize and auto pickup on by default.
		-- so override them on spawn when they are put in a tree.
		local override = nil
		local resourceType = Luattrib:ReadAttribute( fruitToSpawn[1], fruitToSpawn[2], "ResourceType" )
		if resourceType == Constants.ResourceTypes["QuestItem"] or resourceType == Constants.ResourceTypes["Unlockable"] then
			override = {}
			override.Tuning_MAGNETIZE = false
			override.Tuning_AUTO_PICKUP = false
		end
		
		Common:SpawnQuick(fruitToSpawn[1], fruitToSpawn[2], self, 0, 0, 0, 0, override, AddChildOption.RetainRelative, Slot.Containment, iSlot, nil)
--		self:PlaySound( self.SoundInfo["fruitSpawn"] )
		
		self:TimerGrowthStart()
	else
		self:TimerGrowthKill()
		
        --MLAWSON 040908 - Removed auto-dropping of fruits
        --self:TimerFruitDropStart()
        
	end -- verify availableSlots has entries

	EA:ProfileLeaveBlock("Lua__Tree_FruitSpawn", self.mType)
end

function Tree:FruitDrop()
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	local allContainedFruits = {}
	
	for i=0,(Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SLOT_NUM") - 1) do
		local containedFruit = self:GetGameObjectInSlot( Slot.Containment, i )
		
		if ( containedFruit ~= nil ) and ( containedFruit.isValid ) then
			allContainedFruits[ #allContainedFruits + 1 ] = containedFruit
		end -- check if slot is empty
	end
	
	if ( #allContainedFruits > 0 ) then
		local fruitToDrop = allContainedFruits[ math.random(#allContainedFruits) ]
		
		if ( fruitToDrop ~= nil ) and ( fruitToDrop.isValid ) then
			fruitToDrop:ReleaseFromSlot()
		end -- check if slot is empty
	end -- verify allContainedFruits has entries
	
	self:TimerGrowthStart()
end

function Tree:FruitDropAll()
	if ( self:GetAttribute("SavedStage") < self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) then
		return
	end -- verify valid self:GetAttribute("SavedStage")
	
	if ( self:GetAttribute("SavedStage") > self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		return
	end -- verify valid self:GetAttribute("SavedStage")
	
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	for i=0,(Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SLOT_NUM") - 1) do
		local containedFruit = self:GetGameObjectInSlot( Slot.Containment, i )
		
		if ( containedFruit ~= nil ) and ( containedFruit.isValid ) then
			containedFruit:ReleaseFromSlot()
			
			-- stagger fruit for SFX
			local jobSleep = Classes.Job_Sleep:Spawn( Clock.Sim, 0, 0, 0, math.random(3,20) )
			if ( jobSleep ~= nil ) then
				jobSleep:Execute( self )
				jobSleep:BlockOn()
			end -- verify jobSleep
		end -- check if slot is empty
	end

	self:TimerGrowthStart()
end

function Tree:FruitCount()
	local count = 0;
	local treeType = self:GetAttribute( "SavedTreeType" )
	for i=0,(Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_FRUIT_SLOT_NUM") - 1) do
		local containedFruit = self:GetGameObjectInSlot( Slot.Containment, i )
		if ( containedFruit ~= nil ) and ( containedFruit.isValid ) then
			count = count + 1;
		end
	end
	
	return count;
end

--========--
-- Health --
--========--
function Tree:HealthDelta( amt )
	local prevHealth = self:GetAttribute( "SavedHealth" )
	self:SetAttribute( "SavedHealth", prevHealth + amt )
	
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	if ( self:GetAttribute( "SavedHealth" ) > Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_MAX") ) then
		self:SetAttribute( "SavedHealth", Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_MAX") )
	end -- check max
	
	if ( self:GetAttribute( "SavedHealth" ) <= 0 ) then
		self:RunEventAdd( self.GrowthStageAdvance )
	elseif ( prevHealth > Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_DYING") ) and ( self:GetAttribute( "SavedHealth" ) <= Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_DYING") ) then
		self:RunEventAdd( self.GrowthStageAdvance )
	elseif ( prevHealth <= Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_DYING") ) and ( self:GetAttribute( "SavedHealth" ) > Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_HEALTH_DYING") ) then
		self:RunEventAdd( self.GrowthStageSet, { self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] } )
	end -- check transition states
end

--======--
-- Chop --
--======--
function Tree:ChopStart( job )
	if ( not self:ChopIsAvailable(job) ) then
		return false
	end -- check if should stop
	
	self.jobChop = job
	self.bChopForceStop = false
	
	self:RegisterGesture( "GestureChop" )
	
	-- self:SetCameraFadeDistance(1)   -- small fade distance for no fading in interaction
	
	return true
end

function Tree:ChopStop()
	self:UnregisterGesture( "GestureChop" )
	self.bChopForceStop = false
	self.jobChop = nil

   	local distance = self:GetAttribute("Fadable")
	-- self:SetCameraFadeDistance(distance)    -- put back fade distance
end

function Tree:ChopOnSwing()
	local treeType = self:GetAttribute( "SavedTreeType" )
	
	local woodWeights = Luattrib:ReadAttribute( treeType[1], treeType[2], "Tuning_WoodWeights" )
	local woodTypes = Luattrib:ReadAttribute( treeType[1], treeType[2], "Tuning_WoodTypes" )
	local weightTotal = 0
	
	weightTotal, woodWeights, woodTypes = Classes.ResourceBase:CreateTableOfValidResourcesAndWeights( woodWeights, woodTypes )
	
	local weightedRand = math.random( weightTotal )
	
	weightTotal = 0
	local winningIdx = #woodWeights
	for i,v in pairs(woodWeights) do
		weightTotal = weightTotal + v
		if ( weightedRand <= weightTotal ) then
			winningIdx = i
			break
		end -- check weightedRand <= weightTotal
	end -- for woodWeights
	
	local woodToSpawn = woodTypes[winningIdx]
	
	local resourceMax = 0
	
	-- if this is an exhaustable resource the make sure not to spawn too many
	local resourceType =  Luattrib:ReadAttribute(woodToSpawn[1], woodToSpawn[2], "ResourceType" )
	if resourceType == Constants.ResourceTypes["QuestItem"] then 
		resourceMax = Luattrib:ReadAttribute( woodToSpawn, woodToSpawn, "TotalRemaining" )
	elseif resourceType == Constants.ResourceTypes["Unlockable"] then
		resourceMax = 1 --we don't want to spawn more than one version of an unlock at a time.
	end
	
	local numResources = Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_CHOP_WOOD_PER_SWING")
	
	if resourceMax ~= 0 and resourceMax < numResources then
		numResources = resourceMax
	end
	
	local player = Universe:GetPlayerGameObject()
	local x, y, z, rotY = player:GetPositionRotation()
	local x, z = Common:GetRelativePosition( -.8, 1, x, z, rotY )
	local spawnJob = Classes.Job_PropellResource:Spawn( player, { x=x, y=y+.5, z=z, rotY=rotY }, woodToSpawn[1], woodToSpawn[2], numResources, 45, nil, { x=0, y=1, z=0 }, -100, { player, self } )
	spawnJob:ExecuteAsIs()
	
	self:HealthDelta( Luattrib:ReadAttribute(treeType[1], treeType[2], "Tuning_CHOP_HEALTH_DELTA_PER_SWING") )
end

function Tree:ChopQueryGesture()
	local bEvent, fForce = self:QueryGesture( "GestureChop" )
	return bEvent, fForce
end

function Tree:ChopIsAvailable( job )
	if ( self:GetAttribute("SavedStage") < self.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) then
		return false
	end -- verify valid self:GetAttribute("SavedStage")
	
	if ( self:GetAttribute("SavedStage") > self.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		return false
	end -- verify valid self:GetAttribute("SavedStage")
	
	if ( self.jobChop ~= nil ) and ( self.jobChop ~= job ) then
		return false
	end -- verify self.jobChop
	
	if ( self.bGrabbed ) then
		return false
	end -- check self.bGrabbed
	
	if ( self.bChopForceStop ) then
		return false
	end -- check self.bChopForceStop
	
	return true
end

--=================--
-- Interaction Set --
--=================--
Tree.interactionSet =
{
	Chop  = { name                    = "STRING_INTERACTION_TREE_CHOP",
	          interactionClassName    = "Tree_Interaction_Chop",
	          metaState               = MetaStates.TreeChop,
	          icon = "uitexture-interaction-chop",
	        },
	Plant = { name                    = "STRING_INTERACTION_TREE_PLANT",
	          interactionClassName    = "Tree_Interaction_Plant",
	          icon = "uitexture-interaction-plant",
	        },
	Stomp = { name                    = "STRING_INTERACTION_TREE_STOMP",
	          interactionClassName    = "Tree_Interaction_Stomp",
	          icon = "uitexture-interaction-stomp",
	        },
	Water = { name                    = "STRING_INTERACTION_TREE_WATER",
	          interactionClassName    = "Tree_Interaction_Water",
	          icon = "uitexture-interaction-water",
	        },
	Harvest = { name                  = "STRING_INTERACTION_TREE_HARVEST",
		interactionClassName   		  = "Tree_Interaction_Harvest",
		icon = "uitexture-interaction-harvest",
		menu_priority = 0
	},
	HarvestAll = { name                  = "Harvest All",
		interactionClassName   		  = "Unlocked_I_Tree_PickAll",
		icon = "uitexture-interaction-harvest",
		menu_priority = 1
	},
}
