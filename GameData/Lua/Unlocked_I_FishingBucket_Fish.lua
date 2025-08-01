local Unlocked_I_FishingBucket_Fish = Classes.Job_InteractionState:Inherit("Unlocked_I_FishingBucket_Fish")

Unlocked_I_FishingBucket_Fish._instanceVars =
{
	bucket          = NIL, -- the bucket object
	sim             = NIL, -- the sim that is fishing
	waterHeight		= NIL,
	fishingCursor   = NIL,
	--resourceList    = NIL, -- list of resources to spawn
	spawnItem       = NIL, -- the item to spawn when fishing
}

function Unlocked_I_FishingBucket_Fish:Test(sim, obj, autonomous )

	if ( sim ~= Universe:GetPlayerGameObject() ) then
		--return true
		local simInterest = tonumber(sim:GetAttribute("InterestCharacter")[1])
		if ( simInterest == Constants.Interests.Nature or
				simInterest == Constants.Interests.Food or
				simInterest == Constants.Interests.Sculpture) then
			-- allow autonomous with nature, food, or sculpture interest
			return true
		end
	end

    return false
end

function Unlocked_I_FishingBucket_Fish:Destructor()
	self:StopFishing()
end

--- BEFORE CATCH ANIM ---
function Unlocked_I_FishingBucket_Fish:Pre_ANIM_GETOUT_START(sim, bucket)
	local x, y, z = self.fishingCursor:GetPositionRotation()

	self.fishingCursor:CreateFX(  "Obj-fishing-catch-splash",
			FXPriority.High,
			FXStart.Now,
			FXLifetime.OneShot,
			FXAttach.None,
			-1,
			x, y, z )

	self:StopFishing()

	-- Spawn the resource
	if self.spawnItem ~= nil then
		local npcX, npcY, npcZ, npcRotY = self.sim:GetPositionRotation()
		local spawnJob3 = Classes.Job_PropellResource:Spawn(
				self.sim, -- sim
				{ x=x, y=y+1, z=z, rotY=-npcRotY }, -- object or position
				self.spawnItem.resourceRef[1], -- resource class
				self.spawnItem.resourceRef[2], -- resource collection
				math.random( 1, 2 ), -- spawn number (resource value)
				270, -- random arc angle
				nil, -- initial position modifier
				{ x=0, y=5, z=0 }, -- velocity
				180, -- angle
				{ self.sim, self.bucket } -- disable collision object list
		)
		spawnJob3:ExecuteAsIs()
	end
end

