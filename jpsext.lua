jpsext = {}

jpsext.timeToLiveData = {}
jpsext.timeToLiveLastUpdate = 100
jpsext.timeToLiveThrottle = 0.1
jpsext.timeToLiveMinAge = 1.0
jpsext.timeToLiveMaxAge = 7.0
jpsext.timeToLiveMaxSamples = 60


local JPSEXTInfoFrame = CreateFrame("frame","JPSEXTInfoFrame")
JPSEXTInfoFrame:SetBackdrop({
      bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", 
      tile=1, tileSize=32, edgeSize=32, 
      insets={left=11, right=12, top=12, bottom=11}
})
JPSEXTInfoFrame:SetWidth(100)
JPSEXTInfoFrame:SetHeight(50)
JPSEXTInfoFrame:SetPoint("CENTER",UIParent)
JPSEXTInfoFrame:EnableMouse(true)
JPSEXTInfoFrame:SetMovable(true)
JPSEXTInfoFrame:RegisterForDrag("LeftButton")
JPSEXTInfoFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
JPSEXTInfoFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
JPSEXTInfoFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
JPSEXTInfoFrame:SetFrameStrata("FULLSCREEN_DIALOG")
local infoFrameText = JPSEXTInfoFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
infoFrameText:SetPoint("CENTER")
infoFrameText:SetText("TTL: n/a")



JPSEXTFrame = CreateFrame("Frame", "JPSEXTFrame")
JPSEXTFrame:SetScript("OnUpdate", function(self, elapsed)
    jpsext.updateTimeToLive(self, elapsed)
end)
JPSEXTFrame:SetScript("OnEvent", function(self, event, ...) 
    if event == "PLAYER_REGEN_DISABLED" then
        -- Combat Start
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Out of Combat
        jpsext.clearTimeToLive()
    end
end)
JPSEXTFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
JPSEXTFrame:RegisterEvent("PLAYER_REGEN_DISABLED")




function jpsext.updateTimeToLive(self, elapsed)
    jpsext.timeToLiveLastUpdate = jpsext.timeToLiveLastUpdate + elapsed
    if jps.Combat and jpsext.timeToLiveLastUpdate > jpsext.timeToLiveThrottle then
        jpsext.timeToLiveLastUpdate = 0
        if UnitExists("target") then
            jpsext.updateUnitTimeToLive("target")
        end
        if UnitExists("focus") and UnitGUID("focus") ~= UnitGUID("target") then
            jpsext.updateUnitTimeToLive("focus")
        end
        if UnitExists("mouseover") and UnitGUID("focus") ~= UnitGUID("mouseover") and UnitGUID("mouseover") ~= UnitGUID("target") then
            jpsext.updateUnitTimeToLive("mouseover")
        end
        ttl = jpsext.timeToLive("target")
        if ttl ~= nil then
            infoFrameText:SetText(string.format("TTL: %.1f", ttl))
        else 
            infoFrameText:SetText("TTL: n/a")
        end 
    end
end

function jpsext.updateUnitTimeToLive(unit)
    local guid = UnitGUID(unit)
    if jpsext.timeToLiveData[guid] == nil then
        jpsext.timeToLiveData[guid] = {}
    end
    dataset = jpsext.timeToLiveData[guid]
    if table.getn(dataset) >= jpsext.timeToLiveMaxSamples then
        table.remove(dataset, jpsext.timeToLiveMaxSamples)
    end
    
    local timeDelta = dataset[1][1] - dataset[table.getn(dataset)][1]
    local hpDelta = dataset[table.getn(dataset)][2] - dataset[1][2]
    local avgDps = hpDelta / timeDelta
    table.insert(dataset, 1, {GetTime(), UnitHealth(unit), avgDps})
    jpsext.timeToLiveData[guid] = dataset
end

function jpsext.clearTimeToLive()
    jpsext.timeToLiveData = {}
end

function jpsext.timeToLive(unit, percent)
    local guid = UnitGUID(unit)
    if percent ~= nil then targetHP = UnitHealthMax(unit) end
    if guid ~= nil and jpsext.timeToLiveData[guid] ~= nil then
        local dataset = jpsext.timeToLiveData[guid]
        
        local timeDelta = dataset[1][1] - dataset[table.getn(dataset)][1]
        if timeDelta < jpsext.timeToLiveMinAge or timeDelta > jpsext.timeToLiveMaxAge then
            return nil
        end
        local hpDelta = dataset[table.getn(dataset)][2] - dataset[1][2]
        if hpDelta <= 0 then
            return nil
        end
        local avgDps = hpDelta / timeDelta
        
        local targetHP = 0
        if percent ~= nil then targetHP = UnitHealthMax(unit) * percent end
        local hpLeft = UnitHealth(unit) - targetHP
        if hpLeft <= 0 then
            return 0.0
        end
        
        return hpLeft / avgDps
    else
        return nil
    end
end

function jpsext.interruptSpellTable(kickSpell,kickCastLeft)
    local kickAvailable = jps.cooldown(kickSpell) == 0
    if not jps.Interrupts or not kickAvailable then return {"nested", false, nil} end
    
    local kickTarget, stopCastForTarget = jpsext.checkForInterrupt("target", kickCastLeft)
    local kickFocus, stopCastForFocus = jpsext.checkForInterrupt("focus", kickCastLeft)
    --local kickMouseover, stopCastForMouseover = jpsext.checkForInterrupt("mouseover", kickCastLeft)
    
    local kickSpellTable = {
        {kickSpell, kickTarget, "target"},
        {kickSpell, kickFocus, "focus"},
        --{kickSpell, kickMouseover, "mouseover"},
    }
    
    --if stopCastForTarget or stopCastForFocus or stopCastForMouseover then
    if stopCastForTarget or stopCastForFocus then
        SpellStopCasting()
    end
    
    -- return {"nested",(kickTarget or kickFocus or kickMouseover),kickSpellTable}
    return {"nested",(kickTarget or kickFocus),kickSpellTable}
end

function jpsext.checkForInterrupt(target,kickCastLeft)
    local isFriend = UnitIsFriend("player", target)
    local castTimeLeft = jps.castTimeLeft(target)
    local targetIsCasting = castTimeLeft > 0
    local needStopCast = not isFriend and targetIsCasting and castTimeLeft <= (jps.castTimeLeft("player") + 1)
    return (targetIsCasting and not isFriend and castTimeLeft < kickCastLeft), needStopCast
end

function jpsext.healthstone(percent)
    healthStoneId = 5512
    local healthstoneCharges = GetItemCount(healthStoneId, false, true)
    local startTime, duration, enable = GetItemCooldown(healthStoneId)
    local onCooldown = startTime > 0
    return {{"macro","/use item:" .. healthStoneId}, healthstoneCharges > 0 and jps.hp() < percent and not onCooldown}
end