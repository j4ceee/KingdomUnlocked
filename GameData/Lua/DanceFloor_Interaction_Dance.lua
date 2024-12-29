
local DanceFloor_Interaction_Dance = Classes.Job_InteractionState:Inherit("DanceFloor_Interaction_Dance")
DanceFloor_Interaction_Dance._instanceVars = {}

function DanceFloor_Interaction_Dance:Test( sim, obj, autonomous )
        
    return (obj:GetWidgetPowerValue() > 0) --and obj.bOn
end

function DanceFloor_Interaction_Dance:Destructor()
end

function DanceFloor_Interaction_Dance:ShouldTurnOff()
    
    for i, interaction in ipairs(self.obj:GetInteractionJobList()) do
        if interaction ~= self then
            if interaction.currentState == Classes.Job_InteractionState.States["ANIM_LOOPS"] then
                return false
            end
        end
    end
    return true
end

function DanceFloor_Interaction_Dance:Pre_ANIM_LOOPS( sim, obj )
    if not self.bOn then
        obj:TurnOn()
    end
end

function DanceFloor_Interaction_Dance:ANIMATE_LOOPS_CONTINUE( sim, obj )
    --return (obj.bOn)
    return true -- npcs should keep on dancing when the player turns off the dance floor
end

function DanceFloor_Interaction_Dance:Post_ANIM_LOOPS( sim, obj )
    --[[ don't turn off the dance floor
    if self:ShouldTurnOff() then
        obj:TurnOff()
    end
    --]]
end

function DanceFloor_Interaction_Dance:Shutdown( sim, obj )
    --[[ don't turn off the dance floor
    if self:ShouldTurnOff() then
        obj:TurnOff()
    end
    --]]
end


DanceFloor_Interaction_Dance.DefaultStateSpec =
{
    ROUTE               =   {   routeType = "rect", left = -1.5, top = -1.5, right = 1.5, bottom = 1.5, skipIfInRect = true,   },
    
    ANIM_LOOPS          =   {
                                {   sim = "a-dance-bopLoop",    weight = 1 },
                                {   sim = "a-dance-armPump",    weight = 1 },
                                {   sim = "a-dance-hipBump",      weight = 1 },    
                                {   sim = "a-dance-shimmy",   weight = 1 },
                                spawnProbability = .4,
                                spawnProbabilityNPC = .1,
                                spawnTuning =
                                {
                                    spawnableResources = {
                                                             {resource = "interaction_happy", weight = 1, minSpawn = 1, maxSpawn = 1,},
                                                         },
                                },                                     
                            },                                                             
}

DanceFloor_Interaction_Dance.DefaultTuningSpec =
{
    duration =  {   
                    minSeconds    = 10,      
                    maxSeconds    = 30,
                    
                    parkable = true,
                },
    resources = {
    				spawnableResources = {
    										{resource = "interaction_happy", weight = 1, minSpawn = 1, maxSpawn = 1, minSpawnNPC = 1, maxSpawnNPC = 1},
    									 },
    				spawnFromSim = true,
    				randomArcAngle = 360,
    				--- these are optional :)
    				velocityModifier = { x=0, y=7, z=0,}, 
    				initPosModifier = { x=0, y=2, z=0, rotY = 0},
    			},               
}


