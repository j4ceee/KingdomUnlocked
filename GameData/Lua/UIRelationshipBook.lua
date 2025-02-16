local UIRelationshipBook = Classes.UIBase:Inherit( "UIRelationshipBook" )

--Enum for Info Table
local kScript = 1
local kName = 2
local kTexture = 3
local kId = 4

--attrib collections
local AttribCols = {}

UIRelationshipBook._instanceVars =
{
	bExitLoop = false,
	NPCInfo = NIL,
	Islands = NIL,
	bSpawnMode = false,
	clothing = NIL,
	npc = NIL,
}

UIRelationshipBook.DefaultUISpec =
{
	swfName = "relationship_book.swf",
	layerName = "RelationshipBook",
	bCreateNewLayer = true,
	bShouldHideOtherLayers = true,
	bIsModal = true,
	bShouldSuspendWorld = true,
	bShouldDisableCamera = true,
	bShouldDisablePause = true,
	bShouldDisableSimMenu = true,
	bShouldPauseAudio = true,
}
System:MakeTableConst(UIRelationshipBook.DefaultUISpec)

function UIRelationshipBook:Constructor()
	self.bExitLoop = false
	self.NPCInfo = {}
	self.Islands = {}
	self.bSpawnMode = nil
	self.clothing = nil
	self.npc = nil
end

function UIRelationshipBook:CreateKeybinds()
	-- Create an Array with your Keybinds
	local keybinds = {}
	table.insert(keybinds, KeybindUtils:NewKeybind(10, 10, KeybindUtils.Button.B, KeybindUtils.Alignment.BOTTOM_RIGHT, 0, 0))
	table.insert(keybinds, KeybindUtils:NewKeybind(0, 10, KeybindUtils.Button.LEFT, KeybindUtils.Alignment.BOTTOM_RIGHT, 0, 0))
	table.insert(keybinds, KeybindUtils:NewKeybind(0, 10, KeybindUtils.Button.RIGHT, KeybindUtils.Alignment.BOTTOM_RIGHT, 0, 0))

	-- Add them to this screen table
	KeybindUtils:AddKeybindsToScreen(keybinds, self.uiTblRef)
end

function UIRelationshipBook:SetParams(mode, npc)
	self:CreateKeybinds()

	-- Clear all entries from AttribCols (entries are cached)
	for k in pairs(AttribCols) do
		AttribCols[k] = nil
	end


	if mode == "spawn" then
		self.bSpawnMode = true
		self.clothing = nil
		self.uiTblRef.TitleText = "Spawn Menu"
		self.uiTblRef.TitleIcon = "uitexture-hud-relationships-on"
	elseif mode == "clothing_head" and npc then
		self.bSpawnMode = false
		self.clothing = "head"
		self.npc = npc
		self.uiTblRef.TitleText = "Model Swap Menu (Head)"
		self.uiTblRef.TitleIcon = "uitexture-interaction-change"
	elseif mode == "clothing_body" and npc then
		self.bSpawnMode = false
		self.clothing = "body"
		self.npc = npc
		self.uiTblRef.TitleText = "Model Swap Menu (Body)"
		self.uiTblRef.TitleIcon = "uitexture-interaction-change"
	else
		self.bSpawnMode = false
		self.clothing = nil
		self.uiTblRef.TitleText = "STRING_UI_RELATIONSHIPS_TITLE"
		self.uiTblRef.TitleIcon = "uitexture-hud-relationships-on"
	end

	self.uiTblRef.BackIconTexture = "uitexture-flow-back"
	self.uiTblRef.LockTexture = "uitexture-locked-icon-blue"

	--Arrow Icons
	self.uiTblRef.lArrowIcon = "uitexture-arrow-left"
	self.uiTblRef.rArrowIcon = "uitexture-arrow-right"

	self:BuildNPCList()
	self:BuildNPCInfo()

	local currentIsland = self:FindCurrentIsland() or self.Islands[1]
	self:BuildNPCEntries( currentIsland )
end

function UIRelationshipBook:PreLoop()
	UIUtility:ShowScreen( self.uiTag )
end

function UIRelationshipBook:LoopExitTest()
	return self.bExitLoop
