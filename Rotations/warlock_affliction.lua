--[[
Warlock Affliction Rotations:

Warlock PvE Rotation:
 * ALT: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)
 * jps.Interrupts - Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)
 * jps.Defensive - Create Healthstone if necessary, cast mortal coil
 * jps.UseCDs - use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated!

Interrupt Only:
 * Interrupt target, focus or mouseover with FelHunter or Observer only (you still need to check jps.Interrupt!)


]]--





-- Returns the status of the three dots on the given unit - returns: oneDotMissing, allDotsMissing
local function getDotStatus(unit)
    local dotTracker = jps.dotTracker
    local castCorruption = jps.dotTracker.shouldSpellBeCast("corruption" ,unit)
    local castAgony = jps.dotTracker.shouldSpellBeCast("agony", unit)
    local castUnstableAffliction = jps.dotTracker.shouldSpellBeCast("unstableAffliction", unit)
    return (castCorruption or castAgony or castUnstableAffliction), (castCorruption and castAgony and castUnstableAffliction)
end

-- checks if the given unit (or all dottableUnits) are possible targets for soulburn/soulswap
local function isSoulburnSoulSwapTarget(unit)
    local shards = UnitPower("player", 7)
    local attackFocus = false
    local attackMouseOver = false
    local burnPhase = jps.hp("target") <= 0.20;
    
        -- If focus exists and is not the same as target, consider attacking focus too
    if not UnitExists(unit) or UnitIsFriend("player", unit) then
        return false
    end

    
    local oneDotMissing, allDotsMissing = getDotStatus(unit)
    local castSoulburn = false
    if unit == "target" and burnPhase then
        -- if we're in the burn phase, and at least 1 needs to refreshed do it - but only on the target
        if oneDotMissing and shards >= 1 then
            castSoulburn = true
        end
    elseif allDotsMissing then
        -- since soulburn mouseover is a bit risky, only do it at 4 shards
        if unit == "mouseover" then
            if shards > 3 then
            castSoulburn = true
            end
        -- every other target can be recasted with at least 2 shards left
        elseif shards >= 2 then
            castSoulburn = true
        end
    end

    -- Don't cast soulburn is last cast was soulswap!
    return castSoulburn and not jps.isRecast(wl.spells.soulSwap, unit)
end


function wl.soulburnSoulSwapTable()
    local soulburnTable = {wl.spells.soulburn,false}
    local soulSwapTable = {wl.spells.soulSwap, false}
    --local cancelSoulburnTable = {{"macro","/cancelaura "..wl.spells.soulburn}, true}
    local function setTable(tbl,condition,target) tbl[2] = condition; tbl[3] = target; return tbl end
    
    return function()
        for i, dottableUnit in ipairs(wl.dottableUnits) do
            if isSoulburnSoulSwapTarget(dottableUnit) then
                if jps.buffDuration(wl.spells.soulburn) > 0 then
                    -- If we are not soulburned, cast soulburn
                    return setTable(soulburnTable,true,unit)
                else
                    -- If we are alredy soulburned, cast soulswap
                    return setTable(soulSwapTable,true,unit)
                end
            end 
        end
        return setTable(soulburnTable,false,"target")
    end
end


-- aborts channeling spells, if necessary
local function cancelChannelingIfNecessary()
    local targetTimeToDie = jps.TimeToDie("target") or 0
    local stopChanneling = false
    local burnPhase = jps.hp("target") <= 0.20
    if UnitChannelInfo("player") ~= nil and burnPhase and targetTimeToDie > 10 then
        local hauntDuration = jps.myDebuffDuration(wl.spells.haunt, "target")
        local shards = UnitPower("player", 7)
        if hauntDuration < 1.5 and shards >= 1 and not jps.isRecast(wl.spells.haunt,"target") then
            stopChanneling = true
        elseif shards >= 1 then
            local _, allDotsMissing = getDotStatus("target")
            if allDotsMissing then stopChanneling = true end
        end
    elseif UnitChannelInfo("player") == wl.spells.maleficGrasp then
        if targetTimeToDie <= 5 then
            stopChanneling = true
        elseif UnitClassification("target") == "worldboss" or UnitClassification("target") == "elite" then
            local oneDotMissing, allDotsMissing = getDotStatus("target")
            if oneDotMissing then stopChanneling = true end
        end
        -- Clip last tick...
        local haste = GetRangedHaste()
        local tickEvery = 1/(1+(haste/100))
        if jps.ChannelTimeLeft("player") < tickEvery then
            stopChanneling = true
        end
    end
    if stopChanneling then
        SpellStopCasting()
        jps.NextSpell = {}
    end
end


-- checks whether a unit has seed of curruption or soulburned seed of corruption
function wl.socDuration(unit,soulburned)
    local hasSoC, hasSoulburnSoC = false
    local durationSoC, durationSoulburnSoC = 0
    for i=1,40 do 
        local _, _, _, _, _, _, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i)
        local duration = 0
        if expirationTime~=nil then
            duration = expirationTime-GetTime()
            if duration < 0 then duration = 0 end
        end
        if not soulburned and spellId==27243 and caster=="player" then -- Default SoC
            return duration
        elseif soulburned and spellId==114790 and caster=="player" then -- Soulburn SoC
            return duration
        end
    end
    return 0
