
--- Animal Overrides -----------------------------------------------------------------

--{{{ Animal Interactions --------------------------------------------------------------
local function addInteractionsToAnimals()
    for _,animal in pairs(Constants.AnimalTable) do
        local class = animal.class

        if class ~= nil then
            if not class.interactionSet then
                class.interactionSet = {}
            end

            if class.interactionSet.Hyaa then
                class.interactionSet.Hyaa.menu_priority  = 0
            end
            if class.interactionSet.Pet then
                class.interactionSet.Pet.menu_priority   = 1
            end
            if class.interactionSet.Feed then
                class.interactionSet.Feed.menu_priority  = 2
            end
            if class.interactionSet.Fluff then
                class.interactionSet.Fluff.menu_priority = 3
            end
            if class.interactionSet.Milk then
                class.interactionSet.Milk.menu_priority  = 3
            end

            class.interactionSet.PushSim = {
                name                    = "STRING_INTERACTION_CHARACTERBASE_PushSim",
                interactionClassName    = "CharacterBase_Debug_PushSim",
                icon                    = "uitexture-interaction-warmhands",
                menu_priority           = 21,
            }
            class.interactionSet.Teleport = {
                name                    = "STRING_INTERACTION_CHARACTERBASE_TELEPORT",
                interactionClassName    = "CharacterBase_Interaction_TeleportToSafePosition",
                icon                    = "uitexture-interaction-teleport",
                menu_priority           = 22,
            }
            class.interactionSet.DebugUi = {
                name                    = "Debug Menu",
                interactionClassName    = "Unlocked_AnimalMenu",
                icon                    = "uitexture-interaction-use",
                menu_priority           = 30,
            }
        end
    end
end

addInteractionsToAnimals()
--}}}