
--- Interaction Overrides -----------------------------------------------------------------

--{{{ DanceFloor_Interaction_Dance.lua --------------------------------------------------------------
function Classes.DanceFloor_Interaction_Dance:Pre_ANIM_LOOPS( sim, obj )
    if not self.bOn then
        obj:TurnOn()
    end
end

function Classes.DanceFloor_Interaction_Dance:ANIMATE_LOOPS_CONTINUE( sim, obj )
    --return (obj.bOn)
    return true -- npcs should keep on dancing when the player turns off the dance floor
end

function Classes.DanceFloor_Interaction_Dance:Post_ANIM_LOOPS( sim, obj )
    return -- don't turn off the dance floor
end

function Classes.DanceFloor_Interaction_Dance:Shutdown( sim, obj )
    return -- don't turn off the dance floor
end
--}}}


--{{{ DJBooth_Interaction_DJ.lua --------------------------------------------------------------
function Classes.DJBooth_Interaction_DJ:Test( sim, obj, autonomous )

    if obj.bInUse or obj:GetWidgetPowerValue() == 0 then --- custom code
    return false
    end

    if autonomous == true and GameManager:IsDuringTaskTime() then
        if obj.collectionKey == Luattrib:ConvertStringToUserdataKey("djbooth_00031") then
            if sim.mType ~= "NPC_DJCandy" and Task:IsTaskComplete("Cutscene_Candy_RoadieSoundCheck") then
                return false
            end
        end
    end

    return true
end

function Classes.DJBooth_Interaction_DJ_Uber:Test( sim, obj, autonomous, interactionData )
    local powerRequirement = interactionData.powerRequirement or 2.0

    if sim == Universe:GetPlayerGameObject() then
        --- custom code
        return (not obj.bInUse) and DebugMenu:GetValue("EnableDebugInteractions") and obj:GetWidgetPowerValue() > 0
    end

    return (not obj.bInUse) and obj:GetWidgetPowerValue() >= powerRequirement --- custom code
end
--}}}


--{{{ Boat_Interaction_ChangeOutfit.lua --------------------------------------------------------------
function Classes.Boat_Interaction_ChangeOutfit:Test( sim, obj, autonomous )
    return sim == Universe:GetPlayerGameObject() -- and Unlocks:IsUnlocked("lock", "boat_cas") -- skip unlock check
end

function Classes.Boat_Interaction_ChangeOutfit:Action()
    local gender = nil
    if self.params and self.params.actionKey then
        if self.params.actionKey == "m" then
            gender = Constants.Gender.Male
        elseif self.params.actionKey == "f" then
            gender = Constants.Gender.Female
        end
    end

    -- due to PostSpawn() call in UICASContextPicker:Constructor() we need a different approach
    -- (no idea why PostSpawn() is called in UICASContextPicker:Constructor())
    -- instead: set a pendingGender variable in the class & access inside UICASContextPicker:SetParams()
    Classes.UICASContextPicker.pendingGender = gender

    local reason, context = UI:SpawnAndBlock( "UICASContextPicker" )

    if( reason == 1 ) then
        GameManager:EnterCAS( "cas_context", context )
    end
end
--}}}



--- autonomous interaction fixes

--{{{ PortalBase.lua --------------------------------------------------------------
-- allow sims to go through doors autonomously

function Classes.PortalBase_Interaction_TeleportThroughPortal:Test( sim, obj, autonomous )
    if (sim == Universe:GetPlayerGameObject() or autonomous) and obj:FindActivePortal() then
        -- if the sim is not the player, we only allow autonomous interactions with active portals
        return true
    end

    return false
end

function Classes.PortalBase_Interaction_TeleportThroughPortal:Action( sim, obj )
    --EA:LogMod("PortalDebug", "PortalBase_Interaction_TeleportThroughPortal:Action() called for sim:", sim.mType, "on object:", obj.mType)

    local result, reason
    local portal = obj:FindActivePortal()

    if sim == Universe:GetPlayerGameObject() then
        -- player enters the portal
        sim:PlaySound("ui_npc_location_exit")

        local cond = ConditionCreate()
        Universe:RequestTeleportThroughPortal(sim, portal, cond)
        result, reason = cond:BlockOn()

        sim:PlaySound("ui_npc_location_enter")
    else
        local px, py, pz, _ = portal:GetPositionRotation()
        local job

        -----------------------
        -- route to the portal
        if portal:GetBrokerTypeDescription().Slot == true and (portal:GetSlotCount( Slot.Routing ) > 0) then
            job = Classes.Job_RouteToSlot:Spawn( sim, portal, 0)
        else
            -- Fallback if we don't have a routing slot
            job = Classes.Job_RouteToPosition3D:Spawn( sim, px, py, pz, 1.0, nil)
        end

        job:SetAllowRouteFailure( false )
        job:Execute(self)

        result, reason = job:BlockOn()

        if result ~= BlockingResult.Succeeded then
            return result, reason
        end

        ------------------------------
        -- teleport through the portal
        sim:PlaySound("ui_npc_location_exit")

        job = Classes.Job_TeleportThroughPortal:Spawn( sim, portal )
        job:Execute(self)
        result, reason = job:BlockOn()

        if result ~= BlockingResult.Succeeded then
            return result, reason
        end

        sim:PlaySound("ui_npc_location_enter")

        --------------
        -- spread out
        local spacingAngleDelta = math.random(-90, 90)
        sim:ClearLocoAnimOverrides() -- in some cases the walk animation has been overridden with the run, this makes the wander look bad, so I am clearing that override
        local _,_,_,rot = sim:GetPositionRotation()
        local wx, wz = sim:GetWanderXZ(spacingAngleDelta, spacingAngleDelta)
        job = Classes.Job_Wander:Spawn( sim, 2.0, wx, wz)
        job:Execute(self)
        result, reason = job:BlockOn()

        --reset rotation
        local  x,y,z,_ = sim:GetPositionRotation()
        local randAngle = math.random(1,40) - 20;
        sim:SetPositionRotation(x, y, z, rot + randAngle)
    end

    return result, reason
end
--}}}

