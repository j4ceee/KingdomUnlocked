local DanceFloor = Classes.BlockObjectBase:Inherit( "DanceFloor" )

DanceFloor._instanceVars =
{
    bOn                 = false,
    cellTimer           = NIL,
    changePatternTimer  = NIL,
    
    patternFunction     = NIL,
    patternInfo         = NIL,
    
    maxUseCount = 5,  -- Limits npc's ability to use an object
}

function DanceFloor:PowerChangedCallback( powerValue )
    if powerValue == 0 then
        self:TurnOff()
    else
        self:SetAllCellsByState()
    end
end

function DanceFloor:RunnableCallback()
    self:SetAllCellsByState()    
end

function DanceFloor:SetAllCellsByState()
    if (self:GetWidgetPowerValue() > 0) then
        self:SetAllCells(1)
    else
        self:SetAllCells(0)
    end
end

function DanceFloor:TurnOn()
    if not self.bOn then
        self.bOn = true
        self:StartPattern()
    end    
end

function DanceFloor:TurnOff()
    if self.cellTimer then
        self.cellTimer:Kill()
        self.cellTimer = nil
    end  
    if self.changePatternTimer then
        self.changePatternTimer:Kill()
        self.changePatternTimer = nil
    end
    
    if self.bOn then
        self.bOn = false
    end
    
    self:SetAllCellsByState()
end

function DanceFloor:SetAllCells(materialIndex)
    for i=1,6 do
        for j=1,6 do
            self:SetMaterialIndex((materialIndex or 0), "WidgetDanceFloor_" .. i .. j, 0)
        end
    end
end

function DanceFloor:StartPattern()

    self.patternInfo = {}

    self.patternFunction = Common:SelectRandomWeighted( self.PatternFunctions )[1]
    
    self.changePatternTimer = self:CreateTimer(Clock.Game, 0, 0, 0, 30)
    
    self:ExecuteCurrentPattern()
end

function DanceFloor:ExecuteCurrentPattern()
    self.patternFunction(self)
    self.cellTimer = self:CreateTimer(Clock.Game, 0, 0, 0, 0.5)
end



--=================================================================== 
-- Pattern processing functions
--===================================================================

function DanceFloor:RandomizeAllCells()
    for i=1,6 do
        for j=1,6 do
            self:SetMaterialIndex(math.random(1,5), "WidgetDanceFloor_" .. i .. j, 0)
        end
    end
end

function DanceFloor:InwardSquares()

    if #self.patternInfo == 0 then
        self.patternInfo = { 1, 2, 3, 4, 5 }
    else
        table.insert(self.patternInfo, 1, self.patternInfo[5] )
        self.patternInfo[#self.patternInfo] = nil
    end
    
    
    for i=1,6 do
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. i .. 1, 0)
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. i .. 6, 0)
    end
    
    for i=2,5 do
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. 1 .. i, 0)
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. 6 .. i, 0)
    end
    
    
    for i=2,5 do
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. i .. 2, 0)
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. i .. 5, 0)
    end
    
    for i=3,4 do
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. 2 .. i, 0)
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. 5 .. i, 0)
    end
        
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 3 .. 3, 0)
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 3 .. 4, 0)
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 4 .. 3, 0)
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 4 .. 4, 0)
    
end


function DanceFloor:OutwardSquares()

    if #self.patternInfo == 0 then
        self.patternInfo = { 1, 2, 3, 4, 5 }
    else
        
        local num = table.remove(self.patternInfo, 1)
        self.patternInfo[5] = num
    end
    
    
    for i=1,6 do
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. i .. 1, 0)
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. i .. 6, 0)
    end
    
    for i=2,5 do
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. 1 .. i, 0)
        self:SetMaterialIndex(self.patternInfo[1], "WidgetDanceFloor_" .. 6 .. i, 0)
    end
    
    
    for i=2,5 do
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. i .. 2, 0)
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. i .. 5, 0)
    end
    
    for i=3,4 do
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. 2 .. i, 0)
        self:SetMaterialIndex(self.patternInfo[2], "WidgetDanceFloor_" .. 5 .. i, 0)
    end
        
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 3 .. 3, 0)
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 3 .. 4, 0)
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 4 .. 3, 0)
    self:SetMaterialIndex(self.patternInfo[3], "WidgetDanceFloor_" .. 4 .. 4, 0)
    
end


