local PercyPig = Classes.HerdableScriptObjectBase:Inherit( "PercyPig" )

PercyPig._instanceVars =
{
    herdTypeSearchRefSpec = "pig",
    critterPet			  = "c2a-pig-pet",
    critterFeed			  = "c2a-pig-feed",
}
--[[
function PercyPig:EnterTriggerCallback(go, trigger)

	-- call base class version to handle basic stuff
	Classes.HerdableScriptObjectBase.EnterTriggerCallback(self, go, trigger)
	
	-- then handle pig specific stuff
	if self:TestAllHerded() then
		Task:CompleteTask( "NPC_Renee_ExplainPig", Task:GetNPCFromTaskId("NPC_Renee_ExplainPig" ) )
	end
    
end
--]]
function PercyPig:RunnableCallback()

    self:SetMySpecificScale()

end

function PercyPig:SetMySpecificScale()
    self:SetScale(2.0)
end


PercyPig.idles =
{
    {   anim = "c-pig-idle-oink",    weight = 50,   },
    {   anim = "c-pig-idle-rollAround", weight = 10,   },
    {   anim = "c-pig-idle-rootAround", weight = 10,   },
    {   anim = "c-pig-idle-shakeFur", weight = 10,   },
}

PercyPig.interactionSet = System:CopyShallow( Classes.HerdableScriptObjectBase.interactionSet )


--=========================================--
-- PercyPig:KillInteractions( bSnapToSafePositionOnly ) --
--=========================================--
function PercyPig:KillInteractions( bSnapToSafePositionOnly )
    
    Classes.HerdableScriptObjectBase.KillInteractions(self, bSnapToSafePositionOnly)

    self:SetMySpecificScale()

end