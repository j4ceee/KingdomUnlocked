local Unlocked_J_Mining_Skip = Classes.Job_Mining:Inherit("Unlocked_J_Mining_Skip")


Unlocked_J_Mining_Skip.MiningStates =
{
	Start = 0,
	Search = 1,
	Pick = 2,
	Strike = 3,
	StrikeMax = 4,
	Stop = 98,
	Destroy = 99,
}

function Unlocked_J_Mining_Skip:Destructor()
	self:Cleanup()
end

function Unlocked_J_Mining_Skip:HotSpotGenerateCallback()
	-- Always set nodePos to current player position
	self.nodePos = self.player:GetPlayerPositionOnMotionPath()
	-- Force hotspot to be found
	self.bHotSpotFound = true
end

--============--
-- Actor Loop --
--============--
function Unlocked_J_Mining_Skip:ActorLoop( sim )
	if ( self.miningState == self.MiningStates["Start"] ) then
		self:ActorLoop_Start()
		
	elseif ( self.miningState == self.MiningStates["Search"] ) then
		self:ActorLoop_Search()
		
	elseif ( self.miningState == self.MiningStates["Pick"] ) then
		self:ActorLoop_Pick()
		
	elseif ( self.miningState == self.MiningStates["Strike"] ) then
		self:ActorLoop_Strike( true )
		
	elseif ( self.miningState == self.MiningStates["StrikeMax"] ) then
		-- self:ActorLoop_Strike( true )
		self:ActorLoop_Strike( true )
		
	elseif ( self.miningState == self.MiningStates["Stop"] ) then
		self:ActorLoop_Stop()
		
	end -- check self.miningState
end

function Unlocked_J_Mining_Skip:ActorLoop_Search()
	Yield()
	
	local bExitPressed = self.player:QueryButton( "mining_exit" )
	local bTapPressed = self.player:QueryButton( "mining_tap" ) or self.player:QueryButton( "mining_tap_touch" )
	local bStrikePressed = self.player:QueryButton( "mining_strike" ) or self.player:QueryButton( "mining_strike_touch" )
	
	-- get gesture
	local bGesture, fForce = self.rock:MiningQueryPick()
	
	if ( not self.bDisableExit ) and ( bExitPressed ) then
		-- exit always preempts anything else
		self.miningState = self.MiningStates["Stop"]
	elseif ( not self.bDisableTap ) and ( bTapPressed ) then
		self.miningState = self.MiningStates["Pick"]
	elseif ( not self.bDisableStrike ) and ( bStrikePressed ) then
		self.miningState = self.MiningStates["Strike"]
	elseif ( self.bClearedGestureQueue ) and ( bGesture ) then
		self.bClearedGestureQueue = false
		self:GestureEvaluate( fForce )
	else
		self.bClearedGestureQueue = true
	end -- check conditions for state change
end

function Unlocked_J_Mining_Skip:ActorLoop_Pick()
	self.player:AddRefUnderScriptControl()
	self.bUnderScriptControl = true
	
	if ( self.nodePos ~= nil ) then
		local playerPos = self.player:GetPlayerPositionOnMotionPath()
		local dist = math.abs( playerPos - self.nodePos )
		
		self:FXPlay( dist )
	else
		self:FXPlay( 1.0 )
	end -- verify self.nodePos
	
	if ( self.animJob ~= nil ) then
		self.animJob:Signal( BlockingResult.Canceled, 0 )
		self.animJob = nil
	end -- verify self.animJob
	
	self.animJob = self.player:GetPlayAnimationJob( "a2o-mining-loop-tap", 1, nil )
	if ( self.animJob ~= nil ) then
		self.animJob:Execute(self)
	end
	
	local jobSleep = Classes.Job_Sleep:Spawn( Clock.Sim, 0, 0, 0, self.rock:GetAttribute("Tuning_SimSecondsBetweenTaps") )
	if ( jobSleep ~= nil ) then
		jobSleep:Execute( self )
		jobSleep:BlockOn()
	end -- verify jobSleep
	
	if ( self.bUnderScriptControl ) then
		self.player:ReleaseUnderScriptControl()
		self.bUnderScriptControl = false
	end -- check self.bUnderScriptControl

	self.miningState = self.MiningStates["Search"]
end

function Unlocked_J_Mining_Skip:ActorLoop_Strike( bMax )
	bMax = bMax or false
	
	self.player:AddRefUnderScriptControl()
	self.bUnderScriptControl = true

	-- Always call Success() regardless of position
	self:Success( bMax )
	
	if ( self.bUnderScriptControl ) then
		self.player:ReleaseUnderScriptControl()
		self.bUnderScriptControl = false
	end -- check self.bUnderScriptControl

	-- Always return to Search state
	self.miningState = self.MiningStates["Search"]
end

--=========--
-- Helpers --
--=========--
function Unlocked_J_Mining_Skip:GestureEvaluate( fForce )
	-- Skip distance check and always allow strike
	if (fForce >= self.rock:GetAttribute("Tuning_GestureForceForStrikeMax")) then
		self.miningState = self.MiningStates["StrikeMax"]
	else
		self.miningState = self.MiningStates["Strike"]
	end
