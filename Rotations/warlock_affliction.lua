local start_time = 0
local end_time = 0
local total_time = 0

-- "UNIT_COMBAT"
--arg1 the UnitID of the entity
--arg2 Action,Damage,etc (e.g. HEAL, DODGE, BLOCK, WOUND, MISS, PARRY, RESIST, ...)
--arg3 Critical/Glancing indicator (e.g. CRITICAL, CRUSHING, GLANCING)
--arg4 The numeric damage
--arg5 Damage type in numeric value (1 - physical; 2 - holy; 4 - fire; 8 - nature; 16 - frost; 32 - shadow; 64 - arcane)
local dmgSchool = false
local dmgPlayer = 0
local frame = CreateFrame('Frame')
frame:RegisterEvent("UNIT_COMBAT")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
local function aggroCalculation(self, event, ...)
    if event == "UNIT_COMBAT" then
        local dmg_School = false
        end_time = GetTime()
        local total_time = math.max(end_time - start_time, 1)
        local arg1 = select(1, ...)
        local arg2 = select(2, ...)
        local arg4 = select(4, ...)
        local arg5 = select(5, ...)
        if (arg1 == "player") and (arg2 == "WOUND") and (arg4 > 0) then
            dmgPlayer = dmgPlayer + arg4
            if arg5 == 2 or arg5 == 32 then dmg_School = true end
            total_time = math.max(end_time - start_time, 1)
            dpsPlayer = math.ceil(dmgPlayer / total_time)
        end
        dmgSchool = dmg_School
        else
        if event == "PLAYER_REGEN_DISABLED" then
            start_time = GetTime()
        end
    end
end
frame:SetScript("OnEvent", aggroCalculation)

--////////////////////////////////////////////////////////////////////////////////////////////////--

-- Warlock Affliction Spec.
-- Only Requirement: Kil'jaeden's Cunning, it will work without, but you'll lose a lot of dps
-- On single target rotation, use focus target and mouseover to dot other targets
-- If you want to ignore mouseover targets, you can toggle it with the slash command '/wla'
-- The logic behind recasting DoT's is based on the AddOn AffliDots
-- A note for TidyPlates Users: You need to mouseover the Nameplate not the 3D Model, else it won't show your DoT's

-- Spell ID's
local spellIds = {
    -- Lock Spells
    corruption = 172,
    seededCorruption = 87389, -- Corruption placed by Seed of Corruption
    agony = 980,
    unstableAffliction = 30108,
    curseOfTheElements = 1490,
    shadowFlame = 47960,
    soulLeech = 108366,
    sacrificialPact = 108416,
    havoc = 80240,
    backdraft = 117896,
    soulburn = 74434,
    maleficGrasp = 103103,
    darkSoulMisery = 113860,
    soulSwap = 119678,
    haunt = 48181,
    drainSoul = 1120,
    seedOfCorruption = 27243,
    lifeTap = 1454,
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
    corruption = GetSpellInfo(spellIds.corruption),
    seededCorruption = GetSpellInfo(spellIds.seededCorruption),
    agony = GetSpellInfo(spellIds.agony),
    unstableAffliction = GetSpellInfo(spellIds.unstableAffliction),
    curseOfTheElements = GetSpellInfo(spellIds.curseOfTheElements),
    shadowFlame = GetSpellInfo(spellIds.shadowFlame),
    soulLeech = GetSpellInfo(spellIds.soulLeech),
    sacrificialPact = GetSpellInfo(spellIds.sacrificialPact),
    havoc = GetSpellInfo(spellIds.havoc),
    backdraft = GetSpellInfo(spellIds.backdraft),
    soulburn = GetSpellInfo(spellIds.soulburn),
    maleficGrasp = GetSpellInfo(spellIds.maleficGrasp),
    darkSoulMisery = GetSpellInfo(spellIds.darkSoulMisery),
    soulSwap = GetSpellInfo(spellIds.soulSwap),
    haunt = GetSpellInfo(spellIds.haunt),
    drainSoul = GetSpellInfo(spellIds.drainSoul),
    seedOfCorruption = GetSpellInfo(spellIds.seedOfCorruption),
    lifeTap = GetSpellInfo(spellIds.lifeTap),
    -- Damage Buffs
    masterPoisoner = GetSpellInfo(spellIds.masterPoisoner), -- +5%
    fluidity = GetSpellInfo(spellIds.fluidity), -- +40%
    nutriment = GetSpellInfo(spellIds.nutriment), -- +100% +10% per stack
    tricksOfTheTrade = GetSpellInfo(spellIds.tricksOfTheTrade), -- +15%
    fearless = GetSpellInfo(spellIds.fearless), -- +60%
}

