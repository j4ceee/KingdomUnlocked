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

function UIRelationshipBook:SetParams(mode)
	self:CreateKeybinds()

	if mode == "spawn" then
		self.bSpawnMode = true
		self.uiTblRef.TitleText = "Spawn Menu"
	else
		self.bSpawnMode = false
		self.uiTblRef.TitleText = "STRING_UI_RELATIONSHIPS_TITLE"
	end

	self.uiTblRef.TitleIcon = "uitexture-hud-relationships-on"
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

			local playerSim = Universe:GetPlayerGameObject()
			local x, y, z, rotY = playerSim:GetPositionRotation()
			local x, z = Common:GetRelativePosition( 0, -3, x, z, rotY )

			-- Get the entry from AttribCols
			local entry = AttribCols[simId]
			if entry then
				local spawnJob = Classes.Job_SpawnObject:Spawn(
						entry.type,           -- class (character or herdables)
						entry.collection,     -- collection
						Universe:GetWorld(),  -- parent world
						x, y+2.0, z,         -- position
						rotY,
						nil
				)

				spawnJob:Execute(Universe:GetWorld())
			end

			-- characters the player will likely want to spawn only once (exit UI after spawning)
			-- animals can be spawned multiple times
			if entry.type == "character" then
				self.bExitLoop = true
			end
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
		if not string.starts( tostring(island), "animals" ) then
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

		-- only add sims that have a relationship (excludes things like pirate cove & credits npc)
		local add
		add = Luattrib:ReadAttribute( "character", collection, "TrackRelationship" ) -- return all npcs by setting "add" to true

		if( add == true ) then
			AttribCols[#AttribCols + 1] = {
				collection = collection,
				type = "character",
			}
		end
	end

	if self.bSpawnMode then
		-- do animals #########################################################
		local animalsSpec = Luattrib:GetAllCollections( "herdables", nil )

		for i, collection in ipairs(animalsSpec) do
			AttribCols[#AttribCols + 1] = {
				collection = collection[2],
				type = "herdables",
			}
		end
	end
end

