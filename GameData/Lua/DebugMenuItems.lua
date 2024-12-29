----------------------------------------
-- GeneralPostLoadInit()
--  Allows addition of helpful gameplay
--  cheats at _top_ of list.
----------------------------------------
local generalLoad = false

local function GeneralPostLoadInit()
    generalLoad = true
end

System:RegisterGeneralPostLoadInit( GeneralPostLoadInit )


------------------------
-- AddResourcesCheat
------------------------
local function AddResource( collectionName )
    local count = 999 - Inventory:ResourceGetCountByKey( collectionName )
    
    if count > 0 then
        Inventory:ResourceDeltaByKey( collectionName, count, false )
    end    
end

function AddResourcesCheat( key, value )
    if value == true and generalLoad == true then
            
        local resources = Luattrib:GetAllCollections("resource")
        
        for i, refspec in ipairs(resources) do
        
            local baseTypes = Luattrib:ReadAttribute( refspec[1], refspec[2], "BaseType" )
            
            local bAddResource = true
            
            if baseTypes then
                for j, basetype in ipairs(baseTypes) do
                    
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
    --DebugMenu:ModifyValue( key, false )
end

-----------------
-- EnableTutorial
-----------------
local function EnableTutorial( key, value )
	Tutorial:EnableTutorial( value )
end

-----------------
-- CheatTutorialLocks
-----------------
local function CheatTutorialLocks( key, value )
	if ( value == true ) then
		Tutorial:CheatTutorialLocks()
	end -- check value
	
	DebugMenu:ModifyValue( key, false )
end

-----------------
-- UnlockAllHarvestingTools
-----------------
local function UnlockAllHarvestingTools( key, value )
	if ( value == true ) then
		Unlocks:Unlock( "tools_harvesting", "axe_low" )
		Unlocks:Unlock( "tools_harvesting", "wateringcan_low" )
		Unlocks:Unlock( "tools_harvesting", "pickaxe_low" )
		Unlocks:Unlock( "tools_harvesting", "metaldetector_low" )
        Unlocks:Unlock( "tools_harvesting", "harvest_low" )
	end
	
	DebugMenu:ModifyValue( key, false )
end


------------------------
-- PowerWorld Cheat
------------------------
local function PowerWorldCheat( key, value )
    if generalLoad == true then
        
        local world = Universe:GetWorld()
        if world then
            world:SetAttribute("IsWorldPowered", value)
        end
    end
end

------------------------
-- AdvanceToDay2 Cheat
------------------------
local function AdvanceToDay2( key, value )
    if generalLoad == true then
    
        local function Closure(job)
            local world = Universe:GetWorld()
            if world and GameManager:IsDuringTaskTime() then
                
                GameManager:EndTaskTime()
            
                local sims = Common:GetAllIslandSims()
                
                for i, sim in ipairs(sims) do
                    sim.schedule:DestroyTaskDaySaveData()
                    sim.schedule:InitializeSchedule()
                end
            end
            job:Destroy()
        end
        
        local job = Classes.Job_PerFrameFunctionCallback:Spawn( Closure )
        job:ExecuteAsIs()
        
    end
    DebugMenu:ModifyValue( key, false )
end

------------------------
-- ForceCrash Cheat
------------------------
local function ForceCrash( key, value )
    UIEngineUtils:ForceApplicationCrash()
    
end

--==================--
-- RewardsPerIsland --
--==================--
local islandTbl =
{
	"None",
	"Academy",
	"Animal",
	"Candy",
	"Capital",
	"Cowboy_Junction",
	"Cutopia",
	"Gonk",
	"Leaf",
	"Rocket_Reef",
	"Spookane",
	"Trevor",
	"DAY2_SOCIALIZE",
}

local function UnlockAllRewards( s, mapping )
	if ( s ~= nil ) and ( mapping[s] ~= nil ) then
		local allRefSpecs = Luattrib:GetAllCollections( "reward", mapping[s] )
		
		for i,refSpec in ipairs(allRefSpecs) do
			local allUnlocks = Luattrib:ReadAttribute( refSpec[1], refSpec[2], "Unlocks" )
			
			for j,unlockRefSpec in ipairs(allUnlocks) do
				Unlocks:Unlock( unlockRefSpec[1], unlockRefSpec[2] )
			end -- for allUnlocks
		end -- for allRefSpecs
	end -- verify s
end

local function UnlockAllScrollRewardsForIsland( key, value, s )
	local mapping =
	{
		Academy = "academy_scrolls",
		Animal = "animal_scrolls",
		Candy = "candy_scrolls",
		Capital = "capital_scrolls",
		Cowboy_Junction = "cowboy_junction_scrolls",
		Cutopia = "cutopia_scrolls",
		Gonk = "gonk_scrolls",
		Leaf = "leaf_scrolls",
		Rocket_Reef = "rocket_reef_scrolls",
		Spookane = "spookane_scrolls",
		Trevor = "trevor_scrolls",
	}
	
	UnlockAllRewards( s, mapping )