end

function UIRelationshipBook:GetPackageName()
	return "UIRelationshipTask"
end

function UIRelationshipBook:LoopInternal()
	if( self.uiTblRef.Hit == "Cancel" ) then
		self.bExitLoop = true
	elseif( self.uiTblRef.SimId ~= nil ) then
		local simId = tonumber(self.uiTblRef.SimId)

		if self.bSpawnMode then
			-- what to do when a sim is selected in spawn menu

			local currentWorld = Universe:GetWorld()
			local playerSim = Universe:GetPlayerGameObject()
			local x, y, z, rotY = playerSim:GetPositionRotation()
			local x, z = Common:GetRelativePosition( 0, -3, x, z, rotY )

			-- Get the entry from AttribCols
			local entry = AttribCols[simId]
			if entry then
				local spawnJob = Classes.Job_SpawnObject:Spawn(
						entry.type,           -- class (character or herdables)
						entry.collection,     -- collection
						currentWorld,  -- parent world
						x, y+2.0, z,         -- position
						rotY,
						nil
				)

				spawnJob:Execute(currentWorld)
			end

			-- characters the player will likely want to spawn only once (exit UI after spawning)
			-- animals can be spawned multiple times
			if entry.type == "character" then
				self.bExitLoop = true
				vfxY = y + 1.0
			else
				vfxY = y
			end
			-- TODO: can be moved to a common function
			local override =
			{
				LifetimeInSeconds = 3.0,
				EffectName = "sim-magicTransport-poof-effects",
				EffectPriority = FXPriority.High,
			}

			local spawnJob = Classes.Job_SpawnObject:Spawn( "effect", "default", currentWorld, x, vfxY, z, rotY, override )
			spawnJob:Execute(self)

		elseif self.clothing then
			if self.clothing == "head" then
				self.npc:ReplaceHead(Constants.ModelsTable[AttribCols[simId].script].head)
			elseif self.clothing == "body" then
				self.npc:ReplaceBody(Constants.ModelsTable[AttribCols[simId].script].body)
			end
			self.bExitLoop = true

			self.npc:PushInteraction( self.npc, "Idle",
					{ tuningSpec =
					  {
						  duration =  {
							  minSeconds  = 4,        --  duration is range of seconds and/or
							  maxSeconds  = 4,        --  loop counts to run the ANIMATE_LOOPS
						  },
					  },
					} )

			--spawn vfx
			local x, y, z, rotY = self.npc:GetPositionRotation()

			local override =
			{
				LifetimeInSeconds = 4.0,
				EffectName = "sim-magicTransport-start-effects",
				EffectPriority = FXPriority.High,
			}

			local spawnJob = Classes.Job_SpawnObject:Spawn( "effect", "default", Universe:GetWorld(), x, y, z, rotY, override )
			spawnJob:Execute(self)
		else
			-- what to do when a sim is selected in default relationship book
			UI:SpawnAndBlock( "UIRelationshipCard", AttribCols[simId].collection )
		end
	elseif( self.uiTblRef.Hit == "left" ) then
		self:ChangePages( self.uiTblRef.CurrentIsland - 1 )
	elseif( self.uiTblRef.Hit == "right" ) then
		self:ChangePages( self.uiTblRef.CurrentIsland + 1 )
	end

	self.uiTblRef.Hit = nil
	self.uiTblRef.SimId = nil
end

