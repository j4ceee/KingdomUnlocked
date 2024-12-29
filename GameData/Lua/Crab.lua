local Crab = Classes.HerdableScriptObjectBase:Inherit( "Crab" )

Crab._instanceVars =
{
    herdTypeSearchRefSpec = "Crab",
    appearAnim            = "c-crab-appear", -- first idle animation.
    specifiedTaskToComplete = "NPC_DJCandy_AttackOfTheCrabs",
}

function Crab:EnterTriggerCallback(go, trigger)

	-- call base class version to handle basic stuff
	Classes.HerdableScriptObjectBase.EnterTriggerCallback(self, go, trigger)
    
    local world = self.containingWorld
	
	-- then handle Crab specific stuff
    if world == Universe:GetWorld("candy_01") then
        
        --stop the herdable object
        self:StopSteering()
        
        if self.behaviorAlarm then
            self.behaviorAlarm:Kill()
            self.behaviorAlarm = nil
        end
    
        if self.animJob ~= nil then
            self.animJob:Signal( BlockingResult.Canceled, 0 )
        end
        self.animJob = nil
        
        self.animJob = self:GetPlayAnimationJob("c-crab-disappear", 1)
        self.bHerded = true
        self.animJob:RegisterForJobCompletedCallback( self, self.Disappear )
        self.animJob:Execute(self)
        
        if self:TestAllHerded() then
        
            if Task:IsTaskRevealed( self.specifiedTaskToComplete ) then
                Task:CompleteTask( self.specifiedTaskToComplete, Task:GetNPCFromTaskId( self.specifiedTaskToComplete ) )
            end
        end
        
	end
    
end

Crab.idles =
{
--    {   anim = "c-smallCritter-idle-shakeFur",    weight = 20,   },
    {   anim = "c-crab-dance-01", weight = 10,   },
--    {   anim = "c-crab-idle-breathe", weight = 30,   },
    {   anim = "c-crab-idle-breathe", weight = 30,   },
    {   anim = "c-crab-idle-suprised", weight = 30,   },
}


--{   anim = "c-crab-appear", weight = 30,   },
--{   anim = "c-crab-disappear", weight = 30,   },

function Crab:Disappear()
    self:Destroy()
end

Crab.interactionSet = System:CopyShallow( Classes.HerdableScriptObjectBase.interactionSet )

Crab.interactionSet["Pet"] = nil
Crab.interactionSet["Feed"] = nil