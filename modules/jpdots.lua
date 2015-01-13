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
local L = MyLocalizationTable
local dotTracker = {}
jps.dotTracker = dotTracker
dotTracker.log = jps.Logger(jps.LogLevel.ERROR)

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
[br]
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
		return function()

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
@function jps.dotTracker.castTableStaticOtherUnits
@description 
Generates a static Spell Table Function for the given DoT for old-style Spell Tables.[br]
The DoT Tracker will track your DoT's on all valid units except your current target ( [code]focus[/code], [code]mouseover[/code] and [code]boss1-4[/code]) and will tell you when to recast the spell.
If it is pandemic safe and you don't loose DPS your DoT's will always be re-applied. If it is not pandemic safe
[br]
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
function jps.dotTracker.castTableStaticOtherUnits(spellId)
	-- find actual spell id, it was given as spell table key or spell table entry
		return function()

		local name,rank,_ = GetSpellInfo(spellId)
		-- if no unit is given, try all of them
		if not unit then
			for i, dottableUnit in ipairs(dotTracker.dottableUnits) do
				if UnitExists(unit) then
					if dotTracker.shouldSpellBeCast(spellId, dottableUnit) and ( not UnitIsUnit(unit, "target") or unit ~= "target")then
						return dotTracker.setStaticResult(spellId, name, true, dottableUnit)
					end 
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

function jps.dotTracker.isTrivial(unit)
	if not UnitExists(unit) then return true end
	if (string.match(GetUnitName(unit), L["Dummy"])) then return false end	

	if UnitLevel(unit) < UnitLevel("player") and UnitLevel(unit) ~= -1 then 
		return true
	end
	if UnitLevel(unit) == -1 then return false end
	members = GetNumGroupMembers() or 1
	if UnitHealth(unit) < ((members * UnitHealthMax("player")) /3 ) then
		return true
	end
	return false
end

--[[[ Internal Function - Recast Logic ]]--
function dotTracker.shouldSpellBeCast(spellId, unit)
	if tonumber(spellId) then
		name = GetSpellInfo(name)
	else
		name = spellId
	end
	-- check if we can attack
	if not jps.canDPS(unit) then 
		return false
	end
	if jps.Class == L["Warlock"] then
		if jps.Spec == "Destruction" then
			if UnitName("target") == "Spore Shooter" then return false end -- we need a better logic for small adds... like on brackenspore, Mar'gok.. we never ever need to put immolate on them 
		end
	end
	
	if jps.IsCastingSpell("Arcane Protection",unit) then return false end
	if jps.IsCastingSpell("Awaken Runestone",unit) then return false end

	if jps.dotTracker.isTrivial(unit) and jps.Spec ~= "Affliction" then 
		return false 
	end
	
	-- here's the actual logic
	local _,_,_,_,_,duration,expires = UnitDebuff(unit,name,"","player")
	local castSpell = false

	if duration then
		local timeLeft = expires - GetTime()
		local myCastLeft = jps.CastTimeLeft("player")
		if timeLeft <= (3 + myCastLeft) then
			castSpell = true
		end
	else
		castSpell = true
	end

	-- avoid double casts!
	local wasLastCast = jps.LastCast == name and jps.LastTargetGUID == UnitGUID(unit)
	if jps.IsCastingSpell(name, "player") then return false end
	return castSpell and not wasLastCast
end
