--====================================================--
--  Unlocked_I_Fishing_Skip         --
--                                                    --
--  This interaction starts/is the fishing mini game. --
--====================================================--
local Unlocked_I_Fishing_Skip = Classes.Job_InteractionBase:Inherit("Unlocked_I_Fishing_Skip")

local DEBUG_USE_CAMERA          = true      -- Enables/Disables fixed camera
local DEBUG_HIDE_CURSOR         = false     -- Enables/Disables hiding of the UI cursor

Unlocked_I_Fishing_Skip._instanceVars =
{
    bRestoreWorldCamera = false,

    fishingCursor       = NIL,

    cameraPosition      = NIL,
    targetPosition      = NIL,
    waterHeight         = NIL,

    spawnLocations      = NIL,

    activeHotspots   = NIL,

    maxActiveHotspots = NIL,

    ---------------------------
    simRotY         = NIL,

    bGrabbed        = false,
    grabbedHotspot  = NIL,
    bGrabEffect     = false,

    bCaught         = false,
    caughtHotspot   = NIL,

    bNibbled        = false,
    bSlacked        = false,
    bFailedCatch    = false,

    ---------------------------

    bShouldCast         = false,
    bFirstCast          = true,
    bCasting            = false,
    bAnimCaughtStarted  = false,
    bCanInterruptAnim   = false,

    animDirection       = NIL,
    animKey             = NIL,
    latestDirection     = NIL,

    ---------------------------

    cancelListenerJob   = NIL,

}

function Unlocked_I_Fishing_Skip:Test( sim, obj, autonomous )
    return sim == Universe:GetPlayerGameObject()
end


function Unlocked_I_Fishing_Skip:Destructor()
    self:StopFishing( self.sim, self.obj )
end

function Unlocked_I_Fishing_Skip:InputListenerCallback()
    -----------------------------------
    -- Cancel when trigger is pulled
    --
    if not self.bCanceled then
        self:Cancel()
    end
end


--================--
-- Animation Data
--================--
local AnimDir =
{
    kWest   = 1,
    kNorth  = 2,
    kEast   = 3,
}

local CastRotations =
{
    [AnimDir.kWest]     = 45,
    [AnimDir.kNorth]    = 0,
    [AnimDir.kEast]     = -45,
}

local CastRotationsSpecial =
{
    [AnimDir.kWest]     = 30,
    [AnimDir.kNorth]    = 0,
    [AnimDir.kEast]     = -45,
}


local AnimTables =
{
    [AnimDir.kNorth] =
    {
        kStart =        "a2o-fishing-start",

        kBreatheCast =  "a2o-fishing-breathe-cast-N",
        kCast =         "a2o-fishing-cast-N",

        kBreathe =      "a2o-fishing-breathe-N",
        kYanked =       "a2o-fishing-yanked-N",
        kSlack =        "a2o-fishing-slack-N",
        kCatchStart =   "a2o-fishing-catch-start-N",
        kCatchLoop =    "a2o-fishing-catch-loop-N",

        kCatchSucceed = "a2o-fishing-catch-succeed-N",
        kCatchStop =    "a2o-fishing-catch-stop-N",
        kCatchFail =    "a2o-fishing-catch-fail-N",

        kStop =         "a2o-fishing-stop-N",
        kTurnE =        "a2o-fishing-turn-E",
        kTurnW =        "a2o-fishing-turn-W",
    },

    [AnimDir.kWest] =
    {
        kBreatheCast =  "a2o-fishing-breathe-cast-W",
        kCast =         "a2o-fishing-cast-W",

        kBreathe =      "a2o-fishing-breathe-W",

        kYanked =       "a2o-fishing-yanked-W",
        kSlack =        "a2o-fishing-slack-W",
        kCatchStart =   "a2o-fishing-catch-start-W",
        kCatchLoop =    "a2o-fishing-catch-loop-W",

        kCatchSucceed = "a2o-fishing-catch-succeed-W",
        kCatchStop =    "a2o-fishing-catch-stop-W",
        kCatchFail =    "a2o-fishing-catch-fail-W",

        kStop =         "a2o-fishing-stop-W",
        kTurnN =        "a2o-fishing-turn-W2N",
        kTurnE =        "a2o-fishing-turn-W2E",
    },

    [AnimDir.kEast] =
    {
        kBreatheCast =  "a2o-fishing-breathe-cast-E",
        kCast =         "a2o-fishing-cast-E",

        kBreathe =      "a2o-fishing-breathe-E",
        kYanked =       "a2o-fishing-yanked-E",
        kSlack =        "a2o-fishing-slack-E",
        kCatchStart =   "a2o-fishing-catch-start-E",
        kCatchLoop =    "a2o-fishing-catch-loop-E",

        kCatchSucceed = "a2o-fishing-catch-succeed-E",
        kCatchStop =    "a2o-fishing-catch-stop-E",
        kCatchFail =    "a2o-fishing-catch-fail-E",

        kStop =         "a2o-fishing-stop-E",
        kTurnN =        "a2o-fishing-turn-E2N",
        kTurnW =        "a2o-fishing-turn-E2W",
    },
}

