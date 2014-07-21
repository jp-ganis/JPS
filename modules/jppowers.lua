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


------------------------------
-- HEALTH Functions
------------------------------

function jps.hp(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	if message == "abs" then
		return UnitHealthMax(unit) - UnitHealth(unit)
	else
		return UnitHealth(unit) / UnitHealthMax(unit)
	end
end

function jps.hpInc(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	local hpInc = UnitGetIncomingHeals(unit)
	if not hpInc then hpInc = 0 end
	if message == "abs" then
		return UnitHealthMax(unit) - (UnitHealth(unit) + hpInc)
	else
		return (UnitHealth(unit) + hpInc)/UnitHealthMax(unit)
	end
end

function jps.hpAbs(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	local hpInc = UnitGetIncomingHeals(unit)
	if not hpInc then hpInc = 0 end
	local hpAbs = UnitGetTotalAbsorbs(unit)
	if not hpAbs then hpAbs = 0 end
	if message == "abs" then
		return UnitHealthMax(unit) - (UnitHealth(unit) + hpInc + hpAbs)
	else
		return (UnitHealth(unit) + hpInc + hpAbs)/UnitHealthMax(unit)
	end
end

function jps.rage()
	return UnitPower("player",1)
end

function jps.energy()
	return UnitPower("player",3)
end

function jps.focus()
	return UnitPower("player",2)
end

function jps.runicPower()
	return UnitPower("player",6)
end

function jps.soulShards()
	return UnitPower("player",7)
end

function jps.eclipsePower()
	return UnitPower("player",8)
end

function jps.chi()
	return UnitPower("player", 12)
end

function jps.holyPower()
	return UnitPower("player",9)
end

function jps.shadowOrbs()
	return UnitPower("player",13)
end

function jps.burningEmbers()
	return UnitPower("player",14)
end

function jps.emberShards()
	return UnitPower("player",14, true)
end

function jps.demonicFury()
	return UnitPower("player",15)
end

function jps.mana(unit,message)
	if unit == nil then unit = "player" end
	if not UnitExists(unit) then return 1 end
	if message == "abs" or message == "absolute" then
		return UnitMana(unit)
	else
		return UnitMana(unit)/UnitManaMax(unit)
	end
end