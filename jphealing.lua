------------------------------
-- EVENTHANDLER
------------------------------
-- Prefix
	-- RANGE
	-- SPELL
	-- SPELL_PERIODIC -- SPELL_BUILDING
	-- ENVIRONMENTAL -- For ENVIRONMENTAL, it starts at the 13th.
	
-- Special Events
	-- UNIT_DIED	 eventtable[8] destGUID and eventtable[9] destName refer to the unit that died
	
-- Suffix
	-- _DAMAGE
	-- _HEAL
	-- _CAST_START -- _CAST_SUCCESS -- _CAST_FAILED
	-- _INTERRUPT
	-- _DISPEL -- _DISPEL_FAILED
	-- _AURA_APPLIED -- _AURA_REMOVED
	-- _CAST_START -- _CAST_SUCCESS -- _CAST_FAILED

-- eventtable[1] == timestamp the same format as the return value of the time() function
-- eventtable[2] == event e.g. SPELL_CAST_SUCCESS , SPELL_CAST_FAILED , SPELL_HEAL ...
-- eventtable[3] == hideCaster
-- eventtable[4] == sourceGUID
-- eventtable[5] == sourceName
-- eventtable[6] == sourceFlags
-- eventtable[7] == sourceFlags2
-- eventtable[8] == destGUID
-- eventtable[9] == destName
-- eventtable[10] == destFlags
-- eventtable[11] == destFlags2
-- eventtable[12] == spellID 
-- eventtable[13] == spellName
-- eventtable[14] == spellSchool
-- eventtable[15] == extraSpellID if suffix _INTERRUPT
-- eventtable[15] == amount if suffix is _DAMAGE or _HEAL
-- eventtable[15] == auraType if suffix is _AURA_APPLIED or _AURA_REMOVED e.g. BUFF , DEBUFF
-- eventtable[15] == failedType if suffix is _CAST_FAILED e.g. "Target not in line of sight" "You must be behind your target."
-- eventtable[15] == auraType if suffix is _AURA_APPLIED_DOSE or _AURA_REMOVED_DOSE
-- eventtable[16] == extraSpellName if suffix _INTERRUPT
-- eventtable[16] == amount if suffix is _AURA_APPLIED_DOSE or _AURA_REMOVED_DOSE
-- eventtable[16] == overhealing if suffix is _HEAL
-- eventtable[16] == overkill if suffix is _DAMAGE
-- eventtable[17] == absorbed if suffix is _HEAL
-- eventtable[17] == school if suffix is _DAMAGE
-- eventtable[18] == critical  if suffix is _HEAL
-- eventtable[18] == resisted  if suffix is _DAMAGE
-- eventtable[18] == auraType  if suffix is _DISPEL
-- eventtable[19] == blocked  if suffix is _DAMAGE
-- eventtable[20] == absorbed  if suffix is _DAMAGE
-- eventtable[21] == critical (1 or nil)  if suffix is _DAMAGE


--------------------------
-- LOCALIZATION
--------------------------

local L = MyLocalizationTable

--------------------------
-- TABLE FUNCTIONS
--------------------------

function jps_removeKey(table, key)
	if key == nil then return end
    local element = table[key]
    table[key] = nil
    return element
end

function jps_tableCount(table,tableindex,array)
	local count = 0
	for unit,index in pairs(table) do
		if array == index[tableindex] then count=count+1 end
	end
return count
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

