
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

            -- Disable autosave
            if GameManager:IsAutoSave() then
                GameManager:SetAutoSave( false )
            end

            local selection = UI:DisplayModalDialog( "Cheat Menu", "Choose an action. Use your cursor to select or exit with B (button prompts do not match selections).", nil, 4, "Unlock bonus clothing", "Exit", "Give all resources", "Unlock post-game blocks")

            if selection == 0 then
                for i, unlock in ipairs(PauseUnlockCodes) do
                    local msg = unlock.unlockMsg
                    local unlockClass = unlock.classString
                    local unlockCollection = unlock.collectionString

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
            UI:SpawnAndBlock( "UIRelationshipBook", "spawn" )
        end
    end	
	
	return
end
  
