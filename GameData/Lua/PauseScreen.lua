local PauseScreen = Classes.UIBase:Inherit( "PauseScreen")

local ButtonEnums = 
{
	Button_Options = 0,
	Button_Save = 1,
	Button_Quit = 2,
}

--test codes.
--codes are installed into flash every time this screen starts.
--if the user enters the code correctly, there is a Success message
--passed back from cheatcodes.swf in LoopInternal() 
--We can test if an item needs to get unlocked at this point.
--if the unlock is already unlocked no message needs to be displayed.
--the placement in the unlock array listed below is the return message from flash.
PauseUnlockCodes =
{
	{
		code = "lrududcz",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_CARIBBEAN_FEMALE",
		classString = "unlock",
		collectionString = "unlock_afbodycaribbean",
	},
	
	{
		code = "czducz",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_FAIRY",
		classString = "unlock",
		collectionString = "unlock_afbodyfairy",
	},
	
	{
		code = "dddduuuu",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_KHAKI",
		classString = "unlock",
		collectionString = "unlock_afbodyspy",
	},
	
	{
		code = "lrdul",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_FAIRY_HAIR",
		classString = "unlock",
		collectionString = "unlock_afheadhairfairy",
	},

	{
		code = "czczudlr",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_BUCKET_HAT",
		classString = "unlock",
		collectionString = "unlock_afheadhairspy",
	},

	{
		code = "uuddlrlrcz",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_CARIBBEAN_MALE",
		classString = "unlock",
		collectionString = "unlock_ambodycaribbean",
	},

	{
		code = "udlrudcz",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_COW_BODY",
		classString = "unlock",
		collectionString = "unlock_aubodycow",
	},

	{
		code = "czczdudu",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_TATTOO",
		classString = "unlock",
		collectionString = "unlock_aubodylongpants_tattoo",
	},

	{
		code = "dudu",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_SWORDSMAN",
		classString = "unlock",
		collectionString = "unlock_aubodyswordsman",
	},

	{
		code = "lrlrlr",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_TRENCHCOAT",
		classString = "unlock",
		collectionString = "unlock_aubodytrenchcoat",
	},

	{
		code = "czzccz",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_FEDORA",
		classString = "unlock",
		collectionString = "unlock_auheadhatadventurefedora",
	},

	{
		code = "czzcdu",
		unlockMsg = "STRING_UNLOCK_CAS_PRESALE_COW_HEAD",
		classString = "unlock",
		collectionString = "unlock_auheadhatcow",
	},
}

PauseScreen._instanceVars =
{
--	hMusic = NIL, --handle to the music object
	bSaved = false,  -- prevent saving same game many times in one pause
}

PauseScreen.DefaultUISpec = 
{
	swfName = "pause_screen.swf",
	layerName = "PAUSE_UI_LAYER",
	bCreateNewLayer = true,
	bShouldHideOtherLayers = true,
	bIsModal = true,
	bShouldSuspendWorld = true,
	bShouldDisableCamera = true,
	bShouldDisablePause = false,
	bShouldDisableSimMenu = false,
	bShouldPauseAudio = true,
}
System:MakeTableConst( PauseScreen.DefaultUISpec )

function PauseScreen:Constructor()

	--NOTE: this function is from UIBase. Needs to be called to "get the engine running"
	--Otherwise everything here sets up the UI to run, but doesn't actually run anything yet.
	--We need to handle this screen, in this matter because we're not calling it with 
	--Spawn() or SpawnAndBlock(). This script is being instantiated from the engine side. 
	--See PauseOptions.cpp for more details on the creation of this GameObject. -gsong

	self:PostSpawn( "PauseScreen" )
	UI:SetPauseScreen( self )

end

function PauseScreen:CreateKeybinds()
	-- Create an Array with your Keybinds
	local keybinds  = {} 
	table.insert(keybinds, KeybindUtils:NewKeybind(6, 6, "B", "BOTTOM_RIGHT", 0, 0))

	-- Add them to this screen table
	KeybindUtils:AddKeybindsToScreen(keybinds, self.uiTblRef)
end

function PauseScreen:Destructor()
--[[
	if self.hMusic ~= nil then
		self:StopSound(self.hMusic)
		self.hMusic = nil;
	end
--]]	
	UI:ClearPauseScreen( self )
end

function PauseScreen:GetBrokerTypeName()
	return "PauseScreen"
end

function PauseScreen:GetBrokerTypeDescription()

	local scriptersAPI = Classes.UIBase:GetBrokerTypeDescription()
	--scriptersAPI.Sound = true
	scriptersAPI.Timer = true
	
	return scriptersAPI

end

--UIBase Override functions
function PauseScreen:SetParams()
	self:CreateKeybinds()
	self.uiTblRef.Hit = nil
	self.uiTblRef.exitgame = false
	self.uiTblRef.exitPauseScreen = false
	self.uiTblRef.quitGame = false
	self.uiTblRef.TitleText = "STRING_PAUSE_TITLE" 
	
	--set up textures for all of the icons.	
	self.uiTblRef.BtnTexture0 = "uitexture-flow-options"				--Quit Game
	self.uiTblRef.ToolTip0 = "STRING_OPTIONS_TITLE"

	self.uiTblRef.BtnTexture1 = "uitexture-flow-back"				--Save Game
	self.uiTblRef.ToolTip1 = "STRING_UI_PAUSE_SAVEGAMEBUTTON"

	self.uiTblRef.BtnTexture2 = "uitexture-flow-exit"				--Quit Game
	self.uiTblRef.ToolTip2 = "STRING_UI_PAUSE_QUITBUTTON"
	
	self.uiTblRef.CancelTexture = "uitexture-flow-cancel"				--Cancel Menu
