local HUDMenu = Classes.UIBase:Inherit( "HUDMenu" )

--===========--
-- Constants --
--===========--
local NUM_COLUMNS = 5
local kUpdateInterval = 2
local kInfoPanelUpdateInterval = 5

-- If HUDMenu.DefaultUISpec.swfName changes (elements are added, removed, changed, or reordered), then these enumerations should also change)
local kSwfIndex_InteractionMenu = 1
local kSwfIndex_HUDMenu = 2
local kSwfIndex_HUDInfoPanel = 3
local kSwfIndex_KPMeter = 4

local kShowHUDPuck = 0
local kHideHUDPuck = 1

local enableMapOpen = 1

HUDMenu._instanceVars = 
{
	condition = NIL, -- temporary - to be removed once all "test" UI is moved to final shipping scripts
	interactTimer = NIL,
	interactObj = NIL,
	bInteractionSuspended = NIL,

	PrevInteractionObj = NIL,
	
	--variables for the info panel.
	infoPanelDialogTimer = NIL,
	entryQueue = NIL,
	bScreenInit = false,
	currentKP = 0,

	bIsTaskCardShortcutEnabled = true,
}

--=================--
-- Generic UI data --
--=================--
HUDMenu.DefaultUISpec =
{
	swfName = { "interaction_menu.swf", "hudmenu.swf", "hud_info_panel.swf", "king_point_meter.swf" }, -- if this changes, don't forget to change the enumerated constants above!
	layerName = "HUD_UI",
	bCreateNewLayer = true,
	bShouldHideOtherLayers = false,
	bIsModal = false,
	bShouldSuspendWorld = false,
	bShouldDisableCamera = false,
	bShouldDisablePause = false,
	bShouldDisableSimMenu = false,
}
System:MakeTableConst(HUDMenu.DefaultUISpec)

--============================--
-- Engine interface functions --
--============================--
function HUDMenu:Destructor()
	KeybindUtils:KeybindChangeRemoveListener(self.uiTags[kSwfIndex_HUDMenu])
	KeybindUtils:KeybindChangeRemoveListener(self.uiTags[kSwfIndex_HUDInfoPanel])
	KeybindUtils:KeybindChangeRemoveListener(self.uiTags[kSwfIndex_InteractionMenu])
end

function HUDMenu:Constructor()
	--create the condition that the UI SWFs will use
	self.condition = ConditionCreate(); -- temporary - to be removed once all "test" UI is moved to final shipping scripts
	
	self.interactObj = Universe:GetPlayerGameObject() -- if we don't have an interactable object should just be the player object.
	self:InteractionMenuPulse( true )
	
	--variable to determine if interaction menu should be suspended or not.	
	self.bInteractionSuspended = false
	self.PrevInteractionObj = 
	{
		numActions = 0,
		gameObj = nil,
		actionListStr = "",
		defaultAction = "",
		actionItems = {},
	}

	self.infoPanelDialogTimer = nil

	self.bIsTaskCardShortcutEnabled = true
	
    UIUtility:InitializeTooltipDelay()	
	
	self:PostSpawn( "HUD" ) -- TODO: should not call explicitly like this
end

function HUDMenu:TimerExpiredCallback( timerID )
	
	-- Interaction Menu timer callback
	if( timerID == self.interactTimer ) then
		--if the interaction menu is hidden, then don't do anything.

		self:UpdateInteractionMenuTimerCB()
		self:InteractionMenuPulse( true )
	
	-- HUD Info Panel timer callback 
	elseif( timerID == self.infoPanelDialogTimer ) then
		self:ProcessItems()	
	end
end

function HUDMenu:CreateKeybinds()
	-- Create an Array with your Keybinds
	local keybinds = {}
	table.insert(keybinds, KeybindUtils:NewKeybind(510, 80, "CENTER", 0, 0, KeybindUtils.Actions.ActionTravelogue))
	table.insert(keybinds, KeybindUtils:NewKeybind(490, 22, "CENTER", -10, -10, KeybindUtils.Actions.ActionTraveloguePC))

	-- Add them to this screen table
	KeybindUtils:AddKeybindsToScreen(keybinds, self.uiTblRefs[kSwfIndex_HUDInfoPanel], self.uiTags[kSwfIndex_HUDInfoPanel])
end

function HUDMenu:CreateKeybindsHUDMenu()
	-- Create an Array with your Keybinds
	local keybinds  = {}	
	table.insert(keybinds, KeybindUtils:NewKeybind(585, 40, "CENTER", 0, 0, KeybindUtils.Actions.ActionMoveUp))
	table.insert(keybinds, KeybindUtils:NewKeybind(585, 80, "CENTER", 0, 0, KeybindUtils.Actions.ActionMoveDown))
	table.insert(keybinds, KeybindUtils:NewKeybind(554, 19, "CENTER", 2, 2, KeybindUtils.Actions.ActionToolsTAB))

	-- Add them to this screen table
	KeybindUtils:AddKeybindsToScreen(keybinds, self.uiTblRefs[kSwfIndex_HUDMenu], self.uiTags[kSwfIndex_HUDMenu])
