--- Generic function to check if a string starts with a certain substring
--- @param String string The string to check
--- @param Start string The substring to check for
--- @return boolean
function Common:str_starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

--- Generic function to check if a table contains a value
--- @param tab table The table to search in
--- @param val any The value to search for
--- @return boolean
function Common:tbl_has_value (tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

--- Generic function to find a sim on the current island
function Common:FindSimOnCurrentIsland( typeName )
    local world = Universe:GetWorld()

    local characters = world:CreateArrayOfObjects( "character" )

    for _, go in pairs( characters ) do
        if ( Class:InheritsFrom(go,typeName) ) then
            return go
        end
    end

    return nil -- not found on any world
end

--- Finds the exterior world corresponding to the given interior world
--- @param interiorWorld any The interior world to find the exterior for
--- @return any The exterior world if found, nil otherwise
function Common:GetExteriorWorld(interiorWorld)
    -- Find the buildable region corresponding to dest world
    --
    local regionList = Common:GetAllObjectsOfTypeOnIsland( "buildable_region" )

    for i, region in ipairs( regionList ) do
        local connectedWorld = region:GetAttribute("ConnectedWorld")

        if connectedWorld and connectedWorld[2] == interiorWorld.collectionKey then
            return region.containingWorld
        end
    end

    return nil -- not found
end

--- Finds the interior world corresponding to the given buildable region
--- @param buildableRegion any The buildable region to find the interior for
--- @return any The interior world if found, nil otherwise
function Common:GetInteriorWorld(buildableRegion)
    local connectedWorld = buildableRegion:GetAttribute("ConnectedWorld")
    local connectedCollectionKey = connectedWorld[2]

    -- using connectedCollectionKey directly in Universe:GetWorld() does not work for some reason
    -- so we iterate through the Constants.InteriorWorlds to find the matching world
    for _, worldCollectionKey in ipairs(Constants.InteriorWorlds) do
        local testWorld = Universe:GetWorld(worldCollectionKey)
        if testWorld then
            if testWorld.collectionKey == connectedCollectionKey then
                return testWorld
            end
        end
    end

    return nil
end

--- makes an object fly up and stay there for an amount of frames
--- @param obj any The object to fly (required)
--- @param upY number The amount of units to fly up (defaults to 2)
--- @param frameCount number The amount of frames to stay in the air (defaults to 120)
function Common:FakeFly( obj, upY, frameCount )
    if not ( obj ) then
        if EA.LogMod then
            EA:LogMod("FakeFly", "Missing game object to fly")
        end
        return
    end

    upY = upY or 2
    frameCount = frameCount or 120

    local frame = 0

    local _, startY, _, _ = obj:GetPositionRotation()

    finalY = startY + upY

    local function easeOutCubic(t)
        local v = 1 - t
        return 1 - v * v * v
    end

    local function easeOutQuartic(t)
        local v = 1 - t
        return 1 - v * v * v * v
    end

    local currentWorld = Universe:GetWorld()

    local function PositionClosure( job )
        local curX, _, curZ, curRot =obj:GetPositionRotation()

        -- Calculate progress (0 to 1)
        local progress = frame / frameCount
        -- Apply easing to the progress
        local easedProgress = easeOutQuartic(progress)
        -- Calculate new Y position using eased progress
        local y = startY + (finalY - startY) * easedProgress

        obj:SetPositionRotation( curX, y, curZ, curRot )

        --position = { x = x, y = y, z = z }
        --CameraController:SetFixedCamera( { x = curX, y = y + 10, z = curZ }, { x = curX, y = y, z = curZ }, 0.1 )
        local initFunc = function( block )
            if block then
                block:SetScale( 0 )
                block:Destroy()
            end
        end

        local spawnJob = Classes.Job_SpawnObject:Spawn(
                "block",           -- class (character or herdables)
                "food_placesetting_01",     -- collection
                currentWorld,  -- parent world
                curX, y, curZ,         -- position
                curRot
        )

        spawnJob:SetInitFunction( initFunc )

        spawnJob:Execute(currentWorld)

        if frame == frameCount then
            job:Destroy()
        end
        frame = frame + 1
    end

    local job = Classes.Job_PerFrameFunctionCallback:Spawn( PositionClosure )
    job:ExecuteAsIs()

    return job
end

function Common:ScaleObject( obj, finalScale, frameCount )

    local frame = 0
    local initialScale = obj:GetScale()

    if initialScale ~= finalScale then

        local function ScaleClosure( job )
            local scale = ((finalScale-initialScale)/frameCount)*frame + initialScale

            obj:SetScale( scale )

            if obj.fVisScale then
                obj.fVisScale = scale
            end

            if frame == frameCount then
                job:Destroy()
            end
            frame = frame + 1
        end

        local job = Classes.Job_PerFrameFunctionCallback:Spawn( ScaleClosure )
        job:ExecuteAsIs()

        return job
    end
end

--- Finds an NPC by its mType (script name)
--- @param mType string The mType (script name) of the NPC to find
--- @return string|nil The collection key of the NPC if found, nil otherwise
--- @return string|nil The name of the NPC if found, nil otherwise
--- @return string|nil The face icon of the NPC if found, nil otherwise
--- @return string|nil The home island of the NPC if found, nil otherwise
function Common:GetNPC(mType)
    local refSpecs = Luattrib:GetAllCollections( "character", nil )

    for i, collection in ipairs(refSpecs) do
        collection = collection[2] -- collection key

        local script = Luattrib:ReadAttribute( "character", collection, "ScriptName" )

        if script == mType then
            local homeIsland = Luattrib:ReadAttribute( "character", collection, "HomeIsland" )
            local home = nil

            if( homeIsland ~= nil ) then
                home = homeIsland[2]
            end

            local face = Luattrib:ReadAttribute( "character", collection, "FaceIcon" ) --get face icon
            local name = Luattrib:ReadAttribute( "character", collection, "FullName" ) --get name

            return collection, name, face, home
        end
    end
end

--- Finds all objects of a table of types on the current island
--- @param types table A table containing the object types to search for (e.g. {"buildable_region", "fishing_bucket"})
--- @return table A table containing all found objects of the specified types
function Common:GetAllObjectsOfTypes( types )
    local world = Universe:GetWorld()
    local foundObjects = {}

    for _, typeName in ipairs(types) do
        local objects = world:CreateArrayOfObjects( typeName )
        for _, obj in pairs(objects) do
            table.insert(foundObjects, obj)
        end
    end

    return foundObjects
end

--- Table containing all mTypes of the NPCs of pirate cove
Constants.PirateCoveScripts = {
    "NPC_Neema",
    "NPC_Mira",
    "NPC_Morgan",
    "NPC_Theodore",
}

--- Table containing names & icons of all herdables (by script names / mType)
Constants.AnimalTable = {
    -- base class
    ["HerdableScriptObjectBase"] = {
        name = nil,
        icon = nil,
        collectionKey = nil,
        class = Classes.HerdableScriptObjectBase,
        enabled = false
    },

    -- spawnable animals
    ["Bobaboo"] = {
        name = "Bobaboo",
        icon = "uitexture-map-icon-gonk",
        collectionKey = "reverse_herdable_bobaboo",
        class = Classes.Bobaboo,
        enabled = true,
    },
    ["Cow"] = {
        name = "Cow",
        icon = "uitexture-figurine-cow",
        collectionKey = "cow_cj_01",
        class = Classes.Cow,
        enabled = true,
    },
    ["Pig"] = {
        name = "Pig",
        icon = "uitexture-map-icon-animal",
        collectionKey = "pig_cap_01",
        class = Classes.Pig,
        enabled = true,
    },
    ["PercyPig"] = {
        name = "Sir Percival J. Worthington IV",
        icon = "uitexture-map-icon-animal",
        collectionKey = "pig_animal",
        class = Classes.PercyPig,
        enabled = true,
    },
    ["Unicorn"] = {
        name = "Unicorn",
        icon = "uitexture-map-icon-leaf",
        collectionKey = "unicorns",
        class = Classes.Unicorn,
        enabled = true,
    },
    ["Hedgehog"] = {
        name = "Hedgehog",
        icon = nil,
        collectionKey = "leaf_hedgehog_01",
        class = Classes.Hedgehog,
        enabled = true,
    },
    ["HedgehogLarge"] = {
        name = "Filbert",
        icon = nil,
        collectionKey = "academy_hedgehog_01",
        class = Classes.HedgehogLarge,
        enabled = true,
    },
    ["Bunny"] = {
        name = "Bunny",
        icon = nil,
        collectionKey = "bunny_leaf_master",
        class = Classes.Bunny,
        enabled = true,
    },
    ["Spider"] = {
        name = "Spider",
        icon = "uitexture-essence-flair-spider",
        collectionKey = "spiders",
        class = Classes.Spider,
        enabled = true,
    },
    ["Frog"] = {
        name = "Frog",
        icon = nil,
        collectionKey = "frog",
        class = Classes.Frog,
        enabled = true,
    },
    ["Crab"] = {
        name = "Crab",
        icon = "uitexture-fish-crab",
        collectionKey = "crabs",
        class = Classes.Crab,
        enabled = true,
    },

    -- missing interactions (so cannot be deleted)
    -- TODO: find a way to make them deletable (e.g. RelationshipBook DEspawn functionality)

    ["HerdableTrevor"] = {
        name = "Trevor (Running)",
        icon = "uitexture-npc-head-trevor",
        collectionKey = nil,
        class = Classes.HerdableTrevor,
        enabled = false,
    },
    ["ToborLegs"] = {
        name = "Tobor (Legs)",
        icon = "uitexture-npc-head-tobor",
        collectionKey = nil,
        class = Classes.ToborLegs,
        enabled = false,
    },
    ["Bear"] = {
        name = "Bear",
        icon = nil,
        collectionKey = nil,
        class = Classes.Bear,
        enabled = false,
    },
    ["Panda_Cub"] = {
        name = "Bear Cub",
        icon = nil,
        collectionKey = nil,
        class = Classes.Panda_Cub,
        enabled = false,
    },
    ["Raccoon"] = {
        name = "Raccoon",
        icon = nil,
        collectionKey = "raccoons",
        class = Classes.Raccoon,
        enabled = false,
    },
    ["Dog"] = {
        name = "Dog",
        icon = nil,
        collectionKey = nil, -- 2 - 4 is wandering dog (max. 4)
        class = Classes.Dog,
        enabled = false,
    },
    ["CatAnimal"] = {
        name = "Cat",
        icon = nil,
        collectionKey = nil, -- 3 is following cat (max. 3)
        class = Classes.CatAnimal,
        enabled = false,
    },

    -- never spawn
    ["HerdableTrevor2"] = { name = nil, icon = nil, collectionKey = nil, class = Classes.HerdableTrevor2, enabled = false },
    ["HerdableTrevor3"] = { name = nil, icon = nil, collectionKey = nil, class = Classes.HerdableTrevor3, enabled = false },
    ["HerdableTrevor4"] = { name = nil, icon = nil, collectionKey = nil, class = Classes.HerdableTrevor4, enabled = false },
    ["DummyScript"] = { name = nil, icon = nil, collectionKey = nil, class = nil, enabled = false },
}

--- Table containing head & body models of all NPCs (by script names / mType)
Constants.ModelsTable = {
    --------------------------------------
    --Capital Island----------------------
    --------------------------------------
    ["NPC_Linzey"] = {
        body = "afBodyLindsayNPC",
        head = "afHeadLindsayNPC",
    },
    ["NPC_Buddy"] = {
        body = "amBodyBuddyNPC",
        head = "amHeadBuddyNPC",
    },
    ["NPC_King"] = {
        body = "amBodyKingRolandNPC",
        head = "amHeadKingRolandNPC",
    },
    ["NPC_Pigman"] = {
        body = "afBodyElmiraNPC",
        head = "afHeadElmiraNPC",
    },
    ["NPC_Butter"] = {
        body = "afBodyPrincessButterNPC",
        head = "afHeadPrincessButterNPC",
    },
    ["NPC_Barney"] = {
        body = "amBodyBarneyNPC",
        head = "amHeadBarneyNPC",
    },
    ["NPC_Marlin"] = {
        body = "amBodyWizardNPC",
        head = "amHeadWizardNPC",
    },

    --------------------------------------
    --Cowboy Junction---------------------
    --------------------------------------
    ["NPC_Gino"] = {
        body = "amBodyChefNPC",
        head = "amHeadChefNPC",
    },
    ["NPC_Roxie"] = {
        body = "afBodyRoxieNPC",
        head = "afHeadRoxieNPC",
    },
    ["NPC_Ginny"] = {
        body = "afBodySheriffGinnyNPC",
        head = "afHeadSheriffGinnyNPC",
    },
    ["NPC_Rusty"] = {
        body = "amBodyRustyNPC",
        head = "amHeadRustyNPC",
    },
    ["NPC_Gabby"] = {
        body = "amBodyGabbyNPC",
        head = "amHeadGabbyNPC",
    },

    --------------------------------------
    -- Trevor Island----------------------
    --------------------------------------
    ["NPC_Trevor"] = {
        body = "amBodyTrevorNPC",
        head = "amHeadTrevorNPC",
    },
    ["NPC_Linda"] = {
        body = "afBodyLindaNPC",
        head = "afHeadLindaNPC",
    },
    ["NPC_Gordon"] = {
        body = "amBodyGordonNPC",
        head = "amHeadGordonNPC",
    },

    --------------------------------------
    -- Rocket Reef------------------------
    --------------------------------------
    ["NPC_Tobor"] = {
        body = "amBodyToborNPC",
        head = "amHeadToborNPC",
    },
    ["NPC_Alexa"] = {
        body = "afBodyAlexaNPC",
        head = "afHeadAlexaNPC",
    },
    ["NPC_DrF"] = {
        body = "amBodyDrFNPC",
        head = "amHeadDrFNPC",
    },
    ["NPC_Vic"] = {
        body = "amBodyVicVectorNPC",
        head = "amHeadVicVectorNPC",
    },


    --------------------------------------
    -- Shipwreck Cove---------------------
    --------------------------------------
    ["NPC_Theodore"] = {
        body = "amBodyTheodoreNPC",
        head = "amHeadTheodoreNPC",
    },
    ["NPC_Neema"] = {
        body = "afBodyNeemaNPC",
        head = "afHeadNeemaNPC",
    },
    ["NPC_Mira"] = {
        body = "afBodyMiraNPC",
        head = "afHeadMiraNPC",
    },
    ["NPC_Morgan"] = {
        body = "afBodyMorganNPC",
        head = "afHeadMorganNPC",
    },

    --------------------------------------
    -- Cute ------------------------------
    --------------------------------------
    ["NPC_Violet"] = {
        body = "afBodyVioletNPC",
        head = "afHeadVioletNPC",
    },
    ["NPC_Daniel"] = {
        body = "amBodyLordDanielNPC",
        head = "amHeadLordDanielNPC",
    },
    ["NPC_Spencer"] = {
        body = "amBodySpencerPaladinNPC",
        head = "amHeadSpencerPaladinNPC",
    },
    ["NPC_Poppy"] = {
        body = "afBodyPoppyNPC",
        head = "afHeadPoppyNPC",
    },
    ["NPC_Beverly"] = {
        body = "afBodyDuchessBeverlyNPC",
        head = "afHeadDuchessBeverlyNPC",
    },

    --------------------------------------
    -- Renee's Nature Preserve------------
    --------------------------------------
    ["NPC_Renee"] = {
        body = "afBodyReneeNPC",
        head = "afHeadReneeNPC",
    },

    --------------------------------------
    -- Forest of the Elves----------------
    --------------------------------------
    ["NPC_Hopper"] = {
        body = "amBodyHopperNPC",
        head = "amHeadHopperNPC",
    },
    ["NPC_Protomakoto"] = {
        body = "afBodyProtoMakotoNPC",
        head = "afHeadProtoMakotoNPC",
    },
    ["NPC_Leaf"] = {
        body = "amBodyLeafNPC",
        head = "amHeadLeafNPC",
    },
    ["NPC_Petal"] = {
        body = "afBodyPetalNPC",
        head = "afHeadPetalNPC",
    },


    --------------------------------------
    -- Spookane --------------------------
    --------------------------------------
    ["NPC_Gothboy"] = {
        body = "amBodyGothBoyNPC",
        head = "amHeadGothBoyNPC",
    },
    ["NPC_Yuki"] = {
        body = "afBodyYukiNPC",
        head = "afHeadYukiNPC",
    },
    ["NPC_Morcubus"] = {
        body = "amBodyMorcubusNPC",
        head = "amHeadMorcubusNPC",
    },
    ["NPC_Ruthie"] = {
        body = "afBodyRuthieNPC",
        head = "afHeadRuthieNPC",
    },
    ["NPC_Zombie_Carl"] = {
        body = "amBodyZombieCarlNPC",
        head = "amHeadZombieCarlNPC",
    },



    --------------------------------------
    -- Candy -----------------------------
    --------------------------------------
    ["NPC_Raver2"] = {
        body = "afBodySapphireNPC",
        head = "afHeadSapphireNPC",
    },
    ["NPC_DJCandy"] = {
        body = "afBodyDJCandyNPC",
        head = "afHeadDJCandyNPC",
    },
    ["NPC_Raver1"] = {
        body = "amBodyZackNPC",
        head = "amHeadZackNPC",
    },

    --------------------------------------
    -- Gonk ------------------------------
    --------------------------------------
    ["NPC_Gonk"] = {
        body = "amBodyGonkNPC",
        head = "amHeadGonkNPC",
    },
    ["NPC_Sylvia"] = {
        body = "afBodySylviaNPC",
        head = "afHeadSylviaNPC",
    },
    ["NPC_Vincent_Skullfinder"] = {
        body = "amBodyVincentNPC",
        head = "amHeadVincentNPC",
    },

    --------------------------------------
    -- Academy ---------------------------
    --------------------------------------
    ["NPC_Travis"] = {
        body = "amBodyTravisNPC",
        head = "amHeadTravisNPC",
    },
    ["NPC_Chaz"] = {
        body = "amBodyChazNPC",
        head = "amHeadChazNPC",
    },
    ["NPC_Rosalyn"] = {
        body = "afBodyRosalynNPC",
        head = "afHeadRosalynNPC",
    },
    ["NPC_Summer"] = {
        body = "afBodySummerNPC",
        head = "afHeadSummerNPC",
    },
    ["NPC_Liberty"] = {
        body = "afBodyLibertyNPC",
        head = "afHeadLibertyNPC",
    },

    --------------------------------------
    -- EXTRA ---------------------------
    --------------------------------------
    -- these NPCs are added in "Extra" island
    ["Beebee"] = {
        body = "afBodyBeeBeeNPC",
        head = "afHeadBeeBeeNPC",
    },
    ["Shirley"] = {
        body = nil,
        head = "afHeadShirleyNPC",
    },
    ["Makoto_Human"] = {
        body = nil,
        head = "afHeadMakotoNPC",
    },
    ["Princess"] = {
        body = nil,
        head = "afHeadPrincessNPC",
    },
}


--- CAS Tables

--- Clothes unlocked by being BFF with Sim
Constants.CAS_BFF = {
    {
        unlockMsg = "Buddy & Lyndsay Outfits",
        classString = "unlock",
        collectionString = "buddy_lyndsay_outfits",
    },

    -- TODO: Alexa missing

    {
        unlockMsg = "Barney BFF",
        classString = "unlock",
        collectionString = { "barney_hat", "barney_hat_female"},
    },

    {
        unlockMsg = "Chaz BFF",
        classString = "unlock",
        collectionString = { "chaz_unlock_male", "chaz_unlock_female" },
    },

    {
        unlockMsg = "Gino BFF",
        classString = "unlock",
        collectionString = { "chef_body", "chef_body_hat" },
    },

    -- TODO: DJ Candy missing
    -- TODO: Dr. F missing

    {
        unlockMsg = "Beverly BFF",
        classString = "unlock",
        collectionString = { "beverly_unlock_male", "beverly_unlock_female" },
    },

    {
        unlockMsg = "Elmira BFF",
        classString = "unlock",
        collectionString = { "elmira_body", "elmira_accessories" },
    },

    -- TODO: Gonk missing
    -- TODO: Goth Boy missing

    {
        unlockMsg = "Ruthie BFF",
        classString = "unlock",
        collectionString = { "ruthie_unlock_male", "ruthie_unlock_female" },
    },

    -- TODO: Hopper missing
    -- TODO: King Roland missing

    {
        unlockMsg = "Leaf BFF",
        classString = "unlock",
        collectionString = { "leaf_female", "leaf_body_hat" },
    },

    {
        unlockMsg = "Liberty BFF",
        classString = "unlock",
        collectionString = "liberty_unlock_female",
    },

    {
        unlockMsg = "Linda Clothes", -- Linda has no relationship
        classString = "unlock",
        collectionString = "linda_unlock_male",
    },

    {
        unlockMsg = "Daniel BFF",
        classString = "unlock",
        collectionString = { "daniel_unlock_male", "daniel_unlock_female" },
    },

    {
        unlockMsg = "Marlon Clothes", -- Marlon has no relationship
        classString = "unlock",
        collectionString = "marlon_body_hat",
    },

    -- TODO: Morcobus missing
    -- TODO: Gabby missing

    {
        unlockMsg = "Petal BFF",
        classString = "unlock",
        collectionString = { "petal_unisex_hats", "petal_body" },
    },

    {
        unlockMsg = "Poppy BFF",
        classString = "unlock",
        collectionString = { "poppy_unlock_male", "poppy_unlock_female" },
    },

    {
        unlockMsg = "Butter BFF",
        classString = "unlock",
        collectionString = { "butter_male", "butter_female" },
    },

    {
        unlockMsg = "Proto Makoto BFF",
        classString = "unlock",
        collectionString = "robotgirl_body_hat",
    },

    {
        unlockMsg = "Renée BFF",
        classString = "unlock",
        collectionString = "renee_body",
    },

    {
        unlockMsg = "Rosalyn BFF",
        classString = "unlock",
        collectionString = { "rosalyn_unlock_male", "rosalyn_unlock_female" },
    },

    {
        unlockMsg = "Roxie BFF",
        classString = "unlock",
        collectionString = { "roxie_unisex_cow", "roxie_body_hair" },
    },

    {
        unlockMsg = "Rusty BFF",
        classString = "unlock",
        collectionString = { "rusty_male", "rusty_unisex" },
    },

    {
        unlockMsg = "Sapphire BFF",
        classString = "unlock",
        collectionString = { "sapphire_male_raverdm", "sapphire_body", "raver2_body" },
    },

    {
        unlockMsg = "Ginny BFF",
        classString = "unlock",
        collectionString = "ginny_body_hat",
    },

    {
        unlockMsg = "Spencer BFF",
        classString = "unlock",
        collectionString = { "spencer_unlock_male", "spencer_unlock_female" },
    },

    {
        unlockMsg = "Summer BFF",
        classString = "unlock",
        collectionString = { "summer_unlock_male", "summer_unlock_female" },
    },

    {
        unlockMsg = "Sylvia BFF",
        classString = "unlock",
        collectionString = { "sylvia_unlock_male", "sylvia_unlock_female" },
    },

    {
        unlockMsg = "T.O.B.O.R. BFF",
        classString = "unlock",
        collectionString = "robotboy_body_hat",
    },

    {
        unlockMsg = "Travis BFF",
        classString = "unlock",
        collectionString = { "travis_unlock_male", "travis_unlock_female" },
    },

    -- TODO: Trevor missing

    {
        unlockMsg = "Vic Vector BFF",
        classString = "unlock",
        collectionString = { "vic_unlock_male", "vic_unlock_female" },
    },

    {
        unlockMsg = "Vincent Skullfinder BFF",
        classString = "unlock",
        collectionString = { "skullfinder_unlock_male", "skullfinder_unlock_female" },
    },

    {
        unlockMsg = "Violet BFF",
        classString = "unlock",
        collectionString = { "violet_unlock_male", "violet_unlock_female" },
    },

    {
        unlockMsg = "Yuki BFF",
        classString = "unlock",
        collectionString = { "yuki_unlock_male", "yuki_unlock_female" },
    },

    {
        unlockMsg = "Zack BFF",
        classString = "unlock",
        collectionString = { "zack_body", "zack_female_raverdm" },
    },

    {
        unlockMsg = "Zombie Carl BFF",
        classString = "unlock",
        collectionString = "carl_unlock_female",
    },
}

--- Clothes found in chests or scrolls
Constants.CAS_Misc = {
    {
        unlockMsg = "CAS Initial",
        classString = "unlock",
        collectionString = {
            "cas_initial_unlocks",
            "initial_mouths",
            "initial_eyes",
            "initial_bodies",
            "initial_hair_f",
            "initial_hair_m",
            "initial_hair_u",
            "initial_hats",
            "initial_accessories",
        },
    },

    {
        unlockMsg = "Cowboy Junction Chest",
        classString = "unlock",
        collectionString = "cowboy_junction_cas_chest_unlock",
    },

    {
        unlockMsg = "Leaf Chest",
        classString = "unlock",
        collectionString = "leaf_cas_chest_unlock",
    },

    {
        unlockMsg = "Uncharted Island Chest",
        classString = "unlock",
        collectionString = "gonk_cas_chest_unlock",
    },

    {
        unlockMsg = "Candy Island Chest",
        classString = "unlock",
        collectionString = "candy_cas_chest_unlock",
    },

    {
        unlockMsg = "Rocket Reef Chest",
        classString = "unlock",
        collectionString = "rr_cas_chest_unlock",
    },

    {
        unlockMsg = "Royalty Outfits",
        classString = "unlock",
        collectionString = "royalty_outfits",
    },

    {
        unlockMsg = "King Point Hairs",
        classString = "unlock",
        collectionString = "king_point_hairs",
    },

    {
        unlockMsg = "Sorceress",
        classString = "unlock",
        collectionString = "sorceress_body_hat",
    },

    {
        unlockMsg = "Pants, Jacket, Bag",
        classString = "unlock",
        collectionString = "pantsjacketbag_unisex",
    },
}

--- Clothes that need to be unlocked with button prompts in the pause menu
Constants.CAS_Unlocks = {
    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_CARIBBEAN_FEMALE",
        classString = "unlock",
        collectionString = "unlock_afbodycaribbean",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_FAIRY",
        classString = "unlock",
        collectionString = "unlock_afbodyfairy",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_KHAKI",
        classString = "unlock",
        collectionString = "unlock_afbodyspy",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_FAIRY_HAIR",
        classString = "unlock",
        collectionString = "unlock_afheadhairfairy",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_BUCKET_HAT",
        classString = "unlock",
        collectionString = "unlock_afheadhairspy",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_CARIBBEAN_MALE",
        classString = "unlock",
        collectionString = "unlock_ambodycaribbean",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_COW_BODY",
        classString = "unlock",
        collectionString = "unlock_aubodycow",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_TATTOO",
        classString = "unlock",
        collectionString = "unlock_aubodylongpants_tattoo",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_SWORDSMAN",
        classString = "unlock",
        collectionString = "unlock_aubodyswordsman",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_TRENCHCOAT",
        classString = "unlock",
        collectionString = "unlock_aubodytrenchcoat",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_FEDORA",
        classString = "unlock",
        collectionString = "unlock_auheadhatadventurefedora",
    },

    {
        unlockMsg = "STRING_UNLOCK_CAS_PRESALE_COW_HEAD",
        classString = "unlock",
        collectionString = "unlock_auheadhatcow",
    },
}


