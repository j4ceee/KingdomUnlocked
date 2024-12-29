local HedgehogLarge = Classes.HerdableScriptObjectBase:Inherit( "HedgehogLarge" )

HedgehogLarge._instanceVars =
{
    herdTypeSearchRefSpec = "HedgehogLarge",
    specifiedTaskToComplete = "NPC_Summer_HerdMascot",
}

function HedgehogLarge:RunnableCallback()

    self:SetMySpecificScale()

end

function HedgehogLarge:SetMySpecificScale()
    self:SetScale(1.5)
end



function HedgehogLarge:EnterTriggerCallback(go, trigger)

	-- call base class version to handle basic stuff
	Classes.HerdableScriptObjectBase.EnterTriggerCallback(self, go, trigger)
	
	-- then handle hedgehog specific stuff
	if self:TestAllHerded() then
        if Task:IsTaskRevealed( self.specifiedTaskToComplete ) then
            Task:CompleteTask( self.specifiedTaskToComplete, Task:GetNPCFromTaskId( self.specifiedTaskToComplete ) )
        end
	end
    
end

HedgehogLarge.idles =
{
    {   anim = "c-hedgehog-idle-breathe",    weight = 50,   },
    {   anim = "c-hedgehog-idle-sniff", weight = 10,   },
    {   anim = "c-hedgehog-idle-tailwag", weight = 10,   },
}

HedgehogLarge.interactionSet = System:CopyShallow( Classes.HerdableScriptObjectBase.interactionSet )

--=========================================--
-- HedgehogLarge:KillInteractions( bSnapToSafePositionOnly ) --
--=========================================--
function HedgehogLarge:KillInteractions( bSnapToSafePositionOnly )
    
    Classes.HerdableScriptObjectBase.KillInteractions(self, bSnapToSafePositionOnly)

    self:SetMySpecificScale()

end