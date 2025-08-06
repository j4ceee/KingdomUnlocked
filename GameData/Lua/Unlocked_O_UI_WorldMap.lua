
--- World Map Override -----------------------------------------------------------------

local islandInfo =
{
    { texture = "uitexture-map-icon-cowboy",        collection = "cowboy_junction_island" },    --0
    { texture = "uitexture-map-icon-rocket",        collection = "rocket_reef_island" },        --1
    { texture = "uitexture-map-icon-spookane",      collection = "spookane_island" },           --2
    { texture = "uitexture-map-icon-cutesburg",     collection = "cutesburgh_island" },         --3
    { texture = "",                                 collection = "candy_island" },              --4
    { texture = "uitexture-map-icon-capitol",       collection = "castle_island" },             --5
    { texture = "",                                 collection = "tree_island" },               --6
    { texture = "",                                 collection = "gonk_island" },               --7
    { texture = "",                                 collection = "trevor_island" },             --8
    { texture = "",                                 collection = "reward_island" },             --9
    { texture = "",                                 collection = "animal_island" },             --10
    { texture = "",                                 collection = "academy_island" },            --11
    --{ texture = "", collection = "pirate_island" }, --12
}

Classes.UIWorldMap._instanceVars.mode = "default"

function Classes.UIWorldMap:BuildRefTable()
    for i, v in ipairs( islandInfo ) do
        local name = Luattrib:ReadAttribute( "island", v.collection, "UIIslandName" )
        self.uiTblRef[ "IslandName" .. (i-1) ] = name
        self.uiTblRef[ "IslandIconTexture" .. (i-1) ] = v.texture

        if ( self.mode == "unlockScrolls" or Unlocks:IsUnlocked("island", v.collection) ) then
            self.uiTblRef[ "IslandLocked" .. (i-1) ] = 0
        else
            self.uiTblRef[ "IslandLocked" .. (i-1) ] = 1
        end
    end

    -- if revealing a new unlocked island, then set island's initial status to locked
    for i=0, self.uiTblRef.UnlockCount - 1 do
        self.uiTblRef[ "IslandLocked" .. self.uiTblRef[ "UnlockIsland" .. i ] ] = 1
    end -- verify UnlockIsland
end

function Classes.UIWorldMap:SetParams( unlockIslands, mode )
    self.mode = mode or "default"

    self:CreateKeybinds()

    self.uiTblRef.Hit = nil
    self.uiTblRef.UnlockCount = 0

    if( unlockIslands ~= nil ) then
        if( type( unlockIslands ) ~= "table" ) then
            unlockIslands = { unlockIslands, }
        end

        for num, unlockIsland in ipairs( unlockIslands ) do
            for i, v in ipairs( islandInfo ) do
                if ( unlockIsland == v.collection ) then
                    self.UnlockingMode = 1
                    self.uiTblRef[ "UnlockIsland" .. ( num - 1 ) ] = i - 1
                    self.uiTblRef.UnlockCount = self.uiTblRef.UnlockCount + 1
                    break
                end
            end
        end
    end

    self:BuildRefTable()

    if ( self.mode ~= "unlockScrolls" ) then
        local island = Luattrib:ConvertStringToUserdataKey( tostring( Universe:GetWorld() ) )

        for i, v in ipairs( islandInfo ) do
            local myIsland = Universe:GetIslandStartingWorld( "island" , v.collection )
            if( island ==  myIsland[2] ) then
                self.uiTblRef.CurrentIsland = i-1
                break
            end
        end
    end

    self.uiTblRef.NumIslands = #islandInfo
end

