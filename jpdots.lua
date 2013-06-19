--[[
 DoT Tracker for DoT Classes
 
 Currently supported:
    * Warlock
        * Destruction
        * Affliction
]]--

local dotTracker = {}
dotTracker.log = jps.Logger(jps.LogLevel.ERROR)
dotTracker.isInitialized = false
dotTracker.timer = 0
dotTracker.throttle = 0.1
dotTracker.myGUID = nil
dotTracker.classSpecificSpells = nil
dotTracker.classSpecificUpdateDotDamage = nil
dotTracker.frame = CreateFrame("Frame", "dotTracker", UIParent)
dotTracker.trackedSpells = {}
-- Current DoT Damage
function dotTracker.toDotDamage(id,dps,dur,tE) dotTracker.dotDamage[id] = {dps = dps, duration = dur, tickEvery = tE} end
dotTracker.dotDamage = {}
-- Tracked Targets
function dotTracker.toTarget(guid, spellid) dotTracker.targets[guid..spellid] = { dps = dotTracker.dotDamage[spellid].dps, age = GetTime(), strength = 100, pandemicSafe = false} end
dotTracker.targets = {}
-- Spell Table
function dotTracker.toSpell(id,r,altId) return { id = id, name = GetSpellInfo(id), refreshedByFelFlame = r, alternativeId = altId} end
dotTracker.spells = {}
    -- Warlock Spells
    dotTracker.spells["immolate"] = dotTracker.toSpell(348, true, 108686) -- Immolate + Fire and Brimstone
    dotTracker.spells["felFlame"] = dotTracker.toSpell(77799)
    dotTracker.spells["corruption"] = dotTracker.toSpell(172, true, 87389) -- Corruption from Seed of Corruption
    dotTracker.spells["agony"] = dotTracker.toSpell(980, true)
    dotTracker.spells["unstableAffliction"] = dotTracker.toSpell(30108)

-- Buff Table
function dotTracker.toBuff(id,increase,increasePerStack,filter) return { id = id, name = GetSpellInfo(id), filter = filter or "HELPFUL", increase = increase, increasePerStack = increasePerStack or 0} end
dotTracker.buffs = {}
    dotTracker.buffs["fluidity"] = dotTracker.toBuff(138002, 0.4) -- +40%
    dotTracker.buffs["nutriment"] = dotTracker.toBuff(140741, 1, 0.1, "HARMFUL") -- +100% +10% per stack
    dotTracker.buffs["tricksOfTheTrade"] = dotTracker.toBuff(57934, 0.15) -- +15%
    dotTracker.buffs["fearless"] = dotTracker.toBuff(118977, 0.6) -- +60%

-- Supported Classes/Specs + Damage Calculation
function dotTracker.toClass(fn,...) return { updateFunction = fn, spells = {...} } end
dotTracker.supportedClasses = {}
dotTracker.supportedClasses["WARLOCK"] = {
    false,
    false,
    dotTracker.toClass(function(mastery, haste, crit, spellDamage, damageBuff)
        local damageBonus = (1+crit/100)*(1+(mastery+1)/100)
        
        local tickEvery = 3/(1+(haste/100))
        local ticks = math.floor(15/tickEvery)
        local duration = ticks * tickEvery
        local damage = ((456+spellDamage*0.427)+(ticks*(456+spellDamage*0.427))*damageBonus*damageBuff)
        local dps = damage / duration
        dotTracker.toDotDamage(dotTracker.spells.immolate.id, dps, duration, tickEvery)
    end, 
    dotTracker.spells.immolate),
}

-- Unit which should be dotted
dotTracker.dottableUnits = { 
    "target",
    "focus",
--    "mouseover",
    "boss1",
    "boss2",
    "boss3",
    "boss4",
}

local LOG = dotTracker.log

-- Initialize DotTracker (will only be executed once) and return dotTracker Object
function jps.dotTracker() 
    if not dotTracker.isInitialized then
        LOG.debug("Initializing DoT Tracker...")
        dotTracker.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
        dotTracker.registerEvents()
        dotTracker.isInitialized = true
        LOG.debug("...DoT Tracker initialized!")
    end
    return dotTracker
end