end

function HUDMenu:CreateKeybindsInteractionMenu()
	-- Create an Array with your Keybinds
	local keybinds  = {}	

	-- Controller Keybinds
	table.insert(keybinds, KeybindUtils:NewKeybind(-35, 28, "CENTER", 0, 0, KeybindUtils.Actions.ActionMoveLeftInteractions))
	table.insert(keybinds, KeybindUtils:NewKeybind(7, 28, "CENTER", 0, 0, KeybindUtils.Actions.ActionMoveRightInteractions))

	-- Keyboard keybinds are bigger then controller ones
	table.insert(keybinds, KeybindUtils:NewKeybind(-62, 18, "CENTER", 40, 40, KeybindUtils.Actions.ActionMoveLeftInteractionsKeyboard))
	table.insert(keybinds, KeybindUtils:NewKeybind(13, 18, "CENTER", 40, 40, KeybindUtils.Actions.ActionMoveRightInteractionsKeyboard))

	table.insert(keybinds, KeybindUtils:NewKeybind(25, 28, "CENTER", 0, 0, KeybindUtils.Actions.ActionInteraction))

	-- Add them to this screen table
	KeybindUtils:AddKeybindsToScreen(keybinds, self.uiTblRefs[kSwfIndex_InteractionMenu], self.uiTags[kSwfIndex_InteractionMenu])
end

--===========================--
-- UIBase override functions --
--===========================--
function HUDMenu:SetParams()
	self:CreateKeybinds()
	self:CreateKeybindsHUDMenu()
	self:CreateKeybindsInteractionMenu()
	--HUD Info Panel entry queue
	self.entryQueue = { }
	self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing = true;

	--Interaction Menu 
	self.uiTblRefs[kSwfIndex_InteractionMenu].Hit = nil
	self.uiTblRefs[kSwfIndex_InteractionMenu].DefaultAction = ""
	self.uiTblRefs[kSwfIndex_InteractionMenu].ActionListStr = ""
	self.uiTblRefs[kSwfIndex_InteractionMenu].VisibleInteractions = 6
	self.uiTblRefs[kSwfIndex_InteractionMenu].Rollover = ""	-- set by interaction_menu.as to detect DPD on menu
	self.uiTblRefs[kSwfIndex_InteractionMenu].RolloverRelease = "" -- set by interaction_menu.as
	self.uiTblRefs[kSwfIndex_InteractionMenu].ActionItems = {}
	
	--set the textures for the hud menu.
	self.uiTblRefs[kSwfIndex_HUDMenu].ModeTbl = 
	{
		--game mode data, index 1
		{
			textureName = "uitexture-hud-game-on",
			offTextureName = "uitexture-hud-game-off",
			isEnabled = 1,
		},

		--build mode data, index 2
		{
			textureName = "uitexture-hud-build-on",
			offTextureName = "uitexture-hud-build-off",
			soundName = "ui_hud_select_constr",
			isEnabled = Luattrib:ReadAttribute( "tutorial", "default", "bEnableConstruction" ),
		},
		
		--paint mode data, index 3
		{
			textureName = "uitexture-hud-paint-on",
			offTextureName = "uitexture-hud-paint-off",
			soundName = "ui_hud_select_paint",
			isEnabled = Luattrib:ReadAttribute( "tutorial", "default", "bEnablePaint" ),
		},
		
		--camera mode data, index 4
		{
			textureName = "uitexture-hud-prospect-on",
			offTextureName = "uitexture-hud-prospect-on",
			soundName = "ui_hud_select_prospect",
			isEnabled = Luattrib:ReadAttribute( "tutorial", "default", "bEnableProspecting" ),
		},
	}
	
	self.uiTblRefs[kSwfIndex_HUDMenu].CurrMode = HUDModeType.HUDMode_Game
	--self.uiTblRefs[kSwfIndex_HUDMenu].PrevMode = HUDModeType.HUDMode_Game
	self.uiTblRefs[kSwfIndex_HUDMenu].ModesToSelect = { HUDModeType.HUDMode_Game, HUDModeType.HUDMode_Build, HUDModeType.HUDMode_Paint, HUDModeType.HUDMode_Prospecting }

	--setup the HUDPuck Lua table 
	self:UpdateHUDMenuIcons()

	local levels = Luattrib:ReadAttribute( "reputation", "default", "Levels" )
	
	for i, v in ipairs( levels ) do
		self.uiTblRefs[kSwfIndex_KPMeter][ "KPLevel" .. ( i - 1 ) ] = v
		self.uiTblRefs[kSwfIndex_KPMeter].NumLevels = i
	end
	
	self.currentKP = Luattrib:ReadAttribute( "reputation", "default", "Value" )
	self.uiTblRefs[kSwfIndex_KPMeter].CurrentPoints = self.currentKP
end

