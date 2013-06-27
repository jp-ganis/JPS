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

wld = {}
wld.maxIntCastLength = 2.8


local function toSpellName(id) name = GetSpellInfo(id); return name end
local spells = {}
spells["immolate"] = toSpellName(348)
spells["felFlame"] = toSpellName(77799)
spells["backdraft"] = toSpellName(117896)
spells["rainOfFire"] = toSpellName(5740)
spells["darkSoulInstability"] = toSpellName(113858)
spells["havoc"] = toSpellName(80240)
spells["fireAndBrimstone"] = toSpellName(108683)
spells["opticalBlast"] = toSpellName(119911)
spells["spellLock"] = toSpellName(19647)
spells["mortalCoil"] = toSpellName(6789)
spells["createHealthstone"] = toSpellName(6201)
spells["emberTap"] = toSpellName(114635)
spells["curseOfTheElements"] = toSpellName(1490)
spells["felFlame"] = toSpellName(77799)
spells["shadowburn"] = toSpellName(17877)
spells["chaosBolt"] = toSpellName(116858)
spells["incinerate"] = toSpellName(29722)
spells["conflagrate"] = toSpellName(17962)

spells["lifeblood"] = toSpellName(121279)

wld.spells = spells

function wld.hasKilJaedensCunning()
    local selected, talentIndex = GetTalentRowSelectionInfo(6)
    return talentIndex == 17
end


local function npcId(unit)
    return tonumber(UnitGUID(unit):sub(7, 10), 16)
end

-- stop spam curse of the elements at invalid targets @ mop
function wld.isCotEBlacklisted(unit) 
    local table_noSpamCotE = {
        56923, -- Twilight Sapper
        56341, 56575, -- Burning Tendons 4.3.0/5.2.0
        53889, -- Corrupted Blood
        60913, -- Energy Charge
        60793, -- Celestial Protector
    }
    for i,j in pairs(table_noSpamCotE) do
        if npcId(unit) == j then return true end
    end
    return false
end

function wld.isTrivial(unit)
    local minHp = 1000000
    if IsInGroup() or IsInRaid() then minHp = minHp * GetNumGroupMembers() end
    return  UnitHealth(unit) <= minHp
end

function wld.attackFocus()
    return UnitExists("focus") ~= nil and UnitGUID("target") ~= UnitGUID("focus") and not UnitIsFriend("player", "focus")
end

function wld.burningEmbers()
    return UnitPower("player",14)
end

function wld.emberShards()
    return UnitPower("player", 14, true)
end