-- OnEvent Handler
function dotTracker.handleEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId = ...
        if sourceGUID ~= dotTracker.myGUID then return end
        if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH"  then
            for k,spell in pairs(dotTracker.classSpecificSpells) do
                if spellId == spell.id or spellId == spell.alternativeId then
                    LOG.warn("%s casted on Target: %s", spell.name, destGUID)
                    dotTracker.toTarget(destGUID, spell.id)
                end
            end
        -- Warlock
        elseif eventType == "SPELL_DAMAGE" and spellId == dotTracker.spells.felFlame.id then
            -- Warlock specific - FelFlame enhances DoT Duration..
            for k,spell in pairs(dotTracker.classSpecificSpells) do
                if spell.refreshedByFelFlame and dotTracker.targets[destGUID..spell.id] then
                    LOG.warn("%s refreshed with Fel Flame on Target: %s", spell.name, destGUID)
                    dotTracker.toTarget(destGUID, spell.id)
                end
            end
        elseif eventType=="SPELL_AURA_REMOVED" then
            for k,spell in pairs(dotTracker.classSpecificSpells) do
                if spellId == spell.id or spellId == spell.alternativeId then
                    LOG.warn("%s faded from Target: %s", spell.name, destGUID)
                    dotTracker.targets[destGUID..spell.id] = nil
                end
            end
        end
    elseif event == "COMBAT_RATING_UPDATE" or event == "SPELL_POWER_CHANGED" or event == "UNIT_STATS" or event == "PLAYER_DAMAGE_DONE_MODS" then
        dotTracker.updateDotDamage()
    elseif event == "PLAYER_TALENT_UPDATE" then
        LOG.warn("Player changed Talents")
        dotTracker.registerEvents()
    elseif event == "PLAYER_REGEN_ENABLED" then
        local maxAge = GetTime()-120
        for k,v in pairs(dotTracker.targets) do
            if dotTracker.targets[k].age < maxAge then dotTracker.targets[k]=nil end
        end
    end
end

-- OnUpdate Handler - updates Tracked Target Spells
function dotTracker.handleUpdate(self,elapsed)
    dotTracker.timer = dotTracker.timer + elapsed;
    if dotTracker.timer >= dotTracker.throttle then
        for k,v in pairs(dotTracker.trackedSpells) do
            dotTracker.updateTrackedSpellsOnTargets(v)
        end
        dotTracker.timer = 0
    end
end

-- Adds Spell to trackedSpells Table
function dotTracker.trackSpell(id,target)
    local spell = {}
    if id > 0 then
        local n,r,_ = GetSpellInfo(id)
        spell["name" ] = n
        spell["rank" ] = r
        spell["id" ] = id
    end
    spell["target" ] = target
    tinsert(dotTracker.trackedSpells, spell)
end

-- Updates the Tracked Spell with current Spell Power Values
function dotTracker.updateTrackedSpellsOnTargets(trackedSpell)
    local guid = UnitGUID(trackedSpell.target)
    local _,_,_,_,_,duration,expires = UnitDebuff(trackedSpell.target,trackedSpell.name,trackedSpell.rank,"player")
    if duration and guid then
        local target = dotTracker.targets[guid..trackedSpell.id]
        if target then
            local newStrength = math.floor(dotTracker.dotDamage[trackedSpell.id].dps*100/target.dps)
            if target.strength ~= newStrength then
                target.strength = newStrength
                LOG.info("Strength of %s changed: %s%% on %s (%s)", trackedSpell.name, newStrength, guid, trackedSpell.target)
            end
            if not target.pandemicSafe then
                if expires - GetTime() <= dotTracker.dotDamage[trackedSpell.id].duration/2 then
                    target.pandemicSafe = true
                    LOG.info("%s is now Pandemic Safe on %s (%s)", trackedSpell.name, guid, trackedSpell.target)
                end
            end
        else
            LOG.debug("No %s on %s (%s)", trackedSpell.name, guid, trackedSpell.target)
        end
    end
end

-- Register Events and sets OnUpdate/OnEvent Handler
function dotTracker.registerEvents()
    LOG.info("Un-Registering DoT Tracker Hooks...")
    dotTracker.myGUID = UnitGUID("player")
    dotTracker.frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    dotTracker.frame:UnregisterEvent("COMBAT_RATING_UPDATE")
    dotTracker.frame:UnregisterEvent("SPELL_POWER_CHANGED")
    dotTracker.frame:UnregisterEvent("UNIT_STATS")
    dotTracker.frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
    dotTracker.frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
    dotTracker.frame:UnregisterEvent("PLAYER_DAMAGE_DONE_MODS")
    dotTracker.frame:SetScript("OnUpdate", nil)
    --dotTracker.frame:SetScript("OnEvent", nil)
    dotTracker.frame:Hide()
    dotTracker.classSpecificUpdateDotDamage = nil
    LOG.info("...all hooks removed!")
    
    local class = select(2,UnitClass("player")) or "NONE"
    local spec = GetSpecialization() or -1

    if dotTracker.supportedClasses[class] and dotTracker.supportedClasses[class][spec] then
        LOG.info("Registering DoT Tracker Hooks for %s SPEC %s...", class, spec)
        dotTracker.classSpecificUpdateDotDamage = dotTracker.supportedClasses[class][spec].updateFunction
        dotTracker.classSpecificSpells = dotTracker.supportedClasses[class][spec].spells
        dotTracker.updateDotDamage()
        dotTracker.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        dotTracker.frame:RegisterEvent("COMBAT_RATING_UPDATE")
        dotTracker.frame:RegisterEvent("SPELL_POWER_CHANGED")
        dotTracker.frame:RegisterEvent("UNIT_STATS")
        dotTracker.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
        dotTracker.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
        dotTracker.frame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
        dotTracker.frame:SetScript("OnEvent", dotTracker.handleEvent)
        dotTracker.frame:SetScript("OnUpdate", dotTracker.handleUpdate)
        dotTracker.frame:Show()
        wipe(dotTracker.trackedSpells)
        for i, spell in ipairs(dotTracker.classSpecificSpells) do
            LOG.debug("...adding Spell %s (%s)", spell.name, spell.id)
            for i, dottableUnit in ipairs(dotTracker.dottableUnits) do
                dotTracker.trackSpell(spell.id, dottableUnit)
            end
        end
        LOG.info("...all hooks registered!")
    else
        LOG.warn("Class %s with Spec %s is not supported!", class, spec)
    end