--start the timer before we run LoopInternal()
function HUDMenu:PreLoop()
	self.bScreenInit = true;
	
	--process info panel events.
	self:ProcessItems()
	self:UpdateKPMeter()
end

function HUDMenu:PreLoad()
        -- set textures for the mode (main) menu.
end

function HUDMenu:LoopInternal()
	--interaction menu events.
	
	local IMHit = tonumber( self.uiTblRefs[kSwfIndex_InteractionMenu].Hit )
		
	if( IMHit ~= nil and IMHit ~= -1 ) then
		--EA:Log( "Glenn", "IMHit is " .. IMHit )
		--EA:Log( "Glenn", "self.uiTblRefs[kSwfIndex_InteractionMenu].ActionItems count is " .. #self.uiTblRefs[kSwfIndex_InteractionMenu].ActionItems )
        if( self.uiTblRefs[kSwfIndex_InteractionMenu].ActionItems ~= nil ) then
	        local interaction = self.uiTblRefs[kSwfIndex_InteractionMenu].ActionItems[IMHit+1]
				
			if( interaction ~= nil ) then
				--EA:Log( "Glenn", "HUDMenu:Run(), interaction.key is " .. interaction.key )
				Universe:GetPlayerGameObject():PushInteraction( interaction.object, interaction.key, nil, false, true, Constants.InteractionPriorities["Default"] )
			end
				
			self.uiTblRefs[kSwfIndex_InteractionMenu].Hit = nil
		end
	end
		
	if( self.uiTblRefs[kSwfIndex_HUDMenu].Mode ~= nil ) then
		--index of the button from Flash.
		local idx = tonumber( self.uiTblRefs[kSwfIndex_HUDMenu].Mode )

		--convert that index to the actual mode number.
		local newMode = self.uiTblRefs[kSwfIndex_HUDMenu].ModesToSelect[idx]

		if(UI:GetPauseScreen() ~= nil or UI:GetPauseScreenOpening() == 1) then
			newMode = HUDModeType.HUDMode_Game
		end

		if( newMode == HUDModeType.HUDMode_Build ) then

				self:CloseHUDMenu()

	        	GameManager:RequestMetaStateTransition(MetaStates.Unknown, MetaStates.Construction)
				CameraController:ZoomOutCamera()
		elseif( newMode == HUDModeType.HUDMode_Paint ) then

			self:CloseHUDMenu()
			EA:Log( "UI", "Enter Paint Mode" ) 
			
	        GameManager:RequestMetaStateTransition(MetaStates.Unknown, MetaStates.Painting)
			CameraController:ZoomOutCamera()		
		elseif( newMode == HUDModeType.HUDMode_Prospecting ) then

				--since prospecting doesn't show the puck, just swap the icon back.
				self:CloseHUDMenu()
				
				local player = Universe:GetPlayerGameObject()
				if ( player ~= nil ) and ( player.isValid ) then
					local x,y,z,rot = player:GetPositionRotation()
					local footprintType = player.containingWorld:GetFootPrintType( x, y, z, FootPrintType.FootPrintType_Prospecting )
					if ( footprintType == FootPrintType.FootPrintType_Prospecting ) then
						local job = Classes.Job_Prospecting:Spawn( player )
						job:Execute( player )
						
						EA:Log( "UI", "Enter Prospecting Mode" )
					end -- verify prospecting footprint
				end -- verify player
			
		elseif( newMode == HUDModeType.HUDMode_Game ) then
			self:CloseHUDMenu()
			EA:Log( "UI", "Enter Game Mode" )
	        GameManager:RequestMetaStateTransition(MetaStates.Unknown, MetaStates.Gameplay)			

		else
			self:CloseHUDMenu()
			EA:Log( "UI", "Enter Game Mode" )
	        GameManager:RequestMetaStateTransition(MetaStates.Unknown, MetaStates.Gameplay)			
		end	
		
		self.uiTblRefs[kSwfIndex_HUDMenu].Mode = nil

	elseif( self.uiTblRefs[kSwfIndex_HUDMenu].CloseCurrMode ~= nil ) then
		self:CloseHUDMenu()
		
		--only switch the mode if we're not in gameplay, can't do gameplay to gameplay.
		if( self.uiTblRefs[kSwfIndex_HUDMenu].CurrMode ~= HUDModeType.HUDMode_Game ) then
	        GameManager:RequestMetaStateTransition(MetaStates.Unknown, MetaStates.Gameplay)
	    end
	    
	    self.uiTblRefs[kSwfIndex_HUDMenu].CloseCurrMode = nil
	end
	
	--------------------------------------
	-- INFO PANEL EVENT HANDLING ---------
	--------------------------------------
	if( self.uiTblRefs[kSwfIndex_HUDInfoPanel].CloseInfoPanel == "1" ) then
		self:HideHUDInfoPanel()
		
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].CloseInfoPanel = nil
	
	--Rolling on and off the button to try and stop the timer so the user can dwell on whether or
	--not they want to click on it, is ineffectual. Need to find a different way to do this.
	elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].RollOverInfoBtn == "1" ) then
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].rolledOver = true	
        
        if( self.infoPanelDialogTimer ~= nil ) then
	        self.infoPanelDialogTimer:Pause()
	    end
        
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].RollOverInfoBtn = nil
	
	elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].RollOffInfoBtn == "1" ) then
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].rolledOver = false
        
        if( self.infoPanelDialogTimer ~= nil ) then
	        self.infoPanelDialogTimer:Unpause()
	    end
        
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].RollOffInfoBtn = nil 
	
	elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].OpenTaskCard == "1" ) then
		
		if (self.bIsTaskCardShortcutEnabled == false) then
			UI:SpawnAndBlockCollection( "UITravelogueScreen", "travelogue_screen" )	
		elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskId ~= nil ) then
			--show a task card if there is one.
			UI:SpawnAndBlock( "UITaskCard",  self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskId )
		end

	    if( self.infoPanelDialogTimer ~= nil ) then
		    self.infoPanelDialogTimer:Unpause()
		end
		
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].rolledOver = false
        
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].OpenTaskCard = nil
	elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].OpenTaskScreen == "1" ) then
		--open the task screen.
		--UI:SpawnAndBlock( "UITravelogueScreen" )

		UI:SpawnAndBlockCollection( "UITravelogueScreen", "travelogue_screen" )
		
	    if( self.infoPanelDialogTimer ~= nil ) then
		    self.infoPanelDialogTimer:Unpause()
		end
		
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].rolledOver = false
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].OpenTaskScreen = nil
	elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].MapShortcut == "1" ) then
		--  don't fly if the player is in build mode or paint mode
		if  (self.uiTblRefs[kSwfIndex_HUDMenu].CurrModeIndex == 2 or self.uiTblRefs[kSwfIndex_HUDMenu].CurrModeIndex == 3 ) then
			self.uiTblRefs[kSwfIndex_HUDInfoPanel].MapShortcut = "0"
			return
		end

	    local player = Universe:GetPlayerGameObject()
	    if player ~= nil then
			Common:FakeFly( player, 2, 120)
		end
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].MapShortcut = nil
	elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskShortcut == "1" ) then
		UI:SpawnAndBlock( "UITasksList" )
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskShortcut = nil
	end
