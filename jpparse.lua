--[[
	 JPS - WoW Protected Lua DPS AddOn
	Copyright (C) 2011 Jp Ganis

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--

--------------------------
-- LOCALIZATION
--------------------------

local L = MyLocalizationTable
local LOG=jps.Logger(jps.LogLevel.ERROR)
--------------------------
-- Functions CAST
--------------------------
-- GetSpellInfo -- name, rank, icon, cost, isFunnel, powerType, castTime, minRange, maxRange = GetSpellInfo(spellId or spellName)
-- IsHarmfulSpell(spellname) -- IsHelpfulSpell(spellname)) returns 1 or nil -- USELESS SOMES SPELLS RETURNS NIL AS OUBLI, SPIRIT SHELL
-- IsSpellInRange(spellID, spellType, unit) -- spellType String, "spell" or "pet"
-- IsSpellInRange(spellName, unit) -- returns 0 if out of range, 1 if in range, or nil if the unit is invalid.
function jps_IsSpellInRange(spell,unit)
	if spell == nil then return false end
	if unit == nil then unit = "target" end 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

	local inRange = IsSpellInRange(spellname, unit)
 
	if inRange == nil then 
		local myIndex = nil 
		local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
		local booktype = "spell"
		for index = offset+1, numSpells+offset do 
			-- Get the Global Spell ID from the Player's spellbook 
			local spellID = select(2, GetSpellBookItemInfo(index, booktype))
			if spellID and spellname == GetSpellBookItemName(index, booktype) then 
				myIndex = index
				break -- because we have a match 
			end 
		end 
		-- If a Pet Spellbook is found, do the same as above and try to get an Index on the Spell 
		local numPetSpells = HasPetSpells()
		if myIndex == 0 and numPetSpells then 
			booktype = "pet"
			for index = 1, numPetSpells do 
				-- Get the Global Spell ID from the Pet's spellbook 
				local spellID = select(2, GetSpellBookItemInfo(index, booktype))
				if spellID and spellname == GetSpellBookItemName(index, booktype) then 
					myIndex = index
					break -- Breaking out of the for/do loop, because we have a match 
				end 
			end 
		end 

		if myIndex then 
			inRange = IsSpellInRange(myIndex, booktype, unit)
		end 
		return inRange
	end 
	return inRange
end 

-- Collecting the Spell GLOBAL SpellID, not to be confused with the SpellID
-- Matching the Spell Name and the GLOBAL SpellID will give us the Spellbook index of the Spell 
-- With the Spellbook index, we can then proceed to do a proper IsSpellInRange with the index.
function jps_SpellHasRange(spell)
	if spell == nil then return false end
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

	local hasRange = SpellHasRange(spellname)

	if hasRange == nil then 
		local myIndex = nil 
		local name, texture, offset, numSpells, isGuild = GetSpellTabInfo(2)
		local booktype = "spell"
		for index = offset+1, numSpells+offset do 
			-- Get the Global Spell ID from the Player's spellbook 
			local spellID = select(2, GetSpellBookItemInfo(index, booktype))
			if spellID and spellname == GetSpellBookItemName(index, booktype) then 
				myIndex = index
				break -- Breaking out of the for/do loop, because we have a match 
			end 
		end 

		if myIndex then 
			hasRange= SpellHasRange(myIndex, booktype)
		end 
		return hasRange
	end 
	return hasRange
end 

function jps.IsSpellInRange(spell,unit)
	if spell == nil then return false end
	--if jps_IsSpellInRange(spell,unit)~=1 then return false end
	if jps_IsSpellInRange(spell,unit)==0 then return false end
	return true
end

function jps.SpellHasRange(spell)
	if spell == nil then return false end
	if jps_SpellHasRange(spell)~=1 then return false end 
	return true
end

function jps.UnitExists(unit)
	if unit == nil then return false end
	if UnitExists(unit)~=1 then return false end
	if UnitIsVisible(unit)~=1 then return false end
	if UnitIsDeadOrGhost(unit)==1 then return false end
	return true
end

-- UnitInRange(unit) -- returns FALSE if out of range or if the unit is invalid. TRUE if in range
-- information is ONLY AVAILABLE FOR MEMBERS OF THE PLAYER'S GROUP 
-- when not in a party/raid, the new version of UnitInRange returns FALSE for "player" and "pet". The old function returned true.
-- jps.IsSpellKnown(spell) can be use below lvl 90
function jps.canHeal(unit)
	if not jps.UnitExists(unit) then return false end
	if GetUnitName("player") == GetUnitName(unit) then return true end
	if UnitCanAssist("player",unit)~=1 then return false end -- UnitCanAssist(unitToAssist, unitToBeAssisted) return 1 if the unitToAssist can assist the unitToBeAssisted, nil otherwise
	if UnitIsFriend("player",unit)~=1 then return false end -- UnitIsFriend("unit","otherunit") return 1 if otherunit is friendly to unit, nil otherwise. 
	-- PNJ returns 1 with UnitIsFriend -- PNJ returns 1 or nil (Vendors) with UnitCanAssist
	if UnitInVehicle(unit)==1 then return false end -- inVehicle - 1 if the unit is in a vehicle, otherwise nil
	if jps.PlayerIsBlacklisted(unit) then return false end
	if not select(1,UnitInRange(unit)) then return false end -- return FALSE when not in a party/raid reason why to be true for player GetUnitName("player") == GetUnitName(unit)
	return true
end

-- INVALID IF THE NAMED PLAYER IS NOT A PART OF YOUR PARTY OR RAID -- NEED .."TARGET"
-- JPS.CANDPS IS WORKING ONLY FOR PARTYn..TARGET AND RAIDn..TARGET NOT FOR UNITNAME..TARGET
-- check if we can damage a unit
function jps.canDPS(unit) 
	if not jps.UnitExists(unit) then return false end
	if jps.PvP then 
		local iceblock = tostring(select(1,GetSpellInfo(45438))) -- ice block mage
		local divineshield = tostring(select(1,GetSpellInfo(642))) -- divine shield paladin
		if jps.buff(divineshield,unit) then return false end
		if jps.buff(iceblock,unit) then return false end
	end
	if (GetUnitName(unit) == L["Training Dummy"]) or (GetUnitName(unit) == L["Raider's Training Dummy"]) then return true end	
	if UnitCanAttack("player", unit)~=1 then return false end-- UnitCanAttack(attacker, attacked) return 1 if the attacker can attack the attacked, nil otherwise.
	if UnitIsEnemy("player",unit)~=1 then return false end -- WARNING a unit is hostile to you or not Returns either 1 ot nil -- Raider's Training returns nil with UnitIsEnemy
	if jps.PlayerIsBlacklisted(unit) then return false end -- WARNING Blacklist is updated only when UNITH HEALTH occurs 
	if not jps.IsSpellInRange(jps.HarmSpell,unit) then return false end
	return true
end

local battleRezSpells = {
tostring(select(1,GetSpellInfo(20484))), -- Druid: Rebirth
tostring(select(1,GetSpellInfo(61999))), -- DK: Raise Ally
tostring(select(1,GetSpellInfo(20707))), -- Warlock: Soulstone
tostring(select(1,GetSpellInfo(126393))) -- Hunter: Eternal Guardian

}
local function isBattleRez(spell)
		for _,v in ipairs(battleRezSpells) do
				if v == spell then return true end
		end
		return false
end

-- check if a spell is castable @ unit 
function jps.canCast(spell,unit)
	if spell == "" then return false end
	if unit == nil then unit = "target" end
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if jps.PlayerIsBlacklisted(unit) then return false end -- ADDITION jps.PlayerIsBlacklisted(unit) in CANCAST
	if not jps.UnitExists(unit) and not isBattleRez(spell) then return false end
	if spellname == nil then return false end
	spellname = string.lower(spellname)
	
	if jps.Debug then
		jps_canCast_debug(spell,unit) 
	end
	if(getSpellStatus(spellname ) == 0) then return false end -- NEW
	
	local usable, nomana = IsUsableSpell(spellname) -- usable, nomana = IsUsableSpell("spellName" or spellID)
	if not usable then return false end
	if nomana then return false end
	if (jps.cooldown(spellname)~=0) then return false end
	if jps.SpellHasRange(spell) and not jps.IsSpellInRange(spell,unit) then return false end
	if jps[spell] ~= nil and jps[spell] == false then return false end
	return true
end

----------------------
-- CAST
----------------------
-- "Death and Decay" 43265 -- DK
-- "Mass Dispel" 32375 -- Priest
-- "Power Word: Barrier" 62618 -- Priest
-- "Flamestrike" 2120 -- Mage
-- "Rain of Fire" 104233 -- Mage
-- "Dizzying Haze" 118022 -- Brewmaster
-- "Light's Hammer" 114158 -- Paladin
-- "Healing Rain" 73921 -- Shaman
-- "wild mushroom" 88747 -- Druid
-- "Explosive Trap" 13813 - Hunter
-- "Ice Trap" 13809 - Hunter
-- "Snake Trap" 34600 - Hunter
-- "Freezing Trap" 1499 - Hunter
-- "Summon Jade Serpent Statue" - 115313 Monk
-- "Healing Sphere" - 115460 Monk
-- "demoralizing banner" - 114203 warrior
-- "mocking banner" - 114192 warrior 
-- "heroic leap" - 6544 warrior
-- "Freeze" - 33395 Frost Mage
-- "Rune Of Power" 116011- Mage
-- "Rain of Fire" 5740 -- Warlock
-- "Lightwell" 724 - Priest
-- "Holy Word: Sanctuary" 88685 - Priest
-- "Shadowfury" 30283 - Warlock

jps.spellNeedSelectTable = {30283,88685,724,32375,43265,62618,2120,104233,118022,114158,73921,88747, 13813, 13809, 34600, 1499, 115313, 115460, 114203, 114192, 6544, 33395, 116011, 5740}
function jps.spellNeedSelect(spell)
	local spellname = nil
	if type(spell) == "string" then spellname = string.lower(spell) end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end

	for i,j in ipairs (jps.spellNeedSelectTable) do
		if spellname == string.lower(tostring(select(1,GetSpellInfo(j)))) then return true end 
	end
	return false
end

function jps.Cast(spell) -- "number" "string"
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if jps.Target == nil then jps.Target = "target" end
	if not jps.Casting then jps.LastCast = spellname end
	
	if jps.spellNeedSelect(spellname) and SpellIsTargeting() then jps.groundClick() end

	CastSpellByName(spellname,jps.Target) -- CastSpellByID(spellID [, "target"])
	jps.timedCasting[string.lower(spell)] = math.ceil(GetTime())
	jps.CastBar.currentSpell = spellname
	jps.CastBar.currentTarget = jps.Target
	jps.CastBar.currentMessage = jps.Message
	
	if (jps.IconSpell ~= spellname) or (jps.Target ~= jps.LastTarget) then
		jps.set_jps_icon(spellname)
		if jps.Debug then write(spellname,"|cff1eff00",jps.Target,"|cffffffff",jps.Message) end
	end

	jps.LastTarget = jps.Target
	jps.LastTargetGUID = UnitGUID(jps.Target)
	jps.Target = nil
	jps.Message = ""
	jps.ThisCast = nil
end

jps.UserInitiatedSpellsToIgnore = {
	-- General Skills
	6603, -- Auto Attack (prevents from toggling on/off)
	-- Monk Skills
	109132, -- Roll (Unless you want to roll off cliffs, leave this here)
	137639, -- Storm, Earth, and Fire (prevents you from destroying your copy as soon as you make it)
	115450, -- Detox (when casting Detox without any dispellable debuffs, the cooldown resets)
	119582, -- Purifying Brew (having more than 1 chi, this can prevent using it twice in a row)
	115008, -- Chi Torpedo (same as roll)
	101545, -- Flying Serpent Kick (prevents you from landing as soon as you start "flying")
	115921, -- Legacy of The Emperor
	116781, -- Legacy of the White Tiger
	115072, -- Expel Harm (below 35%, brewmasters ignores cooldown on this spell)
	115181, -- Breath of Fire (if you are chi capped, this can make you burn all your chi)
	115546, -- Provoke (prevents you from wasting your taunt)
	116740, -- Tigereye Brew (prevents you from wasting your stacks and resetting your buff)
	115294, -- Mana Tea (This isn't an instant cast, but since it only has a 0.5 channeled time, it can triggers twice in the rotation)
	111400, -- warlock burning rush
}

function jps.isRecast(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	
	if unit==nil then unit = "target" end
	
	return jps.LastCast==spellname and UnitGUID(unit)==jps.LastTargetGUID
end

function jps.shouldSpellBeIgnored(spell)
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if not spellname then return false end
	spellname = spellname:lower()
	local result = false
	for _, v in pairs(jps.UserInitiatedSpellsToIgnore) do
		if spellname == string.lower(tostring(select(1,GetSpellInfo(v)))) then
			return true
		end
	end
	return false
end

----------------------
-- DEBUG MODE
----------------------`

function jps_canHeal_debug(unit)
	if not jps.UnitExists(unit) then write("not Unit") return false end
	if GetUnitName("player") == GetUnitName(unit) then write("Player") return true end
	if UnitExists(unit)~=1 then write("not Exists") return false end
	if UnitIsVisible(unit)~=1 then write("not Visible") return false end
	if UnitIsDeadOrGhost(unit)==1 then write("Dead") return false end
	if UnitCanAssist("player",unit)~=1 then write("not Friend") return false end
	if UnitInVehicle(unit)==1 then write("in Vehicle") return false end
	if jps.PlayerIsBlacklisted(unit) then write("Blacklist") return false end
	if not select(1,UnitInRange(unit)) then write("not inRange") return false end
	write("Passed all tests canHeal".."|cffa335ee"..unit)
	return true
end

function jps_canCast_debug(spell,unit) -- NEED A SPELLNAME
	LOG.info("Can Cast Debug for %s @ $s ", spell, unit)
	if spell == nil then LOG.info("spell is nil	%s @ $s", spell, unit)return false end
	if not jps.UnitExists(unit) then LOG.info("invalid unit	%s @ $s", spell, unit) return false end

	local usable, nomana = IsUsableSpell(spell) -- IsUsableSpell("spellName" or spellID)
	if not usable then LOG.info("spell is not sable	%s @ $s", spell, unit) return false end
	if nomana then LOG.info("failed mana test	%s @ $s", spell, unit) return false end
	if jps.cooldown(spell)~=0 then LOG.info("cooldown not finished	%s @ $s", spell, unit) return false end
	if jps_SpellHasRange(spell)~=1 then LOG.info("spellhasRange check failed	%s @ $s", spell, unit) return false end

	if jps_IsSpellInRange(spell,unit)~=1 then LOG.info("not in range	%s @ $s", spell, unit) return false end
	LOG.info("Passed all tests	%s @ $s", spell, unit)
	return true
end

-------------------------
-- SPELL CONFIG METHODS
-------------------------
function setSpellStatus(spell, status)
	spell = string.lower(spell)
	jps.spellConfig[jps.Spec][spell] = status
end

function getSpellStatus(spell)
	spell = spell:lower() --spell = string.lower(spell)
	local spellConfig = jps.spellConfig[jps.Spec][spell]
	if(spellConfig == nil) then
		setSpellStatus(spell, 1)
		jps.addSpellCheckboxToFrame(spell)
		return 1
	else
		return jps.spellConfig[jps.Spec][spell]
	end
end

-------------------------
-- PARSE NON-STATIC SPELLTABLE
-------------------------

--[[ -- MultiTable
function jps.IsCastingPoly( unit )
	if ... then return false end
	return true
end
parseMultiUnitTable( { "shadow word: death", jps.IsCastingPoly, {"arena1","arena2","arena3"} } )

the code is equivalent to:

parseSpellTable(
 {
	 { "shadow word: death", jps.IsCastingPoly("arena1") , "arena1" },
	 { "shadow word: death", jps.IsCastingPoly("arena2") , "arena2" },
	 { "shadow word: death", jps.IsCastingPoly("arena3") , "arena3" },
 }
)
--]]

function parseMultiUnitTable( spellTable )
	local spell = spellTable[1]
	local unitFunction = spellTable[2]
	local targets = spellTable[3]
	local message = spellTable[4]
	if message == nil then message = "" end
	local sirenTable = {}

	for _, unit in pairs(targets) do
		local unitTable = {}
		table.insert( unitTable, 1, spell )
		table.insert( unitTable, 2, unitFunction(unit) )
		table.insert( unitTable, 3, unit )
		table.insert( unitTable, 4, message..unit )
		table.insert( sirenTable, unitTable )
	end

	return parseSpellTable(sirenTable)
end

function conditionsMatched(spell,conditions)
	-- nil
	if spell == nil then
		return false
	-- nil
	elseif conditions == nil then
		return true
	-- onCD
	elseif conditions == "onCD" then
		return true
	-- otherwise
	else
		return conditions
	end
end

-- Pick a spell from a priority table.
function parseSpellTable( hydraTable )
	if jps.firstInitializingLoop == true then return nil,"target" end
	local spell = nil
	local conditions = nil
	local target = nil
	local message = ""

	for _, spellTable in pairs(hydraTable) do
		if type(spellTable) == "function" then spellTable = spellTable() end
		spell = spellTable[1] 
		conditions = spellTable[2]
		target = spellTable[3]
		if not target then target = "target" end
		message = spellTable[4]
		if message == nil then message = "" end
		if jps.Message ~= message then jps.Message = message end

		-- NESTED TABLE
		if spell == "nested" and conditions then
			local newTable = spellTable[3]
			spell,target = parseSpellTable( newTable )

		-- MACRO -- BE SURE THAT CONDITION TAKES CARE OF CANCAST -- TRUE or FALSE -- NOT NIL
		elseif type(spell) == "table" and spell[1] == "macro" and conditions then
			local macroText = spell[2]
			local macroTarget = spell[3]
 			
			if conditions and type(macroText) == "string" then
				local macroSpell = macroText
				if string.find(macroText,"%s") == nil then -- {"macro","/startattack"}
					macroSpell = macroText
				else 
					macroSpell = select(3,string.find(macroText,"%s(.*)")) -- {"macro","/cast Sanguinaire"}
				end
				if not jps.Casting then jps.Macro(macroText) end -- Avoid interrupt Channeling with Macro
				if jps.Debug then macrowrite(macroSpell,"|cff1eff00",macroTarget,"|cffffffff",jps.Message) end
			end
		
			if conditions and type(macroText) == "table" then
				for _,sequence in ipairs (macroText) do
					local spellname = tostring(select(1,GetSpellInfo(sequence)))
					if jps.canCast(spellname,macroTarget) then
						local macroText = "/cast "..spellname
						if not jps.Casting then jps.Macro(macroText) end -- Avoid interrupt Channeling with Macro
						if jps.Debug then macrowrite(spellname,"|cff1eff00",macroTarget,"|cffffffff",jps.Message) end
					end
				end
			end

		-- MultiTarget List -- { spell , function_unit , table_unit }
		elseif type(conditions) == "function" and type(target) == "table" then
			spell,target = parseMultiUnitTable(spellTable)
		end

		-- If not already assigned, assign target now.
		if not target and type(spellTable[3]) == "string" then
			target = spellTable[3]
		end

		-- Return spell if conditions are true and spell is castable.
		if type(spell) ~= "table" and conditionsMatched(spell,conditions) and jps.canCast(spell,target) then
			jps.CastBar.nextSpell = tostring(select(1,GetSpellInfo(spell)))
			jps.CastBar.nextTarget = target
			return spell,target 
		end
	end
	return nil
end

-------------------------
-- MULTIPLE ROTATIONS
-------------------------
function hideDropdown()
	rotationDropdownHolder:Hide()
end