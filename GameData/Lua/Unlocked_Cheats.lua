
-- from DebugMenuItems.lua
local function AddResource( collectionName )
    local count = 999 - Inventory:ResourceGetCountByKey( collectionName )

    if count > 0 then
        Inventory:ResourceDeltaByKey( collectionName, count, false )
    end
end

function Common:AddAllResources()
    local resources = Luattrib:GetAllCollections("resource")

    for _, refspec in ipairs(resources) do

        local baseTypes = Luattrib:ReadAttribute( refspec[1], refspec[2], "BaseType" )

        local bAddResource = true

        if baseTypes then
            for _, basetype in ipairs(baseTypes) do

                if basetype[2] == refspec[2] then
                    bAddResource = false
                    break
                end
            end
        end

        if bAddResource then

            local redirect = Luattrib:ReadAttribute( refspec[1], refspec[2], "RedirectRefSpec" )

            if redirect == nil or redirect[2] == refspec[2] then
                AddResource( refspec[2] )
            end
        end

    end
end


--- Function to Lock or Unlock all clothing in a given table, Parameters:
--- - unLock - boolean, true to unlock, false to lock
--- - casTables - table containing tables with unlockable CAS items
---
function Common:UnlockClothes( unLock, casTables )
    for i, casTable in ipairs(casTables) do
        --EA:LogMod('Test', 'Looping over table ' .. i)
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

-- TODO: integrate more cheats, see DebugMenuItems.lua