end

function HUDMenu:CloseHUDMenu()
	UIEngineUtils:AptCallFunction( "CloseModeMenu", nil, self.uiTags[kSwfIndex_HUDMenu], 0 )
end

--go through and set all of the fields for the HUD Puck.
function HUDMenu:UpdateHUDMenuIcons()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]

	HUDMenuTbl.CurrModeIconName = HUDMenuTbl.ModeTbl[HUDMenuTbl.CurrMode].textureName
	HUDMenuTbl.CurrModeSoundName = HUDMenuTbl.ModeTbl[HUDMenuTbl.CurrMode].SoundName
	HUDMenuTbl.CurrModeIndex = HUDMenuTbl.CurrMode
	
	for i=1,#HUDMenuTbl.ModesToSelect do
		if( HUDMenuTbl.CurrModeIndex == HUDMenuTbl.ModesToSelect[i] ) then
			HUDMenuTbl["MainMenuIconName" .. (i-1)] = HUDMenuTbl.ModeTbl[ HUDMenuTbl.ModesToSelect[i] ].offTextureName
			HUDMenuTbl["MainMenuIconEnabled" .. (i-1)] = 0
		else
			if( HUDMenuTbl.ModeTbl[ HUDMenuTbl.ModesToSelect[i] ].isEnabled == 1 ) then
				HUDMenuTbl["MainMenuIconName" .. (i-1)] = HUDMenuTbl.ModeTbl[ HUDMenuTbl.ModesToSelect[i] ].textureName
			else
				HUDMenuTbl["MainMenuIconName" .. (i-1)] = HUDMenuTbl.ModeTbl[ HUDMenuTbl.ModesToSelect[i] ].offTextureName
			end

			HUDMenuTbl["MainMenuSoundName" .. (i-1)] = HUDMenuTbl.ModeTbl[ HUDMenuTbl.ModesToSelect[i] ].soundName		
			HUDMenuTbl["MainMenuIconEnabled" .. (i-1)] = HUDMenuTbl.ModeTbl[ HUDMenuTbl.ModesToSelect[i] ].isEnabled
		end
	end
end

function HUDMenu:UpdateHUDMenuTextures()
	self:UpdateHUDMenuIcons()
	UIEngineUtils:AptCallFunction( "Refresh", nil, self.uiTags[kSwfIndex_HUDMenu], 0 )
end

function HUDMenu:ShowAutoSave()
	UIEngineUtils:AptCallFunction( "showAutoSave", nil, self.uiTags[kSwfIndex_InteractionMenu], 0 )
end

