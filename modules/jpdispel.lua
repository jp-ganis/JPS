--[[
	 JPS - WoW Protected Lua DPS AddOn
	Copyright (C) 2011 Jp Ganis

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program. If not, see <http://www.gnu.org/licenses/>.
]]--

--------------------------
-- LOCALIZATION
--------------------------

local L = MyLocalizationTable

--------------------------
-- Dispel Functions LOOP
--------------------------

function jps.canDispel( unit, ... )
	for _, dtype in pairs(...) do
		if jps_Dispels[dtype] ~= nil then
			for _, spell in pairs(jps_Dispels[dtype]) do
				if jps.debuff(spell,unit) then return true end
			end
		end
	end
	return false
end

function jps.FindMeDispelTarget(dispeltypes) -- jps.FindMeDispelTarget({"Magic"}, {"Poison"}, {"Disease"})
	for unit,index in pairs(jps.RaidStatus) do
		if (index["inrange"] == true) and jps.canDispel(unit,dispeltypes) then return unit end
	end
end

function jps.MagicDispel(unit,debuffunit) -- "Magic" -- "Disease" -- "Poison"
	if not jps.canHeal(unit) then return false end
	if debuffunit == nil then debuffunit = "Magic" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.DiseaseDispel(unit,debuffunit) -- "Magic" -- "Disease" -- "Poison"
	if not jps.canHeal(unit) then return false end
	if debuffunit == nil then debuffunit = "Disease" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then 
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.PoisonDispel(unit,debuffunit) -- "Magic" -- "Disease" -- "Poison"
	if not jps.canHeal(unit) then return false end
	if debuffunit == nil then debuffunit = "Poison" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then 
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.CurseDispel(unit,debuffunit) 
	if not jps.canHeal(unit) then return false end
	if debuffunit == nil then debuffunit = "Curse" end
	local auraName, icon, count, debuffType, expirationTime, castBy
	local i = 1
	auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	while auraName do
		if debuffType==debuffunit then 
		return true end
		i = i + 1
		auraName, _, icon, count, debuffType, _, expirationTime, castBy, _, _, spellId = UnitDebuff(unit, i) -- UnitAura(unit,i,"HARMFUL") 
	end
	return false
end

function jps.DispelMagicTarget()
	for unit,index in pairs(jps.RaidStatus) do	 
		if (index["inrange"] == true) and jps.MagicDispel(unit) then return unit end
	end
end 

function jps.DispelDiseaseTarget()
	for unit,index in pairs(jps.RaidStatus) do	 
		if (index["inrange"] == true) and jps.DiseaseDispel(unit) then return unit end
	end
end 

function jps.DispelPoisonTarget()
	for unit,index in pairs(jps.RaidStatus) do	 
		if (index["inrange"] == true) and jps.PoisonDispel(unit) then return unit end
	end
end 

function jps.DispelCurseTarget()
	for unit,index in pairs(jps.RaidStatus) do	 
		if (index["inrange"] == true) and jps.CurseDispel(unit) then return unit end
	end
end 

--------------------------
-- Dispel Functions TABLE
--------------------------

-- Don't Dispel if unit is affected by some debuffs
jps.stopDispelTable = {
	30108,131736, 	-- "Unstable Affliction"
	33763,94447, 	-- "Lifebloom"
	34914,124465, 	-- "Vampiric Touch"
}
function jps.NoDispelFriendly(unit)
	if not jps.canHeal(unit) then return false end
	for _,debuff in pairs(jps.stopDispelTable) do
		if jps.debuff(debuff,unit) then return true end -- Don't dispel if friend is affected by "Unstable Affliction" or "Vampiric Touch" or "Lifebloom"
	end
	return false
end

-- Dispel all debuff in the debuff table EXCEPT if unit is affected by some debuffs
function jps.DispelFriendly(unit)
	if not jps.canHeal(unit) then return false end
	if jps.NoDispelFriendly(unit) then return false end
	for _, debuff in pairs(jps_DebuffToDispel_Name) do
	  if jps.debuff(debuff,unit) then
	  return true end
	end
	return false
end

function jps.DispelFriendlyTarget()
	for unit,index in pairs(jps.RaidStatus) do	 
		if (index["inrange"] == true) and jps.DispelFriendly(unit) then 
		return unit end
	end
end

------------------------------------
-- OFFENSIVE Dispel -- STUN DEBUFF
------------------------------------

-- arena1 to arena5 - A member of the opposing team in an Arena match
-- { 528, jps.DispelOffensive(unit) , {"arena1","arena2","arena3"} },
function jps.DispelOffensive(unit)
	if not jps.canDPS(unit) then return false end
	for _, buff in pairs(jps_BuffToDispel_Name) do
		if jps.buff(buff,unit) then -- and debuffType=="Magic"
		return true end
	end
	return false
end

function jps.dispelActive() 
	if not jps.Interrupts then return false end
	return true
end
