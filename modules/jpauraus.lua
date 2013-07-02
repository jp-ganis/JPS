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


--------------------------
-- BUFF DEBUFF
--------------------------
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura("unit", index or "name"[, "rank"[, "filter"]])
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitDebuff("unit", index or ["name", "rank"][, "filter"]) 
-- name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitBuff("unit", index or ["name", "rank"][, "filter"])

function jps.buffId(spellId,unit)
	local spellname = nil
	if type(spellId) == "number" then spellname = tostring(select(1,GetSpellInfo(spellId))) end
	if unit == nil then unit = "player" end
	for i = 1, 40 do
		local auraName, _, _, count, _, duration, expirationTime, castBy, _, _, buffId = UnitBuff(unit, i)
		if spellId == buffId and auraName == spellname then return true end
		if not spellId then break end -- no more auras, terminate the loop 
	end
return false
end

function jps.buff(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	if select(1,UnitBuff(unit,spellname)) then return true end
	return false
end

function jps.debuff(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if select(1,UnitDebuff(unit,spellname)) then return true end
	return false
end

function jps.mydebuff(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if select(1,UnitDebuff(unit,spellname)) and select(8,UnitDebuff(unit,spellname))=="player" then return true end
	return false
end

function jps.myBuffDuration(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_,_ = UnitBuff(unit,spellname)
	if caster ~= "player" then return 0 end
	if duration == nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.myDebuffDuration(spell,unit) 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spellname)
	if caster~="player" then return 0 end
	if duration==nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.buffDuration(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_,_ = UnitBuff(unit,spellname)
	if duration == nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffDuration(spell,unit) 
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	if jps.Lag == nil then jps.Lag = 0 end
	local _,_,_,_,_,_,duration,caster,_,_ = UnitDebuff(unit,spellname)
	if duration==nil then return 0 end
	duration = duration-GetTime() -- jps.Lag
	if duration < 0 then return 0 end
	return duration
end

function jps.debuffStacks(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "target" end
	local _,_,_,count, _,_,_,_,_,_ = UnitDebuff(unit,spellname)
	if count == nil then count = 0 end
	return count
end

function jps.buffStacks(spell,unit)
	local spellname = nil
	if type(spell) == "string" then spellname = spell end
	if type(spell) == "number" then spellname = tostring(select(1,GetSpellInfo(spell))) end
	if unit == nil then unit = "player" end
	local _, _, _, count, _, _, _, _, _ = UnitBuff(unit,spellname)
	if count == nil then count = 0 end
	return count
end

function jps.buffTracker(buff)
	for unit,_ in pairs(jps.RaidStatus) do
		if jps.canHeal(unit) and jps.myBuffDuration(buff,unit) > 0 then
		return true end
	end
	return false
end

function jps.bloodlusting()
	return jps.buff("bloodlust") or jps.buff("heroism") or jps.buff("time warp") or jps.buff("ancient hysteria")
end