end

function PauseScreen:PreLoop()
 	
	UIUtility:ShowScreen( self.uiTag )
 	--self.hMusic = self:PlaySound( "pause_screen_music" )
 	
 	--check if we can save.
 	if( UI:IsSaveDisabled() == true ) then
 		self:DisableButton( ButtonEnums.Button_Save )
 	else
 		self:EnableButton( ButtonEnums.Button_Save )
 	end
 	
 	--set up the unlock/cheat codes
 	for i, v in pairs(PauseUnlockCodes) do
 		self:AddCheatCode( v.code, i )
 	end
 	
 	--self:DEBUG_ShowAvailableCheats()
end

function PauseScreen:LoopInternal()

 	--TODO: What are we going to do about saving and loading of the game? Will that still go in PauseScreen?

	if( self.uiTblRef.Button == "0" ) then
	
		EA:Log( "UI", "Options" )
		UI:SpawnAndBlock( "UIOptionsScreen" )
		self.uiTblRef.Button = nil
		
 	elseif( self.uiTblRef.Button == "1" and UI:IsSaveDisabled() == false ) then
		EA:Log( "UI", "Saving Game from Pause Screen" )	
		if self.bSaved == false then    -- first save
			self:DisableButton( ButtonEnums.Button_Options )
			local dialogReturn = UI:SpawnAndBlock( "UISavingDialog" )
			if (dialogReturn == 0) then
				self:EnableButton( ButtonEnums.Button_Options )
			end
	    	self.bSaved = true  -- no more save
    		self:DisableButton( ButtonEnums.Button_Save )
    	end
		self.uiTblRef.Button = nil

 	elseif( self.uiTblRef.Button == "2" ) then
		EA:Log( "UI", "Exiting Game from Pause Screen" )
		
		local dialogReturn = UI:DisplayModalDialog( "STRING_QUIT_TITLE",
													"STRING_QUIT_MESSAGE",
													"uitexture-warning",
													2,
													( "YES_BUTTON" ),
													( "NO_BUTTON" ) )										 
		if (dialogReturn == 0) then -- yes
			GameManager:DestroyPauseOptionsScreen()
			self.uiTblRef.exitPauseScreen = true
			
			--This function only sets an m_bExitGame boolean on the engine side.
			--WILL NOT QUIT THE GAME...There's no quit function in MySimsNextGameManager yet.
			--Talk to Max or Vn. -gsong (1/8/2008)
			GameManager:ExitGameFromPauseOptions()
			self.uiTblRef.quitGame = true
		end		
 		
		self.uiTblRef.Button = nil

	elseif (self.uiTblRef.Hit == "-1" or self.uiTblRef.Hit == "cancel" ) then
		EA:Log( "UI", "Exiting from Pause Screen" )
		
		GameManager:DestroyPauseOptionsScreen()
		self.uiTblRef.exitPauseScreen = true
		self.uiTblRef.Button = nil
		
	        end  
	        
	if( self.uiTblRef.Success ~= nil ) then
		local index = tonumber( self.uiTblRef.Success )
		local msg = PauseUnlockCodes[index].unlockMsg
		local unlockClass = PauseUnlockCodes[index].classString
		local unlockCollection = PauseUnlockCodes[index].collectionString
		
		if( Unlocks:IsUnlocked( unlockClass, unlockCollection ) == false ) then
			Unlocks:Unlock( unlockClass, unlockCollection )
			
			local casUnlockItemTbl = 
			{ 
				{ 
					"resource", 
					"shirt", 
				} 
			}
			
			UI:DisplayRewardDialog( casUnlockItemTbl, "STRING_UNLOCK_CAS_PRESALE_TITLE", msg, { unlockClass, unlockCollection }, nil )
	    end 
		
		self.uiTblRef.Success = nil
	end			
end

function PauseScreen:LoopExitTest()
	return self.uiTblRef.exitPauseScreen
end

--Disable/Enabling Function
--[[
	Given a button number (0-2) you can disable any of the buttons on the Pause menu.
	Lua defines what each button is, so it's better not to hardcode in flash what
	each button is, and to just disable by id in Lua.
--]]

function PauseScreen:EnableButton( buttonId )
	UIEngineUtils:AptCallFunction( "EnableButton", nil, self.uiTag, 1, buttonId )
end

function PauseScreen:DisableButton( buttonId )
	UIEngineUtils:AptCallFunction( "DisableButton", nil, self.uiTag, 1, buttonId )
end


--==============================--
-- Cheat Code Helper Functions  --
--==============================--

function PauseScreen:DEBUG_ShowAvailableCheats()
	UIEngineUtils:AptCallFunction( "DEBUG_ShowAvailableCheats", nil, self.uiTag, 0 )
end

function PauseScreen:AddCheatCode( cheatCodeStr, returnMsg )
	UIEngineUtils:AptCallFunction( "AddCheatCode", nil, self.uiTag, 2, cheatCodeStr, returnMsg )
end

--==============================--
--       Helper Functions       --
--==============================--

-- This is for the edge case when the pause menu opens behind the top screen 
-- and the conventional close methods don't work
function PauseScreen:ForceExit()
	UIEngineUtils:AptCallFunction( "pressB", nil, self.uiTag, 0 )
end