end

-- Success = strike
function Unlocked_J_Mining_Skip:Success( bMax )
	self.bLaskStrikeFailed = false

	-- Play strike animation
	local animName = "a2o-mining-loop-strikeMed"
	if ( bMax ) then
		animName = "a2o-mining-loop-strikeMax"
	end -- check bMax
	
	self.animJob = self.player:GetPlayAnimationJob( animName, 1, nil )
	if ( self.animJob ~= nil ) then
		self.animJob:Execute(self)
	end

	-- Create hot spot effect
	if ( self.fxID ~= nil ) then
		self.player:DestroyFX( self.fxID, FXTransition.Soft )
	end -- verify self.fxID
	
	self.fxID = self.player:CreateFX( "sim-mining-hotspot", FXPriority.SuperHigh, FXStart.Now, FXLifetime.Continuous, FXAttach.Rigid, 0 )

	-- Handle rewards
	local rewardWeights = self.rock:GetAttribute("Tuning_RewardWeights")
	local rewardTypes = self.rock:GetAttribute("Tuning_RewardTypes")
	
	-- need to remove all the scrolls and unlocks from the resource reward types.
	local unlocks = {}
	local scrolls = {}
	rewardTypes, unlocks, scrolls, rewardWeights = Common:ParseResourceAndWeightsListForUnlocksAndScrolls( rewardTypes, rewardWeights )

	-- Calculate reward
	local totalWeight = 0
	totalWeight, rewardWeights, rewardTypes = Classes.ResourceBase:CreateTableOfValidResourcesAndWeights( rewardWeights, rewardTypes )

	if totalWeight > 0 then
		local weightedRand = math.random( totalWeight )

		totalWeight = 0
		local winningIdx = #rewardWeights
		for i,v in pairs(rewardWeights) do
			totalWeight = totalWeight + v
			if ( weightedRand <= totalWeight ) then
				winningIdx = i
				break
			end -- check weightedRand <= weightTotal
		end -- for rewardWeights

		self.winningReward = rewardTypes[winningIdx]

		-- Get number of resources to spawn
		local numResources = ( bMax and self.rock:GetAttribute("Tuning_ResourcesPerStrikeMax", winningIdx) ) or self.rock:GetAttribute("Tuning_ResourcesPerStrikeMed", winningIdx)

		if self.winningReward then
			local resourceType = Luattrib:ReadAttribute(self.winningReward[1], self.winningReward[2], "ResourceType")
			if resourceType == Constants.ResourceTypes["QuestItem"] then
				local resourceMax = Luattrib:ReadAttribute(self.winningReward[1], self.winningReward[2], "TotalRemaining") or 0
				if resourceMax > 0 and resourceMax < numResources then
					numResources = resourceMax
				end
			end

			if numResources > 0 then
				local x, y, z, rotY = self.player:GetPositionRotation()
				local x, z = Common:GetRelativePosition( self.rock:GetAttribute("Tuning_RewardSpawnOffset"), 0, x, z, rotY )
				local y = y + self.rock:GetAttribute("Tuning_RewardSpawnHeight")
				local spawnJob = Classes.Job_PropellResource:Spawn( self.player, { x=x, y=y, z=z, rotY=rotY }, self.winningReward[1], self.winningReward[2], numResources, self.rock:GetAttribute("Tuning_RewardSpawnArc"), nil, { x=0, y=1, z=0 }, self.rock:GetAttribute("Tuning_RewardSpawnAngleMod"), { self.player } )
				spawnJob:ExecuteAsIs()
			end
		end
	end

	-- Short delay between strikes
	local jobSleep = Classes.Job_Sleep:Spawn( Clock.Sim, 0, 0, 0, self.rock:GetAttribute("Tuning_SimSecondsBetweenSuccessfulStrikes") )
	if ( jobSleep ~= nil ) then
		jobSleep:Execute( self )
		jobSleep:BlockOn()
	end -- verify jobSleep
end

function Unlocked_J_Mining_Skip:TimerExpiredCallback( timerID )
	if ( timerID == self.timerStrike ) then
		self.timerStrike = nil
		-- Update nodePos to current player position
		self.nodePos = self.player:GetPlayerPositionOnMotionPath()
		-- Keep hotspot active
		self.bHotSpotFound = true
	end -- check timerID
end

function Unlocked_J_Mining_Skip:FXPlay(_)
	-- Always use closest/hottest effect (index 1)
	local fxLvl = 1
	self.bHotSpotFound = true
	
	if ( self.fxID ~= nil ) then
		self.player:DestroyFX( self.fxID, FXTransition.Soft )
	end -- verify self.fxID
	
	self.fxID = self.player:CreateFX( Unlocked_J_Mining_Skip.TapFX[fxLvl], FXPriority.SuperHigh, FXStart.Now, FXLifetime.Continuous, FXAttach.Rigid, 0 )
end
