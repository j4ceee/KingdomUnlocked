
local Debug_Interaction_ForceNPCUse = Classes.Job_InteractionBase:Inherit("Debug_Interaction_ForceNPCUse")

function Debug_Interaction_ForceNPCUse:Test( sim, obj, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject()
end

function Debug_Interaction_ForceNPCUse:Destructor()
end

function Debug_Interaction_ForceNPCUse:Action( player, obj )
	
    if self.params and self.params.actionKey then

        -- Check if actionKey is a table (array) or a string
        if type(self.params.actionKey) == "table" then
            -- If it's an array, pick a random action from it
            actionToUse = self.params.actionKey[math.random(#self.params.actionKey)]
        else
            -- If it's a string, use it directly
            actionToUse = self.params.actionKey
        end

        local simArray = Universe:GetWorld():CreateArrayOfObjects( "character" )

        local closest
        local closestDistance
        
        for i, sim in ipairs(simArray) do
            
            if sim ~= player then
                local distance = obj:GetXZDist(sim)
                if closest == nil or distance < closestDistance then
                    closest = sim
                    closestDistance = distance
                end                
            end
        end
        
        local params = System:CopyShallow( self.params )

        if closest ~= nil then
            closest:PushInteraction( obj, actionToUse, params )
        end
        
    end	
	
	return
end
  
