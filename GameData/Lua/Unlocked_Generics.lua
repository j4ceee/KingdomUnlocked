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