local AnimInterruptable =
{
    kBreathe =      true,
    kYanked =       true,
    kSlack =        true,
    kCatchStop =    true,
}

--================================================================--
-- Unlocked_I_Fishing_Skip:Action( sim, bucket) --
--================================================================--
function Unlocked_I_Fishing_Skip:Action( sim, bucket )

    local castRotations = CastRotations
    if bucket.collectionKey == Luattrib:ConvertStringToUserdataKey("_lvl_spookane_go_fishingbucket2_") then
        castRotations = CastRotationsSpecial
    end

    -- This condition is to avoid a bug when player starts fishing without fishing Rod (https://jaas.ea.com/browse/MYS-480)
    -- Landing animation event was removing the fishing rod from the player hand bone
    if sim:IsJumping() or  sim:IsFalling() then
        if not self.bCanceled then
            self:Cancel()
        end
        return
    end

    ------------------------------------
    -- Setup members with tuning info
    ------------------------------------
    self:SetupTuning( sim, bucket )

    -----------
    -- Route
    -----------
    local result, reason = self:RouteToSlotBlocking( sim, bucket, 0 )

    if result ~= BlockingResult.Succeeded then
        return result, reason
    end

    local _
    _,_,_,self.simRotY = sim:GetPositionRotation()

    -------------------------------------------
    -- Start - Camera, UI Cursor...
    -------------------------------------------
    self:StartFishing( sim, bucket )

    ------------------------------------
    -- Start - Hotspots
    ------------------------------------
    self:FillHotspots()

    -------------
    -- Animate
    -------------
    self.bShouldCast = true

    self.animDirection = AnimDir["kNorth"]
    self.latestDirection = self.animDirection

    ----------------------------------
    -- Start Anim on Player & Bucket
    --
    result, reason = self:PlaySyncedAnimationBlocking( sim, bucket, "a2o-fishing-start", "o2a-fishing-start" )

    while result == BlockingResult.Succeeded do

        local postAnimDirection = self.animDirection

        self.animKey = "kBreathe"

        ----------
        -- Cast
        ----------
        if self.bShouldCast then
            self.bShouldCast = false
            self.bCasting = true

            self.animKey = "kCast"

            ----------
            -- Fish
            ----------
        else

            ------------
            -- Grabbed
            --
            if self.bGrabbed then

                -------------------
                -- Start Catching
                --
                if (not self.bAnimCaughtStarted) then

                    self.animKey = "kCatchStart"

                    self.bAnimCaughtStarted = true

                    -------------------
                    -- Loop Catching
                    --
                else
                    self.animKey = "kCatchLoop"
                end

                ----------------
                -- Not Grabbed
                --
            else

                ------------------
                -- Stop Catching
                --
                if self.bAnimCaughtStarted then

                    ----------------------------
                    -- The one that got caught
                    --
                    if self.bCaught then

                        self.animKey = "kCatchSucceed"

                        -------------------
                        -- Need to recast
                        --
                        self.bShouldCast = true

                    --------------------------
                    -- The one that got away
                    --
                    else
                        self.animKey = "kCatchStop"
                    end

                    self.bAnimCaughtStarted = false

                    ------------------
                    -- Clear caught
                    --
                    self.bCaught = false

                    ---------------------------------
                    -- Breathe or Turn or something
                    --
                else

                    -----------------------
                    -- Nibble requested
                    --
                    if self.bNibbled then

                        self.bNibbled = false

                        self.animKey = "kYanked"

                        -----------------------
                        -- Slack requested
                        --
                    elseif self.bSlacked then

                        self.bSlacked = false

                        self.animKey = "kSlack"

                        -----------------------
                        -- Fail Catch requested
                        --
                    elseif self.bFailedCatch then

                        self.bFailedCatch = false

                        self.animKey = "kCatchSucceed"

                        -------------------
                        -- Need to recast
                        --
                        self.bShouldCast = true


                    elseif self.latestDirection ~= self.animDirection then

                        postAnimDirection = self.latestDirection

                        self.animKey = "kTurnN"

                        if postAnimDirection == AnimDir["kEast"] then
                            self.animKey = "kTurnE"
                        elseif postAnimDirection == AnimDir["kWest"] then
                            self.animKey = "kTurnW"
                        end
                    end

                end
            end

        end

        ------------
        -- Animate
        --
        result, reason = self:PlayAnimationBlocking( sim, AnimTables[self.animDirection][self.animKey] )

        self.animDirection = postAnimDirection

        ---------------
        -- First Cast
        --
        if self.bFirstCast == true and result == BlockingResult.Succeeded then
            self.bFirstCast = false

            ------------------------------------
            -- Start - Cursor
            ------------------------------------
            self:StartCursor( sim, bucket )

        elseif self.bCasting then

            ---------------
            -- Show Bobber
            --
            if self.fishingCursor ~= nil then
                self.fishingCursor:Recast(castRotations[self.animDirection])
            end

        end

        self.bCasting = false
    end

    ----------------------------------
    -- Stop Anim on Player & Bucket
    --
    result, reason = self:PlaySyncedAnimationBlocking( sim, bucket, AnimTables[self.animDirection]["kStop"], "o2a-fishing-stop" )

    ------------------------------------------
    -- Stop - Camera, cursors, timers etc...
    ------------------------------------------
    self:StopFishing( sim, bucket )

    return result, reason
end

--=======================================================================--
-- Unlocked_I_Fishing_Skip:StartFishing( sim, bucket ) --
--=======================================================================--
function Unlocked_I_Fishing_Skip:StartFishing( sim, bucket )

    -- Change the camera
    if DEBUG_USE_CAMERA then
        CameraController:SetFixedCamera( self.cameraPosition, self.targetPosition, bucket:GetAttribute("Tuning_CameraTransitionSeconds") )
        self.bRestoreWorldCamera = true
    end

    if DEBUG_HIDE_CURSOR then
        UIEngineUtils:HideCursor( true )
        UIEngineUtils:LockCursorStates( true )
    end

    ----------------------------------------------------
    -- Disable stick control, register for cancelation
    --
    sim:ToggleCodeInteractionCancelation( false )

    self.cancelListenerJob = Classes.Job_InputListener:Spawn( "fishing_cancel", self, self.InputListenerCallback )
    self.cancelListenerJob:Execute( self )

end

--======================================================================--
-- Unlocked_I_Fishing_Skip:StartCursor( sim, bucket ) --
--======================================================================--
function Unlocked_I_Fishing_Skip:StartCursor(sim, bucket)
    -- Spawn the bobber
    local x, y, z, rotY = sim:GetPositionRotation()

    x, z = Common:GetRelativePosition( 0, 4, x, z, rotY )

    local bobberRot = sim:GetAngle( {x=x, z=z} )

    local cursor = Classes.Job_SpawnObject:Spawn( "fishingcursor", "default", sim.containingWorld, x, self.waterHeight, z, bobberRot )

    local initFunc =   function ( cursor )
        cursor.waterHeight = self.waterHeight
        cursor.fishingAction = self
        self.fishingCursor = cursor
    end

    cursor:SetInitFunction(initFunc)
    cursor:Execute(self)

end

--======================================================================--
-- Unlocked_I_Fishing_Skip:StopFishing( sim, bucket ) --
--======================================================================--
function Unlocked_I_Fishing_Skip:StopFishing( sim, bucket )

    if self.bRestoreWorldCamera == true then
        self.bRestoreWorldCamera = false
        CameraController:RestoreWorldCamera()
    end

    if self.fishingCursor ~= nil then
        self.fishingCursor:Destroy()
        self.fishingCursor = nil
    end

    if self.activeHotspots ~= nil then
        for i, hotspot in ipairs(self.activeHotspots) do
            self:CleanupHotspot( hotspot )
        end
    end

    if DEBUG_HIDE_CURSOR then
        UIEngineUtils:LockCursorStates( false )
        UIEngineUtils:HideCursor( false )
        UIEngineUtils:UseDefaultCursor()
    end

    --------------------------------------------------
    -- Return stick control, kill cancel listener
    --
    sim:ToggleCodeInteractionCancelation( true, self )

    if self.cancelListenerJob then
        self.cancelListenerJob:Destroy()
        self.cancelListenerJob = nil
    end
end

--==========================================================--
-- Unlocked_I_Fishing_Skip:FillHotspots() --
--==========================================================--
function Unlocked_I_Fishing_Skip:FillHotspots()
    self.activeHotspots = self.activeHotspots or {}

    -- Safety check to prevent overspawning
    if #self.activeHotspots >= self.maxActiveHotspots then
        return
    end

    local freeIndicies = {}

    for index,info in ipairs( self.spawnLocations ) do

        if not info.active then

            freeIndicies[#freeIndicies+1] = index
        end
    end

    if #freeIndicies > 0 then
        for i=0,(self.maxActiveHotspots - #self.activeHotspots) do
            if #freeIndicies > 0 then

                local chosenIndex = table.remove(freeIndicies, math.random(#freeIndicies))

                -- New active hotspot
                local newHotspot =
                {
                    index       = chosenIndex,
                    isValid     = true,
                }

                self.activeHotspots[#self.activeHotspots+1] = newHotspot


                local location = self.spawnLocations[chosenIndex]

                location.active = true

                local distance = math.random() * (location.radiusMax - location.radiusMin) + location.radiusMin

                local x, z = Common:GetRelativePosition( 0, distance, location.position["x"], location.position["z"], math.random(0,360) )

                -------------------------
                -- Chose the spawn item
                local spawnItem = Common:SelectRandomWeightedWithTest( location )

                newHotspot.position = { x = x, y = self.waterHeight, z = z }
                newHotspot.spawnItem = spawnItem

                newHotspot.nibbleCount = spawnItem.nibbles

                self:HotspotFX( newHotspot, "Obj-fish-swimming", FXTransition.Soft, true )


                -- spawn hotspot visualizations
                local scale = Luattrib:ReadAttribute("fishingcursor", "default", "Tuning_HotspotGrabDistance")

                local initFunc =    function( hotspotObj )
                    newHotspot.debugObj = hotspotObj

                    hotspotObj:SetAlpha( 1 )
                    hotspotObj:SetScale( scale )
                end

                local spawnJob = Classes.Job_SpawnObject:Spawn( "fishinghotspot",
                        "default",
                        Universe:GetWorld(),
                        newHotspot.position.x,
                        newHotspot.position.y-.2,
                        newHotspot.position.z,
                        0 )
                spawnJob:SetInitFunction( initFunc )
                spawnJob:Execute(self)
            end
        end
    end
end


--===========================================================================--
-- Unlocked_I_Fishing_Skip:TimerExpiredCallback( timerId ) --
--===========================================================================--
function Unlocked_I_Fishing_Skip:TimerExpiredCallback( timerId )

    for index, hotspot in ipairs(self.activeHotspots) do

        --------------------------------------
        -- Nibble
        --
        if timerId == hotspot.nibbleTimer then

            hotspot.nibbleTimer = nil

            hotspot.nibbleCount = hotspot.nibbleCount - 1

            if hotspot.nibbleCount <= 0 then
                -- set bite timer?
            end

            --------------------------------------
            -- Bite
            --
        elseif timerId == hotspot.biteTimer then

            hotspot.biteTimer = nil

            --------------------------------------
            -- My leiben!
            --
        elseif timerId == hotspot.lifeTimer then
            if not hotspot.bCatching then
                self:HotspotDestroyed( hotspot )
            end
        end
    end
end


--===============================================================================--
-- Unlocked_I_Fishing_Skip:HotspotGrabbed( bGrabbed, hotspot ) --
--===============================================================================--
function Unlocked_I_Fishing_Skip:HotspotGrabbed( bGrabbed, hotspot )
    if bGrabbed then

        if self.bGrabbed == false or self.grabbedHotspot == nil then
            self.bGrabbed = true
            self.grabbedHotspot = hotspot

            -- Break out of idle/turn/whatever
            self:SignalBlockingOp( BlockingResult.Succeeded, 0 )

            -------------------------
            -- Change FX
            --
            self:HotspotFX( hotspot, "Obj-fish-bobber-underwater" )

            if self.fishingCursor then
                local x, y, z = self.fishingCursor:GetPositionRotation()
                self:HotspotFXMove( hotspot, x, y, z )
            end

            hotspot.lifeTimer = self:CreateTimer( Clock.Game, 0, 0, 0, hotspot.spawnItem.biteSeconds )
        else
            EA:Fail("Registering a hotspot before previous hotspot unregistered")
        end

    else
        if self.bGrabbed and self.grabbedHotspot == hotspot then
            self.bGrabbed = false
            self.grabbedHotspot = nil

            if hotspot.bCatching ~= true then

                -------------------------
                -- Change FX
                --
                --self:HotspotFX( hotspot, "Obj-fish-swimming" )

            end

            -- Break out of looping catch
            self:SignalBlockingOp( BlockingResult.Succeeded, 0 )

        else
            --EA:Fail("Unregistering for grab by unregistered hotspot")
        end
    end
end


--================================================================================================--
-- Unlocked_I_Fishing_Skip:HotspotFX( hotspot, effectName, transition, bSpawn ) --
--================================================================================================--
function Unlocked_I_Fishing_Skip:HotspotFX( hotspot, effectName, transition, bSpawn )
    -------------------------
    -- Soft-stop old effect
    --
    if hotspot.effectObject then
        if hotspot.effectHandle ~= nil then
            hotspot.effectObject:DestroyFX( hotspot.effectHandle, FXTransition.Soft )
            hotspot.effectHandle = nil
        end

        -------------------------
        -- Hard-start new effect
        --
        hotspot.effectHandle = hotspot.effectObject:CreateFX(   effectName,
                FXPriority.SuperHigh,
                FXStart.Manual,
                FXLifetime.Continuous,
                FXAttach.Rigid,
                -1,
                0,
                0,
                0 )
        hotspot.effectObject:SetScale(2.0)
        hotspot.effectObject:StartFX( hotspot.effectHandle, (transition or FXTransition.Hard) )

    elseif bSpawn then
        -------------------------
        -- Spawn initial effect
        --
        local initFunc =    function ( effectObject )
            hotspot.effectObject = effectObject

            self:HotspotFX( hotspot, effectName, transition )
        end

        local spawnJob = Classes.Job_SpawnObject:Spawn( "effect", "fx",
                Universe:GetWorld(),
                hotspot.position.x,
                hotspot.position.y,
                hotspot.position.z,
                0 )
        spawnJob:SetInitFunction( initFunc )
        spawnJob:Execute(self)
    end
end

--===================================================================--
-- Unlocked_I_Fishing_Skip:BobberDirectionUpdate() --
--===================================================================--
function Unlocked_I_Fishing_Skip:BobberDirectionUpdate()

    local angle = self.sim:GetRelativeAngle( self.fishingCursor )

    -- angles are wrong below...
    angle = angle * -1

    self.latestDirection = self.animDirection

    if self.animDirection == AnimDir["kWest"] then

        if angle > -30 and angle < 30 then
            self.latestDirection = AnimDir["kNorth"]
        elseif angle > 30 then
            self.latestDirection = AnimDir["kEast"]
        end

    elseif self.animDirection == AnimDir["kEast"] then

        if angle > -30 and angle < 30 then
            self.latestDirection = AnimDir["kNorth"]
        elseif angle < -30 then
            self.latestDirection = AnimDir["kWest"]
        end

    else -- kNorth

        if angle < -30 then
            self.latestDirection = AnimDir["kWest"]
        elseif angle > 30 then
            self.latestDirection = AnimDir["kEast"]
        end

    end

    local bShouldTurn = self.latestDirection ~= self.animDirection

    if bShouldTurn and AnimInterruptable[self.animKey] then
        -------------------------------------------
        -- Immediate response to animation change
        --
        self:SignalBlockingOp( BlockingResult.Succeeded, 0 )
    end

end

--=============================================================================--
-- Unlocked_I_Fishing_Skip:HotspotFXMove( hotspot, x, y, z ) --
--=============================================================================--
function Unlocked_I_Fishing_Skip:HotspotFXMove( hotspot, x, y, z )
    if hotspot.effectObject then
        hotspot.effectObject:SetPositionRotation( x, y, z, 0 )
    end
end

--====================================================================--
-- Unlocked_I_Fishing_Skip:HotspotCaught( hotspot ) --
--====================================================================--
function Unlocked_I_Fishing_Skip:HotspotCaught( hotspot )

    self.bCaught = true
    self.caughtHotspot = hotspot

    local spawnLocationIndex, activeIndex

    for i, activeHotspot in ipairs(self.activeHotspots) do

        if activeHotspot == hotspot then
            spawnLocationIndex = activeHotspot.index
            activeIndex = i
            break
        end
    end

    if spawnLocationIndex then

        if activeIndex then

            self.spawnLocations[spawnLocationIndex].bCaught = true
            self.spawnLocations[spawnLocationIndex].active = false

            self:CleanupHotspot( table.remove( self.activeHotspots, activeIndex ) )

        end

    end

    self:FillHotspots()

end

--=======================================================================--
-- Unlocked_I_Fishing_Skip:HotspotDestroyed( hotspot ) --
--=======================================================================--
function Unlocked_I_Fishing_Skip:HotspotDestroyed( hotspot )

    local spawnLocationIndex, activeIndex

    for i, activeHotspot in ipairs(self.activeHotspots) do

        if activeHotspot == hotspot then
            spawnLocationIndex = activeHotspot.index
            activeIndex = i
            break
        end
    end

    if spawnLocationIndex then

        self.spawnLocations[spawnLocationIndex].bCaught = false
        self.spawnLocations[spawnLocationIndex].active = false

        self:CleanupHotspot( table.remove( self.activeHotspots, activeIndex ) )

    end

    self:FillHotspots()

end


--====================================================================--
-- Unlocked_I_Fishing_Skip:CatchSucceed( hotspot ) --
--====================================================================--
function Unlocked_I_Fishing_Skip:CatchSucceed( hotspot )
    hotspot.bCatching = true

    self:CleanupHotspot( hotspot )

    local x, y, z = self.fishingCursor:GetPositionRotation()

    self.sim:CreateFX(  "Obj-fishing-catch-splash",
            FXPriority.High,
            FXStart.Now,
            FXLifetime.OneShot,
            FXAttach.None,
            -1,
            x, y, z )


    --local x, y, z = hotspot.position.x, hotspot.position.y, hotspot.position.z

    local rotY = self.sim:GetAngle( hotspot.position )

    rotY = rotY + 180

    local override = nil
    local resourceType = Luattrib:ReadAttribute( hotspot.spawnItem.resourceRef[1], hotspot.spawnItem.resourceRef[2], "ResourceType" )
    if resourceType == Constants.ResourceTypes["QuestItem"] then
        override = {}
        override.Tuning_MAGNETIZE_DELAY_SIM_MINUTES = 0
        override.Tuning_MAGNETIZE_DELAY_SIM_SECONDS = 1
        override.Tuning_MAGNETIZE_DELAY_VARIANCE    = 0
        if not Classes.ResourceBase:ResourceIsValidToSpawn( hotspot.spawnItem.resourceRef[1], hotspot.spawnItem.resourceRef[2] ) then
            -- if this item is no longer valid to be spawned because two hot spots chose to spawn a limited resource
            -- then we need to select a new resource to spawn
            local spawnItem = Common:SelectRandomWeightedWithTest( self.spawnLocations[hotspot.index] )
            hotspot.spawnItem = spawnItem
        end
    end

    local spawnJob = Classes.Job_SpawnObject:Spawn( hotspot.spawnItem.resourceRef[1],
            hotspot.spawnItem.resourceRef[2],
            self.sim.containingWorld,
            x, y+2.0, z, rotY, override )

    spawnJob:Execute(self)

    ----------------------------------------------
    -- Notify caught
    -- (removes from active list, forces recast)
    --
    self:HotspotCaught( hotspot )

    ---------------------------
    -- Rumble on Catch
    --
    local kCatchRumbleHiWord = 3855  -- 0x0f0f 0b0000111100001111
    local kCatchRumbleLoWord = 3855  -- 0x0f0f 0b0000111100001111
    RumbleRemoteOnce( kCatchRumbleLoWord, kCatchRumbleHiWord )

    -- This may be the correct location for this (versus ResourceBase.lua) -Scott Huber
    UI:Spawn( "UISpinningFish", hotspot.spawnItem.resourceRef[1], hotspot.spawnItem.resourceRef[2] )
end

--================================================================--
-- Unlocked_I_Fishing_Skip:CatchFail( hotspot ) --
--================================================================--
function Unlocked_I_Fishing_Skip:CatchFail( hotspot )
    if hotspot then
        self:CleanupHotspot( hotspot )

        -- Call CatchSucceed for the item spawn and UI
        self:CatchSucceed(hotspot)

        -- We don't need to call HotspotDestroyed here since CatchSucceed already handles that
    end

    -- Set the fail state to trigger the recast animation
    self.bFailedCatch = true
    self:SignalBlockingOp( BlockingResult.Succeeded )

end

--==============================================================--
-- Unlocked_I_Fishing_Skip:Touched( hotspot ) --
--==============================================================--
function Unlocked_I_Fishing_Skip:Touched( hotspot )

    ---------------------------
    -- Rumble on First Touch
    --
    local kStdRumbleHiWord = 43008  -- 0xa800 0b1010100000000000
    local kStdRumbleLoWord = 0      -- 0x0000 0b0000000000000000
    RumbleRemoteOnce( kStdRumbleLoWord, kStdRumbleHiWord )

    ----------------------------------
    -- Create Fish FX on first touch
    --
    if hotspot.effectObject == nil then
        --self:HotspotFX( hotspot, "Obj-fish-swimming", FXTransition.Soft, true )
    end

    if hotspot.nibbleCount > 0 then
        hotspot.nibbleTimer = self:CreateTimer( Clock.Game, 0, 0, 0, hotspot.spawnItem.secondsBetweenNibbles )
    else
        hotspot.biteTimer = self:CreateTimer( Clock.Game, 0, 0, 0, hotspot.spawnItem.secondsBeforeBite )
    end

end

--==============================================================--
-- Unlocked_I_Fishing_Skip:Untouched( hotspot ) --
--==============================================================--
function Unlocked_I_Fishing_Skip:Untouched( hotspot )

    self:CleanupHotspot( hotspot )
    self:HotspotDestroyed( hotspot )

end



--=============================================================--
-- Unlocked_I_Fishing_Skip:Nibble( hotspot ) --
--=============================================================--
function Unlocked_I_Fishing_Skip:Nibble( hotspot )

    self.bNibbled = true
    self:SignalBlockingOp( BlockingResult.Succeeded )

    ---------------------------
    -- Rumble on Nibble
    --
    local kNibbleRumbleHiWord = 43008   -- 0xa0a0 0b1010000010100000
    local kNibbleRumbleLoWord = 0       -- 0xa0a0 0b1010000010100000
    RumbleRemoteOnce( kNibbleRumbleLoWord, kNibbleRumbleHiWord )


    if hotspot.nibbleCount > 0 then
        hotspot.nibbleTimer = self:CreateTimer( Clock.Game, 0, 0, 0, hotspot.spawnItem.secondsBetweenNibbles )

    else
        hotspot.biteTimer = self:CreateTimer( Clock.Game, 0, 0, 0, hotspot.spawnItem.secondsBeforeBite )
    end

end

--=============================================================--
-- Unlocked_I_Fishing_Skip:Slack( hotspot ) --
--=============================================================--
function Unlocked_I_Fishing_Skip:Slack( hotspot )

    self.bSlacked = true

    self:SignalBlockingOp( BlockingResult.Succeeded )

end

--=====================================================================--
-- Unlocked_I_Fishing_Skip:CleanupHotspot( hotspot ) --
--=====================================================================--
function Unlocked_I_Fishing_Skip:CleanupHotspot( hotspot )

    hotspot.isValid = false

    if hotspot.debugObj ~= nil then
        hotspot.debugObj:Destroy()
        hotspot.debugObj = nil
    end
    if hotspot.nibbleTimer ~= nil then
        hotspot.nibbleTimer:Kill()
        hotspot.nibbleTimer = nil
    end
    if hotspot.biteTimer ~= nil then
        hotspot.biteTimer:Kill()
        hotspot.biteTimer = nil
    end
    if hotspot.lifeTimer ~= nil then
        hotspot.lifeTimer:Kill()
        hotspot.lifeTimer = nil
    end
    if hotspot.effectHandle ~= nil then
        hotspot.effectObject:DestroyFX( hotspot.effectHandle, FXTransition.Soft )
        hotspot.effectHandle = nil
    end
    if hotspot.effectObject ~= nil then
        -- Allow FX to fade out
        hotspot.effectObject:SetKillTimer( 3 )
        hotspot.effectObject = nil
    end
end


--================================================================================--
-- Unlocked_I_Fishing_Skip:GetClosestGrabbableHotspotToCursor() --
--================================================================================--
function Unlocked_I_Fishing_Skip:GetClosestGrabbableHotspotToCursor()

    local closestHotspot, closestDistance = nil, 1000000000

    if self.fishingCursor ~= nil and self.fishingCursor.isValid and self.activeHotspots ~= nil then

        for i, activeHotspot in ipairs(self.activeHotspots) do
            if (not activeHotspot.bCatching) and activeHotspot.position ~= nil then

                local distance = self.fishingCursor:GetXZDist_Coords( activeHotspot.position.x, activeHotspot.position.z )

                if distance < closestDistance then
                    closestHotspot = activeHotspot
                    closestDistance = distance
                end
            end
        end

    end

    return closestHotspot, closestDistance
end

--=====================================================================--
-- Unlocked_I_Fishing_Skip:SetupTuning( sim, bucket) --
--=====================================================================--
function Unlocked_I_Fishing_Skip:SetupTuning( sim, bucket )

    -- INITIALIZE FROM ATTRIBULATOR

    -- CameraPosition
    local cameraLocatorNodeRef = bucket:GetAttribute( "Tuning_CameraPositionNode" )
    EA:Assert( cameraLocatorNodeRef ~= nil and #cameraLocatorNodeRef >= 2 )
    self.cameraPosition = Luattrib:ReadAttribute( cameraLocatorNodeRef[1], cameraLocatorNodeRef[2], "Position" )

    -- TargetPosition
    local targetLocatorNodeRef = bucket:GetAttribute( "Tuning_CameraTargetNode" )
    EA:Assert( targetLocatorNodeRef ~= nil and #targetLocatorNodeRef >= 2 )
    self.targetPosition = Luattrib:ReadAttribute( targetLocatorNodeRef[1], targetLocatorNodeRef[2], "Position" )

    -- WaterHeight
    local waterHeightLocatorNodeRef = bucket:GetAttribute( "Tuning_WaterHeightNode" )
    EA:Assert( waterHeightLocatorNodeRef ~= nil and #waterHeightLocatorNodeRef >= 2 )

    local waterHeightPos = Luattrib:ReadAttribute( waterHeightLocatorNodeRef[1], waterHeightLocatorNodeRef[2], "Position" )
    EA:Assert( waterHeightPos ~= nil )
    self.waterHeight = waterHeightPos["y"] or EA:Fail("Position isn't a vector or something")


    -- maxActiveHotspots
    self.maxActiveHotspots = bucket:GetAttribute("Tuning_MaximumActiveSpawnLocations")

    -- Initialize spawn locations
    self.spawnLocations = {}

    local spawnLocationList = bucket:GetAttribute( "Tuning_FishingSpawnLocationList" )
    EA:Assert( spawnLocationList ~= nil and #spawnLocationList > 0 )

    for locIndex, spawnLocationRef in ipairs(spawnLocationList) do

        EA:Assert( #spawnLocationRef >= 2 )

        local position = Luattrib:ReadAttribute( spawnLocationRef[1], spawnLocationRef[2], "Position" )
        EA:Assert( position ~= nil )

        local radiusMin = Luattrib:ReadAttribute( spawnLocationRef[1], spawnLocationRef[2], "Tuning_SpawnRadiusMin" )
        EA:Assert( radiusMin ~= nil )

        local radiusMax = Luattrib:ReadAttribute( spawnLocationRef[1], spawnLocationRef[2], "Tuning_SpawnRadiusMax" )
        EA:Assert( radiusMax ~= nil )

        local spawnItemList = Luattrib:ReadAttribute( spawnLocationRef[1], spawnLocationRef[2], "Tuning_FishingSpawnItems" )
        EA:Assert( spawnItemList ~= nil and #spawnItemList > 0 )

        self.spawnLocations[locIndex] =
        {
            position = position,
            radiusMin = radiusMin,
            radiusMax = radiusMax,

            active = false,
            hotspot = nil,
            bCaught = false,

            GenericTest = self.ValidResourceTest
        }

        for itemIndex, spawnItemEntry in ipairs(spawnItemList) do

            EA:Assert( #spawnItemEntry >= 3 )

            local resourceRefSpec = spawnItemEntry[1]
            local tuningRefSpec = spawnItemEntry[2]
            local weight = spawnItemEntry[3]

            local nibbles = 1
            EA:Assert( nibbles ~= nil )

            local secondsBetweenNibbles = .1
            EA:Assert( secondsBetweenNibbles ~= nil )

            local secondsBeforeBite = .5
            EA:Assert( secondsBeforeBite ~= nil )

            local biteSeconds = 5
            EA:Assert( biteSeconds ~= nil )

            self.spawnLocations[locIndex][itemIndex] =
            {
                resourceRef = resourceRefSpec,
                weight = weight,

                nibbles = nibbles;

                secondsBetweenNibbles = secondsBetweenNibbles,
                secondsBeforeBite = secondsBeforeBite,
                biteSeconds = biteSeconds,
            }
        end

    end

    -- Clamp max spawn points to actual max spawn point count
    if self.maxActiveHotspots > #self.spawnLocations then
        self.maxActiveHotspots = #self.spawnLocations
    end

end


function Unlocked_I_Fishing_Skip.ValidResourceTest( value, ... )
    local refSpec = value.resourceRef
    local resourceType = Luattrib:ReadAttribute( refSpec[1], refSpec[2], "ResourceType")
    if resourceType == Constants.ResourceTypes.Unlockable then
        EA:Fail( "Unlocks being found while fishing is not supported. Please remove unlock tuning from this fishing location." )
        return false
    end
    return Classes.ResourceBase:ResourceIsValidToSpawn( refSpec[1], refSpec[2] )
end