function UIRelationshipBook:BuildNPCInfo()
	local animalCount = 0 -- only 8 animals fit on a page
	local animalPage = 0 -- page number for animals

	local namesAdded = { -- we only want to add each animal once (can also be used to prevent animals from being added at all)
		"HerdableScriptObjectBase",
		"DummyScript",
		"HerdableTrevor2",
		"HerdableTrevor3",
		"HerdableTrevor4",

		-- missing interactions (so cannot be deleted)
		-- TODO: find a way to make them deletable (e.g. RelationshipBook DEspawn functionality)
		"ToborLegs",
		"HerdableTrevor",
		"Bear",
		"Panda_Cub",
		"Raccoon",
		"Dog",
		"CatAnimal",
	}

	-- if there are multiple variants of an animal, show the x one in order
	-- TODO: this is a hack, find a better way to do this (printing the collectionKeys in-game shows a memory address instead of the actual key)
	local animalIndex = {
		["Bobaboo"] = 3, -- use the 3rd bobaboo (fixes interactions)
		["Cow"] = 4, -- 1 - 4 are standing, 5 is fleeing (max. 5)

		["Unicorn"] = 1, -- 1 - 6 fleeing (max. 6)
		["Hedgehog"] = 4, -- 1 - 4 fleeing (max. 4)
		["HedgehogLarge"] = 2, -- 1 - 3 standing (max. 2)
		["Bunny"] = 11, -- 1 - 11 standing (max. 11)
		["Spider"] = 4, -- 1 - 3 standing, 4 fleeing (max. 4)
		["Frog"] = 9, -- 1 - 4, 9 - 10 standing (green) | 5 - 8 standing (black) | max. 10

		["Dog"] = 4, -- 2 - 4 is wandering dog (max. 4)
		["CatAnimal"] = 3, -- 3 is following cat (max. 3)
		 }

	local imageLib = {
		["Bobaboo"] = "uitexture-map-icon-gonk",
		["Pig"] = "uitexture-map-icon-animal",
		["PercyPig"] = "uitexture-map-icon-animal",
		["Unicorn"] = "uitexture-map-icon-leaf",
		["HerdableTrevor"] = "uitexture-npc-head-trevor",
		["ToborLegs"] = "uitexture-npc-head-tobor",
		["Crab"] = "uitexture-fish-crab",
		["Spider"] = "uitexture-essence-flair-spider",
		["Cow"] = "uitexture-figurine-cow",
	}

	for i, entry in ipairs(AttribCols) do
		if entry.type == "character" then
			local script = Luattrib:ReadAttribute( "character", entry.collection, "ScriptName" ) -- script == sim.mType
			local homeIsland = Luattrib:ReadAttribute( "character", entry.collection, "HomeIsland" )
			local home = nil

			if( homeIsland ~= nil ) then
				home = homeIsland[2]
			end

			if( home ~= nil ) then
				-- in the relationship book, only show sims whose island is unlocked
				-- in spawn menu, show all sims
				if ( Unlocks:IsUnlocked("island", home) ) or self.bSpawnMode then
					local face = Luattrib:ReadAttribute( "character", entry.collection, "FaceIcon" ) --get face icon
					local name = Luattrib:ReadAttribute( "character", entry.collection, "FullName" ) --get name

					if( self.NPCInfo[home] == nil ) then
						self.NPCInfo[home] = {}
						self.Islands[#self.Islands+1] = home -- add island to list
					end
					if( self.NPCInfo[home][script] == nil ) then
						self.NPCInfo[home][script] = {script, name, face, i, type = entry.type}
					end
				end
			end
		elseif entry.type == "herdables" then
			-- do animals #########################################################
			if animalCount == 8 then -- only 8 animals fit on a page, so we create a new page for the next 8
				animalPage = animalPage + 1
				animalCount = 0
			end

			local home = "animals" .. animalPage

			if ( self.NPCInfo[home] == nil ) then -- if the island doesn't exist in the table
				self.NPCInfo[home] = {}
				self.Islands[#self.Islands + 1] = home
			end

			-- Try to get a proper name from the herdables attributes
			local animalName = Luattrib:ReadAttribute("herdables", entry.collection, "ScriptName")

			if animalIndex[animalName] and animalIndex[animalName] > 1 then
				animalIndex[animalName] = animalIndex[animalName] - 1
			end

			-- check if name is already in the namesAdded table, if not add it
			if ( not  table.has_value( namesAdded, animalName ) ) and ( animalIndex[animalName] == nil or animalIndex[animalName] == 1 ) then
				namesAdded[#namesAdded + 1] = animalName

				if( self.NPCInfo[home][entry.collection] == nil ) then -- if the animal doesn't exist in the table
					self.NPCInfo[home][entry.collection] = {
						entry.collection,  -- script
						animalName,  	  -- name
						imageLib[animalName] or "uitexture-interaction-pet", -- face icon (use default if not defined)
						i,                -- id
						type = entry.type -- type (herdables)
					}
				end

				animalCount = animalCount + 1 -- we added an animal, so increment the counter
			end
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
	if string.starts( tostring(island), "animals" ) then
		self.uiTblRef.IslandName = "Animals " .. tonumber(string.sub( tostring(island), 8 ))+1
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
			if self.bSpawnMode then
				self.uiTblRef[entryName] = sim[kId] .. "|" .. sim[kName] .. "|" .. sim[kTexture] .. "|"
			else
				-- Get the collection from the new AttribCols structure
				local entry = AttribCols[ sim[kId] ]
				if not entry then
					self.uiTblRef[entryName] = "locked|||"
				else
					local relationshipData = player:GetRelationship( entry.collection )
					if ( relationshipData == nil ) then
						self.uiTblRef[entryName] = "locked|||"
					else
						self.uiTblRef[entryName] = sim[kId] .. "|" .. sim[kName] .. "|" .. sim[kTexture] .. "|" .. self:GetRelationshipIcon(relationshipData)
					end
				end
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

-- Generic function to check if a string starts with a certain substring
function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end

--- Generic function to check if a table contains a value
function table.has_value (tab, val)
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end