-----------------------
-- UPDATE TABLE
-----------------------
--[[
jps.RaidTarget[unittarget] = { ["enemy"] = enemyname, ["friend"] = unitname } 	-- ["raid1target"] = { ["enemy"] = "Bob", ["friend"] = "Fred" }
jps.FriendTable[enemyFriend] = { ["name"] = enemyName , ["enemy"] = enemyGuid } -- ["Fred-Ysondre"] = { ["name"] = "Bob-Garona" , ["enemy"] = enemyGuid }
jps.EnemyTable[enemyGuid] = { ["name"] = enemyName , ["friend"] = enemyFriend } -- [enemyGuid] = { ["name"] = "Bob-Garona" , ["friend"] = "Fred-Ysondre"
jps.UnitStatus[unitGuid] = { ["name"] = unitName, ["damage"] = incoming_dmg } -- [unitGuid] = { ["name"] = "Bob-Garona", ["damage"] = incoming_dmg }


enemyFriend in jps.FriendTable and jps.EnemyTable with jps_stringTarget is "Fred" and not ""Fred-Ysondre"
jps.FriendTable is 	["Fred"] = { ["name"] = "Bob-Garona" , ["enemy"] = enemyGuid }
jps.EnemyTable is 	[enemyGuid] = { ["name"] = "Bob-Garona" , ["friend"] = "Fred"
unitName in jps.UnitStatus with jps_stringTarget is "Fred" and not ""Fred-Ysondre" or "Bob" and not "Bob-Garona"
jps.UnitStatus is 	[unitGuid] = { ["name"] = "Bob", ["damage"] = incoming_dmg }
]]

function jps.UpdateEnemyTable()
-- remove all friends I CAN'T HEAL
-- FriendTable & RaidStatus ont pour index UnitName
-- jps.RaidStatus[unitname] = {["unit"] = unit, ["hpct"] = hpct,["subgroup"] = subgroup,["target"] = unittarget}
	for unit,index in pairs(jps.RaidStatus) do
		if not jps.canHeal(unit) then
			jps_removeKey(jps.RaidStatus,unit)
			jps_removeKey(jps.FriendTable,unit)
			--local unitGuid =  UnitGUID(unit)
			--jps_removeKey(jps.UnitStatus,unitGuid)
		end
-- Impossible to get infos on a unit enemy not targeted
-- so take only canDPS on RaidTarget and remove of EnemyTable enemies I CAN'T DPS
		if (index.target ~= nil) and not jps.canDPS(index.target) then
			jps_removeKey(jps.RaidTarget,index.target)
			local unit_Guid =  UnitGUID(index.target)
			jps_removeKey(jps.EnemyTable,unit_Guid)
			--jps_removeKey(jps.UnitStatus,unit_Guid)
		
		end
	end
	
end

-- TABLE ENEMY & MOBS TARGETED BY inRange FRIENDS RAID MEMBERS
function jps.RaidEnemyTargeted()
	for unit,index in pairs(jps.RaidStatus) do
		local raidtarget = index["unit"].."target" -- Working only with raidindex.."target" and not with unitname.."target"
		if jps.canHeal(unit) and jps.canDPS(raidtarget) then
			jps.RaidTarget[raidtarget] = { ["enemy"] = select(1,UnitName(raidtarget)) , ["friend"] = unit }
		end
	end
end

-----------------------
-- RAID ENEMY COUNT 
-----------------------

-- COUNT ENEMY ONLY WHEN THEY DO DAMAGE TO inRange FRIENDLIES
function jps.TableEnemyCount() 
local enemycount = 0
local targetcount = 0
	for unit,index in pairs(jps.EnemyTable) do 
		enemycount = enemycount + 1
	end
	for tar_unit,tar_index in pairs(jps.RaidTarget) do
		targetcount = targetcount + 1 -- if CheckInteractDistance(tar_unit, 4) == 1
	end
return enemycount,targetcount
end

-- LOWEST HEALTh ENEMY UNIT
function jps.RaidLowestEnemy() 
local mytarget = "target"
local lowestHP = 1 
	for tar_unit,tar_index in pairs(jps.RaidTarget) do
		local thisHP = UnitHealth(tar_unit) / UnitHealthMax(tar_unit)
		if thisHP < lowestHP then
			lowestHP = thisHP
			mytarget = tar_unit
		end
	end
return mytarget
end

-- ENEMY MOST TARGETED BY FRIENDS
function jps.RaidEnemyTarget()
	local table_RaidTarget = {}
	for unit,index in pairs(jps.RaidTarget) do 
		local enemyName = index["enemy"] -- "Jean" "Mark" "Fred"
		local count = jps_tableCount(jps.RaidTarget , "enemy" , enemyName)
		table_RaidTarget[enemyName] = { ["friend"] = unit , ["count"] = count}
	end

	local mytarget = "target"
	local friend_count = 0
	for unit,index in pairs(table_RaidTarget) do
		if index.count > friend_count then
			friend_count = index.count
			mytarget = index.friend
		end
	end

return mytarget
end

-- STRING FUNCTION -- change a string "Bob" or "Bob-Garona" to "Bob"
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

-- ENEMY TARGETING THE PLAYER
function jps.IstargetMe()
	local threatUnit = nil
	for unit,index in pairs(jps.FriendTable) do 
		-- ["Fred"] = { ["name"] = Bob-Garona , ["enemy"] = enemyGuid }
		if unit == GetUnitName("player") then
			threatUnit = tostring(index.name)
		end
	end
	-- enemyname with "COMBAT_LOG_EVENT_UNFILTERED" is "Bob" or "Bob-Garona"
	local enemyname = jps_stringTarget(threatUnit,"-") -- return "Bob" or "UnKnown"
	
	-- ["raid1target"] = { ["enemy"] = "Bob", ["friend"] = "Fred" }
	for unit, index in pairs(jps.RaidTarget) do 
		if  (index.enemy == enemyname) and (enemyname ~= "UnKnown") then 
			return unit -- return "raid1target"
		end 
	end
return enemyname
end

 
-- jps.UnitStatus[unitGuid] = { ["name"] = unitName, ["damage"] = incoming_dmg }
-- [unitGuid] = { ["name"] = "Bob", ["damage"] = incoming_dmg }
-- FRIEND UNIT WITH THE HIGHEST DMG PER SECOND -- USAGE FOR HEALING TO SHIELD INCOMING DAMAGE
function jps.HighestDamage()
	local lowestUnit = jpsName
	local highestdmg = 0
	for unit, unitTable in pairs(jps.UnitStatus) do
		if jps.canHeal(unitTable["name"]) and unitTable["damage"] > highestdmg then
			highestdmg= unitTable["damage"]
			lowestUnit = unitTable["name"]
		end
	end
	return lowestUnit
end

-- TIME TO DIE -- jps.UnitStatus[unitGuid] = { ["name"] = unitName, ["damage"] = incoming_dmg }
function jps.TimetoDie(unit)
	if unit == nil then return 1200 end
	local guid = UnitGUID(unit)
	local health_unit = UnitHealth(unit)
	local incoming_dps = 1 -- to avoid 0/0
	local timetodie = 1200 -- e.g. 60 seconds x 20 min
	
	for unit_guid,index in pairs (jps.UnitStatus) do
		if guid == unit_guid then incoming_dps = index.damage break end
	end
	timetodie = health_unit / incoming_dps
	return timetodie
end

------------------------------
-- SPELLTABLE -- contains the average value of healing spells
------------------------------

function update_healtable(...)
	local eventtable =  {...}
    if Healtable[eventtable[13]] == nil then
		Healtable[eventtable[13]] = { 	["healname"]= eventtable[13],
										["healtotal"]= eventtable[15],
										["healcount"]= 1,
										["averageheal"]=eventtable[15]
									}
    else
		Healtable[eventtable[13]]["healtotal"] = Healtable[eventtable[13]]["healtotal"] + eventtable[15]
		Healtable[eventtable[13]]["healcount"] = Healtable[eventtable[13]]["healcount"] + 1
		Healtable[eventtable[13]]["averageheal"] = Healtable[eventtable[13]]["healtotal"] / Healtable[eventtable[13]]["healcount"]
    end
end

-- Resets the count of each healing spell to 1 makes sure that the average takes continuously into account changes in stats due to buffs etc
function reset_healtable(self)
  for k,v in pairs(Healtable) do
    Healtable[k]["healtotal"] = Healtable[k]["averageheal"]
    Healtable[k]["healcount"] = 1
  end
end

-- Displays the different health values - mainly for tweaking/debugging
function print_healtable(self)
  for k,v in pairs(Healtable) do
    print(k,"|cffff8000", Healtable[k]["healtotal"],"  ", Healtable[k]["healcount"],"  ", Healtable[k]["averageheal"])
  end
end

-- Returns the average heal value of given spell. 
function getaverage_heal(spellname)
  	if Healtable[spellname] == nil then
    	return 0
  	else
    	return (Healtable[spellname]["averageheal"])
  	end
end

----------------------------
--Blacklistplayer functions - These functions will blacklist a target for a set time.
----------------------------

function jps.UpdateHealerBlacklist(self)
   if #jps.HealerBlacklist > 0 then
	  for i = #jps.HealerBlacklist, 1, -1 do
		 if GetTime() - jps.HealerBlacklist[i][2] > jps.BlacklistTimer then
            if jps.Debug then print("Releasing ", jps.HealerBlacklist[i][1]) end
			table.remove(jps.HealerBlacklist,i)
		 end
	  end
   end
end

function jps.PlayerIsBlacklisted(unit)
  for i = 1, #jps.HealerBlacklist do
		if jps.HealerBlacklist[i][1] == unit then
			return true
		end
	end
	return false
end

function jps.BlacklistPlayer(unit)
	if unit ~= nil then
      local playerexclude = {}
	  table.insert(playerexclude, unit)
	  table.insert(playerexclude, GetTime())
	  table.insert(jps.HealerBlacklist,playerexclude)
      if jps.Debug then print("|cffa335eeBlacklisting", unit) end
    end

end

---------------------------
-- HEALTH UNIT RAID
---------------------------

-- COUNTS THE NUMBER OF PARTY MEMBERS INRANGE HAVING A SIGNIFICANT HEALTH PCT LOSS
function jps.CountInRaidStatus(low_health_def)
	if low_health_def == nil then low_health_def = 0.80 end
	local units_needing_heals = 0
			for unit, unitTable in pairs(jps.RaidStatus) do 
				if jps.canHeal(unit) and unitTable["hpct"] < low_health_def then
				units_needing_heals = units_needing_heals + 1
				end
			end	
	return units_needing_heals
end

-- LOWEST HP in RaidStatus
function jps.LowestFriendly()
	local lowestUnit = jpsName
	local lowestHP = 0
	for unit, unitTable in pairs(jps.RaidStatus) do
	local thisHP = UnitHealthMax(unit) - UnitHealth(unit) 
		if jps.canHeal(unit) and thisHP > lowestHP then
			lowestHP = thisHP
			lowestUnit = unit
		end
	end
	return lowestUnit
end

-- LOWEST PERCENTAGE in RaidStatus
function jps.LowestInRaidStatus() 
	local lowestUnit = jpsName
	local lowestHP = 1
	for unit, unitTable in pairs(jps.RaidStatus) do
	--local thisHP = UnitHealth(unit) / UnitHealthMax(unit)
		if jps.canHeal(unit) and unitTable["hpct"] < lowestHP then -- if thisHP < lowestHP 
			lowestHP = unitTable["hpct"] -- thisHP
			lowestUnit = unit
		end
	end
	return lowestUnit
end

------------------------------------
-- GROUP FUNCTION IN RAID
------------------------------------

-- FIND THE SUBGROUP OF AN UNIT IN RAIDSTATUS
-- partypet1 to partypet4 -- party1 to party4 -- raid1 to raid40 -- raidpet1 to raidpet40 -- arena1 to arena5 - A member of the opposing team in an Arena match
function jps.FindSubGroupUnit(unit)
	if not IsInRaid() then return 0 end
	local raidname = string.sub(unit,1,4) -- return raid
	local raidIndex = tonumber(string.sub(unit,5)) -- raid1..40 return returns 1 for raid1, 13 for raid13 
	-- local raidIndex = UnitInRaid(unit) + 0.5 -- UnitInRaid("unit") returns 0 for raid1, 12 for raid13 
	-- 0-4 > grp1 -- 5-9 > grp2 -- 10-14 > grp3 -- 15-19 > grp4 -- 20-24 > grp5
	-- Pet return nil with UnitInRaid
	local subgroup = 0 
	if type(raidIndex) == "number" and raidname == "raid" then subgroup = math.ceil(raidIndex/5) end
	-- math.floor(0.5) > 0 math.ceil(0.5) > 1 Renvoie le nombre entier au-dessus et au-dessous d'une valeur donnée.
return subgroup
end	

-- FIND THE RAID SUBGROUP TO HEAL WITH AT LEAST 3 RAID UNIT of the SAME GROUP IN RANGE
function jps.FindSubGroup()
	if not IsInRaid() then return 0 end
	
	local groupVal = 0
	local gr1 = 0
	local gr2 = 0
	local gr3 = 0
	local gr4 = 0
	local gr5 = 0
	local gr6 = 0
	local gr7 = 0
	local gr8 = 0

	for unit,unitTable in pairs(jps.RaidStatus) do
        if jps.canHeal(unit) then
            	if  unitTable["subgroup"] == 1 then gr1= gr1+1
            elseif  unitTable["subgroup"] == 2 then gr2= gr2+1
            elseif  unitTable["subgroup"] == 3 then gr3 = gr3+1
            elseif  unitTable["subgroup"] == 4 then gr4 = gr4+1
            elseif  unitTable["subgroup"] == 5 then gr5 = gr5+1
            elseif  unitTable["subgroup"] == 6 then gr6 = gr6+1
            elseif  unitTable["subgroup"] == 7 then gr7 = gr7+1
            elseif  unitTable["subgroup"] == 8 then gr8 = gr8+1
            end
         end
	end

	local groupToHeal = 0
	local groupVal = 2
	local groupTable = { gr1, gr2, gr3, gr4, gr5, gr6, gr7, gr8 }

	for i=1,#groupTable  do
		if groupTable[i] > groupVal then -- Heal >= 3 joueurs
			groupVal = groupTable[i]
			groupToHeal = i
		end
	end
return groupToHeal
end

-- FIND THE TARGET IN SUBGROUP TO HEAL WITH POH IN RAID
function jps.FindSubGroupTarget(low_health_def)
	if low_health_def == nil then low_health_def = 0.80 end
	local groupToHeal = jps.FindSubGroup()
	local tt = nil
	local tt_count = 0
	local lowestHP = low_health_def
	for unit,unitTable in pairs(jps.RaidStatus) do
		if  jps.canHeal(unit) and (unitTable["subgroup"] == groupToHeal) and (unitTable["hpct"] < lowestHP) then
			tt = unit
			lowestHP = unitTable["hpct"]
		end
		if  jps.canHeal(unit) and (unitTable["subgroup"] == groupToHeal) and (unitTable["hpct"] < low_health_def) then
			tt_count = tt_count + 1
		end
	end
	if tt_count > 2 then return tt end
	return nil
end

-- FIND THE TARGET IN SUBGROUP TO HEAL WITH BUFF SPIRIT SHELL IN RAID
function jps.FindSubGroupAura(auratypes) --  FindSubGroupAura("Carapace spirituelle") ou  FindSubGroupAura(114908)
	local groupToHeal = jps.FindSubGroup()
	local tt = nil

	for unit,unitTable in pairs(jps.RaidStatus) do
		if  jps.canHeal(unit) and (unitTable["subgroup"] == groupToHeal) and (not jps.buff(auratypes,unit)) then
			tt = unit
		break end
	end
	return tt
end

----------------------
-- RAID TABLE HEALTH
----------------------

function jps.SortRaidStatus()
	
	-- GetNumSubgroupMembers() -- Number of players in the player's sub-group, excluding the player. remplace GetNumPartyMembers patch 5.0.4
	-- GetNumGroupMembers() -- returns Number of players in the group (either party or raid), 0 if not in a group. remplace GetNumRaidMembers patch 5.0.4
	-- IsInRaid() Boolean - returns true if the player is currently in a raid group, false otherwise
	-- IsInGroup() Boolean - returns true if the player is in a some kind of group, otherwise false
	-- UnitInParty returns 1 or nil
	-- UnitInRaid Layout position for raid members: integer ascending from 0 (which is the first member of the first group)
	-- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex)
	-- raidIndex of raid member between 1 and MAX_RAID_MEMBERS (40). If you specify an index that is out of bounds, the function returns nil
		

	-- table.wipe(jps.RaidStatus)
	-- jps.RaidStatus = {}
	-- for k,v in pairs (jps.RaidStatus) do jps.RaidStatus[k]=nil end
	-- The difference between wipe(table) and table={} is that wipe removes the contents of the table, but retains the variable's internal pointer.
	
	table.wipe(jps.RaidStatus)
	table.wipe(jps.RaidTarget)
			
	local group_type = nil
	local unit = nil
	local subgroup = 0

	if IsInRaid() then
		group_type="raid"
		nps=1
		npe=GetNumGroupMembers()
	else
		group_type="party"
		nps=0
		npe=GetNumSubgroupMembers()
	end

	for i=nps,npe do
		if i==0 then
		unit="player"
		else
		unit = group_type..i
		end
		
		if nps==1 then subgroup = select(3,GetRaidRosterInfo(i)) else subgroup = 0 end
		local unitname = select(1,UnitName(unit))  -- to avoid that party1, focus and target are added all refering to the same player
		local unittarget = unit.."target"
		
		if jps.canHeal(unit) then -- and (UnitHealth(unit) + hpInc < UnitHealthMax(unit))
			local hpct = jps.hpInc(unit) 
			jps.RaidStatus[unitname] = {
				["unit"] = unit, -- RAID INDEX player, party..n, raid..n
				["hpct"] = hpct,
				["subgroup"] = subgroup,
				["target"] = unittarget
			}
		end
		
		if jps.canDPS(unittarget) then -- Working only with raidindex.."target" and not with unitname.."target"
			local enemyname = select(1,UnitName(unittarget))
			jps.RaidTarget[unittarget] = { 
				["enemy"] = enemyname, 
				["friend"] = unitname
			}
		end
	end
end

-----------------------
-- RAID TEST 
-----------------------

function jps_RaidTest()

	print("|cff0070dd","HighestDMG","|cffffffff"..jps.HighestDamage())
	print("|cff0070dd","LowestFriendly","|cffffffff"..jps.LowestInRaidStatus())
	print("|cff0070dd","AggroTank","|cffffffff"..jps.findMeATank())

	for unit,index in pairs(jps.RaidStatus) do 
		print("|cffa335ee",unit," - ",index.unit," - ",index.hpct,"- subGroup: ",index.subgroup) -- color violet 
	end

	for unit,index in pairs(jps.RaidTarget) do
		print("|cffe5cc80",unit," - ",index.enemy,"|cffa335ee","Friend_", index.friend)
	end
	
	local enemycount,targetcount = jps.TableEnemyCount()
	local enemytargeted = jps.RaidEnemyTarget() -- UNIT ENEMY MOST TARGETED BY FRIENDS
	local enemytargetMe = jps.IstargetMe() -- UNIT ENEMY TARGETING THE PLAYER
	print("|cFFFF0000","EnemyCount_","|cffffffff",enemycount,"|cFFFF0000","TargetCount_","|cffffffff",targetcount)
	print("|cFFFF0000","EnemyTarget_","|cffffffff",enemytargeted,"|cFFFF0000","EnemyTargetMe_","|cffffffff",enemytargetMe)

end

