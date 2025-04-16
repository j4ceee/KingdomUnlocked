
local Unlocked_CheatMenu = Classes.Job_InteractionBase:Inherit("Unlocked_CheatMenu")

function Unlocked_CheatMenu:Test( sim, obj, autonomous )
    -- DEBUG ONLY
    return DebugMenu:GetValue("EnableDebugInteractions") and sim == Universe:GetPlayerGameObject()
end

function Unlocked_CheatMenu:Destructor()
end

function Unlocked_CheatMenu:Action( player, obj )
	
    if self.params and self.params.actionKey then

        if self.params.actionKey == "db_menu" then
            --===========================================================================--
            -- Cheat Menu Logic --

            if EA.LogMod then
                EA:LogMod("KingdomUnlocked", "Opened Cheat Menu")
            end

            -- Disable autosave
            if GameManager:IsAutoSave() then
                GameManager:SetAutoSave( false )
            end

            local selection = UI:DisplayModalDialog( "Cheat Menu", "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).", nil, 4, "Open Clothing Cheats", "Exit", "Give all resources", "Unlock post-game blocks")

            if selection == 0 then
                EA:LogMod('Test', 'Opened Clothing Cheat Menu')
                local casTables = { PauseUnlockCodes, Constants.CAS_BFF, Constants.CAS_Misc }

                local selectionClothes = UI:DisplayModalDialog( "Cheat Menu", "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).\n *Work in progress (does not cover all clothing pieces yet)", nil, 4, "Unlock Bonus Clothing", "Exit", "*Unlock all Clothing", "*Lock all Clothing")

                if selectionClothes == 0 then -- Bonus Clothing
                    self:UnlockClothes(true, { casTables[1] })

                elseif selectionClothes == 1 then -- Exit
                    return

                elseif selectionClothes == 2 then -- unlock all clothes
                    self:UnlockClothes(true, casTables)

                elseif selectionClothes == 3 then -- lock all clothes
                    self:UnlockClothes(false, casTables)
                end

            elseif selection == 1 then
                return

            elseif selection == 2 then
                AddResourcesCheat(_, true)

            elseif selection == 3 then
                -- unlock wingame blocks
                Unlocks:Unlock( "unlock", "unlock_blocks_wingame" )
                Unlocks:Unlock( "unlock", "essences" )
                Unlocks:Unlock( "unlock", "plantables" )
                Unlocks:Unlock( "unlock", "social_essences" )
            end
        elseif self.params.actionKey == "db_menu_islands" then
            --===========================================================================--
            -- Island Cheat Menu Logic --

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
        elseif self.params.actionKey == "db_spawn" then
            --===========================================================================--
            -- Spawn Menu Logic --

            if EA.LogMod then
                EA:LogMod("KingdomUnlocked", "Opened Spawn Menu")
            end

            UI:SpawnAndBlock( "UIRelationshipBook", "spawn" )
        end
    end	
	
	return
end

--- Function to Lock or Unlock all clothing in a given table, Parameters:
--- - unLock - boolean, true to unlock, false to lock
--- - casTables - table containing tables with unlockable CAS items
---
function Unlocked_CheatMenu:UnlockClothes( unLock, casTables )
    for i, casTable in ipairs(casTables) do
        EA:LogMod('Test', 'Looping over table ' .. i)
        for j, unlock in ipairs(casTable) do
            local unlockClass = unlock.classString

            local unlockCollection = unlock.collectionString
            if (type(unlock.collectionString) ~= "table") then
                unlockCollection = { unlockCollection }
            end

            local msg = ""
            if (unlockClass == "reward") then
                msg = Luattrib:ReadAttribute("reward", unlockCollection, "RewardDialogMessage" )
            else
                msg = unlock.unlockMsg
            end

            local didUnlock = false
            for k, collection in ipairs(unlockCollection) do
                if (unLock == true) then
                    if( Unlocks:IsUnlocked( unlockClass, collection ) == false ) then
                        Unlocks:Unlock( unlockClass, collection )

                        didUnlock = true
                    end
                else
                    if( Unlocks:IsUnlocked( unlockClass, collection ) == true ) then
                        Unlocks:Lock( unlockClass, collection )
                    end
                end
            end

            if (unLock and didUnlock) then
                local casUnlockItemTbl =
                {
                    {
                        "resource",
                        "shirt",
                    }
                }

                UI:DisplayRewardDialog( casUnlockItemTbl, "STRING_UNLOCK_CAS_PRESALE_TITLE", msg, { unlockClass, unlockCollection[1] }, nil )
            end
        end
    end
end