function HUDMenu:UpdateHUDMenuOptions( newCurrModeIdx )
	
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.CurrMode = HUDMenuTbl.ModesToSelect[newCurrModeIdx]
	self:UpdateHUDMenuTextures()
end

function HUDMenu:UpdateKPMeter()
	local kp = Luattrib:ReadAttribute( "reputation", "default", "Value" )
	local deltaKP = kp - self.currentKP
	self.currentKP = kp
	
	if( deltaKP > 0 ) then
		UIEngineUtils:AptCallFunction( "AddPoints", nil, self.uiTags[kSwfIndex_KPMeter], 1, deltaKP )
	end
end


function HUDMenu:LoopExitTest()
	return false
end

--=====================--
-- Mixin Functionality --
--=====================--

function HUDMenu:GetBrokerTypeName()
	return "HUDMenu"
end

function HUDMenu:GetBrokerTypeDescription()
	local scriptersAPI = Classes.UIBase.GetBrokerTypeDescription(self)
	scriptersAPI.HUDMenu = true
		
	return scriptersAPI
end

--bPulse: determines if we should set the timer for the interaction menu callback or not.
--the engine, when it hides the interaction menu turns the pulse off. When we want to hide it
--during gameplay we want to keep the pulse going.
function HUDMenu:HideInteractionMenu( bPulse )
	--GSONG_TODO: We need a better way to find out if an individual SWF is hidden or not and let Lua know.
	--This right now seems to be a special case, need to generalize this later.

	if( bPulse ~= nil ) then
		self:InteractionMenuPulse( bPulse )
	else
		self:InteractionMenuPulse( false )
	end
	
	UIUtility:HideScreen( self.uiTags[kSwfIndex_InteractionMenu] )
	--UIUtility:DEBUG_PrintUIScreen( self.uiTags[kSwfIndex_InteractionMenu] )
end

function HUDMenu:ShowInteractionMenu()
	UIUtility:ShowScreen( self.uiTags[kSwfIndex_InteractionMenu] )
	KeybindUtils:UpdateScreenKeybinds(self.uiTblRefs[kSwfIndex_InteractionMenu].KeybindTrack, KeybindUtils.CurrentDeviceID)
	
	self:UpdateInteractionMenuTimerCB()	
	
	--if the interaction menu pulse timer hasn't started, then start it up.
	self:InteractionMenuPulse( true )
	--UIUtility:DEBUG_PrintUIScreen( self.uiTags[kSwfIndex_InteractionMenu] )
end

function HUDMenu:ShowKPMeter()
	UIUtility:ShowScreen( self.uiTags[kSwfIndex_KPMeter] )
end

function HUDMenu:HideKPMeter()
	UIUtility:HideScreen( self.uiTags[kSwfIndex_KPMeter] )
end

function HUDMenu:ShowTaskInfoButton()
	UIUtility:ShowScreen( self.uiTags[kSwfIndex_HUDInfoPanel] )
	KeybindUtils:UpdateScreenKeybinds(self.uiTblRefs[kSwfIndex_HUDInfoPanel].KeybindTrack, KeybindUtils.CurrentDeviceID)
end

function HUDMenu:HideTaskInfoButton()
	UIUtility:HideScreen( self.uiTags[kSwfIndex_HUDInfoPanel] )
end

function HUDMenu:ForceShowHUDPuck()
	self:UpdateHUDMenuOptions( HUDModeType.HUDMode_Game )
	UIEngineUtils:AptCallFunction( "ForceShow", nil, self.uiTags[kSwfIndex_HUDMenu], 0 )
end

function HUDMenu:ForceShowInteractionMenu()
	UIEngineUtils:AptCallFunction( "ForceShow", nil, self.uiTags[kSwfIndex_InteractionMenu], 0 )
end
 	
function HUDMenu:ForcePuckOpenAndLock()
	UIEngineUtils:AptCallFunction( "OpenModeMenu", nil, self.uiTags[kSwfIndex_HUDMenu], 0 )
	UIEngineUtils:AptCallFunction( "LockPuck", nil, self.uiTags[kSwfIndex_HUDMenu], 0 )
end

function HUDMenu:UnlockPuck()
	UIEngineUtils:AptCallFunction( "UnlockPuck", nil, self.uiTags[kSwfIndex_HUDMenu], 0 )
end
 	
--called from HUDMenuScriptersAPI.cpp
function HUDMenu:ShowHUDPuckAndChangeIcon( modeEnum )
	--show the HUD Puck.
	--switch the icon
	self:UpdateHUDMenuOptions( modeEnum )

	UIUtility:ShowScreen( self.uiTags[kSwfIndex_HUDMenu] )
	KeybindUtils:UpdateScreenKeybinds(self.uiTblRefs[kSwfIndex_HUDMenu].KeybindTrack, KeybindUtils.CurrentDeviceID)
end
 	
function HUDMenu:HideHUDPuck()	
	UIUtility:HideScreen( self.uiTags[kSwfIndex_HUDMenu] )
end


