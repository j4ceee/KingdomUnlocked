
local DJBooth_Interaction_DJ = Classes.Job_InteractionState:Inherit("DJBooth_Interaction_DJ")

DJBooth_Interaction_DJ._instanceVars =
{
    bShouldTurnOff = false,
}

function DJBooth_Interaction_DJ:Test( sim, obj, autonomous )
    
    if obj.bIsUsed or obj:GetWidgetPowerValue() == 0 then
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

function DJBooth_Interaction_DJ:Destructor()
end

function DJBooth_Interaction_DJ:Setup( sim, obj )
    if self.stateSpec == self.DefaultStateSpec and ( not Class:InheritsFrom(sim, "NPC_DJCandy") ) then
        self.stateSpec = self.PlayerStateSpec
    end
end

function DJBooth_Interaction_DJ:ANIMATE_LOOPS_CONTINUE( sim, obj )
    return obj.bOn and obj:GetWidgetPowerValue() > 0
end


--=============================
-- StartAnimCallback
--=============================
function DJBooth_Interaction_DJ:StartAnimCallback(animJob, eventText)
    if eventText == "500" then
        self.bShouldTurnOff = true
        
        local trackIndex
        
        if self.params ~= nil then
            trackIndex = self.params.trackIndex
        end
        
        self.obj:TurnOn(trackIndex)
    end
end

--=============================
-- StopAnimCallback
--=============================
function DJBooth_Interaction_DJ:StopAnimCallback(animJob, eventText)
    if eventText == "501" or eventText == "end" then
        self.bShouldTurnOff = false
        self.obj:TurnOff()
    end
end

--=============================
-- ChangeSongAnimCallback
--=============================
function DJBooth_Interaction_DJ:ChangeSongAnimCallback(animJob, eventText)
    if eventText == "502" then
        self.obj:ChangeSong()
    end
end

--=============================
-- VoxualAnimCallback
--=============================
function DJBooth_Interaction_DJ:VoxualAnimCallback(animJob, eventText)
    if eventText ~= "end" and tonumber(eventText) == nil then
    
        --modify the text to reflect the variation picking
        local variationChoice = math.random( 2 )
        if  variationChoice == 1 then
            eventText = eventText .. "a"
        else
            eventText = eventText .. "b"
        end
        
        self.sim:PlayVoxThroughObject( self.sim, eventText )
        
        local maxCount, current = 1, 0 
        
        if self.obj.speakerList then
            for i,speaker in ipairs(self.obj.speakerList) do
                speaker:PlayVoxThroughObject( self.sim, eventText )
                current = current+1
                if current >= maxCount then
                    break
                end
            end
        end
        
    end
end


--=============================
-- LoopCanceledCallback
--=============================
function DJBooth_Interaction_DJ:LoopCanceledCallback( sim, obj )
    self.bShouldTurnOff = false
    obj:TurnOff()
end

function DJBooth_Interaction_DJ:Shutdown( sim, obj )
    if self.bShouldTurnOff then
        self.bShouldTurnOff = false
        obj:TurnOff()
    end
end

function DJBooth_Interaction_DJ:AllowChangeRecord()
    local bAllow = true
    if self.params ~= nil then
        if self.params.bDisableChangeRecord then
            bAllow = false
        end
    end
    return bAllow
end


DJBooth_Interaction_DJ.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "slot", slotNum = 0 },
    
    ANIM_TRANS_IN       =   {   
                                sim = "a2o-DJBooth-NPC-start",
                                AnimEventCallback = DJBooth_Interaction_DJ.StartAnimCallback,
                            },
       
    ANIM_LOOPS          =   {
                                {   sim = "a2o-DJBooth-NPC-loop-groove",    weight = 60 },
                                {   
                                    sim = "a2o-DJBooth-NPC-dedicate",       
                                    weight = 5,
                                    AnimEventCallback = DJBooth_Interaction_DJ.VoxualAnimCallback,
                                },
                                {   
                                    sim = "a2o-DJBooth-NPC-shout",
                                    weight = 5,
                                    AnimEventCallback = DJBooth_Interaction_DJ.VoxualAnimCallback,
                                },
                                {
                                    sim = "a2o-DJBooth-NPC-changeRecord",   
                                    weight = 5,
                                    AnimEventCallback = DJBooth_Interaction_DJ.ChangeSongAnimCallback,
                                    Test = DJBooth_Interaction_DJ.AllowChangeRecord,
                                },
                                spawnProbability = .4,
                                spawnProbabilityNPC = .1,
                                spawnTuning =
                                {
                                    spawnableResources = {
                                                             {resource = "interaction_music", weight = 80, minSpawn = 1, maxSpawn = 1,},
                                                             {resource = "interaction_8ball", weight = 5, minSpawn = 1, maxSpawn = 1,},
                                                             {resource = "interaction_figurine_djcandy", weight = 10, minSpawn = 1, maxSpawn = 1,},
                                                         },
                                },  
                                
                                AnimCanceledCallback = DJBooth_Interaction_DJ.LoopCanceledCallback,
                            },
    
    ANIM_TRANS_OUT      =   {   
                                sim = "a2o-DJBooth-NPC-stop",
                                AnimEventCallback = DJBooth_Interaction_DJ.StopAnimCallback,
                            },
}

