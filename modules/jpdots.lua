--[[[
@module DoT Tracker
@description 
DoT Tracker for DoT-Classes. Currently only Destruction-Warlocks and Affliction-Warlocks are supported.
[br][br]
The DoT Tracker will track your DoT's on all valid units ([code]target[/code], [code]focus[/code], [code]mouseover[/code] and [code]boss1-4[/code]) and will tell you when to recast the spell.
If it is pandemic safe and you don't loose DPS your DoT's will always be re-applied. If it is not pandemic safe
the DoT will only be re-applied if you gain at least 225K DPS - based on 150K average DPS this should compensate
for the lost GCD. If you don't have the DoT on the target or there is only 2 seconds left it will be applied ignoring any DPS difference.
[br][br]
The DoT Tracker can be used with normal tables (#ref:jps.dotTracker.castTable) but since normal tables
are deprecated you should instead convert your rotation to a static spell table and use the appropriate function (#ref:jps.dotTracker.castTableStatic).
]]--


local dotTracker = {}
jps.dotTracker = dotTracker
dotTracker.log = jps.Logger(jps.LogLevel.ERROR)
dotTracker.isInitialized = false
dotTracker.timer = 0
dotTracker.throttle = 0.1
dotTracker.myGUID = nil
dotTracker.classSpecificSpells = nil
dotTracker.classSpecificUpdateDotDamage = nil
dotTracker.frame = CreateFrame("Frame", "dotTracker", UIParent)
dotTracker.trackedSpells = {}
--[[[ Internal: Current DoT Damage ]]--
function dotTracker.toDotDamage(id,dps,dur,tE, ss) dotTracker.dotDamage[id] = {dps = dps, duration = dur, tickEvery = tE, snapshot = ss} end
dotTracker.dotDamage = {}

--[[[ Internal: Tracked Targets ]]--
function dotTracker.toTarget(guid, spellid) dotTracker.targets[guid..spellid] = { dps = dotTracker.dotDamage[spellid].dps, age = GetTime(), strength = 100, pandemicSafe = false} end
dotTracker.targets = {}
-- 
-- Spell Table
local function toSpell(id,r,altId) return { id = id, name = GetSpellInfo(id), refreshedByFelFlame = r, alternativeId = altId} end
dotTracker.spells = {}
	-- Warlock Spells
	dotTracker.spells["immolate"] = toSpell(157736, false, 108686) -- Immolate + Fire and Brimstone
	dotTracker.spells["felFlame"] = toSpell(77799)
	dotTracker.spells["corruption"] = toSpell(172, false, 146739) -- Corruption from Seed of Corruption
	dotTracker.spells["agony"] = toSpell(980, false)
	dotTracker.spells["unstableAffliction"] = toSpell(30108)
	dotTracker.spells["doom"] = toSpell(603)

-- Buff Table
local function toBuff(id,increase,increasePerStack,filter) return { id = id, name = GetSpellInfo(id), filter = filter or "HELPFUL", increase = increase, increasePerStack = increasePerStack or 0} end
dotTracker.buffs = {}
	dotTracker.buffs["fluidity"] = toBuff(138002, 0.4) -- +40%
	dotTracker.buffs["nutriment"] = toBuff(140741, 1, 0.1, "HARMFUL") -- +100% +10% per stack
	dotTracker.buffs["tricksOfTheTrade"] = toBuff(57934, 0.15) -- +15%
	dotTracker.buffs["fearless"] = toBuff(118977, 0.6) -- +60%

-- Supported Classes/Specs + Damage Calculation
local function toClass(fn,...) return { updateFunction = fn, spells = {...} } end

dotTracker.supportedClasses = {}
dotTracker.supportedClasses["WARLOCK"] = {
	toClass(function(mastery, haste, crit, spellDamage, damageBuff)
		local damageBonus = (1+crit/100)*(1+(mastery*3.1)/100)
		local tickEvery = 2/(1+(haste/100))
		
		local ticks = math.floor(24/tickEvery)
		local duration = ticks * tickEvery
		local damage = ((280 + spellDamage * 0.26) * ticks)*damageBonus*damageBuff
		local dps = damage / duration
		local snapshot = false;
		dotTracker.toDotDamage(dotTracker.spells.agony.id, dps, duration, tickEvery, snapshot)
		
		local ticks = math.floor(18/tickEvery)
		local duration = ticks * tickEvery
		local damage = (1440 + spellDamage * 0.15 * ticks)*damageBonus*damageBuff
		local dps = damage / duration
		local snapshot = false;
		dotTracker.toDotDamage(dotTracker.spells.corruption.id, dps, duration, tickEvery, snapshot)
		
		local ticks = math.floor(14/tickEvery)
		local duration = ticks * tickEvery
		local damage = (1792 + spellDamage * 0.24 * ticks)*damageBonus*damageBuff
		local dps = damage / duration
		local snapshot = false;
		dotTracker.toDotDamage(dotTracker.spells.unstableAffliction.id, dps, duration, tickEvery, snapshot)
	end, 
	dotTracker.spells.agony,dotTracker.spells.corruption,dotTracker.spells.unstableAffliction),
	
	toClass(function(mastery, haste, crit, spellDamage, damageBuff)
		local damageBonus = (1+crit/100)*(1+(mastery)/100)
		local tickEvery = 2/(1+(haste/100))
		local ticks = math.floor(24/tickEvery)
		local duration = ticks * tickEvery
		local damage = (1440 + spellDamage * 0.15 * ticks)*damageBonus*damageBuff
		local dps = damage / duration
		local snapshot = false;
		dotTracker.toDotDamage(dotTracker.spells.corruption.id, dps, duration, tickEvery,snapshot )
		
		local damageBonus = (1+crit/100)*(1+(mastery*3)/100)
		local tickEvery = 15/(1+(haste/100))
		local ticks = math.floor(60/tickEvery)
		local duration = ticks * tickEvery
		local damage = (4004/ticks+spellDamage*1.25*ticks)*damageBonus*damageBuff
		local dps = damage / duration
		local snapshot = false;
		dotTracker.toDotDamage(dotTracker.spells.doom.id, dps, duration, tickEvery, snapshot)
	end, 
	dotTracker.spells.corruption,dotTracker.spells.doom),
	toClass(function(mastery, haste, crit, spellDamage, damageBuff)
		local damageBonus = (1+crit/100)*(1+(mastery+1)/100)
		
		local tickEvery = 3/(1+(haste/100))
		local ticks = math.floor(15/tickEvery)
		local duration = ticks * tickEvery
		local damage = ((456+spellDamage*0.427)+(ticks*(456+spellDamage*0.427))*damageBonus*damageBuff)
		local dps = damage / duration
		local snapshot = false
		dotTracker.toDotDamage(dotTracker.spells.immolate.id, dps, duration, tickEvery, snapshot)
	end, 
	dotTracker.spells.immolate),
}

-- Unit which should be dotted
dotTracker.dottableUnits = { 
	"target",
	"focus",
	"mouseover",
	"boss1",
	"boss2",
	"boss3",
	"boss4",
}

local LOG = dotTracker.log


-- OnEvent Handler
--[[[ Internal Function - DON'T USE! ]]--
function dotTracker.handleEvent(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, sourceGUID, _, _, _, destGUID, _, _, _, spellId = ...

		sourceGUID = UnitGUIDnorm(sourceGUID, true)
		destGUID = UnitGUIDnorm(destGUID , true)

		if sourceGUID ~= dotTracker.myGUID then return end
			
		if eventType == "SPELL_AURA_APPLIED" or eventType == "SPELL_AURA_REFRESH"  then
			
			for k,spell in pairs(dotTracker.classSpecificSpells) do
				if spellId == spell.id or spellId == spell.alternativeId then
					LOG.warn("%s casted on Target: %s", spell.name, destGUID)
					dotTracker.toTarget(destGUID, spell.id)
				end
			end
		elseif eventType=="SPELL_AURA_REMOVED" then
			for k,spell in pairs(dotTracker.classSpecificSpells) do
				if spellId == spell.id or spellId == spell.alternativeId then
					LOG.warn("%s (%s) faded from Target: %s", spell.name, spellId, destGUID)
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
--[[[ Internal Function - DON'T USE! ]]--
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
--[[[ Internal Function - DON'T USE! ]]--
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
--[[[ Internal Function - DON'T USE! ]]--
function dotTracker.updateTrackedSpellsOnTargets(trackedSpell)
	local guid = UnitGUIDnorm(trackedSpell.target)
	local _,_,_,_,_,duration,expires = UnitDebuff(trackedSpell.target,trackedSpell.name,nil,"player")
	if duration and guid then
		local target = dotTracker.targets[guid..trackedSpell.id]
		if target then
			local newStrength = math.floor(dotTracker.dotDamage[trackedSpell.id].dps*100/target.dps)
			if target.strength ~= newStrength then
				target.strength = newStrength
			end
			if not target.pandemicSafe then
				if expires - GetTime() <= dotTracker.dotDamage[trackedSpell.id].duration/2 then
					target.pandemicSafe = true
				end
			end
		else
			LOG.debug("No %s on %s (%s)", trackedSpell.name, guid, trackedSpell.target)
		end
	end
end

-- Register Events and sets OnUpdate/OnEvent Handler
--[[[ Internal Function - DON'T USE! ]]--
function dotTracker.registerEvents()
	dotTracker.myGUID = UnitGUIDnorm("player")
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
	
	local class = select(2,UnitClass("player")) or "NONE"
	local spec = GetSpecialization() or -1

	if dotTracker.supportedClasses[class] and dotTracker.supportedClasses[class][spec] then
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
	else
		LOG.warn("Class %s with Spec %s is not supported!", class, spec)
	end
end

--[[[ Internal Function - DON'T USE! ]]--
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

dotTracker.results = {}

--[[[ Internal Function - DON'T USE! ]]--
function dotTracker.setStaticResult(spellId, name, condition, unit)
	if not dotTracker.results[spellId] then dotTracker.results[spellId] = {} end
	dotTracker.results[spellId][1] = name
	dotTracker.results[spellId][2] = condition
	dotTracker.results[spellId][3] = unit
	return dotTracker.results[spellId]
end


--[[[
@function jps.dotTracker.castTableStatic
@description 
Generates a static Spell Table Function for the given DoT for old-style Spell Tables.[br]
The DoT Tracker will track your DoT's on all valid units ([code]target[/code], [code]focus[/code], [code]mouseover[/code] and [code]boss1-4[/code]) and will tell you when to recast the spell.
If it is pandemic safe and you don't loose DPS your DoT's will always be re-applied. If it is not pandemic safe
the DoT will only be re-applied if you gain at least 225K DPS - based on 150K average DPS this should compensate
for the lost GCD. If you don't have the DoT on the target or there is only 2 seconds left it will be applied ignoring any DPS difference.[br]
[br][i]Usage:[/i][br]
[code]
local staticSpellTable = {[br]
...[br]
jps.dotTracker.castTable("Immolate"),[br]
...[br]
}[br]
[/code]
@param spellID Spell-ID to cast, can be a spell name, a spell id
@param unit [i]Optional:[/i] Unit to cast upon, if [code]nil[/code] all of [code]target[/code], 
			[code]focus[/code], [code]mouseover[/code] and [code]boss1-4[/code] will be tried in this order
@returns Spell-Table Function for static Spell Tables
]]--
function jps.dotTracker.castTableStatic(spellId, unit)
	-- find actual spell id, it was given as spell table key or spell table entry
	if not tonumber(spellId) then
		if tonumber(spellId.id) then 
			spellId = spellId.id
		elseif dotTracker.spells[spellId] then 
			spellId = dotTracker.spells[spellId].id
		else
			-- nothing left to try...
			LOG.error("Can't check spell: %s", tostring(spellId))
			return nil
		end
	end
	return function()
		-- Init if not already done
		if not dotTracker.isInitialized then
			LOG.warn("Initializing DoT Tracker...")
			dotTracker.frame:RegisterEvent("PLAYER_TALENT_UPDATE")
			dotTracker.registerEvents()
			dotTracker.isInitialized = true
			LOG.warn("...DoT Tracker initialized!")
		end
		local name,rank,_ = GetSpellInfo(spellId)
		-- if no unit is given, try all of them
		if not unit then
			for i, dottableUnit in ipairs(dotTracker.dottableUnits) do
				if dotTracker.shouldSpellBeCast(spellId, dottableUnit) then
					return dotTracker.setStaticResult(spellId, name, true, dottableUnit)
				end 
			end		   
			return dotTracker.setStaticResult(spellId, name, false)
		else
			return dotTracker.setStaticResult(spellId, name, dotTracker.shouldSpellBeCast(spellId, unit), unit)
		end
	end
end


--[[[
@function jps.dotTracker.castTable
@deprecated Use: #ref:jps.dotTracker.castTableStatic
@description 
Generates a Spell Table Element for the given DoT for old-style Spell Tables.[br]
The DoT Tracker will track your DoT's on all valid units ([code]target[/code], [code]focus[/code], [code]mouseover[/code] and [code]boss1-4[/code]) and will tell you when to recast the spell.
If it is pandemic safe and you don't loose DPS your DoT's will always be re-applied. If it is not pandemic safe
the DoT will only be re-applied if you gain at least 225K DPS - based on 150K average DPS this should compensate
for the lost GCD. If you don't have the DoT on the target or there is only 2 seconds left it will be applied ignoring any DPS difference.[br]
[br][i]Usage:[/i][br]
[code]
local spellTable = {[br]
...[br]
jps.dotTracker.castTable("Immolate"),[br]
...[br]
}[br]
[/code]
@param spellID Spell-ID to cast, can be a spell name, a spell id
@param unit [i]Optional:[/i] Unit to cast upon, if [code]nil[/code] all of [code]target[/code], 
            [code]focus[/code], [code]mouseover[/code] and [code]boss1-4[/code] will be tried in this order
@returns Spell-Table Element, e.g.: [code]{"Immolate", false, "mouseover"}[/code]
]]--
--JPTODO: Remove dotTracker.castTable when all Rotations use static tables
function jps.dotTracker.castTable(spellId, unit)
	return dotTracker.castTableStatic(spellId, unit)()
end

--[[[ Internal Function - Recast Logic ]]--
function dotTracker.shouldSpellBeCast(spellId, unit)
	if not tonumber(spellId) then
		if tonumber(spellId.id) then 
			spellId = spellId.id
		elseif dotTracker.spells[spellId] then 
			spellId = dotTracker.spells[spellId].id
		else
			-- nothing left to try...
			LOG.error("Can't check spell: %s", tostring(spellId))
			return false
		end
	end
	-- check if we can attack
	if not jps.canDPS(unit) then 
		return false
	end
	
	-- here's the actual logic
	local guid = UnitGUIDnorm(unit)
	local name,rank,_ = GetSpellInfo(spellId)
	local _,_,_,_,_,duration,expires = UnitDebuff(unit,name,rank,"player")
	local castSpell = false
	
	if duration and guid then
		local timeLeft = expires - GetTime()
		local myCastLeft = jps.CastTimeLeft("player")

		local target = dotTracker.targets[guid..spellId]
		local snapshot = dotTracker.dotDamage[spellId].snapshot
	
		if target then
			if target.pandemicSafe then
				if target.strength > 100 and snapshot == true then
					castSpell = true
				else
					if timeLeft <= (3 + myCastLeft) and select(1, UnitCastingInfo("player")) ~= name  then
						castSpell = true
					end
				end
			else
			--if enough dps increase - fuck pandemic!
				if target.strength > 100 and snapshot == true then
					damageDelta = (dotTracker.dotDamage[spellId].dps * dotTracker.dotDamage[spellId].duration) - (target.dps * timeLeft)
					-- assume 150k dps - if you waste 1.5 seconds for gcd (or immolate cast) you should get an increase of at least 225k to compensate
					if damageDelta >= 225000  then
						castSpell = true
					else
					end
				end
			end
			
		else
			castSpell = true
		end
	elseif guid then
		castSpell = true
	end

	-- avoid double casts!
	local wasLastCast = jps.LastCast == name and jps.LastTargetGUID == UnitGUIDnorm(unit)
	return castSpell and not wasLastCast
end
