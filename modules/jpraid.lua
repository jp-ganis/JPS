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



function jps.targetIsRaidBoss(target) 
	if target == nil then target = "target" end
	local dungeon = jps.raid.getInstanceInfo()
	if inArray(dungeon.difficulty, {"normal10","normal25","hereoic10","heroic25","lfr25", "normal40"}) then		
		if UnitLevel(target) == -1 and UnitPlayerControlled(target) == false then
			return true
		end
	end
	return false
end

function jps.playerInLFR()
	local dungeon = jps.raid.getInstanceInfo()
	if dungeon.difficulty == "lfr25" then return true end
	return false
end

function jps.raid.getInstanceInfo()
    local name, instanceType , difficultyID = GetInstanceInfo()
    local targetName = UnitName("target")
    local diffTable = {}
    diffTable[0] = "none"
    diffTable[1] = "normal5"
    diffTable[2] = "heroic5"
    diffTable[3] = "normal10"
    diffTable[4] = "normal25"
    diffTable[5] = "heroic10"
    diffTable[6] = "heroic25"
    diffTable[7] = "lfr25"
    diffTable[8] = "challenge"
    diffTable[9] = "normal40"
    diffTable[10] = "none"
    diffTable[11] = "normal3"
    diffTable[12] = "heroic3" 
    return {instance = name , enemy = targetName, difficulty = diffTable[difficultyID]}
end

----------------------
-- Find TANK
----------------------

function jps.findMeAggroTank()
	local allTanks = jps.findTanksInRaid() 
	local highestThreat = 0
	local aggroTank = "player"
	for possibleTankUnit, _ in pairs(allTanks) do
		local unitThreat = UnitThreatSituation(possibleTankUnit)
		if unitThreat > highestThreat then 
			highestThreat = unitThreat
			aggroTank = possibleTankUnit
		end
	end
	if jps.Debug then write("found Aggro Tank: "..aggroTank) end
	return aggroTank
end

function jps.findMeATank()
	local allTanks = jps.findTanksInRaid() 
	if jps_tableLen(allTanks) == 0 then
		if jps.UnitExists("focus") then return "focus" end
	else
		return allTanks[1] 
	end
	return "player"
end

function jps.findTanksInRaid() 
	local myTanks = {}
	for unitName, _ in pairs(jps.RaidStatus) do
		local foundTank = false
		if UnitGroupRolesAssigned(unitName) == "TANK" then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("bear form",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("blood presence",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
		if foundTank == false and jps.buff("righteous fury",unitName) then
			table.insert(myTanks, unitName);
			foundTank = true
		end
	end
	return myTanks
end

function jps.targetTargetTank()
	if jps.buff("bear form","targettarget") then return true end
	if jps.buff("blood presence","targettarget") then return true end
	if jps.buff("righteous fury","targettarget") then return true end
	
	local _,_,_,_,_,_,_,caster,_,_ = UnitDebuff("target","Sunder Armor")
	if caster ~= nil then
		if UnitName("targettarget") == caster then return true end end
	return false
end

-----------------------
-- RAID ENEMY COUNT 
-----------------------
-- jps.RaidTarget[unittarget_guid] = { ["unit"] = unittarget, ["hpct"] = hpct_enemy, ["count"] = countTargets + 1 }

-- COUNT ENEMY ONLY WHEN THEY DO DAMAGE TO inRange FRIENDLIES
function jps.RaidEnemyCount() 
local enemycount = 0
local targetcount = 0
	for unit,index in pairs(jps.EnemyTable) do 
		enemycount = enemycount + 1
	end
	for tar_unit,tar_index in pairs(jps.RaidTarget) do
		targetcount = targetcount + 1
	end
return enemycount,targetcount
end



-- ENEMY MOST TARGETED
function jps.RaidTargetUnit()
if enemies == nil then return "target" end
local maxTargets = 0
local enemyWithMostTargets = "target"
	for enemyGuid, enemyName in pairs(jps.RaidTarget) do
		if enemyName["count"] > maxTargets then
		maxTargets = enemyName["count"]
		enemyWithMostTargets = enemyName.unit
	end
end
return enemyWithMostTargets
end




-- ENEMY TARGETING THE PLAYER
-- jps.EnemyTable[enemyGuid] = { ["friend"] = enemyFriend } -- TABLE OF ENEMY GUID TARGETING FRIEND NAME
-- jps.RaidTarget[unittarget_guid] = { ["unit"] = unittarget, ["hpct"] = hpct_enemy, ["count"] = countTargets + 1 }
function jps.IstargetMe()
	local enemy_guid = nil
	for unit,index in pairs(jps.EnemyTable) do 
		if index.friend == GetUnitName("player") then
			enemy_guid = unit
		end
	end
	for unit, index in pairs(jps.RaidTarget) do 
		if  (unit == enemy_guid) then 
			return index.unit -- return "raid1target"
		end 
	end
	return nil
end