Constants.InteriorWorlds = {
    "interior_poppy_01",
    "interior_leaf_01",
    "interior_ginnys_01",
    "interior_ruthie_01",
    "interior_dorm_01",
    "interior_generic_02",
    "interior_rj_ginny",
    "interior_theodore",
    "interior_tobor_01",
    "interior_genericopen",
    "interior_reward_01",
    "interior_candy",
    "interior_barney",
    "interior_gino_01",
    "interior_castle",
    "interior_morcubus_01",
    "interior_pigman_01",
    "interior_lab_01",
    "interior_gothboy_01",
    "interior_classroom_01",
    "interior_neema_01",
    "interior_roxie_01",
    "interior_renee_01",
}

Constants.AllTaskRewards = {
    ["academy_island"] = "academy_task_rewards",
    ["animal_island"] = "animal_task_rewards",
    ["candy_island"] = "candy_task_rewards",
    ["castle_island"] = "capital_task_reward",
    ["cowboy_junction_island"] = "cj_task_rewards",
    ["cutesburgh_island"] = "cutesburg_task_rewards",
    ["gonk_island"] = "gonk_task_rewards",
    ["tree_island"] = "leaf_task_rewards",
    ["rocket_reef_island"] = "rocketreef_task_rewards",
    ["spookane_island"] = "spookane_task_rewards",
    ["trevor_island"] = "trevor_island_task_rewards",
    ["day2"] = "day2socialize_task_rewards",
}

Constants.AllScrollRewards = {
    ["academy_island"] = "academy_scrolls",
    ["animal_island"] = "animal_scrolls",
    ["candy_island"] = "candy_scrolls",
    ["castle_island"] = "capital_scrolls",
    ["cowboy_junction_island"] = "cowboy_junction_scrolls",
    ["cutesburgh_island"] = "cutopia_scrolls",
    ["gonk_island"] = "gonk_scrolls",
    ["tree_island"] = "leaf_scrolls",
    ["rocket_reef_island"] = "rocket_reef_scrolls",
    ["spookane_island"] = "spookane_scrolls",
    ["trevor_island"] = "trevor_scrolls",
}