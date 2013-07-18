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
-- TABLE FUNCTIONS
--------------------------

function jps_tableSum(table)
	if table == nil then return 0 end
	local total = 0
	for i,j in ipairs(table) do
		total = total + table[i]
	end
	return total
end 

function jps_removeKey(table, key)
	if key == nil then return end
    local element = table[key]
    table[key] = nil
    return element
end

--get table length
function jps_tableLen(table)
	if table == nil then return 0 end
    local count = 0
    for k,v in pairs(table) do 
        count = count+1
    end
    return count
end

function jps_deepCopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--------------------------
-- STRING FUNCTION -- change a string "Bob" or "Bob-Garona" to "Bob"
--------------------------

function jps_stringTarget(unit,case)
	if unit == nil then return "UnKnown" end -- ERROR if threatUnit is nil
	local threatUnit = tostring(unit)
	local playerName = threatUnit
	local playerServer = "UnKnown"
	
	local stringLength = string.len(threatUnit)
	local startPos, endPos = string.find(threatUnit,case)  -- "-" "%s" space
	if ( startPos ) then
		playerName = string.sub(threatUnit, 1, (startPos-1))
		playerServer = string.sub(threatUnit, (startPos+1), stringLength)
		--print("playerName_",playerName,"playerServer_",playerServer) 
	else
		playerName = threatUnit
		playerServer = "UnKnown"
		--print("playerName_",playerName,"playerServer_",playerServer)
	end
return playerName
end



------------------------------
-- BenPhelps' Timer Functions
------------------------------

function jps.resetTimer( name )
	jps.Timers[name] = nil
end

function jps.createTimer( name, duration )
	if duration == nil then duration = 60 end -- 1 min
	jps.Timers[name] = duration + GetTime()
end

function jps.checkTimer( name )
	if jps.Timers[name] ~= nil then
		local now = GetTime()
		if jps.Timers[name] < now then
			jps.Timers[name] = nil
			return 0
		else
			return jps.Timers[name] - now
		end
	end
	return 0
end

-- returns seconds in combat or if out of combat 0
function jps.combatTime()
	return GetTime() - jps.combatStart
end

------------------------------
-- function like C / PHP ternary operator val = (condition) ? true : false
------------------------------

function Ternary(condition, doIt, notDo)
	if condition then return doIt else return notDo end
end

function inArray(needle, haystack)
	if type(haystack) ~= "table" then return false end
	for key, value in pairs(haystack) do 
		local valType = type(value)
		if valType == "string" or valType == "number" or valType == "boolean" then
			if value == needle then 
				return true
			end
		end
	end
	return false
end

function jps_round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

------------------------------
-- GUID
------------------------------
-- GUID is a string containing the hexadecimal representation of the unit's GUID, 
-- e.g. "0xF130C3030000037F2", or nil if the unit does not exist
-- className, classId, raceName, raceId, gender, name, realm = GetPlayerInfoByGUID("guid")

function ParseGUID(unit)
local guid = UnitGUID(unit)
if guid then
	local first3 = tonumber("0x"..strsub(guid, 5,5))
	local known = tonumber(strsub(guid, 5,5))
	
	local unitType = bit.band(first3,0x7)
	local knownType = tonumber(guid:sub(5,5), 16) % 8
	
   if (unitType == 0x000) then
		local playerID = (strsub(guid,6))
		print("Player, ID #", playerID)
   elseif (unitType == 0x003) then
      local creatureID = tonumber("0x"..strsub(guid,7,10))
      local spawnCounter = tonumber("0x"..strsub(guid,11))
      print("NPC, ID #",creatureID,"spawn #",spawnCounter)
   elseif (unitType == 0x004) then
      local petID = tonumber("0x"..strsub(guid,7,10))
      local spawnCounter = tonumber("0x"..strsub(guid,11))
      print("Pet, ID #",petID,"spawn #",spawnCounter)
   elseif (unitType == 0x005) then
      local creatureID = tonumber("0x"..strsub(guid,7,10))
      local spawnCounter = tonumber("0x"..strsub(guid,11))
      print("Vehicle, ID #",creatureID,"spawn #",spawnCounter)
   end
end
   return guid
end
