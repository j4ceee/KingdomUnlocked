local Spider = Classes.HerdableScriptObjectBase:Inherit( "Spider" )

Spider._instanceVars =
{
    herdTypeSearchRefSpec = "spider",
    appearAnim            = "c-spider-appear", -- first idle animation.
    
    targetUpdateTimer   = NIL,
    
    currentTarget = NIL,
}

function Spider:EnterTriggerCallback(go, trigger)

	-- call base class version to handle basic stuff
	Classes.HerdableScriptObjectBase.EnterTriggerCallback(self, go, trigger)
    
    self:AnimatedDisappear()       
        
end

Spider.idles =
{
    {   anim = "c-spider-idle-breathe",     weight = 10,   },
    {   anim = "c-spider-idle-lookAround",  weight = 2,   },
}

function Spider:Disappear()
    self:Destroy()
end

function Spider:AnimatedDisappear()
    self:StopSteering()
    -- Stop Idles
	if self.animJob ~= nil then
		self.animJob:Signal( BlockingResult.Canceled, 0 )
	end
    
    self.animJob = self:GetPlayAnimationJob("c-spider-disappear", 1)
    self.animJob:RegisterForJobCompletedCallback( self, self.Disappear )
    self.animJob:Execute(self)
end

--===========================================
-- For NPC_Violet / NPC_Daniel picnic-panic
--===========================================

function Spider:StartTargetUpdateTimer()
    self.targetUpdateTimer = self:CreateTimer( Clock.Game, 0, 0, 0, 1 )
end

local PicnicPanicStateSpecDaniel =
{
    ROUTE = {   
                routeType = "position",
                x = 36,  z = 65,
                distance = 1.0,
                facingX = 35, facingZ = 67,
                locoOverrides =
                {
                    [0] = nil,
                    [1] = nil,
                    [2] = nil,
                    [3] = nil,
                    [4] = nil,
                    [5] = "a-run",
                    [6] = nil,
                    [7] = nil,
                    [8] = nil,
                },
            },
}

function Spider:TimerExpiredCallback( timerID )
    if timerID == self.targetUpdateTimer then
    
        local maxDistance = Luattrib:ReadAttribute( "herdables", "spider_cute_default", "FleeAwarenessDistance" )
        
        local player = Universe:GetPlayerGameObject()
        
        local playerDist = self:GetXZDist(player)
        local targetDist = self:GetXZDist(self.target)
        
        if playerDist < maxDistance then
            self:SetTarget(player)
            self:SetAttribute( "FleeAwarenessDistance", maxDistance )
            self:SetAttribute( "HerdingReverseHerdable", false )
            self.bReverse = false
            
            if self.currentTarget ~= player then
                if self.animJob ~= nil then
                    self.animJob:Signal( BlockingResult.Canceled, 0 )
                end
                self:StopSteering()
                self:StartFleeing()
            end


            self.currentTarget = player
        else
            self:SetTarget(self.target)
            self:SetAttribute( "FleeAwarenessDistance", targetDist+1 )
            self:SetAttribute( "HerdingReverseHerdable", true )
            self.bReverse = true
            
            if self.currentTarget ~= self.target then
                if self.animJob ~= nil then
                    self.animJob:Signal( BlockingResult.Canceled, 0 )
                end
                self:StopSteering()
                self:StartReverseSteering()
            end
            
            self.currentTarget = self.target
        end
            
        if targetDist < 3.0 then
            
            local daniel = self.target.containingWorld:FindGameObject("character", "cute_daniel")
            
            if daniel ~= nil then
                if self.target:GetXZDist(daniel) < 3.0 then
                    daniel:PushInteraction(daniel, "Idle", { stateSpec = PicnicPanicStateSpecDaniel } )
                end
            end

        end       
    
        self:StartTargetUpdateTimer()
    end    
end

function Spider:LoadCallback()
	self:StartTargetUpdateTimer()
end

Spider.interactionSet = System:CopyShallow( Classes.HerdableScriptObjectBase.interactionSet )
