--[[
Warlock Destruction Rotations:

Warlock PvE Rotation:
 * SHIFT: Cast Rain of Fire @ Mouse - ONLY if RoF Duration is less than 1 seconds
 * CTRL-SHIFT: Cast Rain of Fire @ Mouse - ignoring the current RoF duration
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



local function debugPrint(msg)
    --print(msg)
end

-- Spell ID's
local spellIds = {
    -- Lock Spells
    immolate = 348,
    felFlame = 77799,
    -- Damage Buffs
    masterPoisoner = 93068, -- +5%
    fluidity = 138002, -- +40%
    nutriment = 140741, -- +100% +10% per stack
    tricksOfTheTrade = 57934, -- +15%
    fearless = 118977, -- +60%
}

-- Spell Names's
local spellNames = {
    -- Lock Spells
    immolate = GetSpellInfo(spellIds.immolate),
    felFlame = GetSpellInfo(spellIds.felFlame),
    -- Damage Buffs
    masterPoisoner = GetSpellInfo(spellIds.masterPoisoner), -- +5%
    fluidity = GetSpellInfo(spellIds.fluidity), -- +40%
    nutriment = GetSpellInfo(spellIds.nutriment), -- +100% +10% per stack
    tricksOfTheTrade = GetSpellInfo(spellIds.tricksOfTheTrade), -- +15%
    fearless = GetSpellInfo(spellIds.fearless), -- +60%
}

-- Unit which should be dotted with Immolate
local dottableUnits = {
    "target",
    "focus",
    "mouseover",
    "boss1",
    "boss2",
    "boss3",
    "boss4",
}

-- stop spam curse of the elements at invalid targets @ mop
function isCotEBlacklisted(unit) 
    local table_noSpamCotE = {
        "Twilight Sapper", 
        "Burning Tendons",
        "Corrupted Blood",
        "Energy Charge",
        "Celestial Protector",
    }
    for i,j in pairs(table_noSpamCotE) do
        if UnitName(unit) == j then return true end
    end
    return false
end

-- checks if item is in bag and not on cd 


function hasKilJaedensCunning()
    local selected, talentIndex = GetTalentRowSelectionInfo(6)
    return talentIndex == 17
end




function warlock_destro()
    initializeDotTracker()
    
    local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
    local burningEmbers = UnitPower("player",14)
    local emberShards = UnitPower("player", 14, true)
    local immolateDuration = jps.debuffDuration("immolate")
    local focusImmolateDuration = jps.debuffDuration("immolate", "focus")
    local rainOfFireDuration = jps.buffDuration("rain of fire")
    local backdraftStacks = jps.buffStacks("backdraft")
    local darkSoulActive = jps.buff("Dark Soul: Instability")
    local havocStacks = jps.buffStacks("Havoc")
    local burnPhase = jps.hp("target") <= 0.20
    local attackFocus = false
    local spell = nil
    local fireAndBrimstoneBuffed = jps.buff("Fire and Brimstone", "player")
    local timeToBurst = jps.TimeToDie("target", 0.2) or 0
    local immolate, immolateTarget = canCastImmolate()
    local avoidInterrupts = IsAltKeyDown()
    local maxIntCastLength = 2.8

    -- If focus exists and is not the same as target, consider attacking focus too
    if UnitExists("focus") ~= nil and UnitGUID("target") ~= UnitGUID("focus") and not UnitIsFriend("player", "focus") then
        attackFocus = true
    end
    

    if avoidInterrupts and jps.CastTimeLeft("player") >= enemyCastLeft then
        SpellStopCasting()
    end
    
    local spellTable = {}
    
    --- JPS doesn't seem to react fast enough so you might get stuck with fire and brimstone and no embers...
    if (fireAndBrimstoneBuffed and not jps.MultiTarget) or
       (burningEmbers == 0 and fireAndBrimstoneBuffed) or
       (burningEmbers > 1 and not fireAndBrimstoneBuffed and jps.MultiTarget) then 
        jps.Cast( "fire and brimstone" ) 
    end

    spellTable[1] = {
    ["ToolTip"] = "Warlock PvE",
        -- Interrupts
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Spell lock", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},

        -- Def CD's
        { "mortal coil", jps.Defensive and jps.hp() <= 0.80 },
        { "create healthstone", jps.Defensive and GetItemCount(5512, false, false) == 0},

        { jps.useBagItem("Healthstone"), jps.hp("player") < 0.65 },
        { "ember tap", jps.Defensive and jps.hp() <= 0.30 and burningEmbers > 0 },

        -- Rain of Fire
        { "rain of fire", IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire") },
        { "rain of fire", IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire")},
        -- COE Debuff
        { "curse of the elements", not jps.debuff("curse of the elements") and not isCotEBlacklisted("target") },
        { "curse of the elements", attackFocus and not jps.debuff("curse of the elements", "focus") and not isCotEBlacklisted("focus"), "focus" },
        
        -- On the move
        { "fel flame", currentSpeed > 0 and not hasKilJaedensCunning() },
        
        -- CD's
        { {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { "Lifeblood", jps.UseCDs },
        { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
        { jps.useTrinket(0),       jps.UseCDs },
        { jps.useTrinket(1),       jps.UseCDs },
        
        {"nested", not jps.MultiTarget, {
            { "havoc", attackFocus, "focus" },
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "chaos bolt", not avoidInterrupts and burningEmbers >= 1 and  havocStacks>=3},
            { spellNames.immolate, immolate, immolateTarget},
            { "conflagrate", "onCD" },
            { "chaos bolt", not avoidInterrupts and darkSoulActive and emberShards >= 19 },
            { "chaos bolt", not avoidInterrupts and timeToBurst > 5.0 and burningEmbers >= 3 and backdraftStacks < 3},
            { "chaos bolt", not avoidInterrupts and emberShards >= 35},
            { "incinerate", not avoidInterrupts },
            { "fel flame"},
        }},        
        {"nested", jps.MultiTarget, {
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "immolate", not avoidInterrupts and fireAndBrimstoneBuffed and canCastImmolate("target")},
            { "incinerate", not avoidInterrupts },
            { "conflagrate"},
            { "fel flame"},
        }},
    }
    spellTable[2] = {
    ["ToolTip"] = "Interrupt Only",
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Spell lock", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
    }


	local spellTableActive = jps.RotationActive(spellTable)
	local spell,target = parseSpellTable(spellTableActive)

	return spell,target
end

--[[
DANGER HERE BE DRAGONS!
]]--

local timer, throttle = 0, 0.1
local myGUID
local dotDamage, targets, trackedSpells = {},{},{}
local isInitialized = false
local destroLock = CreateFrame("Frame", "destroLock", UIParent)


function canCastImmolate(unit)
    if not unit then
        for i, dottableUnit in ipairs(dottableUnits) do
            cast, unit = canCastImmolate(dottableUnit)
            if cast then
                if jps.LastCast ~= spellNames.immolate or jps.LastCast == spellNames.immolate and jps.LastTarget ~= unit then 
                    return cast, unit
                end
            end 
        end
        return false, "target"
    end
    if not jps.canDPS(unit) then return false, unit end
    
    local guid = UnitGUID(unit)
    local name,rank,_ = GetSpellInfo(spellIds.immolate)
    local _,_,_,_,_,duration,expires = UnitDebuff(unit,name,rank,"player")
    local castImmolate = false
    
    if duration and guid and targets[guid] then
        local timeLeft = expires - GetTime()
        if targets[guid][4].pandemicSafe then
            if targets[guid][4].strength > 100 then
                debugPrint("Recasting: "..name.."@ "..unit.." (Pandemic Safe @ "..targets[guid][4].strength.."% with "..timeLeft.." sec left)")
                castImmolate = true
            else
                if timeLeft > 2 then
                    castImmolate = false
                else
                    debugPrint("Recasting: "..name.."@ "..unit.." (Pandemic Safe @ "..targets[guid][4].strength.."% with "..timeLeft.." sec left)")
                    castImmolate = true
                end
            end
        else
            --TODO: Be more specific when to clip dots...20% increase is nice, but a better logic might increse dps further
            if targets[guid][4].strength > 120 then
                debugPrint("Recasting: "..name.."@ "..unit.." (NOT Pandemic Safe @ "..targets[guid][4].strength.."% with "..timeLeft.." sec left)")
                castImmolate = true
            else
                castImmolate = false
            end
        end
    else
        castImmolate = true
    end
    return castImmolate, unit
end

-- OnUpdate Handler - updates Tracked Target Spells
local function handleUpdate(self,elapsed)
    timer = timer + elapsed;
    if timer >= throttle then
        for k,v in pairs(trackedSpells) do
            updateTrackedSpell(v)
        end
        timer = 0
        end
end


-- OnEvent Handler
local function handleEvent(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        --[[
        local timestamp, type, hideCaster, -- arg1 to arg3
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, -- arg4 to arg11
        spellId, spellName, spellSchool, -- arg12 to arg14
        amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ... -- arg15 to arg23
        ]]
        --local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
        local _, type, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId = ...
        updateDotsOnTarget(type,spellId,sourceGUID,destGUID)
    elseif event == "COMBAT_RATING_UPDATE" or event == "SPELL_POWER_CHANGED" or event == "UNIT_STATS" or event == "PLAYER_DAMAGE_DONE_MODS" then
        updateDotDamage()
    elseif event == "PLAYER_TALENT_UPDATE" then
        registerEvents()
    end
end


-- Helper method to round up
local function round(num) return math.floor(num+.5) end

-- Add Spell to watched List
function trackSpell(id,target,duration)
    local spell = {}
    if id > 0 then
        local n,r,_ = GetSpellInfo(id)
        spell["pandemic" ] = duration/3
        spell["name" ] = n
        spell["rank" ] = r
        spell["id" ] = id
    end
    spell["target" ] = target
    spell.data = {strength=0, pandemicSafe=true}
    tinsert(trackedSpells, spell)
end


-- Register Events and sets OnUpdate/OnEvent Handler
function registerEvents()
    myGUID = UnitGUID("player")
    destroLock:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    destroLock:UnregisterEvent("COMBAT_RATING_UPDATE")
    destroLock:UnregisterEvent("SPELL_POWER_CHANGED")
    destroLock:UnregisterEvent("UNIT_STATS")
    destroLock:UnregisterEvent("PLAYER_REGEN_ENABLED")
    destroLock:UnregisterEvent("PLAYER_REGEN_DISABLED")
    destroLock:UnregisterEvent("PLAYER_DAMAGE_DONE_MODS")
    --destroLock:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    destroLock:SetScript("OnUpdate", nil)
    destroLock:SetScript("OnEvent", nil)
    destroLock:Hide()
    spec = GetSpecialization() or ""
    -- Only Re
    if spec == 3 then
        updateDotDamage()
        destroLock:SetScript("OnEvent", handleEvent)
        destroLock:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        destroLock:RegisterEvent("COMBAT_RATING_UPDATE")
        destroLock:RegisterEvent("SPELL_POWER_CHANGED")
        destroLock:RegisterEvent("UNIT_STATS")
        destroLock:RegisterEvent("PLAYER_REGEN_ENABLED")
        destroLock:RegisterEvent("PLAYER_REGEN_DISABLED")
        destroLock:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
        --destroLock:RegisterEvent("PLAYER_FOCUS_CHANGED")
        destroLock:SetScript("OnUpdate", handleUpdate)
        destroLock:Show()
        wipe(trackedSpells)
        --Track Dot's (id,target,duration,tick)
        for i, dottableUnit in ipairs(dottableUnits) do
            trackSpell(spellIds.immolate, dottableUnit, 15)
        end
    end
end

-- Updates the Tracked Spell with current Spell Power Values
function updateTrackedSpell(trackedSpell)
    local guid = UnitGUID(trackedSpell.target)
    local _,_,_,_,_,duration,expires = UnitDebuff(trackedSpell.target,trackedSpell.name,trackedSpell.rank,"player")
    if duration and guid and targets[guid] then
        local newStrength = dotDamage[1]*100/targets[guid][1]
        --if targets[guid][4].strength ~= newStrength then debugPrint("New Strength " .. newStrength .. " on ".. trackedSpell.target) end
        targets[guid][4].strength = newStrength
        targets[guid][4].delta = dotDamage[1] - targets[guid][1]
        if expires - GetTime() <= trackedSpell.pandemic then
            --trackedSpell.data.pandemicSafe = true
            targets[guid][4].pandemicSafe = true
        else
            --trackedSpell.data.pandemicSafe = false
            targets[guid][4].pandemicSafe = false
        end
    else
        --if trackedSpell.data.strength < 9000 then debugPrint("No Target/No Debuff on " .. trackedSpell.target) end
        trackedSpell.data.strength = 9000
        trackedSpell.data.delta = 9000
        trackedSpell.data.pandemicSafe = true
    end
end

-- Initialize DotTracker, will only be executed once
function initializeDotTracker()
    if not isInitialized then
        isInitialized = true
        destroLock:RegisterEvent("PLAYER_TALENT_UPDATE")
        registerEvents()
    end
end


function updateDotDamage()
    -- Get Damage multipliers
    local dmgBuff = 1
    local fluidity = UnitAura("player", spellNames.fluidity, nil, "HARMFUL")
    local _,_,_,nutriment = UnitAura("player", spellNames.nutriment)
    local tricks = UnitAura("player", spellNames.tricksOfTheTrade)
    local fearless = UnitAura("player", spellNames.fearless)
    if fluidity then dmgBuff = 1.4 end
    if nutriment then dmgBuff = 2 + (nutriment-1)*0.1 end
    if fearless then dmgBuff = 1.6 end
    if tricks then dmgBuff = dmgBuff * 1.15 end
    
    
    -- Calc Damage for all dot's
    local mastery, haste, crit, spd = GetMastery(), GetRangedHaste(), GetSpellCritChance(6), GetSpellBonusDamage(6)
    if crit > 100 then crit = 100 end
    damageBonus = (1+crit/100)*(1+(mastery*3.1)/100)
    
    -- Immolate
    local tickEvery = 3/(1+(haste/100))
    local ticks = round(15/tickEvery)
    local duration = ticks * tickEvery
    local damage = (456+spd*0.427)+(ticks*(456+spd*0.427)*damageBonus*dmgBuff)
    local dps = round(damage/duration)
    
    
   -- local dD = round(dps/100)/10
   --if dps ~= dotDamage[1] or tickEvery ~= dotDamage[2] then  debugPrint("DOT-Damage Changed - DPS: " .. dps .. " Ticks every: " .. tickEvery) end
    dotDamage = {dps, tickEvery}
    --dotDamage = {round(dps/100)/10, tickEvery}
end

-- Parce Combat Log to update Spell Power Values on Targets
function updateDotsOnTarget(event,spellId,sourceGUID,destGUID)
    if sourceGUID ~= myGUID then return end
    if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
        if(spellId == spellIds.immolate) then
            debugPrint("Immolate casted on Target: " .. destGUID)
            targets[destGUID] = {dotDamage[1],GetTime(),dotDamage[2],{strength=100,pandemicSafe=false,delta=0}}
        end
    elseif(event == "SPELL_DAMAGE" and spellIds.felFlame) then
        if targets[destGUID] then
            debugPrint("Immolate refreshed with Fel Flame on Target: " .. destGUID)
            targets[destGUID] = {dotDamage[1],GetTime(),dotDamage[2],{strength=100,pandemicSafe=false,delta=0}}
        end
    elseif event=="SPELL_AURA_REMOVED" then
        debugPrint("Immolate faded from Target: " .. destGUID)
        targets[destGUID] = nil
    end
end