function DanceFloor:RowsShiftRight()

    if #self.patternInfo == 0 then
        self.patternInfo = { 1, 2, 3, 4, 5 }
    else
        table.insert(self.patternInfo, 1, self.patternInfo[5] )
        self.patternInfo[#self.patternInfo] = nil
    end
        
    for i=1,6 do
        for j=1,6 do
            local colorIndex = i
            if i == 6 then colorIndex = 1 end
            self:SetMaterialIndex(self.patternInfo[colorIndex], "WidgetDanceFloor_" .. i .. j, 0)
        end
    end    
end

function DanceFloor:RowsShiftLeft()

    if #self.patternInfo == 0 then
        self.patternInfo = { 1, 2, 3, 4, 5 }
    else
        local num = table.remove(self.patternInfo, 1)
        self.patternInfo[5] = num
    end
        
    for i=1,6 do
        for j=1,6 do
            local colorIndex = i
            if i == 6 then colorIndex = 1 end
            self:SetMaterialIndex(self.patternInfo[colorIndex], "WidgetDanceFloor_" .. i .. j, 0)
        end
    end    
end

function DanceFloor:ColumnsShiftDown()

    if #self.patternInfo == 0 then
        self.patternInfo = { 1, 2, 3, 4, 5 }
    else
        table.insert(self.patternInfo, 1, self.patternInfo[5] )
        self.patternInfo[#self.patternInfo] = nil
    end
        
    for i=1,6 do
        for j=1,6 do
            local colorIndex = j
            if j == 6 then colorIndex = 1 end
            self:SetMaterialIndex(self.patternInfo[colorIndex], "WidgetDanceFloor_" .. i .. j, 0)
        end
    end    
end

function DanceFloor:ColumnsShiftUp()

    if #self.patternInfo == 0 then
        self.patternInfo = { 1, 2, 3, 4, 5 }
    else
        local num = table.remove(self.patternInfo, 1)
        self.patternInfo[5] = num
    end
        
    for i=1,6 do
        for j=1,6 do
            local colorIndex = j
            if j == 6 then colorIndex = 1 end
            self:SetMaterialIndex(self.patternInfo[colorIndex], "WidgetDanceFloor_" .. i .. j, 0)
        end
    end    
end


function DanceFloor:CheckerBoard()

    if #self.patternInfo == 0 then
        local color1 = math.random(1,5)
        local color2 = math.random(1,5)
        
        if color2 == color1 then
            color2 = color2 + 1
            if color2 > 5 then
                color2 = 1
            end
        end
            
        self.patternInfo = { color2, color1 }
    else
        self.patternInfo[1], self.patternInfo[2] = self.patternInfo[2], self.patternInfo[1]
    end
        
    for i=1,6 do
        for j=1,6 do
            local colorIndex = (i+j)/2
            colorIndex = math.ceil(math.ceil(colorIndex)-colorIndex)+1
            
            self:SetMaterialIndex(self.patternInfo[colorIndex], "WidgetDanceFloor_" .. i .. j, 0)
        end
    end    
end

local BitMapTestTable =
{
    [1] =   {   1, 1, 0, 0, 1, 1,   },
    [2] =   {   1, 1, 0, 0, 1, 1,   },
    [3] =   {   0, 0, 1, 1, 0, 0,   },
    [4] =   {   0, 0, 1, 1, 0, 0,   },
    [5] =   {   1, 1, 0, 0, 1, 1,   },
    [6] =   {   1, 1, 0, 0, 1, 1,   },
}

function DanceFloor:BitMap()

    if #self.patternInfo == 0 then
        local color1 = math.random(1,5)
        local color2 = math.random(1,5)
        
        if color2 == color1 then
            color2 = color2 + 1
            if color2 > 5 then
                color2 = 1
            end
        end
            
        self.patternInfo = { color2, color1 }
    else
        self.patternInfo[1], self.patternInfo[2] = self.patternInfo[2], self.patternInfo[1]
    end
        
    for i=1,6 do
        for j=1,6 do
            
            local bit = BitMapTestTable[i][j]
                                
            local colorIndex = self.patternInfo[1]
            if bit == 1 then
                colorIndex = self.patternInfo[2]
            end
            
            self:SetMaterialIndex(colorIndex, "WidgetDanceFloor_" .. i .. j, 0)
        end
    end    
end



function DanceFloor:CycleFromBeginning()
    if self.patternInfo.i == nil then
        self.patternInfo.i = 1
        self.patternInfo.j = 1
        
    else
        self.patternInfo.i = self.patternInfo.i + 1
        if self.patternInfo.i > 6 then
            self.patternInfo.i = 1
            
            self.patternInfo.j = self.patternInfo.j + 1
            
            if self.patternInfo.j > 6 then
                self.patternInfo.j = 1
            end
        end        
    end
    
    self:SetMaterialIndex(math.random(1,5), "WidgetDanceFloor_" .. self.patternInfo.i .. self.patternInfo.j, 0)
end


DanceFloor.PatternFunctions =
{
    {   DanceFloor.RandomizeAllCells,   weight = 1  },
    {   DanceFloor.InwardSquares,       weight = 1  },
    {   DanceFloor.OutwardSquares,      weight = 1  },
    {   DanceFloor.RowsShiftRight,      weight = 1  },
    {   DanceFloor.RowsShiftLeft,       weight = 1  },
    {   DanceFloor.ColumnsShiftDown,    weight = 1  },
    {   DanceFloor.ColumnsShiftUp,      weight = 1  },
    {   DanceFloor.CheckerBoard,        weight = 1  },
    {   DanceFloor.BitMap,              weight = 1  },
    
    
--|     {   DanceFloor.CycleFromBeginning, weight = 100    },
}

--=================================================================== 
-- DanceFloor:TimerExpiredCallback( timerId )
--===================================================================
function DanceFloor:TimerExpiredCallback( timerId )
    if timerId == self.cellTimer then
        
        self:ExecuteCurrentPattern()
        
    elseif timerId == self.changePatternTimer then
        
        self:StartPattern()
    
    end
end


--=================================================================== 
-- Interactions
--===================================================================

DanceFloor.interactionSet =
{
                    
    Dance =     {   
                    name                    = "STRING_INTERACTION_DANCEFLOOR_DANCE",
                    interactionClassName    = "DanceFloor_Interaction_Dance",
                    maxCount = 5,
                    icon = "uitexture-interaction-dance",
                    menu_priority = 0,
                },

    TurnOn =    {
                    name                    = "STRING_INTERACTION_STEREO_TURNON",
                    interactionClassName    = "Unlocked_I_DanceFl_On",
                    icon = "uitexture-interaction-use",
                    menu_priority = 1,
                },

    TurnOff =   {
                    name                    = "STRING_INTERACTION_STEREO_TURNOFF",
                    interactionClassName    = "Unlocked_I_DanceFl_Off",
                    icon = "uitexture-interaction-use",
                    menu_priority = 2,
                },
}


