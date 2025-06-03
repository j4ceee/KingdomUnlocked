
--{{{ UICASContextPicker.lua --------------------------------------------------------------
local contexts = { "kmirror", "kkingdom", "kmodern", "kcostume", "kfriends" }

--function Classes.UICASContextPicker:Constructor()
--    self.bShouldExit = false
--    --self:PostSpawn( "UICASContextPicker" ) -- TODO: should not call explicitly like this
--end

function Classes.UICASContextPicker:SetParams()
    self:CreateKeybinds();
    self.uiTblRef.TitleText = "STRING_CAS_TITLE"

    --- custom code start
    local gender = self.pendingGender or "none"
    if gender ~= Constants.Gender.Male and gender ~= Constants.Gender.Female then
        gender = Luattrib:ReadAttribute( "character", "player", "Gender" )
    end

    local genderSuffix = "m"
    if( gender == Constants.Gender.Male ) then
        genderSuffix = "m"
    elseif( gender == Constants.Gender.Female ) then
        genderSuffix = "f"
    end
    --- custom code end

    -- Collection Info
    -- Mirror context used by button 0 (c0) on flash is always unlocked (locked 0)
    self.uiTblRef.cIcon0 = "uitexture-cas-context5"
    self.uiTblRef.cDesc0 = "STRING_CAS_CONTEXT_5"
    self.uiTblRef.cLocked0 = 0

    -- For the other contexts and buttons, kkingdom (c1), kmodern (c2), kcostume (c3), kfriends (c4)
    -- we need to check, and since the element 1 from contexts array is Mirror, we skip the first element
    -- to map buttons correctly
    self.uiTblRef.cIcon1 = "uitexture-cas-context1"
    self.uiTblRef.cDesc1 = "STRING_CAS_CONTEXT_1"
    self.uiTblRef.cLocked1 = self:IsContextLocked( contexts[2] .. genderSuffix )

    self.uiTblRef.cIcon2 = "uitexture-cas-context2"
    self.uiTblRef.cDesc2 = "STRING_CAS_CONTEXT_2"
    self.uiTblRef.cLocked2 = self:IsContextLocked( contexts[3] .. genderSuffix )

    self.uiTblRef.cIcon3 = "uitexture-cas-context3"
    self.uiTblRef.cDesc3 = "STRING_CAS_CONTEXT_3"
    self.uiTblRef.cLocked3 = self:IsContextLocked( contexts[4] .. genderSuffix )

    self.uiTblRef.cIcon4 = "uitexture-cas-context4"
    self.uiTblRef.cDesc4 = "STRING_CAS_CONTEXT_4"
    self.uiTblRef.cLocked4 = self:IsContextLocked( contexts[5] .. genderSuffix )

    self.uiTblRef.cancelIcon = "uitexture-flow-cancel"
    self.uiTblRef.cancelTooltip = ""
end

function Classes.UICASContextPicker:LoopInternal()
    local Hit = self.uiTblRef.Hit
    local Context = tonumber( self.uiTblRef.Context )

    if( Context ~= nil ) then
        --- custom code start
        local gender = self.pendingGender or "none"
        if gender ~= Constants.Gender.Male and gender ~= Constants.Gender.Female then
            gender = Luattrib:ReadAttribute( "character", "player", "Gender" )
        end

        local genderSuffix = "m"
        if( gender == Constants.Gender.Male ) then
            genderSuffix = "m"
        elseif( gender == Constants.Gender.Female ) then
            genderSuffix = "f"
        end
        --- custom code end

        local cName = contexts[Context+1] .. genderSuffix
        self.returnValue = cName
        self.bShouldExit = true
    end


    self.uiTblRef.Context = nil

    --Press A actions
    if( Hit == "cancel" ) then
        self.bShouldExit = true
    end

    self.uiTblRef.Hit = nil
end
--}}}