jpsext = {}


function jpsext.provoke()
    RunMacroText("/run local z,t,s={[32099]='Sha of Anger this week.'},GetQuestsCompleted();for c,v in pairs(z) do if t[c] then s='' else s=' not' end print('You have'..s,'done',v) end")
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