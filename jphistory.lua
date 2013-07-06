local jphistory = {}

jphistory.castFrames = {}
jphistory.textWidth = 120
jphistory.targetWidth = 50
jphistory.rowHeight = 15
jphistory.frameWidth = jphistory.textWidth + jphistory.targetWidth + jphistory.rowHeight
jphistory.width = 150
jphistory.thisSpell = nil
jphistory.updateInterval = 0.05
jphistory.isCasting = false
jphistory.target = nil
jphistory.lastSpellLineId = 0
jphistory.showNext = false

jps.registerEvent("UNIT_SPELLCAST_SUCCEEDED", function(unit,spellName,rank,lineId,spellId)
    -- lineId is 0 for ticks!
    if unit=="player" and lineId > 1 and lineId ~= jphistory.lastSpellLineId then
        jphistory.addSpellEvent(spellId)
        jphistory.isCasting = false
        jphistory.lastSpellLineId = lineId
    end
end)

jps.registerEvent("UNIT_SPELLCAST_START", function(unit,spellName,rank,lineId,spellId)
    jphistory.isCasting = true
end)
jps.registerEvent("UNIT_SPELLCAST_FAILED", function(unit,spellName,rank,lineId,spellId)
    jphistory.isCasting = false
end)

--[[


function SampleTrackerFunctions.UNIT_SPELLCAST_START()
  is_casting = true
end
----
function SampleTrackerFunctions.UNIT_SPELLCAST_FAILED()
  is_casting = false
end
]]

function cooldownLeft(spellName)
    local spellID = nil
    if spellName == nil then spellID = 61304 end
    if spellID == nil then
        local spellID = GetSpellID(spellName)
    end

    local minValue = 0.05
    local maxValue = 0.3
    local curPing = tonumber((select(3, GetNetStats()) + select(4, GetNetStats())) / 1000) + .025

    if curPing < minValue then
        curPing = minValue
    elseif curPing > maxValue then
        curPing = maxValue
    end

    local cdStart, duration = GetSpellCooldown(spellID)
    if cdStart == 0 then return 0 end
    local timeLeft = duration - (GetTime() - cdStart )
    if timeLeft < 0 then timeLeft = 0 end
    return timeLeft, duration
end



jphistory.maxSize = 10
jphistory.history = RingBuffer:init(jphistory.maxSize,{})

function jphistory.update(self, elapsed)
    if self.TimeSinceLastUpdate == nil then self.TimeSinceLastUpdate = 0 end
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
    if (self.TimeSinceLastUpdate > jphistory.updateInterval) then
        self.TimeSinceLastUpdate = 0
        if jphistory.showNext then
            -- Next Cast
            local nextCast, nextTarget = jps.Rotation()
            local cf = jphistory.castFrames[1]
            if not nextTarget then nextTarget = "target" end
            if nextCast then
                name, _, icon = GetSpellInfo(nextCast)
                cf.frame:Show()
                cf.text:SetText(name)
                cf.target:SetText(nextTarget)
                cf.texture:SetTexture(icon)
            else
                cf.frame:Hide()
            end
        end
        
        local cf = jphistory.castFrames[2]
        if UnitCastingInfo("player") or UnitChannelInfo("player") then
            --jphistory.thisSpell
            local name, _, _, icon, startTime, endTime = UnitCastingInfo("player")
            if not name then
                name, _, _, icon, startTime, endTime = UnitChannelInfo("player")
            end
            local duration = endTime/1000-startTime/1000
            local castLeft = endTime/1000-GetTime()
            local percentDone = 100 - castLeft / duration * 100
            cf.frame:Show()
            cf.text:SetText(name .. " " ..math.floor( castLeft * 10) / 10)
            --XXX: cf.target:SetText(jphistory.thisSpell.target)
            cf.texture:SetTexture(icon)
            cf.frame:SetValue(percentDone)
        else
            local gcdLeft, gcdTotal = cooldownLeft()
            if gcdLeft > 0 then
                name, _, icon = GetSpellInfo(61304)
                cf.frame:Show()
                cf.text:SetText("GCD " .. math.floor( (gcdTotal-gcdLeft) * 10) / 10)
                cf.target:SetText(jps.ThisTarget)
                cf.texture:SetTexture(icon)
                cf.frame:SetValue((gcdTotal-gcdLeft)/gcdTotal * 100)
            else
            --"Interface\\CastingBar\\UI-CastingBar-Small-Shield")
                cf.frame:Hide()
            end
        end
    
        -- History Cast's
        local i = 3
        for spell in jphistory.history:iterator() do
            local cf = jphistory.castFrames[i]
            i = i+1
            if spell then
                cf.frame:Show()
                cf.text:SetText(spell.name)
                cf.target:SetText(spell.target)
                cf.texture:SetTexture(spell.icon)
            else
                cf.frame:Hide()
            end
        end
    end
end