end



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

    -- COE Debuff
    {"nested", 'not jps.MultiTarget and jps.buffDuration(wl.spells.soulburn) == 0', {
        { wl.spells.curseOfTheElements, 'not jps.debuff(wl.spells.curseOfTheElements) and not wl.isTrivial("target") and not wl.isCotEBlacklisted("target")'},
        { wl.spells.curseOfTheElements, 'wl.attackFocus() and not jps.debuff(wl.spells.curseOfTheElements, "focus") and not wl.isTrivial("focus") and not wl.isCotEBlacklisted("focus")', "focus" },
    }},

    -- CD's
    { {"macro","/cast " .. wl.spells.darkSoulMisery}, 'jps.cooldown(wl.spells.darkSoulMisery) == 0 and jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },
    { wl.spells.lifeblood, 'jps.UseCDs' },
    { jps.useSynapseSprings(), 'jps.UseCDs' },
    { jps.useTrinket(0),       'jps.UseCDs' },
    { jps.useTrinket(1),       'jps.UseCDs' },

    {"nested", 'not jps.MultiTarget and not IsAltKeyDown()', {
        -- On the move
        { wl.spells.felFlame, 'jps.Moving and not wl.hasKilJaedensCunning() and jps.mana() > 0.5' },
        -- Life Tap
        {wl.spells.lifeTap, 'jps.mana() < 0.4 and jps.mana() < jps.hp("player")' },
        wl.soulburnSoulSwapTable(),
        {wl.spells.drainSoul, 'jps.hp("target") <= 0.20 and jps.TimeToDie("target") <= 10' },
        -- Haunt
        {"nested", 'not jps.isRecast(wl.spells.haunt,"target")', {
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.hp("target") <= 0.20 and jps.soulShards() >= 1' },
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.soulShards() == 4'},
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.soulShards() >= 2'},
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.buff(wl.spells.darkSoulMisery) and jps.soulShards() >= 1'},
        }},
        -- DoT's
        jps.dotTracker.castTableStatic("corruption"),
        jps.dotTracker.castTableStatic("agony"),
        jps.dotTracker.castTableStatic("unstableAffliction"),
        -- Filler
        {wl.spells.drainSoul, 'jps.hp("target") <= 0.20' },
        {wl.spells.maleficGrasp, 'jps.TimeToDie("target") > 5'},
        {wl.spells.drainSoul },
    }},
    {"nested", 'not jps.MultiTarget and IsAltKeyDown()', {
        -- On the move
        { wl.spells.felFlame, 'jps.Moving and not wl.hasKilJaedensCunning() and jps.mana() > 0.5' },
        wl.soulburnSoulSwapTable(),
        -- DoT's
        jps.dotTracker.castTableStatic("corruption"),
        jps.dotTracker.castTableStatic("agony"),
        -- Life Tap might not cause problems per se - but using life tap with Interrupting Jolt = bad idea ;)
        --{ "life tap", jps.mana() < 0.4 and jps.mana() < jps.hp("player") },
    }},
    {"nested", 'jps.MultiTarget', {
        -- Life Tap
        {wl.spells.lifeTap, 'jps.mana() < 0.4 and jps.mana() < jps.hp("player")' },
        {wl.spells.soulburn, 'not jps.debuff(wl.spells.curseOfTheElements) or (jps.myDebuffDuration(wl.spells.corruption, "target") < 2 and wl.socDuration("target",true)<1)'},
        {wl.spells.curseOfTheElements, 'jps.buffDuration(wl.spells.soulburn) > 0 and not jps.debuff(wl.spells.curseOfTheElements)' },
        {wl.spells.curseOfTheElements, 'jps.buffDuration(wl.spells.soulburn) == 0 and not jps.debuff(wl.spells.curseOfTheElements, mouseover) and not wl.isTrivial("mouseover")', "mouseover" },
        {wl.spells.seedOfCorruption, 'jps.buffDuration(wl.spells.soulburn) > 0 and jps.myDebuffDuration(wl.spells.corruption,"target") < 2 and not wl.socDuration("target",true)<1 and not jps.isRecast(wl.spells.seedOfCorruption,"target")'},
        {wl.spells.seedOfCorruption, 'wl.socDuration("target") < 2 and not jps.isRecast(wl.spells.seedOfCorruption,"target")'},
        {wl.spells.seedOfCorruption, 'wl.socDuration("mouseover") < 2 and not jps.isRecast(wl.spells.seedOfCorruption,"mouseover")', "mouseover"},
        -- Haunt
        {"nested", 'not jps.isRecast(wl.spells.haunt,"target")', {
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.hp("target") <= 0.20 and jps.soulShards() >= 1' },
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") < 1.5 and jps.soulShards() == 4'},
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.soulShards() >= 2'},
            {wl.spells.haunt, 'jps.myDebuffDuration(wl.spells.haunt, "target") == 0 and jps.buff(wl.spells.darkSoulMisery) and jps.soulShards() >= 1'},
        }},
        -- Filler - better than nothing...
        {wl.spells.drainSoul, 'jps.hp("target") <= 0.20' },
        {wl.spells.maleficGrasp, 'jps.TimeToDie("target") > 5'},
        {wl.spells.drainSoul },
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



function warlock_affliction()   
    if IsAltKeyDown() and jps.CastTimeLeft("player") >= 0 then
        SpellStopCasting()
        jps.NextSpell = {}
    end
    
    cancelChannelingIfNecessary()

    return parseStaticSpellTable(jps.RotationActive(spellTable))
end

