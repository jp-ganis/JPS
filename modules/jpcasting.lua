--[[[
@module JPS Casting
@description
Functions which handle casting & channeling stuff.
]]--

--------------------------
local L = MyLocalizationTable


--------------------------
-- CASTING SPELL
--------------------------

--name, subText, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
--name, subText, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("unit")

function jps.CastTimeLeft(unit)
	if unit == nil then unit = "player" end
	local spellName,_,_,_,_,endTime,_,_,_ = UnitCastingInfo(unit)
	if endTime == nil then return 0 end
	return ((endTime - (GetTime() * 1000 ) )/1000), spellName
end

function jps.ChannelTimeLeft(unit)
	if unit == nil then unit = "player" end
	local spellName,_,_,_,_,endTime,_,_,_ = UnitChannelInfo(unit)
	if endTime == nil then return 0 end
	return ((endTime - (GetTime() * 1000 ) )/1000), spellName
end

function jps.IsCasting(unit)
	if unit == nil then unit = "player" end
	local enemycasting = false
	if jps.CastTimeLeft(unit) > 0 or jps.ChannelTimeLeft(unit) > 0 then -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
		enemycasting = true
	end
	return enemycasting
end

function jps.IsCastingSpell(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local name, _, _, _, startTime, endTime, _, _, interrupt = UnitCastingInfo(unit) -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
	if not name then return false end
	if spellname:lower() == name:lower() and jps.CastTimeLeft(unit) > 0 then return true end
	return false
end

function jps.IsChannelingSpell(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local name, _, _, _, startTime, endTime, _, interrupt = UnitChannelInfo(unit) -- WORKS FOR CASTING SPELL NOT CHANNELING SPELL
	if not name then return false end
	if spellname:lower() == name:lower() and jps.ChannelTimeLeft(unit) > 0 then return true end
	return false
end

function jps.spellCastTime(spell)
	return select(4, GetSpellInfo(spell)) /1000
end

jps.polySpellIds = {
	[51514] = "Hex" ,
	[118]	= "Polymorph" ,
	[61305] = "Polymorph: Black Cat" ,
	[28272] = "Polymorph: Pig" ,
	[61721] = "Polymorph: Rabbit" ,
	[61780] = "Polymorph: Turkey" ,
	[28271] = "Polymorph: Turtle" ,
}

jps.CCSpellIds = {
	-- Priest
	[605]=	"Mind Control",
	-- Druid
	[339] =		"Entangling Roots",
	[33786] =	"Cyclone",
	[2637] =	"Hibernate",
	-- Hunter
	[1499] =	"Freezing Trap",
	[13809] =	"Frost Trap",
	[34600] =	"Snake Trap",
	-- Mage
	[118] =		"Polymorph",
	[61305] = 	"Polymorph: Black Cat" ,
	[28272] = 	"Polymorph: Pig" ,
	[61721] = 	"Polymorph: Rabbit" ,
	[61780] = 	"Polymorph: Turkey" ,
	[28271] = 	"Polymorph: Turtle" ,
	-- Warlock
	[5782] =	"Fear",
	[5484] =	"Howl of Terror",
	-- Warrior

	-- Shaman
	[51514] =	"Hex"
}

-- Enemy Casting Polymorph Target is Player
function jps.IsCastingPoly(unit)
	if not jps.canDPS(unit) then return false end
	local delay = 0
	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)

	for spellID,spellname in pairs(jps.polySpellIds) do
		if UnitIsUnit(unit.."target", "player") == 1 and spell == tostring(select(1,GetSpellInfo(spellID))) and jps.CastTimeLeft(unit) > 0 then
			delay = jps.CastTimeLeft(unit) - jps.Lag
		break end
	end

	if delay < 0 then return true end
	return false
end

-- Enemy casting CrowdControl Spell
function jps.IsCastingControl(unit)
	if not jps.canDPS(unit) then return false end
	local delay = 0
	local spell, _, _, _, startTime, endTime = UnitCastingInfo(unit)

	for spellID,spellname in pairs(jps.CCSpellIds) do
		if spell == tostring(select(1,GetSpellInfo(spellID))) and jps.CastTimeLeft(unit) > 0 then
			delay = jps.CastTimeLeft(unit)
		break end
	end

	if delay > 0 then return true end
	return false
end

-- returns cooldown off a spell
function jps.cooldown(spell) -- start, duration, enable = GetSpellCooldown("name") or GetSpellCooldown(id)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if not jps.IsSpellKnown(spellname) then return 999 end
	if jps.Lag == nil then jps.Lag = 0 end
	local start,duration,_ = GetSpellCooldown(spellname)
	if start == nil then return 0 end
	local cd = start+duration-GetTime() -- jps.Lag
	if cd < 0 then return 0 end
	return cd
end


function jps_IsSpellKnown(spell)
	local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
	local booktype = "spell"
	local mySpell = nil
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	for index = offset+1, numSpells+offset do
		-- Get the Global Spell ID from the Player's spellbook
		local spellID = select(2,GetSpellBookItemInfo(index, booktype))
		local slotType = select(1,GetSpellBookItemInfo(index, booktype))
		local name = select(1,GetSpellBookItemName(index, booktype))
		if ((spellname:lower() == name:lower()) or (spellname == name)) and slotType ~= "FUTURESPELL" then
			mySpell = spellname
			break -- Breaking out of the for/do loop, because we have a match
		end
	end
		
	local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(1)
	for index = offset+1, numSpells+offset do
		-- Get the Global Spell ID from the Player's spellbook
		local spellID = select(2,GetSpellBookItemInfo(index, booktype))
		local slotType = select(1,GetSpellBookItemInfo(index, booktype))
		local name = select(1,GetSpellBookItemName(index, booktype))
		if ((spellname:lower() == name:lower()) or (spellname == name)) and slotType ~= "FUTURESPELL" then
			mySpell = spellname
			break -- Breaking out of the for/do loop, because we have a match
		end
	end			
	return mySpell
end


function jps.IsSpellKnown(spell)
	if jps_IsSpellKnown(spell) == nil then return false end
return true
end
------------------------------
-- PLUA PROTECTED
------------------------------

function jps.groundClick()
	jps.Macro("/console deselectOnClick 0")
	CameraOrSelectOrMoveStart()
	CameraOrSelectOrMoveStop()
	jps.Macro("/console deselectOnClick 1")
end

function jps.faceTarget()
	InteractUnit("target")
end

function jps.moveToTarget()
	InteractUnit("target")
end

function jps.Macro(text)
	RunMacroText(text)
end


---------
-- timed casting
---------

function jps.castEverySeconds(spell, seconds)
	if not jps.timedCasting[string.lower(spell)] then
		return true
	end
	if jps.timedCasting[string.lower(spell)] + seconds <= GetTime() then
		return true
	end
	return false
end


--[[[
@function jps.cancelCasting
@description
Cancels spell casting on matched conditions. Useful for overhealing, execute phases, long cast's / channels. Careful: currently only "dynamic" tables are supported, this leaks currently some memory!
@param table with spell & condition: {"pew pew healspell","jps.hp(unit) > 0.9"},{"less pew healspell","jps.hp(unit) > 0.5"}....
]]--
function jps.cancelCasting(hydraTable)
	if not hydraTable or type(hydraTable) ~= "table" then
		write("jps.cancelCasting() wrong params in rotation "..jps.Spec.."  -  "..jps.Class)
		return false
	end
	for _, spellTable in pairs(hydraTable) do
		spell = spellTable[1]
		conditions = spellTable[2]
		local isCasting = false
		if jps.CastTimeLeft("player") > 0 then
			castTimeLeft, castSpellName = jps.CastTimeLeft("player")
			isCasting = true
		elseif jps.ChannelTimeLeft("player") > 0 then
			castTimeLeft, castSpellName = jps.ChannelTimeLeft("player")
			isCasting = true
		end
		if isCasting == true then
			if spell == "" or spell == nil or not spell then
				spell = "all" -- matches every spell casted
			end
			if (spell == "all" or spell:lower() == castSpellName:lower()) and conditionsMatched(spell, conditions) then
				return true
			end
		end
	end
	return false
end