local ignoreMouseOverTargets = false

function warlock_affliction(self)
    initializeDotTracker()
    
    
    ----------------------------
    -- debuffstack tsulong ---
    ----------------------------
    local TsulongStack = jps.debuffStacks(122768,"player")
    ----------------------------
    
    
    
    local pet = UnitExists("pet")
    local shards = UnitPower("player", 7)
    local soulburnDuration = jps.buffDuration(spellNames.soulburn);
    local hauntDuration = jps.debuffDuration(spellNames.haunt, "target");
    local burnPhase = jps.hp("target") <= 0.20;
    local attackFocus = false
    local attackMouseOver = false
    local isInRaid = GetNumGroupMembers() > 0
    
    -- If focus exists and is not the same as target, consider attacking focus too
    if UnitExists("focus") ~= nil and UnitGUID("target") ~= UnitGUID("focus") and not UnitIsFriend("player", "focus") then
        attackFocus = true
    end
    -- If focus exists and is not the same as target, consider attacking focus too
    if not ignoreMouseOverTargets and UnitExists("mouseover") ~= nil and UnitGUID("target") ~= UnitGUID("mouseover") and not UnitIsFriend("player", "mouseover") then
        attackMouseOver = true
    end
    
    local castCorruptionAtTarget = shouldSpellBeCast(spellIds.corruption,"target")
    local castCorruptionAtFocus = attackFocus and shouldSpellBeCast(spellIds.corruption,"focus")
    local castCorruptionAtMouseover = attackMouseOver and shouldSpellBeCast(spellIds.corruption,"mouseover")
    
    local castAgonyAtTarget = shouldSpellBeCast(spellIds.agony,"target")
    local castAgonyAtFocus = attackFocus and shouldSpellBeCast(spellIds.agony,"focus")
    local castAgonyAtMouseover = attackMouseOver and shouldSpellBeCast(spellIds.agony,"mouseover")
    
    local castUnstableAfflictionAtTarget = shouldSpellBeCast(spellIds.unstableAffliction,"target")
    local castUnstableAfflictionAtFocus = attackFocus and shouldSpellBeCast(spellIds.unstableAffliction,"focus")
    local castUnstableAfflictionAtMouseover = attackMouseOver and shouldSpellBeCast(spellIds.unstableAffliction,"mouseover")
    
    -- Cast soulburn if either target, focus has no dots at all and there are ar least 3 shards left
    -- since soulburn mouseover is a bit risky, only do it at 4 shards
    -- if we're in the burn phase, and at least 1 needs to refreshed do it
    local castSoulburn = false
    local soulSwapTarget = "target"
    if burnPhase and (castCorruptionAtTarget or castAgonyAtTarget or castUnstableAfflictionAtTarget) and shards >= 1 then
        castSoulburn = true
    elseif castCorruptionAtTarget and castAgonyAtTarget and castUnstableAfflictionAtTarget and shards >= 2 then
        castSoulburn = true
    elseif castCorruptionAtFocus and castAgonyAtFocus and castUnstableAfflictionAtFocus and shards >= 2 then
        castSoulburn = true
        soulSwapTarget = "focus"
    elseif castCorruptionAtMouseover and castAgonyAtMouseover and castUnstableAfflictionAtMouseover and shards >= 3 then
    	castSoulburn = true
    	soulSwapTarget = "mouseover"
    end
    
    if jps.MultiTarget then
        -- Multi Target COE
        if not jps.debuff(spellNames.curseOfTheElements) then
        	castSoulburn = true
        end
        -- SeedOfCorruption+Soulburn
        if castCorruptionAtTarget then
        	castSoulburn = true
        end
        -- Prevent Double SoC's
        
        local multiTargetSpellTable = {
            -- Soulburn
            {spellNames.soulburn, castSoulburn},
            -- COE Debuff
            { spellNames.curseOfTheElements, not jps.debuff(spellNames.curseOfTheElements) and soulburnDuration > 0 },
            -- CD's
            { {"macro","/cast "..spellNames.darkSoulMisery}, jps.cooldown(spellNames.darkSoulMisery) == 0 and jps.UseCDs },
            { jps.DPSRacial, jps.UseCDs },
            { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
            --{ jps.useTrinket(1), jps.UseCDs},
            --{ jps.useTrinket(2), jps.UseCDs},
            -- Soulburn + SoC/Soul Swap
            {spellNames.seedOfCorruption, soulburnDuration > 0 and castCorruptionAtTarget and not jps.debuff(spellNames.seedOfCorruption, "target") and not isRecast(spellNames.seedOfCorruption,"target")},
            {spellNames.soulSwap, soulburnDuration > 0 and soulSwapTarget, soulSwapTarget},
            -- SoC on all possible Targets
            {spellNames.seedOfCorruption, not jps.debuff(spellNames.seedOfCorruption, "target") and not isRecast(spellNames.seedOfCorruption,"target")},
            {spellNames.seedOfCorruption, attackFocus and not jps.debuff(spellNames.seedOfCorruption, "focus") and not isRecast(spellNames.seedOfCorruption,"focus"), "focus"},
            {spellNames.seedOfCorruption, attackMouseOver and not jps.debuff(spellNames.seedOfCorruption, "mouseover") and not isRecast(spellNames.seedOfCorruption,"mouseover"), "mouseover"},
            -- Haunt
            {spellNames.haunt, hauntDuration < 1.5 and burnPhase and shards >= 1},
            {spellNames.haunt, hauntDuration == 0 and shards >= 3},
            -- DoT's
            { spellNames.agony, castAgonyAtTarget},
            { spellNames.agony, castAgonyAtFocus, "focus"},
            { spellNames.unstableAffliction, castUnstableAfflictionAtTarget},
            { spellNames.unstableAffliction, castUnstableAfflictionAtFocus, "focus"},
            -- Life Tap
            { spellNames.lifeTap, jps.mana() < 0.4 and jps.mana() < jps.hp("player") },
            -- Filler
            { spellNames.drainSoul, burnPhase },
            { spellNames.maleficGrasp },
        }
        return parseSpellTable( multiTargetSpellTable )
    else
        local singleTargetSpellTable = {
            ----pluie de feu si alt --
            { 5740, IsControlKeyDown() ~= nil },
            -- bouclier shadow sur tsulong ---
            { 6229, (TsulongStack > 9 and jps.cooldown(6229) == 0) or (dmgSchool and jps.cooldown(6229) == 0) },
            --- aggro reduction ----
            { "soulshatter", targetThreatStatus ~= 0 and isInRaid },
            -------- survival cd ----
            
            -- survival cd --
            { {"macro","/use Healthstone"}, jps.itemCooldown(5512)==0 and jps.hp() < 0.4 and GetItemCount(5512) > 0 },
            { "mortal coil", jps.hp("player") < 0.70 },
            { 108416, jps.hp("player") < 0.60 and jps.cooldown(108416) == 0 }, -- sacrifical pact--
            { "unending resolve", jps.hp("player") < 0.35 },
            
            -- doomguard/Potion--
            { {"macro","/use Potion of the Jade Serpent"}, jps.itemCooldown(76093)==0 and jps.bloodlusting() and GetItemCount(76093) > 0 and jps.UseCDs },
            
            { "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.bloodlusting() and jps.UseCDs },
            { "summon doomguard", jps.cooldown("summon doomguard") == 0 and jps.hp("target") < 0.25 and jps.UseCDs },
            
            --cd--
            
            ---- pet casting ----
            
            { 115781, jps.cooldown(115781) == 0 and pet },
            
            -- COE Debuff
            { spellNames.curseOfTheElements, not jps.debuff(spellNames.curseOfTheElements) },
            { spellNames.curseOfTheElements, attackFocus and not jps.debuff(spellNames.curseOfTheElements, "focus"), "focus" },
            { spellNames.curseOfTheElements, attackMouseOver and not jps.debuff(spellNames.curseOfTheElements, "mouseover"), "mouseover" },
            -- CD's 

            { {"macro","/cast "..spellNames.darkSoulMisery}, jps.cooldown(spellNames.darkSoulMisery) == 0 },
            { jps.DPSRacial, jps.UseCDs },
            { {"macro","/use 10"}, jps.glovesCooldown() == 0 },
            --{ jps.useTrinket(1), jps.UseCDs},
            --{ jps.useTrinket(2), jps.UseCDs},
            -- Soulburn/Soul Swap
            
            {spellNames.soulSwap, soulburnDuration > 0, soulSwapTarget},
            {spellNames.soulburn, castSoulburn},
            -- Haunt
            {spellNames.haunt, hauntDuration < 1.5 and burnPhase and shards >= 1 and not isRecast(spellNames.haunt,"target")},
            {spellNames.haunt, hauntDuration == 0 and shards >= 3 and not isRecast(spellNames.haunt,"target")},
            -- DoT's
            { spellNames.corruption, castCorruptionAtTarget},
            { spellNames.corruption, castCorruptionAtFocus, "focus"},
            { spellNames.corruption, castCorruptionAtMouseover, "mouseover"},
            { spellNames.agony, castAgonyAtTarget},
            { spellNames.agony, castAgonyAtFocus, "focus"},
            { spellNames.agony, castAgonyAtMouseover, "mouseover"},
            { spellNames.unstableAffliction, castUnstableAfflictionAtTarget and not isRecast(spellNames.unstableAffliction,"target")},
            { spellNames.unstableAffliction, castUnstableAfflictionAtFocus and not isRecast(spellNames.unstableAffliction,"focus"), "focus"},
            { spellNames.unstableAffliction, castUnstableAfflictionAtMouseover and not isRecast(spellNames.unstableAffliction,"mouseover"), "mouseover"},
            -- Life Tap
            { spellNames.lifeTap, jps.mana() < 0.4 and jps.mana() < jps.hp("player") },
            -- Filler
            { spellNames.drainSoul, burnPhase },
            { spellNames.maleficGrasp },
        }
        
        local res = parseSpellTable( singleTargetSpellTable )
        return res
    end
end


--[[
DANGER HERE BE DRAGONS!
]]--


local timer, throttle = 0, 0.1
local myGUID
local dotDamage, targets, trackedSpells = {},{},{}
local inCombat = false
local isInitialized = false
local afflictionLock = CreateFrame("Frame", "afflictionLock", UIParent)


-- Slash Command to enable/disable MouseOver Targets
SLASH_WL_AFFLI1 = '/wla'
function WarlockAffliHandler(msg, editBox)
    ignoreMouseOverTargets = not ignoreMouseOverTargets
    if ignoreMouseOverTargets then
        print("MouseOver Targets are now ignored")
    else
        print("MouseOver Targets are evaluted")
    end
end
SlashCmdList["WL_AFFLI"] = WarlockAffliHandler


function isRecast(spell,target)
    return jps.LastCast == spell and jps.LastTarget == target
end

-- Checks whether the Spell should be cast on the given target
function shouldSpellBeCast(spellId, target)
    --print("Should Spell "..spellId.." be cast on "..target.."?")
    local guid = UnitGUID(target)
    local name,rank,_ = GetSpellInfo(spellId)
    local _,_,_,_,_,duration,expires = UnitDebuff(target,name,rank,"player")
    
    if duration and guid and targets[guid..spellId] then
    --print("Pandemic: "..targets[guid..spellId][4].pandemicSafe.." Strength: "..targets[guid..spellId][4].strength)
        local timeLeft = expires - GetTime()
        if targets[guid..spellId][4].pandemicSafe then
            if targets[guid..spellId][4].strength > 100 then
                --print("Recasting: "..name.."@ "..target.." (Pandemic Safe @ "..targets[guid..spellId][4].strength.."% with "..timeLeft.." sec left)")
                return true
            else
                if timeLeft > 4 then
                    return false
                else
                    --print("Recasting: "..name.."@ "..target.." (Pandemic Safe @ "..targets[guid..spellId][4].strength.."% with "..timeLeft.." sec left)")
                    return true
                end
            end
        else
            --TODO: Be more specific when to clip dots...20% increase is nice, but a better logic might increse dps further
            if targets[guid..spellId][4].strength > 120 then
                --print("Recasting: "..name.."@ "..target.." (NOT Pandemic Safe @ "..targets[guid..spellId][4].strength.."% with "..timeLeft.." sec left)")
                return true
            else
                return false
            end
        end
    else
        return true
    end
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
        parseCombatLog(type,spellId,sourceGUID,destGUID)
    elseif event == "COMBAT_RATING_UPDATE" or event == "SPELL_POWER_CHANGED" or event == "UNIT_STATS" or event == "PLAYER_DAMAGE_DONE_MODS" then
        updateDotDamage()
    elseif event == "PLAYER_REGEN_DISABLED" then
        setCombatStarted()
    elseif event == "PLAYER_REGEN_ENABLED" then
        setCombatEnded()
    elseif event == "PLAYER_TALENT_UPDATE" then
        registerEvents()
    end
end

-- Disable Comat
function setCombatEnded()
    inCombat = false
    local t = GetTime()
    for k,v in pairs(targets) do
        if targets[k][2] < t-120 then targets[k]=nil end
    end
end

-- Enable Combat
function setCombatStarted()
    inCombat = true
end

-- Helper method to round up
local function round(num) return math.floor(num+.5) end

-- Add Spell to watched List
function trackSpell(id,target,duration,tick)
    local spell = {}
    if id > 0 then
        local n,r,_ = GetSpellInfo(id)
        spell["pandemic" ] = duration/3
        spell["name" ] = n
        spell["rank" ] = r
        spell["id" ] = id
        spell["timer" ] = 0
    end
    spell["tick" ] = tick
    spell["duration" ] = duration
    spell["target" ] = target
    spell.data = {strength=0, pandemicSafe=true}
    tinsert(trackedSpells, spell)
end

-- Checks whether Unending Affliction is gylphed
function getDotDurationMultiplier()
    for i=1,6 do
        local _,_,_,id,_ = GetGlyphSocketInfo(i)
        if id == 118778 then return 1.5 end
    end
    return 1
end

-- Register Events and sets OnUpdate/OnEvent Handler
function registerEvents()
    myGUID = UnitGUID("player")
    afflictionLock:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    afflictionLock:UnregisterEvent("COMBAT_RATING_UPDATE")
    afflictionLock:UnregisterEvent("SPELL_POWER_CHANGED")
    afflictionLock:UnregisterEvent("UNIT_STATS")
    afflictionLock:UnregisterEvent("PLAYER_REGEN_ENABLED")
    afflictionLock:UnregisterEvent("PLAYER_REGEN_DISABLED")
    afflictionLock:UnregisterEvent("PLAYER_DAMAGE_DONE_MODS")
    --afflictionLock:UnregisterEvent("PLAYER_FOCUS_CHANGED")
    afflictionLock:SetScript("OnUpdate", nil)
    afflictionLock:SetScript("OnEvent", nil)
    afflictionLock:Hide()
    spec = GetSpecialization() or ""
    -- Only Re
    if spec == 1 then
        updateDotDamage()
        afflictionLock:SetScript("OnEvent", handleEvent)
        afflictionLock:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        afflictionLock:RegisterEvent("COMBAT_RATING_UPDATE")
        afflictionLock:RegisterEvent("SPELL_POWER_CHANGED")
        afflictionLock:RegisterEvent("UNIT_STATS")
        afflictionLock:RegisterEvent("PLAYER_REGEN_ENABLED")
        afflictionLock:RegisterEvent("PLAYER_REGEN_DISABLED")
        afflictionLock:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
        --afflictionLock:RegisterEvent("PLAYER_FOCUS_CHANGED")
        afflictionLock:SetScript("OnUpdate", handleUpdate)
        afflictionLock:Show()
        local durationMultiplier = getDotDurationMultiplier()
        wipe(trackedSpells)
        --Track Dot's (id,target,duration,tick)
        trackSpell(spellIds.corruption, "target", 27*durationMultiplier, 9*durationMultiplier)
        trackSpell(spellIds.agony, "target", 36*durationMultiplier, 12*durationMultiplier)
        trackSpell(spellIds.unstableAffliction, "target", 21*durationMultiplier, 7*durationMultiplier)
        trackSpell(spellIds.corruption, "focus", 27*durationMultiplier, 9*durationMultiplier)
        trackSpell(spellIds.agony, "focus", 36*durationMultiplier, 12*durationMultiplier)
        trackSpell(spellIds.unstableAffliction, "focus", 21*durationMultiplier, 7*durationMultiplier)
        trackSpell(spellIds.corruption, "mouseover", 27*durationMultiplier, 9*durationMultiplier)
        trackSpell(spellIds.agony, "mouseover", 36*durationMultiplier, 12*durationMultiplier)
        trackSpell(spellIds.unstableAffliction, "mouseover", 21*durationMultiplier, 7*durationMultiplier)
    end
end

-- Updates the Tracked Spell with current Spell Power Values
function updateTrackedSpell(trackedSpell)
    local guid = UnitGUID(trackedSpell.target)
    local _,_,_,_,_,duration,expires = UnitDebuff(trackedSpell.target,trackedSpell.name,trackedSpell.rank,"player")
    if duration and guid and targets[guid..trackedSpell.id] then
        if(math.abs(expires-trackedSpell.timer)>1) then
            if trackedSpell.id == spellIds.agony then
                if targets[guid..trackedSpell.id][5] == 0 then
                    targets[guid..spellIds.agony][5] = expires
                elseif expires - targets[guid..trackedSpell.id][5] > 1 then
                    targets[guid..spellIds.agony][5] = expires
                    targets[guid..spellIds.agony][1] = dotDamage[spellIds.agony][1]
                    targets[guid..spellIds.agony][3] = dotDamage[spellIds.agony][2]
                end
            end
            --trackedSpell.data.expires = expires
            --trackedSpell.data.duration = duration
            --trackedSpell.timer = expires
        end
        --trackedSpell.datanew.color = colors[AffDots:FindColor(guid,expires - GetTime(),f.spell,f.pandemic)]
        --trackedSpell.data.tick = targets[guid..trackedSpell.id][3]
        --trackedSpell.data.strength = dotDamage[trackedSpell.id][1]*100/targets[guid..trackedSpell.id][1]
        targets[guid..trackedSpell.id][4].strength = dotDamage[trackedSpell.id][1]*100/targets[guid..trackedSpell.id][1]
        targets[guid..trackedSpell.id][4].delta = dotDamage[trackedSpell.id][1] - targets[guid..trackedSpell.id][1]
        if expires - GetTime() <= trackedSpell.pandemic then
            --trackedSpell.data.pandemicSafe = true
            targets[guid..trackedSpell.id][4].pandemicSafe = true
        else
            --trackedSpell.data.pandemicSafe = false
            targets[guid..trackedSpell.id][4].pandemicSafe = false
        end
    else
        trackedSpell.data.strength = 9000
        trackedSpell.data.delta = 9000
        trackedSpell.data.pandemicSafe = true
    end
end

-- Initialize DotTracker, will only be executed once
function initializeDotTracker()
    if not isInitialized then
        isInitialized = true
        afflictionLock:RegisterEvent("PLAYER_TALENT_UPDATE")
        registerEvents()
    end
end



-- Parce Combat Log to update Spell Power Values on Targets
function parseCombatLog(event,spellId,sourceGUID,destGUID)
    --print("sourceGUID " .. sourceGUID .. " event "..event)
    if(sourceGUID ~= myGUID or (event ~= "SPELL_AURA_REFRESH" and event ~= "SPELL_AURA_APPLIED" and event ~= "SPELL_DAMAGE")) then
        return
    end
    if(event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") then
        if(spellId == spellIds.unstableAffliction) then
            targets[destGUID..spellIds.unstableAffliction] = {dotDamage[spellIds.unstableAffliction][1],GetTime(),dotDamage[spellIds.unstableAffliction][2],{strength=100,pandemicSafe=false,delta=0}}
        elseif(spellId == spellIds.corruption or spellId == spellIds.seededCorruption) then
            targets[destGUID..spellIds.corruption] = {dotDamage[spellIds.corruption][1],GetTime(),dotDamage[spellIds.corruption][2],{strength=100,pandemicSafe=false,delta=0}}
        elseif(spellId == spellIds.agony) then
            targets[destGUID..spellIds.agony] = {dotDamage[spellIds.agony][1],GetTime(),dotDamage[spellIds.agony][2],{strength=100,pandemicSafe=false,delta=0},0}
        end
    elseif(event == "SPELL_DAMAGE" and spellId == 77799) then
        targets[destGUID..spellIds.corruption] = {dotDamage[spellIds.corruption][1],GetTime(),dotDamage[spellIds.corruption][2],{strength=100,pandemicSafe=false,delta=0}}
        targets[destGUID..spellIds.unstableAffliction] = {dotDamage[spellIds.unstableAffliction][1],GetTime(),dotDamage[spellIds.unstableAffliction][2],{strength=100,pandemicSafe=false,delta=0}}
    end
end

-- Update Damage Values
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
    tickEvery = 2/(1+(haste/100))
    
    -- Agony
    ticks = round(24/tickEvery)
    duration = ticks * tickEvery
    damage = ticks*(280+spd*0.26)*damageBonus*dmgBuff
    dps = round(damage/duration)
    dotDamage[spellIds.agony] = {round(dps/100)/10, tickEvery}
    
    -- Corruption
    ticks = round(18/tickEvery)
    duration = ticks * tickEvery
    damage = (1926+ticks*spd*0.2)*damageBonus*dmgBuff
    dps = round(damage/duration)
    dotDamage[spellIds.corruption] = {round(dps/100)/10, tickEvery}
    
    -- Unstable Affliction
    ticks = round(14/tickEvery)
    duration = ticks * tickEvery
    damage = (1792+ticks*spd*0.24)*damageBonus*dmgBuff
    dps = round(damage/duration)
    dotDamage[spellIds.unstableAffliction] = {round(dps/100)/10, tickEvery}
end
