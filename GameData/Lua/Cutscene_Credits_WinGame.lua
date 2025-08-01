local DEBUG_ALL_BLOCKS = false

local function DebugBlocksHelper( t )
    if DEBUG_ALL_BLOCKS or DebugMenu:GetValue("ShowAllCreditsBlocks") then
        return nil
    end
    return t
end

--
-- Helper data/functions to generate delete sequences
--
local AllDeletableCharacters =
{
    "Barney","Pigman", "Butter", "DrF", "Vic", "Alexa", "Tobor", "Raver2", "Raver1", "DJCandy",
    "Gabby", "Ginny", "Gino", "Roxie", "Rusty", "Skullfinder", "Sylvia", "Gonk", "Travis", "Chaz",
    "Rosalyn", "Summer", "Liberty", "Renee", "Dog", "Cat", "Morcubus", "Gothboy", "Ruthie",
    "Yuki", "Carl", "Petal", "Hopper", "Leaf", "Protomakoto", "Daniel", "Violet", "Spencer",
    "Poppy", "Beverly", "Trevor", "Linda", "Gordon", "Neema", "Theodore", "Mira", "Morgan",
}

local function GenerateDeleteSequence( ... )
    
    local exclude = {}
    for i, label in pairs({...}) do
        exclude[label] = true
    end
    
    local sequence = {}
    
    for i, label in ipairs(AllDeletableCharacters) do
        
        if not exclude[label] then
            sequence[#sequence+1] =
            {
                command = "destroyobject",
                label = label,
            }
        end    
    end
    
    return  {
                command = "sequence",
                sequence = sequence,
            }
end

---------------------------------------------
-- Island Blocks 
---------------------------------------------
local CreditsCutsceneBlocks = {}

CreditsCutsceneBlocks.CapitalIsland =
{
    command = "sequence",
    taskPrerequisites = nil,
    sequence =
    {
        --
        -- Butter
        --
        {
            command = "spawnobject",
            label = "Butter",
            classKey = "character",
            collectionKey = "cr_butter",
            x = 51.025,
            y = 0.6,
            z = 47.305,
            rotY = 236.313,
            blocking = true,
        },
        
        --
        -- Barney
        --
        {
            command = "spawnobject",
            label = "Barney",
            classKey = "character",
            collectionKey = "cr_barney",
            x = 51.701,
            y = 0.6,
            z = 46.036,
            rotY = -110.869,
            blocking = true,
        },
        
        --
        -- Pigman
        --
        {
            command = "spawnobject",
            label = "Pigman",
            classKey = "character",
            collectionKey = "cr_pigman",
            x = 50.108,
            y = 0.6,
            z = 48.439,
            rotY = 221.709,
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 43.135 ,  y = 1.805 ,    z = 42.703 },
            target   = { x = 51.698 ,   y = 1.452 ,    z = 47.715 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Butter", "Barney", "Pigman"),
                
        -- Camera End
        
        {
            command         = "camera",
            
            position = { x = 44.618 ,  y = 7.812 ,    z = 40.797 },
            target   = { x = 51.568 ,   y = 1.031 ,    z = 47.655 },
            transitionDuration = 18.84,
            micY = 0.601, 
        },
        
        -- Dance
        {
            command = "pause",
            seconds = 0.125,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsForward-01", 2},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsSides-02", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsIn-03a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsIn-03b", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsIn-03a", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsSides-03", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Butter",},
        },

        {
            command = "signal",
            who = {"Barney",},
        },
        
        {
            command = "signal",
            who = {"Pigman",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Butter", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Barney", "a-dance-credits-armsIn-02b", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Pigman", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },

    },
    
}

CreditsCutsceneBlocks.RocketReefIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper(  {{ taskId = "NPC_Tobor_FindMyLegs", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Vic
        --
        {
            command = "spawnobject",
            label = "Vic",
            classKey = "character",
            collectionKey = "cr_vic",
            x = 23.502,
            y = 0.6,
            z = 41.464,
            rotY = 74.079,
            blocking = true,
        },
        
        --
        -- Tobor
        --
        {
            command = "spawnobject",
            label = "Tobor",
            classKey = "character",
            collectionKey = "cr_tobor",
            x = 26.098,
            y = 0.6,
            z = 38.034,
            rotY = 30.074,
            blocking = true,
        },
        
        --
        -- Alexa
        --
        {
            command = "spawnobject",
            label = "Alexa",
            classKey = "character",
            collectionKey = "cr_alexa",
            x = 23.922,
            y = 0.6,
            z = 40.017,
            rotY = 57.571,
            blocking = true,
        },
        
        --
        -- DrF
        --
        {
            command = "spawnobject",
            label = "DrF",
            classKey = "character",
            collectionKey = "cr_drf",
            x = 24.81,
            y = 0.6,
            z = 38.808,
            rotY = 39.752,
            blocking = true,
        },
        
        --
        -- Tobor's funky idle
        --
        -- Special Tobor Dance
        {   
            jobClassName =  "Job_PlayAnimation_CutsceneTalk",
            jobParams =     {
                                "$Tobor",
                                {
                                    count = 100,
                                    "a2a-funkyRobot-performer",
                                },
                            },
            blocking = false,
        },
        
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 36.348 ,  y = 3.449 ,    z = 44.174 },
            target   = { x = 32.768 ,   y = 2.819 ,    z = 42.74 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Vic", "Tobor", "Alexa", "DrF"),
        
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = {x = 31.87 ,   y = 3.21 ,    z = 50.568 },
            target   = { x = 29.235 ,   y = 2.594 ,    z = 46.687 },
            transitionDuration = 8.67,
            micY = 0.601, 
        },        
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Vic", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Alexa", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DrF", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Vic",
        },
        
        {
            command = "wait",
            who = "Alexa",
        },

        {
            command = "wait",
            who = "DrF",
        },

        {
            command = "signal",
            who = {"DrF",},
        },        
        
        {
            command = "signal",
            who = {"Vic",},
        },

        {
            command = "signal",
            who = {"Alexa",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Vic", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Alexa", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DrF", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Vic",
        },
        
        {
            command = "wait",
            who = "Alexa",
        },

        {
            command = "wait",
            who = "DrF",
        },

        {
            command = "signal",
            who = {"DrF",},
        },                
        
        {
            command = "signal",
            who = {"Vic",},
        },

        {
            command = "signal",
            who = {"Alexa",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Vic", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Alexa", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DrF", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Vic",
        },
        
        {
            command = "wait",
            who = "Alexa",
        },

        {
            command = "wait",
            who = "DrF",
        },

        {
            command = "signal",
            who = {"DrF",},
        },       
        
        {
            command = "signal",
            who = {"Vic",},
        },

        {
            command = "signal",
            who = {"Alexa",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Vic", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Alexa", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DrF", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Vic",
        },
        
        {
            command = "wait",
            who = "Alexa",
        },

        {
            command = "wait",
            who = "DrF",
        },

        {
            command = "signal",
            who = {"DrF",},
        },               
        
        {
            command = "signal",
            who = {"Vic",},
        },

        {
            command = "signal",
            who = {"Alexa",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Vic", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Alexa", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DrF", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "signal",
            who = {"Tobor",},
        },
        
    },
    
}

CreditsCutsceneBlocks.PirateIsland =
{
    command = "sequence",

    --taskPrerequisites = DebugBlocksHelper(  {{ taskId = "NPC_Tobor_FindMyLegs", taskState = Task.States["kComplete"] }} ),

    sequence =
    {
        --
        -- Neema
        --
        {
            command = "spawnobject",
            label = "Neema",
            classKey = "character",
            collectionKey = "cr_neema",
            x = 23.502,
            y = 0.6,
            z = 41.464,
            rotY = 74.079,
            blocking = true,
        },

        --
        -- Theodore
        --
        {
            command = "spawnobject",
            label = "Theodore",
            classKey = "character",
            collectionKey = "cr_theodore",
            x = 26.098,
            y = 0.6,
            z = 38.034,
            rotY = 30.074,
            blocking = true,
        },

        --
        -- Mira
        --
        {
            command = "spawnobject",
            label = "Mira",
            classKey = "character",
            collectionKey = "cr_mira",
            x = 23.922,
            y = 0.6,
            z = 40.017,
            rotY = 57.571,
            blocking = true,
        },

        --
        -- Morgan
        --
        {
            command = "spawnobject",
            label = "Morgan",
            classKey = "character",
            collectionKey = "cr_morgan",
            x = 24.81,
            y = 0.6,
            z = 38.808,
            rotY = 39.752,
            blocking = true,
        },

        --
        -- Theodore's funky idle
        --
        -- Special Theodore Dance
        {
            jobClassName =  "Job_PlayAnimation_CutsceneTalk",
            jobParams =     {
                "$Theodore",
                {
                    count = 100,
                    "a2a-funkyRobot-performer",
                },
            },
            blocking = false,
        },


        -- Camera Start

        {
            command         = "camera",

            position = { x = 36.348 ,  y = 3.449 ,    z = 44.174 },
            target   = { x = 32.768 ,   y = 2.819 ,    z = 42.74 },
            transitionDuration = 0,
            micY = 0.601,
        },

        GenerateDeleteSequence("Neema", "Theodore", "Mira", "Morgan"),

        -- Camera Stop

        {
            command         = "camera",

            position = {x = 31.87 ,   y = 3.21 ,    z = 50.568 },
            target   = { x = 29.235 ,   y = 2.594 ,    z = 46.687 },
            transitionDuration = 8.67,
            micY = 0.601,
        },

        -- Dance

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Neema", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Mira", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morgan", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {
            command = "wait",
            who = "Neema",
        },

        {
            command = "wait",
            who = "Mira",
        },

        {
            command = "wait",
            who = "Morgan",
        },

        {
            command = "signal",
            who = {"Morgan",},
        },

        {
            command = "signal",
            who = {"Neema",},
        },

        {
            command = "signal",
            who = {"Mira",},
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Neema", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Mira", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morgan", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {
            command = "wait",
            who = "Neema",
        },

        {
            command = "wait",
            who = "Mira",
        },

        {
            command = "wait",
            who = "Morgan",
        },

        {
            command = "signal",
            who = {"Morgan",},
        },

        {
            command = "signal",
            who = {"Neema",},
        },

        {
            command = "signal",
            who = {"Mira",},
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Neema", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Mira", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morgan", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {
            command = "wait",
            who = "Neema",
        },

        {
            command = "wait",
            who = "Mira",
        },

        {
            command = "wait",
            who = "Morgan",
        },

        {
            command = "signal",
            who = {"Morgan",},
        },

        {
            command = "signal",
            who = {"Neema",},
        },

        {
            command = "signal",
            who = {"Mira",},
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Neema", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Mira", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morgan", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {
            command = "wait",
            who = "Neema",
        },

        {
            command = "wait",
            who = "Mira",
        },

        {
            command = "wait",
            who = "Morgan",
        },

        {
            command = "signal",
            who = {"Morgan",},
        },

        {
            command = "signal",
            who = {"Neema",},
        },

        {
            command = "signal",
            who = {"Mira",},
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Neema", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Mira", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morgan", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {
            command = "signal",
            who = {"Theodore",},
        },

    },

}

CreditsCutsceneBlocks.CandyIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_Candy_Arrival", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    { 
        --
        -- Buddy
        --
        {
            command = "setposition",
            who = "Buddy",
            x = 50.979 ,
            y = 0.601,
            z = 42.326,
            rotY = -105.144 ,
        },
        --
        -- DJCandy
        --
        {
            command = "spawnobject",
            label = "DJCandy",
            classKey = "character",
            collectionKey = "cr_djcandy",
            x = 50.781 ,
            y = 0.6,
            z = 39.257 ,
            rotY = 295.031 ,
            blocking = true,
        },
        --
        -- Raver1
        --
        {
            command = "spawnobject",
            label = "Raver1",
            classKey = "character",
            collectionKey = "cr_raver1",
            x = 49.74 ,
            y = 0.6,
            z = 38.023 ,
            rotY = -48.52 ,
            blocking = true,
        },
        --
        -- Raver2
        --
        {
            command = "spawnobject",
            label = "Raver2",
            classKey = "character",
            collectionKey = "cr_raver2",
            x = 51.015 ,
            y = 0.6,
            z = 40.968 ,
            rotY = 271.548 ,
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 40.621 ,  y = 7.668 ,    z = 42.021 },
            target   = { x = 52.634 ,   y = 0.149 ,    z = 39.495 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("DJCandy", "Raver1", "Raver2"),

        {
            command = "destroyobject",
            label = "Barney",
            blocking = true,
        }, 
        
        {
            command = "destroyobject",
            label = "Pigman",
            blocking = true,
        },

        {
            command = "destroyobject",
            label = "Butter",
            blocking = true,
        },             
        
        {
            command = "destroyobject",
            label = "DrF",
            blocking = true,
        }, 
        
        {
            command = "destroyobject",
            label = "Vic",
            blocking = true,
        },

        {
            command = "destroyobject",
            label = "Alexa",
            blocking = true,
        },

        {
            command = "destroyobject",
            label = "Tobor",
            blocking = true,
        },
        
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 39.009 ,  y = 2.555 ,    z = 45.715 },
            target   = { x = 53.042 ,   y = 1.177 ,    z = 39.185 },
            transitionDuration = 10.68,
            micY = 0.601, 
        },
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DJCandy", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver1", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver2", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
          jobClassName =  "Job_RouteToCutscenePosition",
          jobParams =     { "$Buddy", 50.979 , 0.6, 42.326 , nil, -105.144, },
          blocking = false,
        },
        
        {
            command = "destroyobject",
            label = "DrF",
        }, 
        
        {
            command = "destroyobject",
            label = "Vic",
        },

        {
            command = "destroyobject",
            label = "Alexa",
        },

        {
            command = "destroyobject",
            label = "Tobor",
        },
        
        {
            command = "wait",
            who = "DJCandy",
        },
        
        {
            command = "wait",
            who = "Raver1",
        },
        
        {
            command = "wait",
            who = "Raver2",
        },
        
        {
            command = "signal",
            who = {"DJCandy",},
        },

        {
            command = "signal",
            who = {"Raver1",},
        },
        
        {
            command = "signal",
            who = {"Raver2",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DJCandy", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver1", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver2", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-danceOff-badDance", 0},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "DJCandy",
        },
        
        {
            command = "wait",
            who = "Raver1",
        },
        
        {
            command = "wait",
            who = "Raver2",
        },
        
        {
            command = "signal",
            who = {"DJCandy",},
        },

        {
            command = "signal",
            who = {"Raver1",},
        },
        
        {
            command = "signal",
            who = {"Raver2",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DJCandy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver1", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver2", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "DJCandy",
        },
        
        {
            command = "wait",
            who = "Raver1",
        },
        
        {
            command = "wait",
            who = "Raver2",
        },
        
        {
            command = "signal",
            who = {"DJCandy",},
        },

        {
            command = "signal",
            who = {"Raver1",},
        },
        
        {
            command = "signal",
            who = {"Raver2",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DJCandy", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver1", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver2", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "DJCandy",
        },
        
        {
            command = "wait",
            who = "Raver1",
        },
        
        {
            command = "wait",
            who = "Raver2",
        },
        
        {
            command = "signal",
            who = {"DJCandy",},
        },

        {
            command = "signal",
            who = {"Raver1",},
        },
        
        {
            command = "signal",
            who = {"Raver2",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DJCandy", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver1", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver2", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "DJCandy",
        },
        
        {
            command = "wait",
            who = "Raver1",
        },
        
        {
            command = "wait",
            who = "Raver2",
        },

        {
            command = "signal",
            who = {"DJCandy",},
        },

        {
            command = "signal",
            who = {"Raver1",},
        },
        
        {
            command = "signal",
            who = {"Raver2",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$DJCandy", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver1", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Raver2", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },

    },
    
}

CreditsCutsceneBlocks.CowboyJunctionIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_CJ_MilkCows", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Ginny
        --
        {
            command = "spawnobject",
            label = "Ginny",
            classKey = "character",
            collectionKey = "cr_ginny",
            x = 22.78 ,
            y = 0.6,
            z = 48.994 ,
            rotY = 97.407 ,
            blocking = true,
        },
        
        --
        -- Gino
        --
        {
            command = "spawnobject",
            label = "Gino",
            classKey = "character",
            collectionKey = "cr_gino",
            x = 22.661 ,
            y = 0.6,
            z = 47.436 ,
            rotY = 93.002 ,
            blocking = true,
        },
        
        --
        -- Gabby
        --
        {
            command = "spawnobject",
            label = "Gabby",
            classKey = "character",
            collectionKey = "cr_gabby",
            x = 23.159 ,
            y = 0.6,
            z = 50.469 ,
            rotY = 112.944 ,
            blocking = true,
        },
        


        --
        -- Roxie
        --
        {
            command = "spawnobject",
            label = "Roxie",
            classKey = "character",
            collectionKey = "cr_roxie",
            x = 22.831 ,
            y = 0.6,
            z = 45.94 ,
            rotY = 77.369 ,
            blocking = true,
        },

        --
        -- Rusty
        --
        {
            command = "spawnobject",
            label = "Rusty",
            classKey = "character",
            collectionKey = "cr_rusty",
            x = 23.322 ,
            y = 0.6,
            z = 44.533 ,
            rotY = 66.708 ,
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 37.664 ,  y = 3.71 ,    z = 42.828 },
            target   = { x = 29.497 ,   y = 2.462 ,    z = 45.334 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Ginny", "Gino", "Gabby", "Roxie", "Rusty"),
                
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 36.6 ,  y = 3.479 ,    z = 53.681 },
            target   = { x = 28.617 ,   y = 2.266 ,    z = 50.124 },
            transitionDuration = 12.99,
            micY = 0.601, 
        },
        
        -- Special Gabby Dance
        
        {   
            jobClassName =  "Job_PlayAnimation_CutsceneTalk",
            jobParams =     {
                                "$Gabby",
                                {
                                    "a-idle-hoedown-start",
                                    count = 1,
                                    idles =
                                    {
                                        {   "a-idle-hoedown-loop-clap",         weight = 2, },
                                        {   "a-idle-hoedown-loop-dance",        weight = 10, },
                                        {   "a-idle-hoedown-loop-quickStep",    weight = 2, },
                                    }
                                },
                            },
            blocking = false,
        },

        -- Dance        
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ginny", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gino", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roxie", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rusty", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Ginny",
        },
        
        {
            command = "wait",
            who = "Gino",
        },
        
        {
            command = "wait",
            who = "Roxie",
        },
        
        {
            command = "wait",
            who = "Rusty",
        },

        {
            command = "signal",
            who = {"Ginny",},
        },

        {
            command = "signal",
            who = {"Gino",},
        },
        
        {
            command = "signal",
            who = {"Roxie",},
        },
        
        {
            command = "signal",
            who = {"Rusty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ginny", "a-dance-credits-armsIn-03a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gino", "a-dance-credits-armsIn-03b", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roxie", "a-dance-credits-armsIn-03a", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rusty", "a-dance-credits-armsIn-03b", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Ginny",
        },
        
        {
            command = "wait",
            who = "Gino",
        },
        
        {
            command = "wait",
            who = "Roxie",
        },
        
        {
            command = "wait",
            who = "Rusty",
        },            
        
        {
            command = "signal",
            who = {"Ginny",},
        },

        {
            command = "signal",
            who = {"Gino",},
        },
        
        {
            command = "signal",
            who = {"Roxie",},
        },
        
        {
            command = "signal",
            who = {"Rusty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ginny", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gino", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roxie", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rusty", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Ginny",
        },
        
        {
            command = "wait",
            who = "Gino",
        },
        
        {
            command = "wait",
            who = "Roxie",
        },
        
        {
            command = "wait",
            who = "Rusty",
        },
        
        {
            command = "signal",
            who = {"Ginny",},
        },

        {
            command = "signal",
            who = {"Gino",},
        },
        
        {
            command = "signal",
            who = {"Roxie",},
        },
        
        {
            command = "signal",
            who = {"Rusty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ginny", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gino", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roxie", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rusty", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Ginny",
        },
        
        {
            command = "wait",
            who = "Gino",
        },
        
        {
            command = "wait",
            who = "Roxie",
        },
        
        {
            command = "wait",
            who = "Rusty",
        },          
        
        {
            command = "signal",
            who = {"Ginny",},
        },

        {
            command = "signal",
            who = {"Gino",},
        },
        
        {
            command = "signal",
            who = {"Roxie",},
        },
        
        {
            command = "signal",
            who = {"Rusty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ginny", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gino", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roxie", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rusty", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Ginny",
        },
        
        {
            command = "wait",
            who = "Gino",
        },
        
        {
            command = "wait",
            who = "Roxie",
        },
        
        {
            command = "wait",
            who = "Rusty",
        },  
        
        {
            command = "signal",
            who = {"Ginny",},
        },

        {
            command = "signal",
            who = {"Gino",},
        },
        
        {
            command = "signal",
            who = {"Roxie",},
        },
        
        {
            command = "signal",
            who = {"Rusty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ginny", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gino", "a-dance-credits-armsIn-02b", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roxie", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rusty", "a-dance-credits-armsIn-02b", 1},
            blocking = false,
        },
        {
            command = "signal",
            who = {"Gabby",},
        },
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gabby", "a-idle-hoedown-stop", 1},
            blocking = false,
        },
        
    },
    
}

CreditsCutsceneBlocks.GonkIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_Gonk_BobabooFree", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Sylvia
        --
        {
            command = "spawnobject",
            classKey = "character",
            collectionKey = "cr_sylvia",
            x = 48.218 ,
            y = 0.6,
            z = 30.839 ,
            rotY = -26.818 ,
            label = "Sylvia",
            blocking = true,
        },
        
        --
        -- Gonk
        --
        {
            command = "spawnobject",
            classKey = "character",
            collectionKey = "cr_gonk",
            x = 49.498 ,
            y = 0.6,
            z = 31.849 ,
            rotY = 310.195 ,
            label = "Gonk",
            blocking = true,
        },
        
        --
        -- Skullfinder
        --
        {
            command = "spawnobject",
            classKey = "character",
            collectionKey = "cr_vincent_skullfinder",
            x = 50.388 ,
            y = 0.6,
            z = 33.173 ,
            rotY = 291.177 ,
            label = "Skullfinder",
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 42.439 ,  y = 1.435 ,    z = 38.287 },
            target   = { x = 50.455 ,   y = 1.494 ,    z = 30.915 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Sylvia", "Gonk", "Skullfinder"),
        
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 40.446 ,  y = 6.134 ,    z = 40.116 },
            target   = { x = 50.408 ,   y = 0.943 ,    z = 31.271 },
            transitionDuration = 8.67,
            micY = 0.601, 
        },        
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Sylvia", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gonk", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Skullfinder", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Sylvia",
        },
        
        {
            command = "wait",
            who = "Gonk",
        },

        {
            command = "wait",
            who = "Skullfinder",
        },

        {
            command = "signal",
            who = {"Skullfinder",},
        },        
        
        {
            command = "signal",
            who = {"Sylvia",},
        },

        {
            command = "signal",
            who = {"Gonk",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Sylvia", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gonk", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Skullfinder", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Sylvia",
        },
        
        {
            command = "wait",
            who = "Gonk",
        },

        {
            command = "wait",
            who = "Skullfinder",
        },

        {
            command = "signal",
            who = {"Skullfinder",},
        },                
        
        {
            command = "signal",
            who = {"Sylvia",},
        },

        {
            command = "signal",
            who = {"Gonk",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Sylvia", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gonk", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Skullfinder", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Sylvia",
        },
        
        {
            command = "wait",
            who = "Gonk",
        },

        {
            command = "wait",
            who = "Skullfinder",
        },

        {
            command = "signal",
            who = {"Skullfinder",},
        },       
        
        {
            command = "signal",
            who = {"Sylvia",},
        },

        {
            command = "signal",
            who = {"Gonk",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Sylvia", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gonk", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Skullfinder", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Sylvia",
        },
        
        {
            command = "wait",
            who = "Gonk",
        },

        {
            command = "wait",
            who = "Skullfinder",
        },

        {
            command = "signal",
            who = {"Skullfinder",},
        },               
        
        {
            command = "signal",
            who = {"Sylvia",},
        },

        {
            command = "signal",
            who = {"Gonk",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Sylvia", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gonk", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Skullfinder", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

    },
    
}

CreditsCutsceneBlocks.AcademyIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_academy_EmptySchool", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Rosalyn
        --
        {
            command = "spawnobject",
            label = "Rosalyn",
            classKey = "character",
            collectionKey = "cr_rosalyn",
            x = 24.399 ,
            y = 0.6,
            z = 41.068 ,
            rotY = 95.711 ,
            blocking = true,
        },
            
        --
        -- Chaz
        --
        {
            command = "spawnobject",
            label = "Chaz",
            classKey = "character",
            collectionKey = "cr_chaz",
            x = 24.318 ,
            y = 0.6,
            z = 39.601 ,
            rotY = 87.581 ,
            blocking = true,
        },
        
        --
        -- Summer
        --
        {
            command = "spawnobject",
            label = "Summer",
            classKey = "character",
            collectionKey = "cr_summer",
            x = 24.521 ,
            y = 0.6,
            z = 37.895 ,
            rotY = 78.634 ,
            blocking = true,
        },
        
        --
        -- Travis
        --
        {
            command = "spawnobject",
            label = "Travis",
            classKey = "character",
            collectionKey = "cr_travis",
            x = 25.108 ,
            y = 0.6,
            z = 36.341 ,
            rotY = 63.627 ,
            blocking = true,
        },
        
        --
        -- Liberty
        --
        {
            command = "spawnobject",
            label = "Liberty",
            classKey = "character",
            collectionKey = "cr_liberty",
            x = 25.903 ,
            y = 0.6,
            z = 35.063 ,
            rotY = 56.882 ,
            blocking = true,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Summer", "a-idle-cheer-start", 1},
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 37.376 ,  y = 3.497 ,    z = 47.006 },
            target   = { x = 30.341 ,   y = 2.453 ,    z = 41.995 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Liberty", "Summer", "Travis", "Chaz", "Rosalyn"),
                
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 41.21 ,  y = 3.844 ,    z = 37.815 },
            target   = { x = 30.581 ,   y = 2.333 ,    z = 37.69 },
            transitionDuration = 10.68,
            micY = 0.601, 
        },
        
        -- Dance
        
        {
            command = "signal",
            who = {"Summer",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Summer", "a-idle-cheer-loop02", 0},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rosalyn", "a-dance-credits-armsIn-01b", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Chaz", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Travis", "a-dance-credits-armsIn-01b", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Liberty", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Rosalyn",
        },
        
        {
            command = "wait",
            who = "Chaz",
        },
        
        {
            command = "wait",
            who = "Travis",
        },
        
        {
            command = "wait",
            who = "Liberty",
        },
        
        {
            command = "signal",
            who = {"Rosalyn",},
        },

        {
            command = "signal",
            who = {"Chaz",},
        },
        
        {
            command = "signal",
            who = {"Travis",},
        },
        
        {
            command = "signal",
            who = {"Liberty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rosalyn", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Chaz", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Travis", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Liberty", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Rosalyn",
        },
        
        {
            command = "wait",
            who = "Chaz",
        },
        
        {
            command = "wait",
            who = "Travis",
        },
        
        {
            command = "wait",
            who = "Liberty",
        },

        {
            command = "signal",
            who = {"Rosalyn",},
        },

        {
            command = "signal",
            who = {"Chaz",},
        },
        
        {
            command = "signal",
            who = {"Travis",},
        },
        
        {
            command = "signal",
            who = {"Liberty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rosalyn", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Chaz", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Travis", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Liberty", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Rosalyn",
        },
        
        {
            command = "wait",
            who = "Chaz",
        },
        
        {
            command = "wait",
            who = "Travis",
        },
        
        {
            command = "wait",
            who = "Liberty",
        },

        {
            command = "signal",
            who = {"Rosalyn",},
        },

        {
            command = "signal",
            who = {"Chaz",},
        },
        
        {
            command = "signal",
            who = {"Travis",},
        },
        
        {
            command = "signal",
            who = {"Liberty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rosalyn", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Chaz", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Travis", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Liberty", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Rosalyn",
        },
        
        {
            command = "wait",
            who = "Chaz",
        },
        
        {
            command = "wait",
            who = "Travis",
        },
        
        {
            command = "wait",
            who = "Liberty",
        },

        {
            command = "signal",
            who = {"Rosalyn",},
        },

        {
            command = "signal",
            who = {"Chaz",},
        },
        
        {
            command = "signal",
            who = {"Travis",},
        },
        
        {
            command = "signal",
            who = {"Liberty",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Rosalyn", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Chaz", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Travis", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Liberty", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
    },
    
}

CreditsCutsceneBlocks.AnimalIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_Animal_Arrival", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Renee
        --
        {
            command = "spawnobject",
            label = "Renee",
            classKey = "character",
            collectionKey = "cr_renee",
            x = 43.193 ,
            y = 0.6,
            z = 29.572 ,
            rotY = -17.826 ,
            blocking = true,
        },
        
        --
        -- Dog
        --
        {
            scriptClassName = "DummyScript",
            command = "spawnobject",
            classKey = "herdables",
            collectionKey = "dog_credits",
            x = 44.348 ,
            y = 0.6,
            z = 29.869 ,
            rotY = 23.482 ,
            label = "Dog",
            blocking = true,
        },
        
        --
        -- Cat
        --
        {
            scriptClassName = "DummyScript",
            command = "spawnobject",
            classKey = "herdables",
            collectionKey = "cat_credits",
            x = 45.882 ,
            y = 0.6,
            z = 30.619 ,
            rotY = 264.331 ,
            label = "Cat",
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 40.005 ,  y = 8.554 ,    z = 36.368 },
            target   = { x = 45.373 ,   y = -0.207 ,    z = 28.371 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Renee", "Dog", "Cat"),
        
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 40.545 ,  y = 1.802 ,    z = 38.099 },
            target   = { x = 45.426 ,   y = 1.04 ,    z = 28.018 },
            transitionDuration = 12.99,
            micY = 0.601, 
        },
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Renee", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Dog", "c2c-dog-fight", 0},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Cat", "c2c-cat-fight", 0},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Renee",
        },
        
        {
            command = "signal",
            who = {"Renee",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Renee", "a-dance-credits-armsIn-03a", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Renee",
        },
        
        {
            command = "signal",
            who = {"Renee",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Renee", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Renee",
        },
        
        {
            command = "signal",
            who = {"Renee",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Renee", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Renee",
        },

        {
            command = "signal",
            who = {"Renee",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Renee", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Renee",
        },

        {
            command = "signal",
            who = {"Renee",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Renee", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },
        {
            command = "signal",
            who = {"Dog","Cat"},
        },
    },
}

CreditsCutsceneBlocks.SpookaneIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_SPOOKANE_RuthieIntro", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Carl
        --
        {
            command = "spawnobject", 
            label = "Carl",
            classKey = "character",
            collectionKey = "cr_zombie_carl",
            x = 32.846 ,
            y = 0.6,
            z = 29.228 ,
            rotY = 10.057 ,
            blocking = true,
        },
        
        --
        -- Gothboy
        --
        {
            command = "spawnobject",
            label = "Gothboy",
            classKey = "character",
            collectionKey = "cr_gothboy",
            x = 27.63 ,
            y = 0.6,
            z = 31.993 ,
            rotY = 48.886 ,
            blocking = true,
        },
        
        --
        -- Ruthie
        --
        {
            command = "spawnobject",
            label = "Ruthie",
            classKey = "character",
            collectionKey = "cr_Ruthie",
            x = 28.644 ,
            y = 0.6,
            z = 30.93 ,
            rotY = 40.756 ,
            blocking = true,
        },
        
        --
        -- Morcubus
        --
        {
            command = "spawnobject", 
            label = "Morcubus",
            classKey = "character",
            collectionKey = "cr_Morcubus",
            x = 29.904 ,
            y = 0.6,
            z = 30.026 ,
            rotY = 31.809 ,
            blocking = true,
        },
        
        --
        -- Yuki
        --
        {
            command = "spawnobject", 
            label = "Yuki",
            classKey = "character",
            collectionKey = "cr_yuki",
            x = 31.347 ,
            y = 0.6,
            z = 29.478 ,
            rotY = 16.802 ,
            blocking = true,
        },
        

        --
        -- Startup Carl's special dance
        --
        -- Special Carl Dance
        {   
            jobClassName =  "Job_PlayAnimation_CutsceneTalk",
            jobParams =     {
                                "$Carl",
                                {
                                    "a-idle-thrillerDance-start",
                                    count = 1,
                                    idles =
                                    {
                                        { "a-idle-thrillerDance-loop" },
                                    },
                                },
                            },
            blocking = false,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 41.641 ,  y = 2.975 ,    z = 42.445 },
            target   = { x = 36.067 ,   y = 2.344 ,    z = 36.44 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Carl", "Gothboy", "Ruthie", "Morcubus", "Yuki"),
                
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 32.079 ,  y = 3.647 ,    z = 46.524 },
            target   = { x = 31.068 ,   y = 2.667 ,    z = 38.477 },
            transitionDuration = 8.67,
            micY = 0.601, 
        },
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gothboy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ruthie", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morcubus", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Yuki", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Gothboy",
        },
        
        {
            command = "wait",
            who = "Ruthie",
        },

        {
            command = "wait",
            who = "Morcubus",
        },
        
        {
            command = "wait",
            who = "Yuki",
        },

        {
            command = "signal",
            who = {"Gothboy",},
        },

        {
            command = "signal",
            who = {"Ruthie",},
        },
        
        {
            command = "signal",
            who = {"Morcubus",},
        },

        {
            command = "signal",
            who = {"Yuki",},
        },     
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gothboy", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ruthie", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morcubus", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Yuki", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Gothboy",
        },
        
        {
            command = "wait",
            who = "Ruthie",
        },

        {
            command = "wait",
            who = "Morcubus",
        },
        
        {
            command = "wait",
            who = "Yuki",
        },

        {
            command = "signal",
            who = {"Yuki",},
        },     

        {
            command = "signal",
            who = {"Morcubus",},
        },                
        
        {
            command = "signal",
            who = {"Gothboy",},
        },

        {
            command = "signal",
            who = {"Ruthie",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gothboy", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ruthie", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morcubus", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Yuki", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Gothboy",
        },
        
        {
            command = "wait",
            who = "Ruthie",
        },

        {
            command = "wait",
            who = "Morcubus",
        },
        
        {
            command = "wait",
            who = "Yuki",
        },

        {
            command = "signal",
            who = {"Yuki",},
        },     

        {
            command = "signal",
            who = {"Morcubus",},
        },       
        
        {
            command = "signal",
            who = {"Gothboy",},
        },

        {
            command = "signal",
            who = {"Ruthie",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gothboy", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ruthie", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morcubus", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Yuki", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Gothboy",
        },
        
        {
            command = "wait",
            who = "Ruthie",
        },

        {
            command = "wait",
            who = "Morcubus",
        },
        
        {
            command = "wait",
            who = "Yuki",
        },

        {
            command = "signal",
            who = {"Yuki",},
        },        

        {
            command = "signal",
            who = {"Morcubus",},
        },               
        
        {
            command = "signal",
            who = {"Gothboy",},
        },

        {
            command = "signal",
            who = {"Ruthie",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gothboy", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Ruthie", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Morcubus", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Yuki", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "signal",
            who = {"Carl",},
        },
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Carl", "a-idle-thrillerDance-stop", 1},
            blocking = false,
        },
        
    },
    
}

CreditsCutsceneBlocks.TrevorIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "NPC_TREVOR_ACTONE", taskState = Task.States["kCompletionAck"] }} ),
    
    sequence =
    {
        --
        -- Trevor
        --
        {
            command = "spawnobject",
            label = "Trevor",
            classKey = "character",
            collectionKey = "cr_trevor",
            x = 51.025,
            y = 0.6,
            z = 47.305,
            rotY = 236.313,
            blocking = true,
        },
        
        --
        -- Linda
        --
        {
            command = "spawnobject",
            label = "Linda",
            classKey = "character",
            collectionKey = "cr_linda",
            x = 51.701,
            y = 0.6,
            z = 46.036,
            rotY = -110.869,
            blocking = true,
        },
        
        --
        -- Gordon
        --
        {
            command = "spawnobject",
            label = "Gordon",
            classKey = "character",
            collectionKey = "cr_gordon",
            x = 50.108,
            y = 0.6,
            z = 48.439,
            rotY = 221.709,
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 43.135 ,  y = 1.805 ,    z = 42.703 },
            target   = { x = 51.698 ,   y = 1.452 ,    z = 47.715 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Trevor", "Linda", "Gordon"),
        
        -- Camera End
        
        {
            command         = "camera",
            
            position = { x = 44.618 ,  y = 7.812 ,    z = 40.797 },
            target   = { x = 51.568 ,   y = 1.031 ,    z = 47.655 },
            transitionDuration = 10.68,
            micY = 0.601, 
        },
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Trevor", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linda", "a-dance-credits-armsIn-01b", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gordon", "a-dance-credits-armsIn-01b", 2},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"Trevor",},
        },

        {
            command = "signal",
            who = {"Linda",},
        },
        
        {
            command = "signal",
            who = {"Gordon",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Trevor", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linda", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gordon", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Trevor",},
        },

        {
            command = "signal",
            who = {"Linda",},
        },
        
        {
            command = "signal",
            who = {"Gordon",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Trevor", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linda", "a-dance-credits-armsForward-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gordon", "a-dance-credits-armsForward-01", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Trevor",},
        },

        {
            command = "signal",
            who = {"Linda",},
        },
        
        {
            command = "signal",
            who = {"Gordon",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Trevor", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linda", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gordon", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"Trevor",},
        },

        {
            command = "signal",
            who = {"Linda",},
        },
        
        {
            command = "signal",
            who = {"Gordon",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Trevor", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linda", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Gordon", "a-dance-credits-armsSides-02", 2},
            blocking = false,
        },
        
    },
    
}

CreditsCutsceneBlocks.LeafIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "NPC_Petal_BuildTemple", taskState = Task.States["kCompletionAck"] }} ),
    
    sequence =
    {
        --
        -- Protomakoto
        --
        {
            command = "spawnobject",
            label = "Protomakoto",
            classKey = "character",
            collectionKey = "cr_protomakoto",
            x = 23.502,
            y = 0.6,
            z = 41.464,
            rotY = 74.079,
            blocking = true,
        },

        --
        -- Hopper
        --
        {
            command = "spawnobject",
            label = "Hopper",
            classKey = "character",
            collectionKey = "cr_hopper",
            x = 26.098,
            y = 0.6,
            z = 38.034,
            rotY = 30.074,
            blocking = true,
        },
        
        --
        -- Leaf
        --
        {
            command = "spawnobject",
            label = "Leaf",
            classKey = "character",
            collectionKey = "cr_leaf",
            x = 23.922,
            y = 0.6,
            z = 40.017,
            rotY = 57.571,
            blocking = true,
        },
        
        --
        -- Petal
        --
        {
            command = "spawnobject",
            label = "Petal",
            classKey = "character",
            collectionKey = "cr_petal",
            x = 24.81,
            y = 0.6,
            z = 38.808,
            rotY = 39.752,
            blocking = true,
        },
        
        --
        -- Protomakoto funky dance
        --
        -- Special Protomakoto Dance
        {   
            jobClassName =  "Job_PlayAnimation_CutsceneTalk",
            jobParams =     {
                                "$Protomakoto",
                                {
                                    count = 100,
                                    "a2a-funkyRobot-performer",
                                },
                            },
            blocking = false,
        },
        
        -- Camera Start
        
        {
            command  = "camera",
            
            position = { x = 31.87 ,  y = 3.21 ,    z =50.568 },
            target   = { x = 29.235 ,   y = 2.594 ,    z = 46.687 },
            transitionDuration = 0.0,
            micY = 0.601, 
        },       
        
        GenerateDeleteSequence("Protomakoto", "Hopper", "Leaf", "Petal"),
        
        -- Camera Stop
        
        {
            command         = "camera",
            
            position = { x = 36.348 ,  y = 3.449 ,    z = 44.174 },
            target   = { x = 32.768 ,   y = 2.819 ,    z = 42.74 },
            transitionDuration = 12.99,
            micY = 0.601, 
        },        
        
        -- Dance
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Hopper", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Leaf", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Petal", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Hopper",
        },
        
        {
            command = "wait",
            who = "Leaf",
        },

        {
            command = "wait",
            who = "Petal",
        },

        {
            command = "signal",
            who = {"Petal",},
        },        
        
        {
            command = "signal",
            who = {"Hopper",},
        },

        {
            command = "signal",
            who = {"Leaf",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Hopper", "a-dance-credits-armsIn-03b", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Leaf", "a-dance-credits-armsIn-03a", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Petal", "a-dance-credits-armsIn-03a", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Hopper",
        },
        
        {
            command = "wait",
            who = "Leaf",
        },

        {
            command = "wait",
            who = "Petal",
        },

        {
            command = "signal",
            who = {"Petal",},
        },                
        
        {
            command = "signal",
            who = {"Hopper",},
        },

        {
            command = "signal",
            who = {"Leaf",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Hopper", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Leaf", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Petal", "a-dance-credits-armsIn-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Hopper",
        },
        
        {
            command = "wait",
            who = "Leaf",
        },

        {
            command = "wait",
            who = "Petal",
        },

        {
            command = "signal",
            who = {"Petal",},
        },       
        
        {
            command = "signal",
            who = {"Hopper",},
        },

        {
            command = "signal",
            who = {"Leaf",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Hopper", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Leaf", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Petal", "a-dance-credits-armsSides-03", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Hopper",
        },
        
        {
            command = "wait",
            who = "Leaf",
        },

        {
            command = "wait",
            who = "Petal",
        },

        {
            command = "signal",
            who = {"Petal",},
        },               
        
        {
            command = "signal",
            who = {"Hopper",},
        },

        {
            command = "signal",
            who = {"Leaf",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Hopper", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Leaf", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Petal", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {
            command = "wait",
            who = "Hopper",
        },
        
        {
            command = "wait",
            who = "Leaf",
        },

        {
            command = "wait",
            who = "Petal",
        },

        {
            command = "signal",
            who = {"Petal",},
        },               
        
        {
            command = "signal",
            who = {"Hopper",},
        },

        {
            command = "signal",
            who = {"Leaf",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Hopper", "a-dance-credits-armsIn-02b", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Leaf", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Petal", "a-dance-credits-armsIn-02a", 1},
            blocking = false,
        },
        {
            command = "signal",
            who = {"Protomakoto",},
        },

    },
    
}

CreditsCutsceneBlocks.CutopiaIsland =
{
    command = "sequence",

    taskPrerequisites = DebugBlocksHelper( {{ taskId = "Cutscene_Cute_BallBegins", taskState = Task.States["kComplete"] }} ),
    
    sequence =
    {
        --
        -- Daniel
        --
        {
            command = "spawnobject",
            label = "Daniel",
            classKey = "character",
            collectionKey = "cr_daniel",
            x = 22.78 ,
            y = 0.6,
            z = 48.994 ,
            rotY = 97.407 ,
            blocking = true,
        },
        
        --
        -- Violet
        --
        {
            command = "spawnobject",
            label = "Violet",
            classKey = "character",
            collectionKey = "cr_violet",
            x = 22.661 ,
            y = 0.6,
            z = 47.436 ,
            rotY = 93.002 ,
            blocking = true,
        },
        
        --
        -- Beverly
        --
        {
            command = "spawnobject",
            label = "Beverly",
            classKey = "character",
            collectionKey = "cr_beverly",
            x = 23.159 ,
            y = 0.6,
            z = 50.469 ,
            rotY = 112.944 ,
            blocking = true,
        },

        --
        -- Spencer
        --
        {
            command = "spawnobject",
            label = "Spencer",
            classKey = "character",
            collectionKey = "cr_spencer",
            x = 22.831 ,
            y = 0.6,
            z = 45.94 ,
            rotY = 77.369 ,
            blocking = true,
        },

        --
        -- Poppy
        --
        {
            command = "spawnobject",
            label = "Poppy",
            classKey = "character",
            collectionKey = "cr_poppy",
            x = 23.322 ,
            y = 0.6,
            z = 44.533 ,
            rotY = 66.708 ,
            blocking = true,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 38.359 ,  y = 3.99 ,    z = 43.595 },
            target   = { x = 29.574 ,   y = 2.573 ,    z = 45.696 },
            transitionDuration = 0.0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence("Daniel", "Poppy", "Violet", "Spencer", "Beverly"),
                
        -- Camera End
        
        {
            command         = "camera",
            
            position = { x = 38.352 ,  y = 3.896 ,    z = 52.162 },
            target   = { x = 28.847 ,   y = 2.412 ,    z = 49.288 },
            transitionDuration = 10.8,
            micY = 0.601, 
        },

        -- Dance     
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Daniel", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
    
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Violet", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Spencer", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Poppy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Beverly", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = true,
        },
        
        {
            command = "wait",
            who = "Poppy",
        },

        {
            command = "signal",
            who = {"Daniel",},
        },

        {
            command = "signal",
            who = {"Violet",},
        },
        
        {
            command = "signal",
            who = {"Spencer",},
        },
        
        {
            command = "signal",
            who = {"Poppy",},
        },
        
        {
            command = "signal",
            who = {"Beverly",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Daniel", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Violet", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Spencer", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Poppy", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Beverly", "a-dance-credits-armsForward-02", 2},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"Daniel",},
        },

        {
            command = "signal",
            who = {"Violet",},
        },
        
        {
            command = "signal",
            who = {"Spencer",},
        },
        
        {
            command = "signal",
            who = {"Poppy",},
        },
        
        {
            command = "signal",
            who = {"Beverly",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Daniel", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Violet", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Spencer", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Poppy", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
            {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Beverly", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"Daniel",},
        },

        {
            command = "signal",
            who = {"Violet",},
        },
        
        {
            command = "signal",
            who = {"Spencer",},
        },
        
        {
            command = "signal",
            who = {"Poppy",},
        },
        
        {
            command = "signal",
            who = {"Beverly",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Daniel", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Violet", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Spencer", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Poppy", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Beverly", "a-dance-credits-armsSides-01", 2},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"Daniel",},
        },

        {
            command = "signal",
            who = {"Violet",},
        },
        
        {
            command = "signal",
            who = {"Spencer",},
        },
        
        {
            command = "signal",
            who = {"Poppy",},
        },
        
        {
            command = "signal",
            who = {"Beverly",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Daniel", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Violet", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Spencer", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Poppy", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Beverly", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"Daniel",},
        },

        {
            command = "signal",
            who = {"Violet",},
        },
        
        {
            command = "signal",
            who = {"Spencer",},
        },
        
        {
            command = "signal",
            who = {"Poppy",},
        },
        
        {
            command = "signal",
            who = {"Beverly",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Daniel", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Violet", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Spencer", "a-dance-credits-armsIn-01b", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Poppy", "a-dance-credits-armsIn-01a", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Beverly", "a-dance-credits-armsIn-01b", 1},
            blocking = true,
        },
    },
}

CreditsCutsceneBlocks.MainCastBlock =
{
    command = "sequence",
    taskPrerequisites = nil,
    sequence =
    {
        
        {
            command = "setposition",
            who = "Buddy",
            x = 42.238,
            y = 0.6,
            z = 58.677,
            rotY = 195.359,
            blocking = true,
        },
        
        {
            command = "setposition",
            who = "Marlin",
            x = 38.475,
            y = 0.6,
            z = 59.085,
            rotY = 179.724,
        },
        
        -- Camera Start
        
        {
            command         = "camera",
            
            position = { x = 36.22  ,  y = 6.793 ,    z = 46.173 },
            target   = { x = 39.618 ,   y = 1.171 ,    z = 58.87 },
            transitionDuration = 0,
            micY = 0.601, 
        },
        
        GenerateDeleteSequence(),
                
        -- Camera End
        
        {
            command         = "camera",
            
            position = { x = 44.712 ,  y = 3.773 ,    z = 45.952 },
            target   = { x = 39.618 ,   y = 1.171 ,    z = 58.87 },
            transitionDuration = 13.5,
            micY = 0.601, 
        },
        
        -- Dance
        
        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsForward-02", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsSides-01", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsIn-01b", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsIn-01b", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
    },
    
}


---------------------------------------------
-- Actual Cutscene
---------------------------------------------
local CheckForCreditCompletionAndExit =
{
    command = "function",
    func =  function(cutscene)
                local creditsUI = cutscene.labelMap["CreditsUI"]
                if creditsUI and creditsUI.lifeCondition then
                    if creditsUI.lifeCondition:IsSignaled() then
                        cutscene.bCanceled = true
                    end
                end            
            end,
}

local Name = "Credits_WinGame"

local Cutscene =
{
    name = "Game Win",
    
    taskIdOnCompletion = "Cutscene_Credits_WinGame",
    
    bLetterboxDisabled = true,
    bDisableCancel = true,
    bPlayMany = true,
--|     bMultiIsland = true,

    
--|     bStartUpFadeOut = true,
--|     bStartupFadeIn = true,
--|     bShutdownFadeOut = true,
--|     bShutdownFadeIn = false, -- because we are about to do a island transition
    
    simLabels = { "PC", "Buddy", "Linzey", "Roland" },
    
    labelMap =  {
                    ["PC"] = "Player",
                    ["Buddy"] = "NPC_Buddy",
                    ["Linzey"] = "NPC_Linzey",
                    ["Roland"] = "NPC_King",
                    },
                
    
startup =    
    {
        -- INITIAL POSITIONS
        {
            command = "setposition",
            who = "PC",
            x = 53.246,
            y = 0.6,
            z = 38.034,
            rotY = 0.0,
        },
        
        {
            command = "setposition",
            who = "Roland",
            x = 53.246,
            y = 0.6,
            z = 38.034,
        },
        
        {
            command = "setposition",
            who = "Linzey",
            x = 53.246,
            y = 0.6,
            z = 38.034,
            rotY = 0.0,
        },
        
        {
            command = "setposition",
            who = "Buddy",
            x = 53.246,
            y = 0.6,
            z = 38.034,
            rotY = 0.0,
        },
        
        {
            command = "spawnobject",
            classKey = "character",
            collectionKey = "cr_marlin",
            x = 53.246,
            y = 0.6,
            z = 38.034,
            rotY = 1,
            label = "Marlin",
            blocking = true,
        },
        
        {
            command         = "camera",
            
            position = { x = 58.232,  y = 24.644,    z = 7.864 },
            target   = { x = 47.856,   y = 15.254,    z = 14.348 },
            transitionDuration = 0,
            micY = 0.601, 
        },    

        {
            command = "function",
            func =  function( cutscene )
                        cutscene.labelMap["CreditsUI"] = UI:Spawn( "UICredits", Credits_Generated:GetCredits() )
                    end,
        },
    },
    
    sequence =
    {
        {
            command         = "camera",
            
            position = { x = 39.254 ,  y = 3.68 ,    z = 46.469 },
            target   = { x = 39.688 ,   y = 1.45 ,    z = 58.867 },
            
            --position = { x = 39.022,  y = 5.033,    z = 45.621 },
            --target   = { x = 40.444,   y = 1.42,    z = 59.069 },
            transitionDuration = 15,
            --blocking = true,
        },
        
        {   
            command = "pause",
            seconds = 10.75,
        },
        
        {   command = "effect",
            name = "sim-magicTransport-poof-effects",
            lifetime = 3.0,
            position = {x = 38.475,    y = 1.35,      z = 59.085,  rotY = 179.724},
        },
        
        {
            command = "setposition",
            who = "Marlin",
            x = 38.475,
            y = 0.6,
            z = 59.085,
            rotY = 179.724,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a2a-magicTransport-appear-transportee", 1},
            blocking =      false,
        },
        
        {
            command = "pause",
            seconds = 0.85,
        },
        {
            command = "signal",
            who = {"Marlin",},
        },
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a2a-magicTransport-disappear-transporter", 1},
            blocking =      true,
        },
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-idle-bop", 0},
            blocking =      false,
        },
        {   command = "effect",
            name = "sim-magicTransport-poof-effects",
            lifetime = 3.0,
            position = {x = 40.967,    y = 1.35,      z = 58.306,  rotY = 190.336},
        },
        {
            command = "setposition",
            who = "Linzey",
            x = 40.967,
            y = 0.6,
            z = 58.306,
            rotY = 190.336,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a2a-magicTransport-appear-transportee", 1},
            blocking =      false,
        },
        
        {
            command = "pause",
            seconds = 0.5,
        },
        
        {   command = "effect",
            name = "sim-magicTransport-poof-effects",
            lifetime = 3.0,
            position = {x = 39.654,    y = 1.35,      z = 57.983,  rotY = 185.168},
        },
           
        {
            command = "setposition",
            who = "PC",
            x = 39.654,
            y = 0.6,
            z = 57.983,
            rotY = 185.168,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a2a-magicTransport-appear-transportee", 1},
            blocking =      false,
        },
        
        {
            command = "pause",
            seconds = 0.3,
        },
        
        {   command = "effect",
            name = "sim-magicTransport-poof-effects",
            lifetime = 3.0,
            position = {x = 37.268,    y = 1.35,      z = 58.257,  rotY = 155.939},
        },
        
        {
            command = "setposition",
            who = "Roland",
            x = 37.268,
            y = 0.6,
            z = 58.257,
            rotY = 155.939,
            blocking = true,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a2a-magicTransport-appear-transportee", 1},
            blocking =      false,
        },
        
        {
            command = "pause",
            seconds = 0.3,
        },
        
        {   command = "effect",
            name = "sim-magicTransport-poof-effects",
            lifetime = 3.0,
            position = {x = 42.238,    y = 1.35,      z = 58.677,  rotY = 195.359},
        },
    
        {
            command = "setposition",
            who = "Buddy",
            x = 42.238,
            y = 0.6,
            z = 58.677,
            rotY = 195.359,
            blocking = true,
        },

        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a2a-magicTransport-appear-transportee", 1},
            blocking =      false,
        },
        
        {
            command = "pause",
            seconds = 0.3,
        },
     
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-react-politeClap", 0},
            blocking = false,
        },
        
        {
            command = "signal",
            who = {"PC",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-react-hoot", 0},
            blocking = false,
        },
        
        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-react-cheer", 0},
            blocking = false,
        },    

        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-react-listenGood", 0},
            blocking = false,
        },

        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-react-superHappy", 0},
            blocking = false,
        },

        {
            command = "pause",
            seconds = 3.0,
        },
        
        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
            
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = true,
        },
        
        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsForward-02", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsForward-02", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsForward-2-armsSides-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsSides-01", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsSides-01", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsSides-2-armsIn-transition", 1},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsIn-01b", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsIn-01a", 2},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsIn-01b", 2},
            blocking = true,
        },

        {
            command = "signal",
            who = {"PC",},
        },

        {
            command = "signal",
            who = {"Marlin",},
        },
        
        {
            command = "signal",
            who = {"Roland",},
        },
        
        {
            command = "signal",
            who = {"Linzey",},
        },
        
        {
            command = "signal",
            who = {"Buddy",},
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$PC", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Marlin", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Roland", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },

        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Linzey", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        {   
            jobClassName =  "Job_PlayAnimation",
            jobParams =     { "$Buddy", "a-dance-credits-armsIn-2-armsForward-transition", 1},
            blocking = false,
        },
        
        
        {
            command = "sequence",
            loops = 1000,           -- loop for a finite 'forever'
            sequence =
            {
                CreditsCutsceneBlocks.CapitalIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.RocketReefIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.CandyIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.CowboyJunctionIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.PirateIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.AcademyIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.AnimalIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.SpookaneIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.TrevorIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.LeafIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.CutopiaIsland,
                CheckForCreditCompletionAndExit,
                CreditsCutsceneBlocks.MainCastBlock,
                CheckForCreditCompletionAndExit,
            },
        },

        {
            command = "function",
            func =  function( cutscene )
                        local creditsUI = cutscene.labelMap["CreditsUI"]
                        
                        while (not cutscene.bCanceled) do
                            local result, reason = creditsUI:BlockOn(Clock.Game, 0, 0, 0, 1)
                            
                            if result ~= BlockingResult.TimedOut then
                                break
                            end
                        end                        
                    end,
        },

    },    

    shutdown =
    {
        {
            command = "restoreposition",
            who = "PC",
        },
        
        {
            command = "restoreposition",
            label = "Roland",
        },
        
        {
            command = "restoreposition",
            label = "Linzey",
        },
        
        {
            command = "restoreposition",
            label = "Buddy",
        },
        
        {
            command = "destroyobject",
            label = "Marlin",
        },
        
        GenerateDeleteSequence(),

        {
            command = "function",
            func =  function( cutscene )
                        
                        local creditsUI = cutscene.labelMap["CreditsUI"]
                        cutscene.labelMap["CreditsUI"] = nil
                        
                        if creditsUI then
                            creditsUI:ForceExit()
                        end
                    end,
        },
        
        
        --
        -- Unlock reward
        --
        {
            command = "unlock",
            classKey = "island",
            collectionKey = "reward_island",
        },


        --
        -- Magic Teleporting command
        -- & Cleanup
        --
        {
            command = "function",
            func =  function(cutscene)
            
                        -- Release the blocks
                        CreditsCutsceneBlocks = nil
                        -- Release the Credits
                        --Credits = nil                        
                                                
                        --===================================
                        -- Teleport
                        --
                        local function TeleportClosure( job )
                            
                            cutscene:BlockOn()
                                                    
                            local destWorld = Universe:GetIslandStartingWorld( "island" , "reward_island" )
                            
                            if destWorld then
                                Universe:RequestGameplayWorldChange(destWorld)
                                local teleport = Classes.Job_Teleport:Spawn( Universe:GetPlayerGameObject(), destWorld )
                                teleport:ExecuteAsIs()	
                                teleport:BlockOn()
                            end
                                                        
                            job:Destroy()
                        end
                        
                        local job = Classes.Job_PerFrameFunctionCallback:Spawn( TeleportClosure )
                        job:ExecuteAsIs()
                        --
                        --===================================
                        
                    end,
        },              
        
    },
    
}

Classes.Job_CutsceneController:AddCutscene( Name, Cutscene )

--------------------------------------------------------

local function DebugMenuTriggered( key, value )
    if value == true then
        Classes.Job_CutsceneController:ExecuteCutscene( Name )
        DebugMenu:ModifyValue( "TestCutscene_" .. Name, false )
    end
end

local function AddDebugMenuTest()
    DebugMenu:AddValueItem( "TestCutscene_" .. Name, false, DebugMenuItemTypes.kTypeBool, DebugMenuTriggered )
end

if not _FINAL then
    System:RegisterGeneralPostLoadInit( AddDebugMenuTest )
end

