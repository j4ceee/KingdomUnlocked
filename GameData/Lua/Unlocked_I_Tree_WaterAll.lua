local Unlocked_I_Tree_WaterAll = Classes.Job_InteractionBase:Inherit("Unlocked_I_Tree_WaterAll")

function Unlocked_I_Tree_WaterAll:Test( sim, obj, autonomous )
	if ( sim ~= Universe:GetPlayerGameObject() ) then
		return false
	end
	
	if ( obj.bGrowthTransitionPending ) then
		return false
	end
	
	if ( obj:GetAttribute("SavedStage") < obj.GrowthStages["TREE_GROWTH_STAGE_SPROUT"] ) then
		return false
	end
	
	if ( obj:GetAttribute("SavedStage") > obj.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
		return false
	end
	
	if ( not Unlocks:IsUnlocked("tools_harvesting", "wateringcan_low") ) then
		return false
	end

	if ( not Task:IsTaskComplete("NPC_Linzey_GatherWood") ) then
		return false
	end
	
    return true
end

function Unlocked_I_Tree_WaterAll:Destructor()
end

function Unlocked_I_Tree_WaterAll:Action( sim, obj )
	local result, reason = self:RouteToObjectBlocking( sim, obj, 1.5 )
	
	if ( result ~= BlockingResult.Succeeded ) then
		return result, reason
	end
	
	result, reason = self:RotateToFaceObjectBlocking( sim, obj )
	if ( result ~= BlockingResult.Succeeded ) then
		return result, reason
	end
	
	-- obj:SetCameraFadeDistance(1)   -- small fade distance for no fading in interaction
	result, reason = self:PlayAnimationBlocking( sim, obj._animations.WATER.sim, 1 )
   	local distance = obj:GetAttribute("Fadable")
	-- obj:SetCameraFadeDistance(distance)    -- put back fade distance

	-- get all trees on the island & call ShakeLoop on them
	local trees = Common:GetAllObjectsOfTypeOnIsland( "tree" )
	for i, tree in ipairs( trees ) do
		if ( self:Test( sim, tree ) ) then
			tree:Water()
		end
	end

	return result, reason
end