end

local function AddScrollRewardsPerIslandMenuItem()
	DebugMenu:AddStringItem( "AllScrollRewardsForIsland", 1, islandTbl, UnlockAllScrollRewardsForIsland )
end

local function UnlockAllTaskRewardsForIsland( key, value, s )
	local mapping =
	{
		Academy = "academy_task_rewards",
		Animal = "animal_task_rewards",
		Candy = "candy_task_rewards",
		Capital = "capital_task_reward",
		Cowboy_Junction = "cj_task_rewards",
		Cutopia = "cutesburg_task_rewards",
		Gonk = "gonk_task_rewards",
		Leaf = "leaf_task_rewards",
		Rocket_Reef = "rocketreef_task_rewards",
		Spookane = "spookane_task_rewards",
		Trevor = "trevor_island_task_rewards",
		DAY2_SOCIALIZE = "day2socialize_task_rewards",
	}
	
	UnlockAllRewards( s, mapping )
end

local function AddTaskRewardsPerIslandMenuItem()
	DebugMenu:AddStringItem( "AllTaskRewardsForIsland", 1, islandTbl, UnlockAllTaskRewardsForIsland )
end



-------------------------------------------------------
-- AddMenuItem( key, default, valueType, callbackFn )
--  Looks for entry in Debug_Settings
--  Initializes menu with value if found
--------------------------------------------------------
local function AddMenuItem( key, default, valueType, callbackFn )

    local initValue = Debug_Settings[key]
    if initValue == nil then
        initValue = default
    end
    
    DebugMenu:AddValueItem( key, initValue, valueType, callbackFn )
end

------------------------------
-- AddSystemDebugMenuItems()
------------------------------
function AddSystemDebugMenuItems()

    -- In FINAL this enum doesn't exist.
    if _FINAL then
        System:DeclareKey(_G, "DebugMenuItemTypes", {})

        DebugMenuItemTypes.kTypeBool    = 0
        DebugMenuItemTypes.kTypeInt     = 1
        DebugMenuItemTypes.kTypeFloat   = 2
        DebugMenuItemTypes.kTypeString  = 3
    end

    -- this needs to be top for special cheat in final debug
    AddMenuItem( "AddResourcesCheat",                  false, DebugMenuItemTypes.kTypeBool, AddResourcesCheat )
    AddMenuItem( "CheatTutorialLocks",                 false, DebugMenuItemTypes.kTypeBool, CheatTutorialLocks )
    AddTaskRewardsPerIslandMenuItem()
    AddScrollRewardsPerIslandMenuItem()
        
    AddMenuItem( "EnableScheduleAutonomy",             true,  DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "EnableDebugInteractions",            false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "EnableCutscenes",                    true,  DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "EnableSkippingCutscenes",            true,  DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "SuppressCutsceneSkipConfirm",        false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "EnableSkippingUnskippableCutscenes", false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "SeeFullBoatTransitionCutscenes",     false, DebugMenuItemTypes.kTypeBool)
    
    AddMenuItem( "EnableFishingDebug",                 false, DebugMenuItemTypes.kTypeBool)
    
    AddMenuItem( "UnlockAllHarvestingTools",           false, DebugMenuItemTypes.kTypeBool, UnlockAllHarvestingTools )
    
    AddMenuItem( "EnableTutorial",                     true,  DebugMenuItemTypes.kTypeBool, EnableTutorial )
    
    AddMenuItem( "PowerWorldCheat",                    false, DebugMenuItemTypes.kTypeBool, PowerWorldCheat )
    
    AddMenuItem( "DisableParkablePlayer",              false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "EnableRealFakeAutonomy",             false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "RealFakeAutonomyDistance",           25,    DebugMenuItemTypes.kTypeInt)
    
    AddMenuItem( "EnableNPCInterruptByPlayerJump",     false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "NPCInterruptByPlayerJumpHeight",     1.0,   DebugMenuItemTypes.kTypeFloat)
    AddMenuItem( "NPCInterruptByPlayerJumpVel",        0.5,   DebugMenuItemTypes.kTypeFloat)
    
    AddMenuItem( "DemoE3",                             false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "DemoPreview",                        false, DebugMenuItemTypes.kTypeBool)
    AddMenuItem( "AdvanceToDay2",                      false, DebugMenuItemTypes.kTypeBool, AdvanceToDay2 )
    AddMenuItem( "ShowAllCreditsBlocks",               false, DebugMenuItemTypes.kTypeBool )
    AddMenuItem( "ForceCrash",                         false, DebugMenuItemTypes.kTypeBool, ForceCrash)
end

System:RegisterSystemPostLoadInit( AddSystemDebugMenuItems )