function HUDMenu:InteractionMenuPulse( bSetTimer )

	if bSetTimer then
		--only create a timer if there isn't one.
		--if( self.interactTimer == nil ) then
			self.interactTimer = self:CreateTimer( Clock.Game, 0, 0, 0, kUpdateInterval )
		--end
	else
		self.interactTimer = nil
	end
end

----------------------------------------------
-- Enable/Disable Functions for HUD Buttons --
----------------------------------------------

function HUDMenu:EnableConstruction()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.ModeTbl[ HUDModeType.HUDMode_Build ].isEnabled = 1
	
	self:UpdateHUDMenuTextures()
end

function HUDMenu:DisableConstruction()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.ModeTbl[ HUDModeType.HUDMode_Build ].isEnabled = 0
	
	self:UpdateHUDMenuTextures()
end

function HUDMenu:EnablePaint()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.ModeTbl[ HUDModeType.HUDMode_Paint ].isEnabled = 1
	
	self:UpdateHUDMenuTextures()
end

function HUDMenu:DisablePaint()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.ModeTbl[ HUDModeType.HUDMode_Paint ].isEnabled = 0
	
	self:UpdateHUDMenuTextures()
end

function HUDMenu:EnableProspecting()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.ModeTbl[ HUDModeType.HUDMode_Prospecting ].isEnabled = 1
	
	self:UpdateHUDMenuTextures()
end

function HUDMenu:DisableProspecting()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	HUDMenuTbl.ModeTbl[ HUDModeType.HUDMode_Prospecting ].isEnabled = 0
	
	self:UpdateHUDMenuTextures()
end

function HUDMenu:EnableMapOpenKeypress()
    enableMapOpen = 1
end

function HUDMenu:DisableMapOpenKeypress()
    enableMapOpen = 0
end

--==================--
-- Helper functions --
--==================--
local function InteractionmenuSortHelper( entryA, entryB )
	local priorityA = entryA.menu_priority or 999
	local priorityB = entryB.menu_priority or 999
	
	if ( priorityA < priorityB ) then
		return true
	end
	
	return false
end

function HUDMenu:SuspendInteractionMenu()
	if( self.bInteractionSuspended == false ) then
		UIUtility:SuspendScreen( self.uiTags[kSwfIndex_InteractionMenu] )
		self.bInteractionSuspended = true
	end
end

function HUDMenu:RestoreInteractionMenu()
	if( self.bInteractionSuspended == true ) then
		UIUtility:RestoreScreen( self.uiTags[kSwfIndex_InteractionMenu] )
		self.bInteractionSuspended = false
	end
end

--NOTE: Playerdriver should always return a gameobject with a valid set of interactions.
function HUDMenu:UpdateInteractionMenu( gameObj )

	--are the game objects the same? If so, then quit.
	if( self.interactObj == gameObj ) then
		return
	end

	--save the game object.
	self.interactObj = gameObj
	
	if( gameObj == nil ) then
		self:SuspendInteractionMenu()
	else
		self:RestoreInteractionMenu()
	end	

	self:InteractionMenuPulse( false )
	self:UpdateInteractionMenuFlash()
	self:InteractionMenuPulse( true )
end

function HUDMenu:ResetInteractionMenu()
	self.interactObj = Universe:GetPlayerGameObject()
	self:UpdateInteractionMenuFlash()
end

