local MiningRock = Classes.ScriptObjectBase:Inherit( "MiningRock" )

MiningRock._instanceVars =
{
	timerReplenishHotSpot = NIL,
	jobMining = NIL,
}

function MiningRock:Constructor()
	self.timerReplenishHotSpot = nil
	self.jobMining = nil
end

function MiningRock:Destructor()
end

function MiningRock:Run()
	self:TimerHotSpotReplenishStart()
	
	while true do
		self:WaitForNotify()
	end
end

--===========--
-- Callbacks --
--===========--
function MiningRock:TimerExpiredCallback( timerID )
	if ( timerID == self.timerReplenishHotSpot ) then
		self:HotSpotReplenish()
		self:TimerHotSpotReplenishStart()
	end
end

--=========--
-- Helpers --
--=========--
function MiningRock:TimerHotSpotReplenishStart()
	local time = self:GetAttribute( "Tuning_HotSpotReplenishInSeconds" )
	local variance = time * self:GetAttribute( "Tuning_HotSpotReplenishVariance" )
	local interval = 2*variance*math.random() - variance
	time = time + interval
	
	self.timerReplenishHotSpot = self:CreateTimer( Clock.Game, 0, 0, 0, time )
end

function MiningRock:HotSpotReplenish()
	local backlog = self:GetAttribute( "Saved_HotSpotBacklog" )
	
	if ( backlog < self:GetAttribute("Tuning_HotSpotBacklogMax") ) then
		self:SetAttribute( "Saved_HotSpotBacklog", backlog + 1 )
		
		if ( self.jobMining ~= nil ) and ( self.jobMining.isValid ) then
			self.jobMining:HotSpotGenerateCallback()
		end -- verify self.jobMining
	end
end

--=================--
-- Interaction Set --
--=================--
MiningRock.interactionSet =
{
	Mine     = {
	               name                 = "STRING_INTERACTION_MININGROCK_MINE",
	               interactionClassName = "MiningRock_Interaction_Mine",
	               icon = "uitexture-interaction-use",
	           },
	MineSkip = {
	               name                 = "Quick Mine",
	               interactionClassName = "Unlocked_I_Mine_Skip",
	               icon = "uitexture-interaction-use",
	           },
}

--==============--
-- Broker stuff --
--==============--
function MiningRock:GetBrokerTypeName()
	return "MiningRock"
end

function MiningRock:GetBrokerTypeDescription()
	local scriptersAPI = Classes.ScriptObjectBase:GetBrokerTypeDescription()
	
    scriptersAPI.Input = true
    	
	return scriptersAPI
end

--====================--
-- Accessor functions --
--====================--
function MiningRock:MiningStart( job )
	self:RegisterGesture( "GesturePick" )
	self.jobMining = job
end

function MiningRock:MiningStop()
	self:UnregisterGesture( "GesturePick" )
	self.jobMining = nil
	
	local job = Classes.Job_PlayAnimation:Spawn( self, "o2a-miningObject-stop", 1 )
	job:Execute(self)
end

function MiningRock:MiningQueryPick()
	local bEvent, fForce = self:QueryGesture( "GesturePick" )
	
	return bEvent, fForce
end

function MiningRock:GetRandomNode()
	local backlog = self:GetAttribute( "Saved_HotSpotBacklog" )
	
	if ( backlog > 0 ) then
		self:SetAttribute( "Saved_HotSpotBacklog", backlog - 1 )
		
		local nodePos = math.random()
		
		if ( nodePos < self:GetAttribute("Tuning_HotSpotDistForSuccess") ) then
			nodePos = self:GetAttribute("Tuning_HotSpotDistForSuccess")
		elseif ( nodePos > 1.0 - self:GetAttribute("Tuning_HotSpotDistForSuccess") ) then
			nodePos = 1.0 - self:GetAttribute("Tuning_HotSpotDistForSuccess")
		end -- check bounds
		
		return nodePos
	end -- verify backlog
	
	return nil
end