function jphistory.createCastFrame(idx)
    local frame = CreateFrame("StatusBar","jpsHistoryCast" .. idx, jphistory.frame)
    
    frame:SetBackdrop({
           bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", 
           tile=1, tileSize=32, edgeSize=0, 
           insets={left=0, right=0, top=0, bottom=0}
     })
    frame:SetBackdropColor(0,0,0,1);
     
    frame:SetWidth(jphistory.frameWidth)
    frame:SetHeight(jphistory.rowHeight)
    frame:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    frame:GetStatusBarTexture():SetHorizTile(false)
    frame:GetStatusBarTexture():SetVertTile(false)
    frame:SetStatusBarColor(0, 0.43, 0.78)
    frame:SetMinMaxValues(0,100)
    frame:SetValue(0)
    frame:SetPoint("TOPLEFT",jphistory.frame,"TOPLEFT",0, -1 * (idx-1) * jphistory.rowHeight)
    local texture = frame:CreateTexture(nil, "OVERLAY")
    texture:SetWidth(jphistory.rowHeight)
    texture:SetHeight(jphistory.rowHeight)
    texture:SetPoint("LEFT",frame)
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT",frame, jphistory.rowHeight, 0)
    text:SetWidth(jphistory.textWidth)
    text:SetHeight(jphistory.rowHeight)

    local target = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    target:SetPoint("LEFT",frame, jphistory.rowHeight + jphistory.textWidth, 0)
    --target:SetJustifyH("LEFT")
    target:SetWidth(jphistory.targetWidth)
    target:SetHeight(jphistory.rowHeight)
    return {frame=frame, texture=texture, text=text, target=target}
end

function jphistory.createAllCastFrames()
    jphistory.frame = CreateFrame("frame","JPHistory")
    jphistory.frame:SetBackdrop({
               bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", 
               tile=1, tileSize=32, edgeSize=0, 
               insets={left=0, right=0, top=0, bottom=0}
         })

    jphistory.frame:SetWidth(jphistory.frameWidth)
    jphistory.frame:SetHeight(jphistory.rowHeight*(jphistory.maxSize+2))
    jphistory.frame:SetPoint("CENTER",UIParent)
    jphistory.frame:EnableMouse(true)
    jphistory.frame:SetMovable(true)
    jphistory.frame:RegisterForDrag("LeftButton")
    jphistory.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    jphistory.frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    jphistory.frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    jphistory.frame:SetFrameStrata("FULLSCREEN_DIALOG")
    jphistory.frame:SetScript("OnUpdate", jphistory.update)

    for i = 1,jphistory.maxSize+2 do
        jphistory.castFrames[i] = jphistory.createCastFrame(i)
    end
    
    jphistory.titleFrame = CreateFrame("frame","jpsHistoryTitle")
    jphistory.titleFrame:SetWidth(jphistory.frameWidth)
    jphistory.titleFrame:SetHeight(jphistory.rowHeight)
    jphistory.titleFrame:SetPoint("TOPLEFT",jphistory.frame,"TOPLEFT",0, jphistory.rowHeight)
    jphistory.titleFrame:Show()
    
    jphistory.spellTitle = jphistory.titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jphistory.spellTitle:SetPoint("LEFT",jphistory.titleFrame, jphistory.rowHeight, 0)
    jphistory.spellTitle:SetWidth(jphistory.textWidth)
    jphistory.spellTitle:SetHeight(jphistory.rowHeight)
    jphistory.spellTitle:SetText("Cast")
    jphistory.spellTitle:Show()
    
    jphistory.targetTitle = jphistory.titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jphistory.targetTitle:SetPoint("LEFT",jphistory.titleFrame, jphistory.rowHeight + jphistory.textWidth, 0)
    --target:SetJustifyH("LEFT")
    jphistory.targetTitle:SetWidth(jphistory.targetWidth)
    jphistory.targetTitle:SetHeight(jphistory.rowHeight)
    jphistory.targetTitle:SetText("Target")
    jphistory.targetTitle:Show()
    
    jphistory.nextTitle = jphistory.titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jphistory.nextTitle:SetPoint("LEFT",jphistory.titleFrame, -105, -1 * jphistory.rowHeight)
    jphistory.nextTitle:SetJustifyH("RIGHT")
    jphistory.nextTitle:SetWidth(100)
    jphistory.nextTitle:SetHeight(jphistory.rowHeight)
    jphistory.nextTitle:SetText("Next:")
    jphistory.nextTitle:Show()
    
    jphistory.currentTitle = jphistory.titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jphistory.currentTitle:SetPoint("LEFT",jphistory.titleFrame, -105, -2 * jphistory.rowHeight)
    jphistory.currentTitle:SetJustifyH("RIGHT")
    jphistory.currentTitle:SetWidth(100)
    jphistory.currentTitle:SetHeight(jphistory.rowHeight)
    jphistory.currentTitle:SetText("Current:")
    jphistory.currentTitle:Show()
    
    jphistory.lastTitle = jphistory.titleFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    jphistory.lastTitle:SetPoint("LEFT",jphistory.titleFrame, -105, -3 * jphistory.rowHeight)
    jphistory.lastTitle:SetJustifyH("RIGHT")
    jphistory.lastTitle:SetWidth(100)
    jphistory.lastTitle:SetHeight(jphistory.rowHeight)
    jphistory.lastTitle:SetText("Last:")
    jphistory.lastTitle:Show()
    
    
end
jphistory.createAllCastFrames()



function jphistory.updateTarget(target)
    if not isCasting then
        jphistory.target = target
    end
end
--[[
function jphistory.addSpell(spellname, target)
    local name, _, icon = GetSpellInfo(spellname)
    local spell = jphistory.history:next()
    spell.name =name
    spell.icon = icon
    spell.target = target
    jphistory.history:rotate()
end
]]

function jphistory.addSpellEvent(spellId)
    local name, _, icon = GetSpellInfo(spellId)
    local spell = jphistory.history:next()
    spell.name = name
    spell.icon = icon
    spell.target = jphistory.target
    jphistory.history:rotate()
end


jps.history = jphistory
