
local Unlocked_CheatMenu = Classes.Job_InteractionBase:Inherit("Unlocked_CheatMenu")

function Unlocked_CheatMenu:Test( sim, obj, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject()
end

function Unlocked_CheatMenu:Destructor()
end

function Unlocked_CheatMenu:Action( player, obj )
	
    if self.params and self.params.actionKey then

        --===========================================================================--
        -- Cheat Menu Logic --

        if self.params.actionKey == "db_menu" then
            if EA.LogMod then
                EA:LogMod("KingdomUnlocked", "Opened Cheat Menu")
            end

            -- Disable autosave
            if GameManager:IsAutoSave() then
                GameManager:SetAutoSave( false )
            end

            local world = Universe:GetWorld()
            local currentPowerState = world:GetAttribute("IsWorldPowered")

            local desc = "Choose an action. Use your cursor to select (button prompts do not match selections).\n"
            desc = desc .. "Unlock Menu - unlock all scrolls, rewards and clothing for any island\n"
            desc = desc .. "Toggle Power - objects don't require power (currently: " .. tostring(currentPowerState) .. ")\n"
            desc = desc .. "\n\n\n\n\n\n\n\n Debug Info:"
            desc = desc .. "\n - MSML_Version: " .. tostring(MSML_VERSION or "-")
            desc = desc .. "\n - EnableRealFakeAutonomy: " .. tostring(DebugMenu:GetValue("EnableRealFakeAutonomy"))
            desc = desc .. "\n"

            local selection = UI:DisplayModalDialog( "Cheat Menu", desc, nil, 4, "Toggle Power", "Exit", "Give all resources", "Open Unlock Menu" )

            if selection == 0 then -- clothing cheats
                if world then
                    world:SetAttribute("IsWorldPowered", not currentPowerState)
                end

            elseif selection == 1 then -- exit
                return

            elseif selection == 2 then -- resource cheat
                Common:AddAllResources()

            elseif selection == 3 then -- unlock menu
                UI:SpawnAndBlock( "UIWorldMap", nil, "unlockScrolls" )
            end


        --===========================================================================--
        -- Island Cheat Menu Logic --

        elseif self.params.actionKey == "db_menu_islands" then
            if EA.LogMod then
                EA:LogMod("KingdomUnlocked", "Opened Island Cheat Menu")
            end

            -- Disable autosave
            if GameManager:IsAutoSave() then
                GameManager:SetAutoSave( false )
            end

            local selection = UI:DisplayModalDialog( "Island Cheat Menu", "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).", nil, 4, "Lock all islands", "Exit", "Unlock all story islands", "Unlock reward island")

            if selection == 0 then -- Lock all islands
                local islands = Luattrib:GetAllCollections( "island" )
                for i,refspec in ipairs( islands ) do
                    local bUnlocked = Unlocks:IsUnlocked( refspec[1], refspec[2] )
                    if ( bUnlocked ) then
                        Unlocks:Lock( refspec[1], refspec[2] )
                    end
                end -- for islands

                -- unlock default islands
                Unlocks:Unlock( "island", "castle_island" )
                Unlocks:Unlock( "island", "tutorial_island" )

            elseif selection == 1 then -- exit
                return -- Exit

            elseif selection == 2 then -- unlock story islands
                local rewardUnlocked = Unlocks:IsUnlocked( "island", "reward_island" )

                local islands = Luattrib:GetAllCollections( "island" )
                for i,refspec in ipairs( islands ) do
                    local bUnlocked = Unlocks:IsUnlocked( refspec[1], refspec[2] )
                    if not ( bUnlocked ) then
                        Unlocks:Unlock( refspec[1], refspec[2] )
                    end
                end -- for islands

                -- lock reward island if it was not unlocked
                if not rewardUnlocked then
                    Unlocks:Lock( "island", "reward_island" )
                end

            elseif selection == 3 then -- unlock champion island
                Unlocks:Unlock( "island", "reward_island" )
            end


        --===========================================================================--
        -- Spawn Menu Logic --

        elseif self.params.actionKey == "db_spawn" then
            if EA.LogMod then
                EA:LogMod("KingdomUnlocked", "Opened Spawn Menu")
            end

            UI:SpawnAndBlock( "UIRelationshipBook", "spawn" )


        --===========================================================================--
        -- Clothing Cheat Menu Logic --

        elseif self.params.actionKey == "db_clothing" then
            local casTables = { Constants.CAS_Unlocks, Constants.CAS_BFF, Constants.CAS_Misc }

            local selectionClothes = UI:DisplayModalDialog( "Cheat Menu", "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).\n *Work in progress (does not cover all clothing pieces yet)", nil, 4, "Unlock Bonus Clothing", "Exit", "*Unlock all Clothing", "*Lock all Clothing")

            if selectionClothes == 0 then -- Bonus Clothing
                Common:UnlockClothes(true, { casTables[1] })

            elseif selectionClothes == 1 then -- Exit
                return

            elseif selectionClothes == 2 then -- unlock all clothes
                Common:UnlockClothes(true, casTables)

            elseif selectionClothes == 3 then -- lock all clothes
                Common:UnlockClothes(false, casTables)
            end
        end
    end	
	
	return
end

function Unlocked_CheatMenu:UnlockEverythingForIsland(islandString)
    if islandString == "reward_island" then
        Unlocks:Unlock( "unlock", "unlock_blocks_wingame" )
        Unlocks:Unlock( "unlock", "essences" )
        Unlocks:Unlock( "unlock", "plantables" )
        Unlocks:Unlock( "unlock", "social_essences" )
    else
        local allTaskRewards = Luattrib:GetAllCollections( "reward", Constants.AllTaskRewards[islandString] )
        local allScrolls = Luattrib:GetAllCollections( "reward", Constants.AllScrollRewards[islandString] )
        local everything = { allTaskRewards, allScrolls }

        for i, rTable in ipairs( everything ) do
            for j, ref in ipairs( rTable ) do
                local allUnlocks = Luattrib:ReadAttribute( ref[1], ref[2], "Unlocks" )
                for k,unlockRefSpec in ipairs(allUnlocks) do
                    Unlocks:Unlock( unlockRefSpec[1], unlockRefSpec[2] )
                end -- for allUnlocks
            end -- for rTable
        end -- for everything
    end
end