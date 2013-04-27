jpsext = {}

function jpsext.interruptSpellTable(kickSpell,kickCastLeft)
    local kickAvailable = jps.cooldown(kickSpell) == 0
    if not jps.Interrupts or not kickAvailable then return {"nested", false, nil} end
    
    local kickTarget, stopCastForTarget = jpsext.checkForInterrupt("target", kickCastLeft)
    local kickFocus, stopCastForFocus = jpsext.checkForInterrupt("focus", kickCastLeft)
    local kickMouseover, stopCastForMouseover = jpsext.checkForInterrupt("mouseover", kickCastLeft)
    
    local kickSpellTable = {
        {kickSpell, kickTarget, "target"},
        {kickSpell, kickFocus, "focus"},
        {kickSpell, kickMouseover, "mouseover"},
    }
    
    if stopCastForTarget or stopCastForFocus or stopCastForMouseover then
        SpellStopCasting()
    end
    
    return {"nested",(kickTarget or kickFocus or kickMouseover),kickSpellTable}
end

function jpsext.checkForInterrupt(target,kickCastLeft)
    local isFriend = UnitIsFriend("player", target)
    local castTimeLeft = jps.castTimeLeft(target)
    local targetIsCasting = castTimeLeft > 0
    local needStopCast = targetIsCasting and castTimeLeft <= (jps.castTimeLeft("player") + 0.5)
    return (targetIsCasting and not isFriend and castTimeLeft < kickCastLeft), needStopCast
end