DJBooth_Interaction_DJ.PlayerStateSpec =
{
    ROUTE               =   {   routeType = "slot", slotNum = 0 },
    
    ANIM_TRANS_IN       =   {
                                sim = "a2o-DJBooth-start",
                                AnimEventCallback = DJBooth_Interaction_DJ.StartAnimCallback,
                            },
       
    ANIM_LOOPS          =   {
                                {   sim = "a2o-DJBooth-loop-groove",    weight = 60 },
                                {   
                                    sim = "a2o-DJBooth-NPC-dedicate",       
                                    weight = 5,
                                    AnimEventCallback = DJBooth_Interaction_DJ.VoxualAnimCallback,
                                },
                                {   
                                    sim = "a2o-DJBooth-NPC-shout",
                                    weight = 5,
                                    AnimEventCallback = DJBooth_Interaction_DJ.VoxualAnimCallback,
                                },
                                {   
                                    sim = "a2o-DJBooth-changeRecord",
                                    weight = 5,
                                    AnimEventCallback = DJBooth_Interaction_DJ.ChangeSongAnimCallback,
                                },
                                spawnProbability = .4,
                                spawnProbabilityNPC = .1,
                                spawnTuning =
                                {
                                    spawnableResources = {
                                                             {resource = "interaction_music", weight = 80, minSpawn = 1, maxSpawn = 1,},
                                                             {resource = "interaction_8ball", weight = 10, minSpawn = 1, maxSpawn = 1,},
                                                             {resource = "interaction_figurine_djcandy", weight = 10, minSpawn = 1, maxSpawn = 1,},
                                                         },
                                },  
                                
                                AnimCanceledCallback = DJBooth_Interaction_DJ.LoopCanceledCallback,
                            },
    
    ANIM_TRANS_OUT      =   {   
                                sim = "a2o-DJBooth-stop",
                                AnimEventCallback = DJBooth_Interaction_DJ.StopAnimCallback,
                            },
}

DJBooth_Interaction_DJ.DefaultTuningSpec =
{
    duration =  {   
                    minSeconds    = 60,      
                    maxSeconds    = 90,
                    
                    parkable = false,
                },
    resources = {
                    spawnableResources = {
                                            {resource = "interaction_music", weight = 80, minSpawn = 1, maxSpawn = 1, minSpawnNPC = 1, maxSpawnNPC = 1},
                                            {resource = "interaction_8ball", weight = 10, minSpawn = 1, maxSpawn = 1, minSpawnNPC = 1, maxSpawnNPC = 1},
                                            {resource = "interaction_figurine_djcandy", weight = 10, minSpawn = 1, maxSpawn = 1,},
                                         },
                    spawnFromSim = false,
                    randomArcAngle = 360,
                    --- these are optional :)
                    velocityModifier = { x=0, y=7, z=0,}, 
                    initPosModifier = { x=0, y=1.5, z=0, rotY = 0},
                },                
}



local DJBooth_Interaction_DJ_Uber = Classes.DJBooth_Interaction_DJ:Inherit("DJBooth_Interaction_DJ_Uber")

function DJBooth_Interaction_DJ_Uber:Test( sim, obj, autonomous, interactionData )
    local powerRequirement = interactionData.powerRequirement or 2.0
    
    if sim == Universe:GetPlayerGameObject() then
        return (not obj.bIsUsed) and DebugMenu:GetValue("EnableDebugInteractions") and obj:GetWidgetPowerValue() > 0
    end

    return (not obj.bIsUsed) and obj:GetWidgetPowerValue() >= powerRequirement
end

DJBooth_Interaction_DJ_Uber.DefaultTuningSpec =
{
    duration =  {   
                    minSeconds    = 10000,      
                    maxSeconds    = 10000,
                    
                    parkable = true,
                },
}

