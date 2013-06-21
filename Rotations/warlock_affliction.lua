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

local function toSpellName(id) name = GetSpellInfo(id); return name end
local spells = {}
spells["corruption"] = toSpellName(172)
spells["darkSoulMisery"] = toSpellName(113860)
spells["opticalBlast"] = toSpellName(119911)
spells["spellLock"] = toSpellName(19647)
spells["mortalCoil"] = toSpellName(6789)
spells["createHealthstone"] = toSpellName(6201)
spells["curseOfTheElements"] = toSpellName(1490)
spells["felFlame"] = toSpellName(77799)
spells["haunt"] = toSpellName(48181)
spells["seedOfCorruption"] = toSpellName(27243)
spells["maleficGrasp"] = toSpellName(103103)
spells["drainSoul"] = toSpellName(1120)
spells["lifeTap"] = toSpellName(1454)
spells["soulSwap"] = toSpellName(86121)
spells["soulburn"] = toSpellName(74434)
spells["drainSoul"] = toSpellName(1120)
spells["maleficGrasp"] = toSpellName(103103)

spells["lifeblood"] = toSpellName(121279)



-- Unit which should be dotted
local dottableUnits = { 
    "target",
    "focus",
    "mouseover",
    "boss1",
    "boss2",
    "boss3",
    "boss4",
}

-- Helper to prevent Recasts
local function isRecast(spell,target)
    return jps.LastCast == spell and jps.LastTarget == target
end

-- Returns the status of the three dots on the given unit - returns: oneDotMissing, allDotsMissing
local function getDotStatus(unit)
    local dotTracker = jps.dotTracker()
    local castCorruption = dotTracker.castTable("corruption" ,unit)[2]
    local castAgony = dotTracker.castTable("agony", unit)[2]
    local castUnstableAffliction = dotTracker.castTable("unstableAffliction", unit)[2]
    return (castCorruption or castAgony or castUnstableAffliction), (castCorruption and castAgony and castUnstableAffliction)
end

-- checks if the given unit (or all dottableUnits) are possible targets for soulburn/soulswap
local function canCastSoulburnSoulSwap(unit)
    if not unit then
        for i, target in ipairs(dottableUnits) do
            cast, target = canCastSoulburnSoulSwap(target)
            if cast then return cast, target end
        end
        return false, "target"
    end

    local shards = UnitPower("player", 7)
    local attackFocus = false
    local attackMouseOver = false
    local burnPhase = jps.hp("target") <= 0.20;
    
        -- If focus exists and is not the same as target, consider attacking focus too
    if not UnitExists(unit) or UnitIsFriend("player", unit) then
        return false, unit
    end

    
    local oneDotMissing, allDotsMissing = getDotStatus(unit)
    
    if unit == "target" and burnPhase then
        -- if we're in the burn phase, and at least 1 needs to refreshed do it - but only on the target
        if oneDotMissing and shards >= 1 then
            return true, unit
        end
    elseif allDotsMissing then
        -- since soulburn mouseover is a bit risky, only do it at 4 shards
        if unit == "mouseover" then
            if shards > 3 then
                return true, unit
            end
        -- every other target can be recasted with at least 2 shards left
        elseif shards >= 2 then
            return true, unit
        end
    end

    return false, unit
end

-- Aborts spell cast
local function cancelChanneling() 
    SpellStopCasting()
    jps.NextSpell = {}
end

-- aborts channeling spells, if necessary
local function cancelChannelingIfNecessary(targetTimeToDie)
    local burnPhase = jps.hp("target") <= 0.20
    if UnitChannelInfo("player") ~= nil and burnPhase and targetTimeToDie > 10 then
        local hauntDuration = jps.myDebuffDuration(spells.haunt, "target")
        local shards = UnitPower("player", 7)
        if hauntDuration < 1.5 and shards >= 1 and not isRecast(spells.haunt,"target") then
            cancelChanneling()
        else
            local _, allDotsMissing = getDotStatus("target")
            if allDotsMissing then cancelChanneling() end
        end
    elseif UnitChannelInfo("player") == spells.maleficGrasp then
        if targetTimeToDie <= 10 then
            cancelChanneling()
        elseif UnitClassification("target") == "worldboss" then
            local oneDotMissing, allDotsMissing = getDotStatus("target")
            if oneDotMissing then cancelChanneling() end
            -- Clip last tick...
            local haste = GetRangedHaste()
            local tickEvery = 1/(1+(haste/100))
            if jps.ChannelTimeLeft("player") < tickEvery then
                cancelChanneling()
            end
        end
    end
end

-- checks whether a unit has seed of curruption or soulburned seed of corruption
local function unitHasSeedOfCorruption(unit)
    local hasSoC, hasSoulburnSoC = false
    local durationSoC, durationSoulburnSoC = 0
    for i=1,40 do 
        local _, _, _, _, _, _, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i)
        local duration = 0
        if expirationTime~=nil then
            duration = expirationTime-GetTime()
            if duration < 0 then duration = 0 end
        end
        if spellId==27243 and caster=="player" then -- Default SoC
            hasSoC = true
            durationSoC = duration
        elseif spellId==114790 and caster=="player" then -- Soulburn SoC
            hasSoulburnSoC = true
            durationSoulburnSoC = duration
        end
    end
    return hasSoc, durationSoC, hasSoulburnSoC, durationSoulburnSoC
end


