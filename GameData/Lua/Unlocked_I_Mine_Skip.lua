local Unlocked_I_Mine_Skip = Classes.MiningRock_Interaction_Mine:Inherit("Unlocked_I_Mine_Skip") --inherit from default mining interaction

function Unlocked_I_Mine_Skip:Post_ROUTE( sim, obj )
	local job = Classes.Unlocked_J_Mining_Skip:Spawn( sim, obj )
	job:Execute( sim )
	
	return 0, 0
end
