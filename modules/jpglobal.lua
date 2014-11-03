--[[[
@module Functions: global helper functions
@description
global functions
]]--


local L = MyLocalizationTable

--------------------------
-- TABLE FUNCTIONS
--------------------------

function jps.removeTableKey(table, key)
	if key == nil then return end
		local element = table[key]
		table[key] = nil
		return element
end
--[[[
@function jps.tableLength
@description 
return the length of a table
[br][i]Usage:[/i][br]
[code]
jps.tableLength({1,2,3})

[/code]
@param table: a pointer to a table

@returns int: length of a table or 0
]]--
--get table length
function jps.tableLength(table)
	if table == nil then return 0 end
		local count = 0
		for k,v in pairs(table) do 
				count = count+1
		end
		return count
end

function jps.deepTableCopy(object)
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
--[[[
@function jps.stringSplit
@description 
splits a Player-Realm string and returns playerName
[br][i]Usage:[/i][br]
[code]
jps.stringSplit("Bob-RandomServer","-")

[/code]
@param string: A player-realm string

@returns string: playerName
]]--
function jps.stringSplit(unit,case)
	if unit == nil then return "UnKnown" end -- ERROR if threatUnit is nil
	local threatUnit = tostring(unit)
	local playerName = threatUnit
	local playerServer = "UnKnown"
	
	local stringLength = string.len(threatUnit)
	local startPos, endPos = string.find(threatUnit,case)	-- "-" "%s" space
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
--[[[
@function jps.combatTime()
@description 
get's the time the player is in combat
[br][i]Usage:[/i][br]
[code]
jps.combatTime()

[/code]


@returns int: time in seconds
]]--
function jps.combatTime()
	return GetTime() - jps.combatStart
end


--[[[
@function jps.movingFor()
@description 
get's the time the player is moving
[br][i]Usage:[/i][br]
[code]
jps.movingFor()

[/code]


@returns int: time in seconds
]]--
function jps.movingFor()
	if not jps.Moving then return 0 end
	return GetTime() - jps.startedMoving
end

--[[[
@function jps.fallingFor()
@description 
get's the time the player is falling
[br][i]Usage:[/i][br]
[code]
jps.fallingFor()

[/code]


@returns int: time in seconds
]]--
function jps.fallingFor()
	if not jps.falling then return 0 end
	return GetTime() - jps.startedFalling
end
------------------------------
-- function like C / PHP ternary operator val = (condition) ? true : false
------------------------------
function Ternary(condition, doIt, notDo)
	if condition then return doIt else return notDo end
end
--[[[
@function inArray
@description 

[br][i]Usage:[/i][br]
[code]
inArray("target",{"target","player","focus"})

[/code]
@param string: needle
@param table: table with data
@returns boolean
]]--
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

function jps.roundValue(num, idp)
		local mult = 10^(idp or 0)
		if num >= 0 then return math.floor(num * mult + 0.5) / mult
		else return math.ceil(num * mult - 0.5) / mult end
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

keyDownMapper = {}
keyDownMapper["shift"] = IsShiftKeyDown
keyDownMapper["left-shift"] = IsLeftShiftKeyDown
keyDownMapper["right-shift"] = IsRightShiftKeyDown
keyDownMapper["alt"]= IsAltKeyDown
keyDownMapper["left-alt"] = IsLeftAltKeyDown
keyDownMapper["right-alt"] = IsRightAltKeyDown
keyDownMapper["ctrl"] = IsControlKeyDown
keyDownMapper["left-ctrl"] = IsLeftControlKeyDown
keyDownMapper["right-ctrl"] = IsRightControlKeyDown

--[[[
@function keyPressed
@description 

[br][i]Usage:[/i][br]
[code]
keyPressed("shift")[br]
keyPressed("shift","alt")[br]

[/code]
@param string: name of a modifier key[br]
@param string: another name of a modifier key[br]
@param string: another name of a modifier key[br]

@returns boolean if the passed key combination is pressed
]]--
function keyPressed(...)	
	local paramType = type(arrayOrString)
	matchesNeed = select("#", ...)
	matchesFound = 0
	i = 1
	while select(i , ...) ~= nil  do
		needle = select(i, ...)
		i = i+1
		local apiFunction = keyDownMapper[needle:lower()]
		if type(apiFunction) == "function" then
			if apiFunction() ~= nil  then
				matchesFound  =matchesFound+1
				if matchesFound == matchesNeed then
					return true
				end
			end
		end
	end
	return false
end

--[[[
@function dump
@description 
dumps a table content to print() - recursive
[br][i]Usage:[/i][br]
[code]
dump({1,2:{"bob","test"},3})

[/code]
@param table: a table

@returns output in print()
]]--
function dump(o)
	if type(o) == 'table' then
		local s = '{ \n'
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '	['..k..'] = ' .. dump(v) .. ',\n'
		end
		print(s .. '\n} ')
	else
		return tostring(o)
	end
end
