jpsext = {}

jpsext.timeToDieData = {}
jpsext.timeToDieLastUpdate = 100
jpsext.timeToDieThrottle = 0.1
jpsext.timeToDieMinSamples = 20
jpsext.timeToDieMaxSamples = 30



local JPSEXTInfoFrame = CreateFrame("frame","JPSEXTInfoFrame")
JPSEXTInfoFrame:SetBackdrop({
      bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", 
      tile=1, tileSize=32, edgeSize=32, 
      insets={left=11, right=12, top=12, bottom=11}
})
JPSEXTInfoFrame:SetWidth(150)
JPSEXTInfoFrame:SetHeight(60)
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
infoFrameText:SetText("TTL: n/a\nDPS: n/a")
local infoDPS = 0.0
local infoTTL = nil
local infoTTLBurst = nil

function jpsext.provoke()
    RunMacroText("/run local z,t,s={[32099]='Sha of Anger this week.'},GetQuestsCompleted();for c,v in pairs(z) do if t[c] then s='' else s=' not' end print('You have'..s,'done',v) end")
end

function jpsext.updateInfoText()
    if infoTTL ~= nil then
        infoFrameText:SetText(string.format("TTL: %.1f\nTTL Burst: %.1f\nDPS: %.1f", infoTTL, infoTTLBurst, infoDPS))
    else 
        infoFrameText:SetText("TTL: n/a\nTTL Burst: n/a\nDPS: n/a")
    end 
end


function jpsext.updatetimeToDie(self, elapsed)
    jpsext.timeToDieLastUpdate = jpsext.timeToDieLastUpdate + elapsed
    if jps.Combat and jpsext.timeToDieLastUpdate > jpsext.timeToDieThrottle then
        jpsext.timeToDieLastUpdate = 0
        if UnitExists("target") then
            jpsext.updateUnittimeToDie("target")
        end
        if UnitExists("focus") and UnitGUID("focus") ~= UnitGUID("target") then
            jpsext.updateUnittimeToDie("focus")
        end
        if UnitExists("mouseover") and UnitGUID("focus") ~= UnitGUID("mouseover") and UnitGUID("mouseover") ~= UnitGUID("target") then
            jpsext.updateUnittimeToDie("mouseover")
        end
        infoTTL = jpsext.timeToDie("target")
        infoTTLBurst = jpsext.timeToDie("target", 0.2)
        jpsext.updateInfoText()
    end
end

JPSEXTFrame = CreateFrame("Frame", "JPSEXTFrame")
JPSEXTFrame:SetScript("OnUpdate", function(self, elapsed)
    jpsext.updatetimeToDie(self, elapsed)
end)
JPSEXTFrame:SetScript("OnEvent", function(self, event, ...) 
    if event == "PLAYER_REGEN_DISABLED" then
        -- Combat Start
    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Out of Combat
        jpsext.cleartimeToDie()
    end
end)
JPSEXTFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
JPSEXTFrame:RegisterEvent("PLAYER_REGEN_DISABLED")


function jpsext.updateUnittimeToDie(unit)
    local guid = UnitGUID(unit)
    if jpsext.timeToDieData[guid] == nil then
        jpsext.timeToDieData[guid] = {}
    end
    dataset = jpsext.timeToDieData[guid]
    if table.getn(dataset) >= jpsext.timeToDieMaxSamples then
        table.remove(dataset, jpsext.timeToDieMaxSamples)
    end
    local avgDps = nil
    if #dataset >= 2 then
        local timeDelta = dataset[1][1] - dataset[table.getn(dataset)][1]
        local hpDelta = dataset[table.getn(dataset)][2] - dataset[1][2]
        avgDps = hpDelta / timeDelta
    end
    table.insert(dataset, 1, {GetTime(), UnitHealth(unit), avgDps})
    jpsext.timeToDieData[guid] = dataset
end

function jpsext.cleartimeToDie()
    jpsext.timeToDieData = {}
end

function jpsext.calcDatasetDPS(dataset)
    local sum = 0
    local count = 0
    for i,v in ipairs(dataset) do
        if v[3] ~= nil then
            sum = sum + v[3]
            count = count + 1
        end
    end
    if count > 0 then
        infoDPS = sum/count
        return sum/count
    else
        infoDPS = -1.0
        return nil
    end
end

function jpsext.timeToDie(unit, percent)
    local guid = UnitGUID(unit)
    if percent ~= nil then targetHP = UnitHealthMax(unit) end
    if guid ~= nil and jpsext.timeToDieData[guid] ~= nil then
        local dataset = jpsext.timeToDieData[guid]
        if #dataset <= jpsext.timeToDieMinSamples then return nil end

        local avgDps = jpsext.calcDatasetDPS(dataset)
        if avgDps == nil then return nil end
        
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
    local targetInRange = IsSpellInRange(kickSpell, "target")
    local focusInRange = IsSpellInRange(kickSpell, "focus")
    
    local kickTarget, stopCastForTarget = jpsext.checkForInterrupt("target", kickCastLeft)
    local kickFocus, stopCastForFocus = jpsext.checkForInterrupt("focus", kickCastLeft)
    --local kickMouseover, stopCastForMouseover = jpsext.checkForInterrupt("mouseover", kickCastLeft)
    kickTarget = kickTarget and targetInRange
    kickFocus = kickFocus and focusInRange
    local kickSpellTable = {
        {kickSpell, kickTarget, "target"},
        {kickSpell, kickFocus, "focus"},
        --{kickSpell, kickMouseover, "mouseover"},
    }
    
    --if stopCastForTarget or stopCastForFocus or stopCastForMouseover then
    if (stopCastForTarget and targetInRange) or (stopCastForFocus and focusInRange) then
        SpellStopCasting()
    end
    
    -- return {"nested",(kickTarget or kickFocus or kickMouseover),kickSpellTable}
    return {"nested",(kickTarget or kickFocus),kickSpellTable}
end

function jpsext.checkForInterrupt(target, kickCastLeft)
--  IsSpellInRange("Pummel", "target")==1 !!!!
    local canAttack = UnitCanAttack("player", target)
    local playerCastTimeLeft = jps.CastTimeLeft("player") + 1
    local enemyCastTimeLeft = jps.CastTimeLeft(target)
    local targetIsCasting = playerCastTimeLeft > 0
    local _, _, _, _, _, _, _, _, unInterruptable = UnitCastingInfo(target)
    local needStopCast = not unInterruptable and canAttack and targetIsCasting and enemyCastTimeLeft-kickCastLeft < playerCastTimeLeft
    return (not unInterruptable and targetIsCasting and canAttack and enemyCastTimeLeft < kickCastLeft), needStopCast
end

function jpsext.healthstone(percent)
    healthStoneId = 5512
    local healthstoneCharges = GetItemCount(healthStoneId, false, true)
    local startTime, duration, enable = GetItemCooldown(healthStoneId)
    local onCooldown = startTime > 0
    return {{"macro","/use item:" .. healthStoneId}, healthstoneCharges > 0 and jps.hp() < percent and not onCooldown}
end