function Classes.UIWorldMap:LoopInternal()
    if( self.uiTblRef.Hit == "exit" ) then

        --REMOVED BY REQUEST
        --[[
        if( self.UnlockingMode == 1 ) then
            for i=0, self.uiTblRef.UnlockCount - 1 do
                local islandName = Luattrib:ReadAttribute( "island", islandInfo[ self.uiTblRef[ "UnlockIsland" .. i ] + 1 ].collection, "UIIslandName" )
                UIEngineUtils:SetSub( "ISLANDNAME", islandName )
                UI:DisplayModalPopUpDialog( "STRING_UI_WORLDMAP_ISLANDUNLOCKTITLE",
                                            "STRING_UI_WORLDMAP_ISLANDUNLOCKMESSAGEFRONT",
                                            "",
                                            1,
                                            ( "OKAY_BUTTON" ) )
            end
        end
        --]]
        ---END REMOVED

        self.bExitLoop = true
    elseif( self.uiTblRef.Hit ~= nil ) then
        ------------------------
        -- START DEMO BUILD HACK
        ------------------------
        local bAllow = true
        if ( DebugMenu:GetValue("DemoE3") == true ) then
            local id = tonumber(self.uiTblRef.Hit)
            local islandName = islandInfo[id+1].collection

            if ( islandName ~= "cowboy_junction_island" ) and ( islandName ~= "rocket_reef_island" ) and ( islandName ~= "castle_island" ) then
                bAllow = false
            end -- check islands
        elseif ( DebugMenu:GetValue("DemoPreview") == true ) then
            local id = tonumber(self.uiTblRef.Hit)
            local islandName = islandInfo[id+1].collection

            if ( islandName ~= "cowboy_junction_island" ) and ( islandName ~= "animal_island" ) and ( islandName ~= "castle_island" ) then
                bAllow = false
            end -- check islands
        end -- check demo unlock permissions

        if ( bAllow ) then
            ----------------------
            -- END DEMO BUILD HACK
            ----------------------
            if ( self.mode == "unlockScrolls" ) then
                local stringName = islandInfo[tonumber(self.uiTblRef.Hit)+1].collection
                local name = Luattrib:ReadAttribute( "island", stringName, "UIIslandName" )

                local message = "Are you want to unlock everything for this island?\nThis will unlock all scrolls, rewards and clothing for this island. This cannot be undone.\n"
                if ( stringName == "reward_island" ) then
                    local dialogReturn = UI:DisplayModalPopUpDialog( name,
                            "Do you want to unlock all post-game blocks or Day 2 scrolls, rewards and clothing?",
                            "uitexture-warning",
                            2,
                            "Post-Game Blocks",
                            "Day 2 Content")

                    if (dialogReturn == 0 ) then -- post-game blocks
                        message = "Are you want to unlock all post-game blocks?\nThis will unlock all post-game blocks. This cannot be undone.\n"
                    elseif (dialogReturn == 1 ) then -- day 2 content
                        stringName = "day2"
                        message = "Are you want to unlock all Day 2 content?\nThis will unlock all Day 2 scrolls, rewards and clothing. This cannot be undone.\n"
                    end
                end

                local dialogReturn = UI:DisplayModalPopUpDialog( name, message,
                        "uitexture-warning",
                        2,
                        ( "YES_BUTTON" ),
                        ( "NO_BUTTON" ) )

                if (dialogReturn == 0 ) then
                    Classes.Unlocked_CheatMenu:UnlockEverythingForIsland( stringName )
                end
            else
                local dialogReturn = UI:DisplayModalPopUpDialog( "STRING_UI_WORLDMAP_LEAVEISLANDTITLE",
                        "STRING_UI_WORLDMAP_LEAVEISLANDMESSAGE",
                        "uitexture-warning",
                        2,
                        ( "YES_BUTTON" ),
                        ( "NO_BUTTON" ) )

                if (dialogReturn == 0 ) then
                    self:SwitchIsland( tonumber(self.uiTblRef.Hit) )
                    self.bExitLoop = true
                end
            end

            ------------------------
            -- START DEMO BUILD HACK
            ------------------------
        end -- check bAllow
        ----------------------
        -- END DEMO BUILD HACK
        ----------------------
    end

    self.uiTblRef.Hit = nil
end