end

-- Update Damage Values
function dotTracker.updateDotDamage()
    LOG.debug("Updating DoT Damage...")
    local damageBuff = 1
    for i, buff in ipairs(dotTracker.buffs) do
        hasBuff,_,_,stacks = UnitAura("player", buff.name, nil, buff.filter)
        if hasBuff then
            damageBuff = damageBuff + buff.increase + (buff.increasePerStack * stacks)
        end
    end
    local mastery, haste, crit, spellDamage = GetMastery(), GetRangedHaste(), GetSpellCritChance(6), GetSpellBonusDamage(6)
    if crit > 100 then crit = 100 end
    dotTracker.classSpecificUpdateDotDamage(mastery, haste, crit, spellDamage, damageBuff)
end


-- Core Logic - responds whether to cast a spell at a give unit (or any possible unit if none given) or not
function dotTracker.castTable(spellId, unit)
    -- Let's be generous about the spell id...
    if not tonumber(spellId) then
        if tonumber(spellId.id) then 
            spellId = spellId.id
        elseif dotTracker.spells[spellId] then 
            spellId = dotTracker.spells[spellId].id
        else
            -- nothing left to try...
            LOG.error("Can't check spell: %s", tostring(spellId))
            return { spellId, false}
        end
    end
    -- if no unit is given, try all of them
    if not unit then
        for i, dottableUnit in ipairs(dotTracker.dottableUnits) do
            local spellTable = dotTracker.castTable(spellId, dottableUnit)
            if spellTable[2] then
                return spellTable
            end 
        end
        return {spellId, false}
    end
    
    -- check if we can attack
    if not jps.canDPS(unit) then return {spellId, false, unit} end
    
    -- here's the actual logic
    local guid = UnitGUID(unit)
    local name,rank,_ = GetSpellInfo(spellId)
    local _,_,_,_,_,duration,expires = UnitDebuff(unit,name,rank,"player")
    local castSpell = false
    
    if duration and guid then
        local timeLeft = expires - GetTime()
        local myCastLeft = jps.CastTimeLeft("player")
        local target = dotTracker.targets[guid..spellId]
        
        if target then            
            if target.pandemicSafe then
                if target.strength > 100 then
                    LOG.info("Re-Casting: %s@%s (Pandemic Safe @ %s%% with %s sec left", name, unit, target.strength, timeLeft)
                    castSpell = true
                else
                    if timeLeft <= (2.0 + myCastLeft) then
                        LOG.info("Re-Casting: %s@%s (Pandemic Safe @ %s%% with %s sec left (current cast left: %s)", name, unit, target.strength, timeLeft, myCastLeft)
                        castSpell = true
                    end
                end
            else
            --if enough dps increase - fuck pandemic!
                if target.strength > 100 then
                    damageDelta = (dotTracker.dotDamage[spellId].dps * dotTracker.dotDamage[spellId].duration) - (target.dps * timeLeft)
                    -- assume 150k dps - if you waste 1.5 seconds for gcd (or immolate cast) you should get an increase of at least 225k to compensate
                    if damageDelta >= 225000  then
                        castImmolate = true
                        LOG.info("Re-Casting: %s@%s (NOT Pandemic Safe @ %s%% with %s sec left (Damage-Delta: %s)", name, unit, target.strength, timeLeft, damageDelta)
                    else
                        LOG.debug("NOT Re-Casting: %s@%s (NOT Pandemic Safe @ %s%% with %s sec left (Damage-Delta: %s)", name, unit, target.strength, timeLeft, damageDelta)
                    end
                end
            end
            
        else
            LOG.info("Casting: %s@%s - was not on target!", name, unit)
            castSpell = true
        end
    elseif guid then
        castSpell = true
    end

    -- avoid double casts!
    local wasLastCast = jps.LastCast == name and UnitGUID(jps.LastTarget) == UnitGUID(unit)
    if not wasLastCast then 
        return {name, castSpell, unit}
    else
        return {name, false}
    end
end