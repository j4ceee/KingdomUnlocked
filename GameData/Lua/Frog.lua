local Frog = Classes.HerdableScriptObjectBase:Inherit( "Frog" )

Frog._instanceVars =
{
    herdTypeSearchRefSpec = "frog",
    specifiedTaskToComplete = "NPC_Hopper_HerdFrogs",
}

function Frog:EnterTriggerCallback(go, trigger)

	-- call base class version to handle basic stuff
	Classes.HerdableScriptObjectBase.EnterTriggerCallback(self, go, trigger)
	
    self:SteeringTargetNotNearbyCallback()
    
	-- then handle frog specific stuff
	if self:TestAllHerded() then
        if Task:IsTaskRevealed( self.specifiedTaskToComplete ) then
            Task:CompleteTask( self.specifiedTaskToComplete, Task:GetNPCFromTaskId( self.specifiedTaskToComplete ) )
        end
	end
    
end


function Frog:SteeringTargetNearbyCallback()

    --if the make hopper better tasks are not complete the frogs should ignore the player
    if Task:GetTaskState( self.specifiedTaskToComplete ) == Task.States["kNone"] or Task:GetTaskState( self.specifiedTaskToComplete ) == Task.States["kMapRevealed"]  then
        Classes.HerdableScriptObjectBase.SteeringTargetNotNearbyCallback(self)
    end
    
end


Frog.idles =
{
    {   anim = "c-frog-idle-breathe",    weight = 50,   },
    {   anim = "c-frog-idle-ribbit", weight = 10,   },
    {   anim = "c-frog-idle-lookAround", weight = 10,   },
}

Frog.interactionSet = System:CopyShallow(Classes.HerdableScriptObjectBase.interactionSet)