--- BEFORE START ANIM ---
function Unlocked_I_FishingBucket_Fish:Pre_ANIM_GETIN_START( sim, bucket ) -- pre anim start, so we can set up the fishing cursor
	self.bucket = bucket
	self.sim = sim

	-----------------
	-- Setup water height
	--
	local waterHeightLocatorNodeRef = bucket:GetAttribute( "Tuning_WaterHeightNode" )
	EA:Assert( waterHeightLocatorNodeRef ~= nil and #waterHeightLocatorNodeRef >= 2 )

	local waterHeightPos = Luattrib:ReadAttribute( waterHeightLocatorNodeRef[1], waterHeightLocatorNodeRef[2], "Position" )
	EA:Assert( waterHeightPos ~= nil )
	self.waterHeight = waterHeightPos["y"] or EA:Fail("Position isn't a vector or something")

	-----------------
	-- Setup resource list
	--
	local resourceList = {}
	local spawnLocationList = bucket:GetAttribute( "Tuning_FishingSpawnLocationList" )
	EA:Assert( spawnLocationList ~= nil and #spawnLocationList > 0 )

	for locIndex, spawnLocationRef in ipairs(spawnLocationList) do
		EA:Assert( #spawnLocationRef >= 2 )

		local spawnItemList = Luattrib:ReadAttribute( spawnLocationRef[1], spawnLocationRef[2], "Tuning_FishingSpawnItems" )
		EA:Assert( spawnItemList ~= nil and #spawnItemList > 0 )

		for itemIndex, spawnItemEntry in ipairs(spawnItemList) do
			EA:Assert( #spawnItemEntry >= 3 )
			local resourceRefSpec = spawnItemEntry[1]
			local weight = spawnItemEntry[3]

			resourceList[#resourceList + 1] = {
				GenericTest = self.ValidResourceTest,
				resourceRef = resourceRefSpec,
				weight = weight,
			}
		end
	end

	local spawnItemType = nil

	while spawnItemType ~= Constants.ResourceTypes.Fishing do
		local spawnItem = Common:SelectRandomWeightedWithTest( resourceList )
		if spawnItem ~= nil then
			spawnItemType = Luattrib:ReadAttribute( spawnItem.resourceRef[1], spawnItem.resourceRef[2], "ResourceType" )
			if spawnItemType == Constants.ResourceTypes.Fishing then
				self.spawnItem = spawnItem
				break
			else
				-- Remove this item from the list, since it isn't a fishing item
				for i = #resourceList, 1, -1 do
					if resourceList[i] == spawnItem then
						table.remove( resourceList, i )
					end
				end
				if #resourceList == 0 then
					EA:Fail("No valid fishing items found in the bucket's spawn list.")
				end
			end
		end
	end
end

--- AFTER CAST ANIM ---
function Unlocked_I_FishingBucket_Fish:Post_ANIM_GETIN_STOP( sim, bucket )
	-- Spawn the bobber
	local x, y, z, rotY = sim:GetPositionRotation()

	x, z = Common:GetRelativePosition( 0, 4, x, z, rotY )

	local bobberRot = sim:GetAngle( {x=x, z=z} )

	local cursor = Classes.Job_SpawnObject:Spawn( "fishingcursor", "default", sim.containingWorld, x, self.waterHeight, z, bobberRot )
	--local cursor = Classes.Job_SpawnObject:Spawn( "block", "food_placesetting_01", sim.containingWorld, x, self.waterHeight, z, bobberRot )

	local initFunc = function ( cursorObj )
		cursorObj.bAllowMove = false
		cursorObj.bHidden = false
		cursorObj.fishingAction = nil
		cursorObj.bQueryRegistered = false

		cursorObj.Run = function(self)
			self:CreateMotionEffectDummy()

			local SplashYOffset = 0.01
			-----------------
			-- Splash down!
			--
			local x2,y2,z2,rotY2 = self:GetPositionRotation()

			self:CreateFX( "Obj-fishing-bobber-splash",
					FXPriority.High,
					FXStart.Now,
					FXLifetime.OneShot,
					FXAttach.None,
					-1,
					x2, self.waterHeight + SplashYOffset, z2 )

			self.idleAnimation = "o-bobber-idle"
			self:Animate( "o-bobber-idle" )

			while true do
				self:UpdateMotionEffect()
				Yield()
			end
			return
		end

		self.fishingCursor = cursorObj
	end

	cursor:SetInitFunction(initFunc)
	cursor:Execute(self)
end

function Unlocked_I_FishingBucket_Fish:StopFishing()
	if self.fishingCursor ~= nil then
		self.fishingCursor:Destroy()
		self.fishingCursor = nil
	end
end

function Unlocked_I_FishingBucket_Fish:FishingCanceled()
	local fixFishingRodJob = Classes.Job_PlayAnimation:Spawn( self.bucket, "o2a-fishing-stop" )
	fixFishingRodJob:ExecuteAsIs()
end

function Unlocked_I_FishingBucket_Fish.ValidResourceTest( value, ... )
	local refSpec = value.resourceRef
	local resourceType = Luattrib:ReadAttribute( refSpec[1], refSpec[2], "ResourceType")
	if resourceType == Constants.ResourceTypes.Unlockable then
		EA:Fail( "Unlocks being found while fishing is not supported. Please remove unlock tuning from this fishing location." )
		return false
	end
	return Classes.ResourceBase:ResourceIsValidToSpawn( refSpec[1], refSpec[2] )
end

Unlocked_I_FishingBucket_Fish.DefaultStateSpec =
{
	ROUTE               =   {   routeType = "distance", distance = 1.0 },

	ANIM_GETIN_START    =   {
		sim = "a2o-fishing-start",
		obj = "o2a-fishing-start",
		AnimCanceledCallback = Unlocked_I_FishingBucket_Fish.FishingCanceled,
	},
	ANIM_GETIN_STOP     =   {
		sim = "a2o-fishing-cast-N",
		AnimCanceledCallback = Unlocked_I_FishingBucket_Fish.FishingCanceled,
	},

	ANIM_LOOPS          =   {
		{   sim = "a2o-fishing-breathe-N",    	weight = 10 },
		{   sim = "a2o-fishing-slack-N",    	weight = 5 },
		--{   sim = "a2o-fishing-catch-loop-N",	weight = 1 },
		AnimCanceledCallback = Unlocked_I_FishingBucket_Fish.FishingCanceled,
	},

	ANIM_GETOUT_START   = {
		sim = "a2o-fishing-catch-succeed-N",
		--spawnProbability = 1.0,
		--spawnProbabilityNPC = 1.0,
		--spawnEligibility = {"interaction_dead_wood"},
		AnimCanceledCallback = Unlocked_I_FishingBucket_Fish.FishingCanceled,
	},

	ANIM_GETOUT_STOP    = {
		sim = "a2o-fishing-stop-N",
		obj = "o2a-fishing-stop",
		AnimCanceledCallback = Unlocked_I_FishingBucket_Fish.FishingCanceled,
	},
}

Unlocked_I_FishingBucket_Fish.DefaultTuningSpec =
{
	duration =  {
		minSeconds    = 5,
		maxSeconds    = 15,

		parkable = false,
	},
	--resources = {
	--	spawnableResources = {
	--		{resource = "interaction_dead_wood", weight = 1, minSpawn = 3, maxSpawn = 6, minSpawnNPC = 2, maxSpawnNPC = 4},
	--	},
	--	spawnFromSim = false,
	--	randomArcAngle = 360,
	--	--- these are optional :)
	--	velocityModifier = { x=0, y=7, z=0,},
	--	initPosModifier = { x=0, y=1, z=0, rotY = 0},
	--},
}