--{{{ TreasureChest_Interaction_Open.lua --------------------------------------------------------------
-- prevent autonomous sims from opening treasure chests
function Classes.TreasureChest_Interaction_Open:Test( sim, obj, autonomous )
    if ( obj:GetGameObjectInSlot( Slot.Containment, 0 ) ~= nil or obj.bOpened) then
        return false
    end

    if ( obj:GetAttribute("IsHidden") ) then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() and autonomous then
        return false
    end

    return true
end
--}}}

--{{{ Time Interactions
-- prevent autonomous sims from advancing time
--{{{ Bed_Interaction_SleepTillDay.lua --------------------------------------------------------------
function Classes.Bed_Interaction_SleepTillDay:Test( sim, obj, autonomous )
    if GameManager:IsDuringTaskTime() or Common:IsDayTime() then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() and autonomous then
        return false
    end

    return obj:GetGameObjectInSlot( Slot.Containment, 0 ) == nil
end
--}}}
--{{{ Bed_Interaction_SleepTillNight.lua --------------------------------------------------------------
function Classes.Bed_Interaction_SleepTillNight:Test( sim, obj, autonomous )
    if GameManager:IsDuringTaskTime() or Common:IsNightTime() then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() and autonomous then
        return false
    end

    return obj:GetGameObjectInSlot( Slot.Containment, 0 ) == nil
end
--}}}
--{{{ Couch_Interaction_SleepTillDay.lua --------------------------------------------------------------
function Classes.Couch_Interaction_SleepTillDay:Test( sim, obj, autonomous )
    if GameManager:IsDuringTaskTime() or Common:IsDayTime() then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() and autonomous then
        return false
    end

    return obj.bSlot0Available and obj.bSlot1Available
end
--}}}
--{{{ Couch_Interaction_SleepTillNight.lua --------------------------------------------------------------
function Classes.Couch_Interaction_SleepTillNight:Test( sim, obj, autonomous )
    if GameManager:IsDuringTaskTime() or Common:IsNightTime() then
        return false
    end

    if sim ~= Universe:GetPlayerGameObject() and autonomous then
        return false
    end

    return obj.bSlot0Available and obj.bSlot1Available
end
--}}}
--}}}

--{{{ Tree_Interaction_Water.lua --------------------------------------------------------------
-- allow autonomous sims to water trees
function Classes.Tree_Interaction_Water:Test( sim, obj, autonomous )
    local player = Universe:GetPlayerGameObject()
    if ( sim ~= player and not autonomous ) then --- custom code
        -- only allow autonomous sims to execute basic watering interaction
        return false
    end

    if ( sim == player and Task:IsTaskComplete("NPC_Linzey_GatherWood")) then
        -- prevent player from using this interaction after tutorial
        return false
    end

    if ( obj.bGrowthTransitionPending ) then
        return false
    end

    if ( obj:GetAttribute("SavedStage") < obj.GrowthStages["TREE_GROWTH_STAGE_SPROUT"] ) then
        return false
    end

    if ( obj:GetAttribute("SavedStage") > obj.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
        return false
    end

    --- custom code start
    if ( autonomous ) then
        local simInterest = tonumber(sim:GetAttribute("InterestCharacter")[1])
        if ( simInterest == Constants.Interests.Nature or
                simInterest == Constants.Interests.Cute) then
            -- allow autonomous with nature or cute interest to water trees
            -- skip the unlock check (npcs can water trees without player having the watering can)
            return true
        end
        return false
    end
    --- custom code end

    if ( not Unlocks:IsUnlocked("tools_harvesting", "wateringcan_low") ) then
        return false
    end

    return true
end
--}}}


--{{{ Tree_Interaction_Harvest.lua --------------------------------------------------------------
function Classes.Tree_Interaction_Harvest:Test( sim, obj, autonomous )
    if ( sim == Universe:GetPlayerGameObject() or not autonomous ) then --- custom code
        -- only allow autonomous sims to execute basic harvesting interaction
        return false
    end

    if ( obj.bGrowthTransitionPending ) then
        return false
    end

    if ( obj:GetAttribute("SavedStage") < obj.GrowthStages["TREE_GROWTH_STAGE_MATURE"] ) then
        return false
    end

    if ( obj:GetAttribute("SavedStage") > obj.GrowthStages["TREE_GROWTH_STAGE_DYING"] ) then
        return false
    end

    --- custom code start
    if ( autonomous ) then
        local simInterest = tonumber(sim:GetAttribute("InterestCharacter")[1])
        if ( simInterest ~= Constants.Interests.Cute and
                simInterest ~= Constants.Interests.Elegant) then
            -- allow any autonomous sim to harvest trees (except cute or elegant interest)
            -- skip the unlock check
            return true
        end
        return false
    end
    --- custom code end

    if ( not Unlocks:IsUnlocked("tools_harvesting", "harvest_low") ) then
        return false
    end

    if ( obj:FruitCount() <= 0 ) then
        return false
    end

    return true
end
--}}}