wld.spellTable = {}
wld.spellTable[1] = jps.compileSpellTable({
["ToolTip"] = "Warlock PvE",
    -- Interrupts
    {spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wld.maxIntCastLength', "target" },
    {spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wld.maxIntCastLength', "focus"},
    {spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wld.maxIntCastLength', "mouseover"},
    {spells.spellLock, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wld.maxIntCastLength', "target" },
    {spells.spellLock, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wld.maxIntCastLength', "focus"},
    {spells.spellLock, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wld.maxIntCastLength', "mouseover"},

    -- Def CD's
    {spells.mortalCoil, 'jps.Defensive and jps.hp() <= 0.80' },
    {spells.createHealthstone, 'jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= wld.spells.createHealthstone'},

    { jps.useBagItem(5512), 'jps.hp("player") < 0.65' }, -- Healthstone
    { spells.emberTap, 'jps.Defensive and jps.hp() <= 0.30 and wld.burningEmbers() > 0' },

    -- Rain of Fire
    { spells.rainOfFire, 'IsShiftKeyDown() and jps.buffDuration(wld.spells.rainOfFire) < 1 and not GetCurrentKeyBoardFocus()'  },
    { spells.rainOfFire, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },
    -- COE Debuff
    { spells.curseOfTheElements, 'not jps.debuff(wld.spells.curseOfTheElements) and not wld.isTrivial("target") and not wld.isCotEBlacklisted("target")' },
    { spells.curseOfTheElements, 'wld.attackFocus() and not jps.debuff(wld.spells.curseOfTheElements, "focus") and not wld.isTrivial("focus") and not wld.isCotEBlacklisted("focus")' , "focus" },
    
    { spells.fireAndBrimstone, 'wld.burningEmbers() > 0 and not jps.buff(wld.spells.fireAndBrimstone, "player") and jps.MultiTarget' },
    { {"macro","/cancelaura "..spells.fireAndBrimstone}, 'jps.buff(wld.spells.fireAndBrimstone, "player") and wld.burningEmbers() == 0' },
    
    { {"macro","/cancelaura "..spells.fireAndBrimstone}, 'jps.buff(wld.spells.fireAndBrimstone, "player") and not jps.MultiTarget' },
    
    -- On the move
    { spells.felFlame, 'jps.Moving and not wld.hasKilJaedensCunning()' },
    
    -- CD's
    { {"macro","/cast " .. spells.darkSoulInstability}, 'jps.cooldown(wld.spells.darkSoulInstability) == 0 and jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },
    { spells.lifeblood, 'jps.UseCDs' },
    { jps.useSynapseSprings(), 'jps.UseCDs' },
    { jps.useTrinket(0),       'jps.UseCDs' },
    { jps.useTrinket(1),       'jps.UseCDs' },
    
    -- Shadowburn mouseover!
    { spells.shadowburn, 'jps.hp("mouseover") < 0.20 and wld.burningEmbers() > 0 and jps.myDebuffDuration(spells.shadowburn, "mouseover")<=0.5', "mouseover"  },

    {"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
        { spells.havoc, 'not IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()', "mouseover" },
        { spells.havoc, 'wld.attackFocus()', "focus" },
        { spells.shadowburn, 'jps.hp("target") <= 0.20 and wld.burningEmbers() > 0'  },
        { spells.chaosBolt, 'wld.burningEmbers() > 0 and  jps.buffStacks(wld.spells.havoc)>=3'},
       jps.dotTracker().castTableStatic("immolate"),
        { spells.conflagrate },
        { spells.chaosBolt, 'jps.buff(wld.spells.darkSoulInstability) and wld.emberShards() >= 19' },
        { spells.chaosBolt, 'jps.TimeToDie("target", 0.2) > 5.0 and wld.burningEmbers() >= 3 and jps.buffStacks(spells.backdraft) < 3'},
        { spells.chaosBolt, 'wld.emberShards() >= 35'},
        { spells.incinerate },
    }},
    
    {"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
        { spells.shadowburn, 'jps.hp("target") <= 0.20 and wld.burningEmbers() > 0'  },
        { spells.conflagrate },
        { spells.felFlame },
    }},
    {"nested", 'jps.MultiTarget', {
        { spells.shadowburn, 'jps.hp("target") <= 0.20 and wld.burningEmbers() > 0'  },
        { spells.immolate , 'jps.buff(wld.spells.fireAndBrimstone, "player") and jps.myDebuffDuration(spells.immolate) <= 2.0 and jps.LastCast ~= wld.spells.immolate'},
        { spells.conflagrate, 'jps.buff(wld.spells.fireAndBrimstone, "player")' },
        { spells.incinerate },
    }},
})
wld.spellTable[2] = jps.compileSpellTable({
["ToolTip"] = "Interrupt Only",
    {spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wld.maxIntCastLength', "target" },
    {spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wld.maxIntCastLength', "focus"},
    {spells.opticalBlast, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wld.maxIntCastLength', "mouseover"},
    {spells.spellLock, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < wld.maxIntCastLength', "target" },
    {spells.spellLock, 'jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < wld.maxIntCastLength', "focus"},
    {spells.spellLock, 'jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < wld.maxIntCastLength', "mouseover"},
})

function warlock_destro()   
    if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
        SpellStopCasting()
        jps.NextSpell = {}
    end
    
    return parseStaticSpellTable(wld.spellTable[1])
end