function UIRelationshipBook:ChangePages( nPage )
	if( nPage > -1 and nPage < #self.Islands ) then
		self.uiTblRef.CurrentIsland = nPage
		self:BuildNPCEntries( self.Islands[nPage+1] )
		UIEngineUtils:AptCallFunction( "RefreshNewPage", nil, self.uiTag, 0 )
	end
end

function UIRelationshipBook:FindCurrentIsland()
	local txHash = Luattrib:ConvertStringToUserdataKey( "tutorial_01" )
	local capHash = Luattrib:ConvertStringToUserdataKey( "capital_01" )

	local worlds = Universe:GetIslandWorlds()
	local world = worlds[1].refSpec

	for i, island in ipairs(self.Islands) do
		if not (Common:str_starts( tostring(island), "animals" ) or tostring(island) == "extra") then
			local myWorld = Universe:GetIslandStartingWorld( "island" , island )
			if( world[2] == txHash and myWorld[2] == capHash ) then
				self.uiTblRef.CurrentIsland = i-1
				return island
			end

			if( world[2] == myWorld[2] ) then
				self.uiTblRef.CurrentIsland = i-1
				return island
			end
		end
	end

	self.uiTblRef.CurrentIsland = 0

	return nil
end

--- Get all the Sims collection keys in the game & store them in a table (AttribCols)
function UIRelationshipBook:BuildNPCList()
	-- get all collectionKeys for classKey "character"
	-- returns a nested table with the collection key having index 2
	local refSpecs = Luattrib:GetAllCollections( "character", nil )

	-- Get all character collections
	for i, v in ipairs( refSpecs ) do
		local collection = v[2] -- collection key

		local script = Luattrib:ReadAttribute( "character", collection, "ScriptName" ) -- script == sim.mType

		local add
		if Luattrib:ReadAttribute( "character", collection, "TrackRelationship" ) or Common:tbl_has_value(Constants.PirateCoveScripts, script ) then
			add = true
		end

		if( add == true ) then
			AttribCols[#AttribCols + 1] = {
				collection = collection,
				script = script,
				type = "character",
			}
		end
	end

	if self.clothing then
		-- add beebee only if we're in clothing mode
		AttribCols[#AttribCols + 1] = {
			collection = nil,
			script = "Beebee",
			type = "character",
		}
	end

	if self.bSpawnMode then
		-- do animals #########################################################
		for animalScript, animal in pairs(Constants.AnimalTable) do
			if animal.enabled then
				AttribCols[#AttribCols + 1] = {
					collection = animal.collectionKey,
					script = animalScript,
					type = "herdables",
				}
			end
		end
	end
end

function UIRelationshipBook:BuildNPCInfo()
	local animalCount = 0 -- only 8 animals fit on a page
	local animalPage = 0 -- page number for animals

	for i, entry in ipairs(AttribCols) do
		if entry.type == "character" and entry.collection then
			local mType = entry.script
			local homeIsland = Luattrib:ReadAttribute( "character", entry.collection, "HomeIsland" )
			local home = nil

			if( homeIsland ~= nil ) then
				home = homeIsland[2]
			end

			if( home ~= nil ) then
				local face = Luattrib:ReadAttribute( "character", entry.collection, "FaceIcon" ) --get face icon
				local name = Luattrib:ReadAttribute( "character", entry.collection, "FullName" ) --get name

				if( self.NPCInfo[home] == nil ) then
					self.NPCInfo[home] = {}
					self.Islands[#self.Islands+1] = home -- add island to list
				end
				if( self.NPCInfo[home][mType] == nil ) then
					self.NPCInfo[home][mType] = { mType, name, face, i, type = entry.type}
				end
			end
		elseif entry.type == "character" and not entry.collection and self.clothing then
			-- do extra models #########################################################
			local extraTable = {
				["Beebee"] = {
					name = "Beebee",
					icon = "uitexture-s-bunny",
				}
			}

			-- add add any clothing items that don't have a collection key
			local home = "extra"

			if( self.NPCInfo[home] == nil ) then
				self.NPCInfo[home] = {}
				self.Islands[#self.Islands+1] = home
			end

			if( self.NPCInfo[home][entry.script] == nil ) then
				self.NPCInfo[home][entry.script] = { entry.script, extraTable[entry.script].name, extraTable[entry.script].icon, i, type = entry.type }
			end
		elseif entry.type == "herdables" then
			-- do animals #########################################################
			local animalScript = entry.script

			if animalCount == 8 then -- only 8 animals fit on a page, so we create a new page for the next 8
				animalPage = animalPage + 1
				animalCount = 0
			end

			local home = "animals" .. animalPage

			if ( self.NPCInfo[home] == nil ) then -- if the island doesn't exist in the table
				self.NPCInfo[home] = {}
				self.Islands[#self.Islands + 1] = home
			end

			if( self.NPCInfo[home][entry.collection] == nil ) then -- if the animal doesn't exist in the table
				self.NPCInfo[home][entry.collection] = {
					entry.collection,  -- collection
					Constants.AnimalTable[animalScript].name, -- name
					Constants.AnimalTable[animalScript].icon or "uitexture-interaction-pet", -- icon
					i,                -- id
					type = entry.type -- type (herdables)
				}
			end

			animalCount = animalCount + 1 -- we added an animal, so increment the counter
		end
	end

	for i, island in ipairs(self.Islands) do
		local count = 0
		if( self.NPCInfo[island] ~= nil ) then
			for junk in pairs(self.NPCInfo[island]) do
				count = count + 1
			end
		end
		self.uiTblRef["NumSims" .. (i-1)] = count
	end

	self.uiTblRef.IslandCount = #self.Islands
end

function UIRelationshipBook:BuildNPCEntries( island )
	local player = Universe:GetPlayerGameObject()

	--- set the island name
	if Common:str_starts( tostring(island), "animals" ) then
		self.uiTblRef.IslandName = "Animals " .. tonumber(string.sub( tostring(island), 8 ))+1
	elseif island == "extra" then
		self.uiTblRef.IslandName = "Extra"
	else
		self.uiTblRef.IslandName = Luattrib:ReadAttribute( "island", island, "UIIslandName" ) or "NO NAME"
	end

	if( self.NPCInfo[island] ~= nil ) then
		local i = 0
		for k,sim in pairs(self.NPCInfo[island]) do

			local entryName = "Entry"..i

			-- nil cannot be concatenated, so set it to an empty string
			if sim[kTexture] == nil then
				sim[kTexture] = ""
			end

			-- sim[kId] is the index of the sim in the AttribCols table
			-- sim[kName] is the name of the sim, e.g. "Lindsay"
			-- sim[kTexture] is the face icon of the sim
			-- sim[kScript] is the script name of the sim, e.g. "NPC_Linzey"

			local entryLocked = "locked|||"
			local entry = AttribCols[sim[kId]]
			local isPirateCove = Common:tbl_has_value(Constants.PirateCoveScripts, sim[kScript])

			if entry then
				if self.bSpawnMode then
					if not isPirateCove then
						-- Spawn mode, non-pirate cove entry
						self.uiTblRef[entryName] = sim[kId] .. "|" .. sim[kName] .. "|" .. sim[kTexture] .. "|"
					else
						-- Spawn mode, pirate cove entry
						self.uiTblRef[entryName] = entryLocked
					end
				elseif self.clothing then
					local script = sim[kScript]
					local modelName

					if Constants.ModelsTable[script] then
						if self.clothing == "head" then
							modelName = Constants.ModelsTable[script].head
						elseif self.clothing == "body" then
							modelName = Constants.ModelsTable[script].body
						end
					end

					if modelName then
						self.uiTblRef[entryName] = sim[kId] .. "|" .. sim[kName] .. "|" .. sim[kTexture] .. "|" .. modelName
					else
						self.uiTblRef[entryName] = entryLocked
					end
				else
					-- Relationship mode
					local relationshipData = player:GetRelationship(entry.collection)
					if relationshipData ~= nil or isPirateCove then
						self.uiTblRef[entryName] = sim[kId] .. "|" .. sim[kName] .. "|" .. sim[kTexture] .. "|" .. self:GetRelationshipIcon(relationshipData)
					else
						self.uiTblRef[entryName] = entryLocked
					end
				end
			else
				self.uiTblRef[entryName] = entryLocked
			end



			i = i + 1
		end
	end
end

function UIRelationshipBook:GetRelationshipIcon( statusLevel )
	if( statusLevel == nil ) then
		statusLevel = 0
	end

	if( statusLevel < -72 ) then
		return "uitexture-relationship-01"
	elseif( statusLevel < -43 ) then
		return "uitexture-relationship-02"
	elseif( statusLevel < -14 ) then
		return "uitexture-relationship-03"
	elseif( statusLevel < 13 ) then
		return "uitexture-relationship-04"
	elseif( statusLevel < 42 ) then
		return "uitexture-relationship-05"
	elseif( statusLevel < 71 ) then
		return "uitexture-relationship-06"
	else
		return "uitexture-relationship-07"
	end
end