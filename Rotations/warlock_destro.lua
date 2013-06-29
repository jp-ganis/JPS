--[[
Warlock Destruction Rotations:

Warlock PvE Rotation:
 * SHIFT: Cast Rain of Fire @ Mouse - ONLY if RoF Duration is less than 1 seconds
 * CTRL-SHIFT: Cast Rain of Fire @ Mouse - ignoring the current RoF duration
 * CTRL: Havoc @ Mouse
 * ALT: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)
 * jps.Interrupts - Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)
 * jps.Defensive - Create Healthstone if necessary, cast mortal coil and use ember tap
 * jps.UseCDs - use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated!

Interrupt Only:
 * Interrupt target, focus or mouseover with FelHunter or Observer only (you still need to check jps.Interrupt!)

Known Bugs:
 * [ADDON_ACTION_FORBIDDEN] AddOn "JPS" tried to call the protected function "CameraOrSelectOrMoveStop()".
    This will occur regulary if you cast Rain of Fire while moving...still works so it's just annoying


]]--

local spellTable = {}
spellTable[1] = {
["ToolTip"] = "Warlock PvE",
    -- Interrupts
    {wl.spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wl.maxIntCastLength', "target" },
    {wl.spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wl.maxIntCastLength', "focus"},
    {wl.spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wl.maxIntCastLength', "mouseover"},
    {wl.spells.spellLock, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wl.maxIntCastLength', "target" },
    {wl.spells.spellLock, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wl.maxIntCastLength', "focus"},
    {wl.spells.spellLock, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wl.maxIntCastLength', "mouseover"},

    -- Def CD's
    {wl.spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
    {wl.spells.createHealthstone, 'jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wl.spells.createHealthstone'},
    {jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
    {wl.spells.emberTap, 'jps.Defensive and jps.hp() <= 0.30 and jps.burningEmbers() > 0' },

    -- Rain of Fire
    {wl.spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wl.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'  },
    {wl.spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },
    -- COE Debuff
    {wl.spells.curseOfTheElements, 'not jps.debuff(wl.spells.curseOfTheElements) and not wl.isTrivial("target") and not wl.isCotEBlacklisted("target")' },
    {wl.spells.curseOfTheElements, 'wl.attackFocus() and not jps.debuff(wl.spells.curseOfTheElements, "focus") and not wl.isTrivial("focus") and not wl.isCotEBlacklisted("focus")' , "focus" },
    
    {wl.spells.fireAndBrimstone, 'jps.burningEmbers() > 0 and not jps.buff(wl.spells.fireAndBrimstone, "player") and jps.MultiTarget' },
    { {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.burningEmbers() == 0' },
    
    { {"macro","/cancelaura "..wl.spells.fireAndBrimstone}, 'jps.buff(wl.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },
    
    -- On the move
    {wl.spells.felFlame, 'jps.Moving and not wl.hasKilJaedensCunning()' },
    
    -- CD's
    { {"macro","/cast " .. wl.spells.darkSoulInstability}, 'jps.cooldown(wl.spells.darkSoulInstability) == 0 and jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },
    {wl.spells.lifeblood, 'jps.UseCDs' },
    { jps.useSynapseSprings(), 'jps.UseCDs' },
    { jps.useTrinket(0),       'jps.UseCDs' },
    { jps.useTrinket(1),       'jps.UseCDs' },
    
    -- Shadowburn mouseover!
    {wl.spells.shadowburn, 'jps.hp("mouseover") < 0.20 and jps.burningEmbers() > 0 and jps.myDebuffDuration(wl.spells.shadowburn, "mouseover")<=0.5', "mouseover"  },

    {"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
        {wl.spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
        {wl.spells.havoc, 'wl.attackFocus()', "focus" },
        {wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
        {wl.spells.chaosBolt, 'jps.burningEmbers() > 0 and  jps.buffStacks(wl.spells.havoc)>=3'},
        jps.dotTracker.castTableStatic("immolate"),
        {wl.spells.conflagrate },
        {wl.spells.chaosBolt, 'jps.buff(wl.spells.darkSoulInstability) and jps.emberShards() >= 19' },
        {wl.spells.chaosBolt, 'jps.TimeToDie("target", 0.2) > 5.0 and jps.burningEmbers() >= 3 and jps.buffStacks(wl.spells.backdraft) < 3'},
        {wl.spells.chaosBolt, 'jps.emberShards() >= 35'},
        {wl.spells.incinerate },
    }},
    
    {"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
        {wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
        {wl.spells.conflagrate },
        {wl.spells.felFlame },
    }},
    {"nested", 'jps.MultiTarget', {
        {wl.spells.shadowburn, 'jps.hp("target") <= 0.20 and jps.burningEmbers() > 0'  },
        {wl.spells.immolate , 'jps.buff(wl.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(wl.spells.immolate) <= 2.0 and jps.LastCast ~= wl.spells.immolate'},
        {wl.spells.conflagrate, 'jps.buff(wl.spells.fireAndBrimstone, "player")' },
        {wl.spells.incinerate },
    }},
}
spellTable[2] = {
["ToolTip"] = "Interrupt Only",
    {wl.spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wl.maxIntCastLength', "target" },
    {wl.spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wl.maxIntCastLength', "focus"},
    {wl.spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wl.maxIntCastLength', "mouseover"},
    {wl.spells.spellLock, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wl.maxIntCastLength', "target" },
    {wl.spells.spellLock, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wl.maxIntCastLength', "focus"},
    {wl.spells.spellLock, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wl.maxIntCastLength', "mouseover"},
}



function warlock_destro()   
    if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
        SpellStopCasting()
        jps.NextSpell = {}
    end

    return parseStaticSpellTable(jps.RotationActive(spellTable))
end