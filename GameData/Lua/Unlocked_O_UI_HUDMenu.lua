
--- HUD Menu Override -----------------------------------------------------------------

local kSwfIndex_InteractionMenu = 1
local kSwfIndex_HUDMenu = 2
local kSwfIndex_HUDInfoPanel = 3


-- TODO: find better way than huge function override
function Classes.HUDMenu:LoopInternal()
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
        --- custom code start
        -- TODO: make flying toggleable (in-game or config file)
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
        --- custom code end
    elseif( self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskShortcut == "1" ) then
        UI:SpawnAndBlock( "UITasksList" )
        self.uiTblRefs[kSwfIndex_HUDInfoPanel].TaskShortcut = nil
    end
end
