local Unlocked_I_Scale_Object = Classes.Job_InteractionBase:Inherit("Unlocked_I_Scale_Object")

function Unlocked_I_Scale_Object:Test( sim, obj, autonomous )
	if ( sim ~= Universe:GetPlayerGameObject() ) then
		return false
	end

	if not ( obj.SetScale or obj.GetScale ) then
		return false
	end
	
	if ( obj.mType == "tree" ) then
		-- only scale trees that exist
		if ( obj:GetAttribute("SavedStage") < obj.GrowthStages["TREE_GROWTH_STAGE_SPROUT"] ) then
			return false
		end
	end
	
    return true
end

function Unlocked_I_Scale_Object:Destructor()
end

function Unlocked_I_Scale_Object:Action( sim, obj )
	local selection = UI:DisplayModalDialog( "Scale Object", "Here you can scale the object. Use your cursor to select an option with the A button.", "uitexture-interaction-change", 4, "Reset Scale", "Exit", "Scale Up", "Scale Down" )

	if selection == 0 then
		Common:ScaleObject( obj, 1.0, 240 )

	elseif selection == 1 then
		return

	elseif selection == 2 then
		local currentScale = obj:GetScale()
		Common:ScaleObject( obj, currentScale + 0.2, 120 )

	elseif selection == 3 then
		local currentScale = obj:GetScale()
		Common:ScaleObject( obj, currentScale - 0.2, 120 )
	end
end