function HUDMenu:GetInteractionMenuInfo( interactObj )
	local interactInfoObj = 
	{
		numActions = 0,
		gameObj = nil,
		actionItems = {},
		actionListStr = "",
		defaultAction = "",
	}

	--"No viable gameobject" case: If we get the player gameobject or a nil for the interactable object
	--they just send back an empty structure for the update function to use.
	local player = Universe:GetPlayerGameObject()
	if( interactObj == nil or interactObj == player ) then
		if( interactObj == player ) then
			interactInfoObj.gameObj = player
		end
		
		return interactInfoObj
	end

	--cull out all of the active interactions. 
	local actionList = {}
    if InteractionUtils:IsObjectInteractable( interactObj ) then
        for key in pairs( interactObj.interactionSet ) do
            if InteractionUtils:InteractionTest( player, interactObj, key, false ) then
                actionList[#actionList+1] = { object = interactObj, key = key, icon = interactObj.interactionSet[key].icon, name = interactObj.interactionSet[key].name, menu_priority = interactObj.interactionSet[key].menu_priority }
            end
        end
    end

	table.sort( actionList, InteractionmenuSortHelper )
	
	--store all the data we found about the interactable object in a data structure.
	interactInfoObj.numActions = #actionList
	interactInfoObj.gameObj = interactObj
	
	local bIsFirstItem = true
	for i=1,interactInfoObj.numActions do
		local interaction = actionList[i]
		if( bIsFirstItem ) then
			interactInfoObj.actionListStr = interaction.name
			interactInfoObj.defaultAction = interaction.name
            bIsFirstItem = false
		else
			interactInfoObj.actionListStr = interactInfoObj.actionListStr .. "," .. interaction.name
		end
	
		interactInfoObj.actionItems[#interactInfoObj.actionItems+1] = { object = interaction.object, key = interaction.key, icon = interaction.icon, name = interaction.name }
	end
		
	return interactInfoObj
end

function HUDMenu:RefreshInteractionMenuFlashData( newInteractObj, prevInteractObj )

	--does it matter that the previous game object and the new one are different to show the interaction menu?
	--does it matter that the list of strings between the new and old interactable objects is different? 
	local IMTbl = self.uiTblRefs[kSwfIndex_InteractionMenu]
	
	IMTbl.ActionItems = newInteractObj.actionItems
	IMTbl.DefaultAction = newInteractObj.defaultAction
	IMTbl.NumActions = newInteractObj.numActions

	--remove previous interaction items before adding new ones.
	for k=1,self.PrevInteractionObj.numActions do
		IMTbl["InteractionItem" .. (k-1)] = nil
	end
	
	--setup the new interaction names and icons. 
	for j=1,newInteractObj.numActions do
		IMTbl["InteractionItem" .. (j-1)] = newInteractObj.actionItems[j].name
		EA:Assert( newInteractObj.actionItems[j].icon ~= nil , "RefreshInteractionMenuFlashData: missing icon for " .. newInteractObj.actionItems[j].name )
		UIEngineUtils:SetTexture( self.uiTags[kSwfIndex_InteractionMenu], "icon" .. j-1, newInteractObj.actionItems[j].icon )
	end
	
	UIEngineUtils:AptCallFunction( "Refresh", nil, self.uiTags[kSwfIndex_InteractionMenu], 0 )
end

function HUDMenu:UpdateInteractionMenuTimerCB()

	--Don't do anything if we have the player gameobject or nil.
	local player = Universe:GetPlayerGameObject()
	if( self.PrevInteractionObj.gameObj == nil or self.PrevInteractionObj.gameObj == player ) then
		return
	end

	local newInteractionObj = HUDMenu:GetInteractionMenuInfo( self.PrevInteractionObj.gameObj )

	--"Flour Mill" Case: The Flour Mill when you first encounter it will be a valid interactable object with 0 
	--interactions. When its fixed then it has 1 (or more) interactions. We need to be able to stand in front of it
	--and have the interactions change and the interaction menu show/hide based on whether there are interactions.

	if( newInteractionObj.numActions <= 0 ) then
		self:RefreshInteractionMenuFlashData( newInteractionObj, self.PrevInteractionObj )
	else

		--"Tree" Case: If we're standing in front of a tree and the interactions change, update it.
		if( newInteractionObj.gameObj == self.PrevInteractionObj.gameObj ) then
			if( newInteractionObj.actionListStr ~= self.PrevInteractionObj.actionListStr ) then
				self:RefreshInteractionMenuFlashData( newInteractionObj, self.PrevInteractionObj )
			end
		end
	end
	
	--need to store the new data because the actionListStr has changed.
	self.PrevInteractionObj = newInteractionObj
end

function HUDMenu:UpdateInteractionMenuFlash()
	local newInteractionObj = HUDMenu:GetInteractionMenuInfo( self.interactObj )
	self:RefreshInteractionMenuFlashData( newInteractionObj, self.PrevInteractionObj )
	self.PrevInteractionObj = newInteractionObj
end

function HUDMenu:IsGamePlayMode()
	local HUDMenuTbl = self.uiTblRefs[kSwfIndex_HUDMenu]
	if (HUDMenuTbl ~= nil) then
		return HUDMenuTbl.CurrMode == HUDModeType.HUDMode_Game
	end
	return false
end

--===================================--
-- HUD INFO PANEL ACCESSOR FUNCTIONS --
--===================================--
function HUDMenu:SetInfoPanelFields( NPCIconTexStr, TaskIconTexStr, Message, TimeInSeconds, TaskId, TaskSoundName )
	self.uiTblRefs[kSwfIndex_HUDInfoPanel].NeedIconTexture = TaskIconTexStr
	self.uiTblRefs[kSwfIndex_HUDInfoPanel].NPCIconTexture = NPCIconTexStr
	self.uiTblRefs[kSwfIndex_HUDInfoPanel].Message = Message or " "
    self.uiTblRefs[kSwfIndex_HUDInfoPanel].TimeInSeconds = TimeInSeconds
    
    --determine if we should show the hud info panel as a button or not.
    if( TaskId == nil ) then
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].IsInfoPanelAButton = 0
	else
		self.uiTblRefs[kSwfIndex_HUDInfoPanel].IsInfoPanelAButton = 1
	end
	   
    self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskId = TaskId
    self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskSoundStr = TaskSoundName
    
end

--called once to start processing the events in the queue.
function HUDMenu:ProcessItems()
	--pull an item from the queue and refresh the screen.
	if( self:RefreshInfoPanel()	) then
		
		self:ShowScreen()

		if( self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing == true ) then
			self:PlayBounce()
		end
		
		self:CreatePopUpTimer()
	else
		if( self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing == true ) then
			self:HideScreen()
		end
	end
end

function HUDMenu:RefreshInfoPanel()
	local infoTbl = self:PopInfoItemOffQueue()
		
	if( infoTbl ~= nil ) then
		--this is the first item in the queue.
		self:SetInfoPanelFields( infoTbl.NPCIconTexture, infoTbl.TaskIconTexture, infoTbl.Message, infoTbl.TimeInSeconds, infoTbl.TaskId, infoTbl.TaskSoundName )
		UIEngineUtils:AptCallFunction( "RefreshInfoPanel", nil, self.uiTags[kSwfIndex_HUDInfoPanel], 0 )
		return true
	end
	
	return false
end

function HUDMenu:CreatePopUpTimer()
	if ( self.infoPanelDialogTimer ~= nil ) then
		self.infoPanelDialogTimer:Kill()
	end -- verify self.infoPanelDialogTimer
	
	self.infoPanelDialogTimer = self:CreateTimer( Clock.Game, 0, 0, 0, self.uiTblRefs[kSwfIndex_HUDInfoPanel].TimeInSeconds or kInfoPanelUpdateInterval )
end

--utility functions, the timer will call UIUtility:ShowScreen()/HideScreen()
--directly, but these are in case the screen needs it for some other standalone purpose.
function HUDMenu:HideScreen()
	--UIUtility:HideScreen( self.uiTag )
	UIEngineUtils:AptCallFunction( "CloseInfoPanel", nil, self.uiTags[kSwfIndex_HUDInfoPanel], 0 )
	self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing = false;
end

function HUDMenu:ShowScreen()
	--UIUtility:ShowScreen( self.uiTag )
	UIEngineUtils:AptCallFunction( "DisplayInfoPanel", nil, self.uiTags[kSwfIndex_HUDInfoPanel], 0 )
	self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing = true;
end

function HUDMenu:CloseInfoPanel()
	UIEngineUtils:AptCallFunction( "CloseInfoPanel", nil, self.uiTags[kSwfIndex_HUDInfoPanel], 0 )
end

--pushes onto the back of the queue.
function HUDMenu:PushInfoItemOnQueue( NPCIconTexStr, TaskIconTexStr, Message, TimeInSeconds, TaskId, TaskSoundStr )
	local tbl = 
	{
		TaskIconTexture = TaskIconTexStr,
		TaskSoundName = TaskSoundStr,
		NPCIconTexture = NPCIconTexStr,
		Message = Message,
		TimeInSeconds = TimeInSeconds or kInfoPanelUpdateInterval,
		TaskId = TaskId,
	}
	
	local queueIndex = #self.entryQueue+1
	
	----------------------------
	-- Attempt a refresh
	----------------------------
	if ( self.bScreenInit ) and ( self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing == true ) and ( self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskId == TaskId ) then
		queueIndex = nil
		self:SetInfoPanelFields( tbl.NPCIconTexture, tbl.TaskIconTexture, tbl.Message, tbl.TimeInSeconds, tbl.TaskId, tbl.TaskSoundName )
		UIEngineUtils:AptCallFunction( "RefreshInfoPanel", nil, self.uiTags[kSwfIndex_HUDInfoPanel], 0 )
		self:ShowScreen() -- make sure info panel is showing and is resized properly
		self:PlayBounce() -- bounce info panel for aesthetic goodness
		self:CreatePopUpTimer() -- reset timer
	else
		for i,entry in ipairs(self.entryQueue) do
			if TaskId ~= nil and entry.TaskId == TaskId then
				queueIndex = i
				break
			end -- if entry.TaskId is this TaskId
		end -- for self.entryQueue
	end -- check if this TaskId is showing right now
	
	if ( queueIndex ~= nil ) then
		self.entryQueue[queueIndex] = tbl
	end -- verify queueIndex
	
	--if the dialog's not showing then, get it started up.
	if( self.bScreenInit ) then
		if( self.uiTblRefs[kSwfIndex_HUDInfoPanel].dialogShowing == false ) then
			--start processing the items in the queue	
			self:ProcessItems()
		end -- check if dialog isn't showing yet
	end	-- check self.bScreenInit
end


--pops off the front of the queue.
function HUDMenu:PopInfoItemOffQueue()
	
	local retVal = nil
	--see if we have anything in the queue
	if( #self.entryQueue > 0 ) then
		retVal = table.remove( self.entryQueue, 1 )
	end
	
	return retVal
end

function HUDMenu:PlayBounce()
	UIEngineUtils:AptCallFunction( "PlayBounce", nil, self.uiTags[kSwfIndex_HUDInfoPanel], 0 )
end

function HUDMenu:DisableOpenTaskCardShortcut()
	self.bIsTaskCardShortcutEnabled = false
end

function HUDMenu:EnableOpenTaskCardShortcut()
	self.bIsTaskCardShortcutEnabled = true
end