function warlock_affliction(self)    
    local hauntDuration = jps.myDebuffDuration(spells.haunt, "target")
    local shards = UnitPower("player", 7)
    local soulburnDuration = jps.buffDuration("soulburn")
    local burnPhase = jps.hp("target") <= 0.20
    local dotTracker = jps.dotTracker()
    local targetTimeToDie = jps.TimeToDie("target") or 0
    local timeToBurst = jps.TimeToDie("target", 0.2) or 0
    local darkSoulActive = jps.buff(spells.darkSoulMisery)
    local avoidInterrupts = IsAltKeyDown()
    local maxIntCastLength = 2.8

    local castSoulburn, soulSwapTarget = canCastSoulburnSoulSwap()
    cancelChannelingIfNecessary(targetTimeToDie)

    local targetHasSoc, targetDurationSoC, targetHasSoulburnSoC, targetDurationSoulburnSoC = unitHasSeedOfCorruption("target")
    local mouseoverHasSoc, mouseoverDurationSoC, mouseoverHasSoulburnSoC, mouseoverDurationSoulburnSoC = unitHasSeedOfCorruption("mouseover")

    local spellTable = {}
    spellTable[1] = {
    ["ToolTip"] = "Warlock PvE",
        -- Interrupts
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.spellLock, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},

        -- Def CD's
        {spells.mortalCoil, jps.Defensive and jps.hp() <= 0.80 },
        {spells.createHealthstone, jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= "create healthstone"},
        { jps.useBagItem(5512), jps.hp("player") < 0.65 }, -- Healthstone

        -- COE Debuff
        {"nested", not jps.MultiTarget, {
            { spells.curseOfTheElements, not jps.debuff(spells.curseOfTheElements) },
            { spells.curseOfTheElements, attackFocus and not jps.debuff(spells.curseOfTheElements, "focus"), "focus" },
        }},

        -- CD's
        { {"macro","/cast " .. spells.darkSoulMisery}, jps.cooldown(spells.darkSoulMisery) == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { spells.lifeblood, jps.UseCDs },
        { jps.useSynapseSprings(), jps.UseCDs },
        { jps.useTrinket(0),       jps.UseCDs },
        { jps.useTrinket(1),       jps.UseCDs },

        {"nested", not jps.MultiTarget and not avoidInterrupts, {
            -- Life Tap
            {spells.lifeTap, jps.mana() < 0.4 and jps.mana() < jps.hp("player") },
            {spells.soulSwap, soulburnDuration > 0, soulSwapTarget},
            {spells.soulburn, castSoulburn},
            {spells.drainSoul, burnPhase and targetTimeToDie <= 10 },
            -- Haunt
            {spells.haunt, hauntDuration < 1.5 and burnPhase and shards >= 1 and not isRecast(spells.haunt,"target")},
            {spells.haunt, hauntDuration == 0 and shards >= 2 and not isRecast(spells.haunt,"target")},
            {spells.haunt, hauntDuration == 0 and darkSoulActive and shards >= 1 and not isRecast(spells.haunt,"target")},
            -- DoT's
            dotTracker.castTable("corruption"),
            dotTracker.castTable("agony"),
            dotTracker.castTable("unstableAffliction"),
            -- Filler
            {spells.drainSoul, burnPhase },
            {spells.maleficGrasp},
        }},
        {"nested", not jps.MultiTarget and avoidInterrupts, {
            {spells.soulSwap, soulburnDuration > 0, soulSwapTarget},
            {spells.soulburn, castSoulburn},
            -- DoT's
            dotTracker.castTable("corruption"),
            dotTracker.castTable("agony"),
            -- Life Tap might not cause problems per se - but using life tap with Interrupting Jold = bad idea ;)
            --{ "life tap", jps.mana() < 0.4 and jps.mana() < jps.hp("player") },
        }},
        {"nested", jps.MultiTarget, {
            -- Life Tap
            {spells.lifeTap, jps.mana() < 0.4 and jps.mana() < jps.hp("player") },
            {spells.soulburn, not jps.debuff(spells.curseOfTheElements) or (jps.myDebuffDuration(spells.corruption, "target") < 2 and not targetHasSoulburnSoC)},
            {spells.curseOfTheElements, soulburnDuration > 0 and not jps.debuff(spells.curseOfTheElements) },
            {spells.curseOfTheElements, soulburnDuration == 0 and not jps.debuff(spells.curseOfTheElements, mouseover), "mouseover" },
            {spells.seedOfCorruption, soulburnDuration > 0 and jps.myDebuffDuration(spells.corruption,"target") < 2 and not targetHasSoulburnSoC and not isRecast(spells.seedOfCorruption,"target")},
            {spells.seedOfCorruption, targetDurationSoC < 2 and not isRecast(spells.seedOfCorruption,"target")},
            {spells.seedOfCorruption, mouseoverDurationSoC < 2 and not isRecast(spells.seedOfCorruption,"mouseover"), "mouseover"},
            -- Haunt
            {spells.haunt, hauntDuration < 1.5 and burnPhase and shards >= 1 and not isRecast(spells.haunt,"target")},
            {spells.haunt, hauntDuration == 0 and shards >= 2 and not isRecast(spells.haunt,"target")},
            {spells.haunt, hauntDuration == 0 and darkSoulActive and shards >= 1 and not isRecast(spells.haunt,"target")},
            -- Filler - better than nothing...
            {spells.maleficGrasp},
        }},
    }
    spellTable[2] = {
    ["ToolTip"] = "Interrupt Only",
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.spellLock, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
    }


    local spellTableActive = jps.RotationActive(spellTable)
    local spell,target = parseSpellTable(spellTableActive)

    return spell,target
end


