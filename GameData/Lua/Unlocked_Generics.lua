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

--- makes an object fly up and stay there for an amount of frames
--- @param obj any The object to fly (required)
--- @param upY number The amount of units to fly up (defaults to 2)
--- @param frameCount number The amount of frames to stay in the air (defaults to 120)
function Common:FakeFly( obj, upY, frameCount )
    if not ( obj ) then
        EA:LogMod("FakeFly", "Missing game object to fly")
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


--- Table containing all mTypes of the NPCs on pirate cove
Constants.PirateCoveScripts = {
    "NPC_Neema",
    "NPC_Mira",
    "NPC_Morgan",
    "NPC_Theodore",
}

--- Table containing names & icons of all herdables (by script names / mType)
Constants.AnimalTable = {
    ["Bobaboo"] = {
        name = "Bobaboo",
        icon = "uitexture-map-icon-gonk",
        collectionKey = "reverse_herdable_bobaboo",
        enabled = true,
    },
    ["Cow"] = {
        name = "Cow",
        icon = "uitexture-figurine-cow",
        collectionKey = "cow_cj_01",
        enabled = true,
    },
    ["Pig"] = {
        name = "Pig",
        icon = "uitexture-map-icon-animal",
        collectionKey = "pig_cap_01",
        enabled = true,
    },
    ["PercyPig"] = {
        name = "Sir Percival J. Worthington IV",
        icon = "uitexture-map-icon-animal",
        collectionKey = "pig_animal",
        enabled = true,
    },
    ["Unicorn"] = {
        name = "Unicorn",
        icon = "uitexture-map-icon-leaf",
        collectionKey = "unicorns",
        enabled = true,
    },
    ["Hedgehog"] = {
        name = "Hedgehog",
        icon = nil,
        collectionKey = "leaf_hedgehog_01",
        enabled = true,
    },
    ["HedgehogLarge"] = {
        name = "Filbert",
        icon = nil,
        collectionKey = "academy_hedgehog_01",
        enabled = true,
    },
    ["Bunny"] = {
        name = "Bunny",
        icon = nil,
        collectionKey = "bunny_leaf_master",
        enabled = true,
    },
    ["Spider"] = {
        name = "Spider",
        icon = "uitexture-essence-flair-spider",
        collectionKey = "spiders",
        enabled = true,
    },
    ["Frog"] = {
        name = "Frog",
        icon = nil,
        collectionKey = "frog",
        enabled = true,
    },
    ["Crab"] = {
        name = "Crab",
        icon = "uitexture-fish-crab",
        collectionKey = "crabs",
        enabled = true,
    },
    --[[
    -- missing interactions (so cannot be deleted)
    -- TODO: find a way to make them deletable (e.g. RelationshipBook DEspawn functionality)

    ["HerdableTrevor"] = {
        name = "Trevor (Running)",
        icon = "uitexture-npc-head-trevor",
        collectionKey = 1,
        enabled = false,
    },
    ["ToborLegs"] = {
        name = "Tobor (Legs)",
        icon = "uitexture-npc-head-tobor",
        collectionKey = 1,
        enabled = false,
    },
    ["Bear"] = {
        name = "Bear",
        icon = nil,
        collectionKey = 1,
        enabled = false,
    },
    ["Panda_Cub"] = {
        name = "Bear Cub",
        icon = nil,
        collectionKey = 1,
        enabled = false,
    },
    ["Raccoon"] = {
        name = "Raccoon",
        icon = nil,
        collectionKey = 1,
        enabled = false,
    },
    ["Dog"] = {
        name = "Dog",
        icon = nil,
        collectionKey = 4, -- 2 - 4 is wandering dog (max. 4)
        enabled = false,
    },
    ["CatAnimal"] = {
        name = "Cat",
        icon = nil,
        collectionKey = 3, -- 3 is following cat (max. 3)
        enabled = false,
    },

    -- never spawn
    ["HerdableTrevor2"] = { name = nil, icon = nil, collectionKey = 1, enabled = false },
    ["HerdableTrevor3"] = { name = nil, icon = nil, collectionKey = 1, enabled = false },
    ["HerdableTrevor4"] = { name = nil, icon = nil, collectionKey = 1, enabled = false },
    ["DummyScript"] = { name = nil, icon = nil, collectionKey = 1, enabled = false },
    ["HerdableScriptObjectBase"] = { name = nil, icon = nil, collectionKey = 1, enabled = false },
    ]]--
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
    ["Beebee"] = { -- is added in "Extra" island
        body = "afBodyBeeBeeNPC",
        head = "afHeadBeeBeeNPC",
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

}

--- CAS Tables

Constants.CAS_BFF = {
    {
        code = "",
        unlockMsg = "Buddy & Lyndsay Outfits",
        classString = "unlock",
        collectionString = "buddy_lyndsay_outfits",
    },

    -- TODO: Alexa missing

    {
        code = "",
        unlockMsg = "Barney BFF",
        classString = "unlock",
        collectionString = { "barney_hat", "barney_hat_female"},
    },

    {
        code = "",
        unlockMsg = "Chaz BFF",
        classString = "unlock",
        collectionString = { "chaz_unlock_male", "chaz_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Gino BFF",
        classString = "unlock",
        collectionString = { "chef_body", "chef_body_hat" },
    },

    -- TODO: DJ Candy missing
    -- TODO: Dr. F missing

    {
        code = "",
        unlockMsg = "Beverly BFF",
        classString = "unlock",
        collectionString = { "beverly_unlock_male", "beverly_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Elmira BFF",
        classString = "unlock",
        collectionString = { "elmira_body", "elmira_accessories" },
    },

    -- TODO: Gonk missing
    -- TODO: Goth Boy missing

    {
        code = "",
        unlockMsg = "Ruthie BFF",
        classString = "unlock",
        collectionString = { "ruthie_unlock_male", "ruthie_unlock_female" },
    },

    -- TODO: Hopper missing
    -- TODO: King Roland missing

    {
        code = "",
        unlockMsg = "Leaf BFF",
        classString = "unlock",
        collectionString = { "leaf_female", "leaf_body_hat" },
    },

    {
        code = "",
        unlockMsg = "Liberty BFF",
        classString = "unlock",
        collectionString = "liberty_unlock_female",
    },

    {
        code = "",
        unlockMsg = "Linda Clothes", -- Linda has no relationship
        classString = "unlock",
        collectionString = "linda_unlock_male",
    },

    {
        code = "",
        unlockMsg = "Daniel BFF",
        classString = "unlock",
        collectionString = { "daniel_unlock_male", "daniel_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Marlon Clothes", -- Marlon has no relationship
        classString = "unlock",
        collectionString = "marlon_body_hat",
    },

    -- TODO: Morcobus missing
    -- TODO: Gabby missing

    {
        code = "",
        unlockMsg = "Petal BFF",
        classString = "unlock",
        collectionString = { "petal_unisex_hats", "petal_body" },
    },

    {
        code = "",
        unlockMsg = "Poppy BFF",
        classString = "unlock",
        collectionString = { "poppy_unlock_male", "poppy_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Butter BFF",
        classString = "unlock",
        collectionString = { "butter_male", "butter_female" },
    },

    {
        code = "",
        unlockMsg = "Proto Makoto BFF",
        classString = "unlock",
        collectionString = "robotgirl_body_hat",
    },

    {
        code = "",
        unlockMsg = "Renée BFF",
        classString = "unlock",
        collectionString = "renee_body",
    },

    {
        code = "",
        unlockMsg = "Rosalyn BFF",
        classString = "unlock",
        collectionString = { "rosalyn_unlock_male", "rosalyn_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Roxie BFF",
        classString = "unlock",
        collectionString = { "roxie_unisex_cow", "roxie_body_hair" },
    },

    {
        code = "",
        unlockMsg = "Rusty BFF",
        classString = "unlock",
        collectionString = { "rusty_male", "rusty_unisex" },
    },

    {
        code = "",
        unlockMsg = "Sapphire BFF",
        classString = "unlock",
        collectionString = { "sapphire_male_raverdm", "sapphire_body", "raver2_body" },
    },

    {
        code = "",
        unlockMsg = "Ginny BFF",
        classString = "unlock",
        collectionString = "ginny_body_hat",
    },

    {
        code = "",
        unlockMsg = "Spencer BFF",
        classString = "unlock",
        collectionString = { "spencer_unlock_male", "spencer_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Summer BFF",
        classString = "unlock",
        collectionString = { "summer_unlock_male", "summer_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Sylvia BFF",
        classString = "unlock",
        collectionString = { "sylvia_unlock_male", "sylvia_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "T.O.B.O.R. BFF",
        classString = "unlock",
        collectionString = "robotboy_body_hat",
    },

    {
        code = "",
        unlockMsg = "Travis BFF",
        classString = "unlock",
        collectionString = { "travis_unlock_male", "travis_unlock_female" },
    },

    -- TODO: Trevor missing

    {
        code = "",
        unlockMsg = "Vic Vector BFF",
        classString = "unlock",
        collectionString = { "vic_unlock_male", "vic_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Vincent Skullfinder BFF",
        classString = "unlock",
        collectionString = { "skullfinder_unlock_male", "skullfinder_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Violet BFF",
        classString = "unlock",
        collectionString = { "violet_unlock_male", "violet_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Yuki BFF",
        classString = "unlock",
        collectionString = { "yuki_unlock_male", "yuki_unlock_female" },
    },

    {
        code = "",
        unlockMsg = "Zack BFF",
        classString = "unlock",
        collectionString = { "zack_body", "zack_female_raverdm" },
    },

    {
        code = "",
        unlockMsg = "Zombie Carl BFF",
        classString = "unlock",
        collectionString = "carl_unlock_female",
    },
}

Constants.CAS_Misc = {
    {
        code = "",
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
        code = "",
        unlockMsg = "Cowboy Junction Chest",
        classString = "unlock",
        collectionString = "cowboy_junction_cas_chest_unlock",
    },

    {
        code = "",
        unlockMsg = "Leaf Chest",
        classString = "unlock",
        collectionString = "leaf_cas_chest_unlock",
    },

    {
        code = "",
        unlockMsg = "Uncharted Island Chest",
        classString = "unlock",
        collectionString = "gonk_cas_chest_unlock",
    },

    {
        code = "",
        unlockMsg = "Candy Island Chest",
        classString = "unlock",
        collectionString = "candy_cas_chest_unlock",
    },

    {
        code = "",
        unlockMsg = "Rocket Reef Chest",
        classString = "unlock",
        collectionString = "rr_cas_chest_unlock",
    },

    {
        code = "",
        unlockMsg = "Royalty Outfits",
        classString = "unlock",
        collectionString = "royalty_outfits",
    },

    {
        code = "",
        unlockMsg = "King Point Hairs",
        classString = "unlock",
        collectionString = "king_point_hairs",
    },

    {
        code = "",
        unlockMsg = "Sorceress",
        classString = "unlock",
        collectionString = "sorceress_body_hat",
    },

    {
        code = "",
        unlockMsg = "Pants, Jacket, Bag",
        classString = "unlock",
        collectionString = "pantsjacketbag_unisex",
    },
}