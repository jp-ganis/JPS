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
jps.RaidTarget[unittarget] = { ["enemy"] = enemyname, ["hpct"] = hpct_enemy } 	-- ["raid1target"] = { ["enemy"] = "Bob", ["hpct"] = jps.hp(unittarget) }
jps.FriendTable[enemyFriend] = { ["name"] = enemyName , ["enemy"] = enemyGuid } -- ["Fred-Ysondre"] = { ["name"] = "Bob-Garona" , ["enemy"] = enemyGuid } -- TABLE OF FRIEND TARGETED BY ENEMY
jps.EnemyTable[enemyGuid] = { ["name"] = enemyName , ["friend"] = enemyFriend } -- [enemyGuid] = { ["name"] = "Bob-Garona" , ["friend"] = "Fred-Ysondre" -- TABLE OF ENEMY TARGETING FRIEND

enemyFriend in jps.FriendTable and jps.EnemyTable with jps_stringTarget is "Fred" and not ""Fred-Ysondre"
jps.FriendTable is 	["Fred"] = { ["name"] = "Bob-Garona" , ["enemy"] = enemyGuid }
jps.EnemyTable is 	[enemyGuid] = { ["name"] = "Bob-Garona" , ["friend"] = "Fred"
]]

function jps.UpdateEnemyTable()
-- remove all friends I CAN'T HEAL
-- FriendTable & RaidStatus ont pour index UnitName
-- jps.RaidStatus[unitname] = {["unit"] = unit, ["hpct"] = hpct,["subgroup"] = subgroup}
	for unit,index in pairs(jps.RaidStatus) do
		if not jps.canHeal(unit) then
			jps_removeKey(jps.RaidStatus,unit)
			jps_removeKey(jps.FriendTable,unit)
		end
	end
-- Impossible to get infos on a unit enemy not targeted
-- so take only canDPS on RaidTarget and remove of EnemyTable enemies I CAN'T DPS
-- jps.RaidTarget[unittarget] = { ["enemy"] = enemyname, ["hpct"] = hpct_enemy }
	for unit,index in pairs(jps.RaidTarget) do
		if not jps.canDPS(unit) then
			jps_removeKey(jps.RaidTarget,unit)
			local unittarget_guid =  UnitGUID(unit)
			jps_removeKey(jps.EnemyTable,unittarget_guid)
		end
	end
end

-----------------------
-- RAID ENEMY COUNT 
-----------------------

-- COUNT ENEMY ONLY WHEN THEY DO DAMAGE TO inRange FRIENDLIES
function jps.RaidEnemyCount() 
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

-- ENEMY UNIT with LOWEST HEALTH
-- jps.RaidTarget[unittarget] = { ["enemy"] = enemyname, ["hpct"] = hpct_enemy }
function jps.RaidLowestEnemy() 
local mytarget = "target"
local lowestHP = 1 
	for unit,index in pairs(jps.RaidTarget) do
		local unit_Hpct = index.hpct
		if unit_Hpct < lowestHP then
			lowestHP = unit_Hpct
			mytarget = unit
		end
	end
return mytarget
end

-- ENEMY MOST TARGETED BY FRIENDS
-- jps.RaidTarget[unittarget] = { ["enemy"] = enemyname, ["hpct"] = hpct_enemy }
function jps.RaidEnemyTarget()
	local table_RaidTarget = {}
	for unit,index in pairs(jps.RaidTarget) do 
		local enemyName = index["enemy"] -- "Jean" "Mark" "Fred"
		local count = jps_tableCount(jps.RaidTarget , "enemy" , enemyName)
		table_RaidTarget[enemyName] = { ["raidtarget"] = unit , ["count"] = count}
	end
	-- table_RaidTarget with the form
	-- ["Mark"] = {["raidtarget"] = "Raid1target" , ["count"] = 4 },
	-- ["Mark"] = {["raidtarget"] = "Raid2target" , ["count"] = 4 },
	-- ["Jean"] = {["raidtarget"] = "Raid10target" , ["count"] = 2 },
	--	for unit,index in pairs(table_RaidTarget) do
	--		print("|cff0070ee-",unit,"|cff9d9d3F-",index.friend,"-",index.count)
	--	end
	local mytarget = "target"
	local target_count = 0
	for tar_unit,tar_index in pairs(table_RaidTarget) do
		if tar_index.count > target_count then
			target_count = tar_index.count
			mytarget = tar_index.raidtarget
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
-- jps.FriendTable[enemyFriend] = { ["name"] = enemyName , ["enemy"] = enemyGuid } -- ["Fred-Ysondre"] = { ["name"] = "Bob-Garona" , ["enemy"] = enemyGuid } -- TABLE OF FRIEND TARGETED BY ENEMY
-- jps.EnemyTable[enemyGuid] = { ["name"] = enemyName , ["friend"] = enemyFriend } -- [enemyGuid] = { ["name"] = "Bob-Garona" , ["friend"] = "Fred-Ysondre" -- TABLE OF ENEMY TARGETING FRIEND
function jps.IstargetMe()
	local threatUnit = nil
	for unit,index in pairs(jps.FriendTable) do 
		if unit == GetUnitName("player") then
			threatUnit = tostring(index.name)
		end
	end
	-- enemyname with "COMBAT_LOG_EVENT_UNFILTERED" is "Bob" or "Bob-Garona"
	local enemyname = jps_stringTarget(threatUnit,"-") -- return "Bob" or "UnKnown"

	-- jps.RaidTarget[unittarget] = { ["enemy"] = enemyname, ["hpct"] = hpct_enemy } 	-- ["raid1target"] = { ["enemy"] = "Bob", ["hpct"] = jps.hp(unittarget) }
	for unit, index in pairs(jps.RaidTarget) do 
		if  (index.enemy == enemyname) and (enemyname ~= "UnKnown") then 
			return unit -- return "raid1target"
		end 
	end
return enemyname
end

-----------------------
-- TIME TO DIE FRAME
-----------------------

jps.UnitToLiveData = {}
jps.timeToLiveMaxSamples = 30

local JPSEXTInfoFrame = CreateFrame("frame","JPSEXTInfoFrame")
JPSEXTInfoFrame:SetBackdrop({
      bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
      tile=1, tileSize=32, edgeSize=32,
      insets={left=11, right=12, top=12, bottom=11}
})
JPSEXTInfoFrame:SetWidth(150)
JPSEXTInfoFrame:SetHeight(60)
JPSEXTInfoFrame:SetPoint("CENTER",UIParent)
JPSEXTInfoFrame:EnableMouse(true)
JPSEXTInfoFrame:SetMovable(true)
JPSEXTInfoFrame:RegisterForDrag("LeftButton")
JPSEXTInfoFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
JPSEXTInfoFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
JPSEXTInfoFrame:SetFrameStrata("FULLSCREEN_DIALOG")
local infoFrameText = JPSEXTInfoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- "OVERLAY"
infoFrameText:SetJustifyH("LEFT")
infoFrameText:SetPoint("LEFT", 10, 0)
local infoTTL = 60
local infoTTD = 60

JPSEXTFrame = CreateFrame("Frame", "JPSEXTFrame")
JPSEXTFrame:SetScript("OnUpdate", function(self, elapsed)
    jps.updateTimeToLive(self, elapsed)
end)

--JPSEXTFrame:SetScript("OnEvent", function(self, event, ...)
--    if event == "PLAYER_REGEN_DISABLED" then
--        -- Combat Start
--    elseif event == "PLAYER_REGEN_ENABLED" then
--        -- Out of Combat
--        jps.clearTimeToLive()
--    end
--end)
--JPSEXTFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
--JPSEXTFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

function jps.updateInfoText()
    if infoTTL ~= nil or infoTTD ~= nil then
        infoFrameText:SetText("TimeToLive: "..infoTTL.."\nTimeToDie: "..infoTTD)
    else
        infoFrameText:SetText("TTL: n/a\nTTD: n/a")
    end
end

function jps.updateTimeToLive(self, elapsed)
	if self.TimeToLiveSinceLastUpdate == nil then self.TimeToLiveSinceLastUpdate = 0 end
    self.TimeToLiveSinceLastUpdate = self.TimeToLiveSinceLastUpdate + elapsed
    if (self.TimeToLiveSinceLastUpdate > jps.UpdateInterval) then
        if jps.Combat and UnitExists("target") then
            --jps.updateUnitTimeToLive("target")
            self.TimeToLiveSinceLastUpdate = 0
        end
        infoTTL = jps.TimeToLive("target")
		infoTTD = jps.TimeToDie("target")
        jps.updateInfoText()
    end
end

-----------------------
-- TIME TO DIE
-----------------------

function jps.updateUnitTimeToLive(unit)
    local guid = UnitGUID(unit)
    if jps.UnitToLiveData[guid] == nil then jps.UnitToLiveData[guid] = {} end
    local dataset = jps.UnitToLiveData[guid]
    local data = table.getn(dataset)
    if data > jps.timeToLiveMaxSamples then table.remove(dataset, jps.timeToLiveMaxSamples) end
    table.insert(dataset, 1, {GetTime(), UnitHealth(unit)})
    jps.UnitToLiveData[guid] = dataset
end

-- table.getn Returns the size of a table, If the table has an n field with a numeric value, this value is the size of the table.
-- Otherwise, the size is the largest numerical index with a non-nil value in the table
-- we supply 3 arguments to the table.insert(table,position,value) function.
-- We can also use the table.remove(table,position) to remove elements from a table array.
-- jps.UnitToLiveData[guid] = { [1] = {GetTime(), UnitHealth(unit)} , [2] = {GetTime(), UnitHealth(unit)} , [3] = {GetTime(), UnitHealth(unit)} }

function jps.clearTimeToLive()
    jps.UnitToLiveData = {}
    jps.RaidTimeToDie = {}
	jps.RaidTimeToLive = {}
end

function jps.UnitTimeToLive(unit)
	if unit == nil then return 60 end
    local guid = UnitGUID(unit)
	local health_unit = UnitHealth(unit)
	local timetolive = 60 -- e.g. 60 seconds
	local totalDmg = 1 -- to avoid 0/0
	local incomingDps = 1
	
    if jps.UnitToLiveData[guid] ~= nil then
        local dataset = jps.UnitToLiveData[guid]
        local data = table.getn(dataset)
        if #dataset > 1 then
        	local timeDelta = dataset[1][1] - dataset[data][1] -- (lasttime - firsttime)
			local totalTime = math.max(timeDelta, 1)
        	totalDmg = dataset[data][2] - dataset[1][2] -- (UnitHealth_old - UnitHealth_last) = Health Loss
        	incomingDps = math.ceil(totalDmg / totalTime)
			if incomingDps <= 0 then incomingDps = 1 end
        end
		timetolive = math.ceil(health_unit / incomingDps)
    end
    return timetolive
end

function jps.TimeToLive(unit)
	if unit == nil then return 60 end
    local guid = UnitGUID(unit)
	local health_unit = UnitHealth(unit)
	local timetolive = 60 -- e.g. 60 seconds
	local totalDmg = 1 -- to avoid 0/0
	local incomingDps = 1
	
    if jps.RaidTimeToLive[guid] ~= nil then
        local dataset = jps.RaidTimeToLive[guid]
        local data = table.getn(dataset)
        if #dataset > 1 then
        	local timeDelta = dataset[1][1] - dataset[data][1] -- (lasttime - firsttime)
			local totalTime = math.max(timeDelta, 1)
        	totalDmg = dataset[data][2] - dataset[1][2] -- (UnitHealth_old - UnitHealth_last) = Health Loss
        	incomingDps = math.ceil(totalDmg / totalTime)
			if incomingDps <= 0 then incomingDps = 1 end
        end
		timetolive = math.ceil(health_unit / incomingDps)
    end
    return timetolive
end

-- jps.RaidTimeToDie[unitGuid] = { [1] = {GetTime(), eventtable[15] },[2] = {GetTime(), eventtable[15] },[3] = {GetTime(), eventtable[15] } }
function jps.TimeToDie(unit)
	if unit == nil then return 60 end
	local guid = UnitGUID(unit)
	local health_unit = UnitHealth(unit)
	local timetodie = 60 -- e.g. 60 seconds
	local totalDmg = 1 -- to avoid 0/0
	local incomingDps = 1

	if jps.RaidTimeToDie[guid] ~= nil then
		local dataset = jps.RaidTimeToDie[guid]
        local data = table.getn(dataset)
        if #dataset > 1 then
        	local timeDelta = dataset[1][1] - dataset[data][1] -- (lasttime - firsttime)
        	local totalTime = math.max(timeDelta, 1)
			for i,j in ipairs(dataset) do
				totalDmg = totalDmg + j[2]
			end
        	incomingDps = math.ceil(totalDmg / totalTime)
        end
        timetodie = math.ceil(health_unit / incomingDps)
    end
	return timetodie
end

-- FRIEND UNIT WITH THE LOWEST TIMETODIE -- USAGE FOR HEALING TO SHIELD INCOMING DAMAGE
function jps.LowestTimetoDie()
	local lowestUnit = jpsName
	local timetodie = 60
	
	for unit, unitTable in pairs(jps.RaidStatus) do
		local timetodieUnit = jps.TimeToDie(unit)
		if timetodieUnit < timetodie then
			timetodie = timetodieUnit
			lowestUnit = unit
		end
	end
	return lowestUnit
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
-- Pet return nil with UnitInRaid -- UnitInRaid("unit") returns 0 for raid1, 12 for raid13
function jps.FindSubGroupUnit(unit)
	if not IsInRaid() then return 0 end
	local raidname = string.sub(unit,1,4) -- return raid
	local raidIndex = tonumber(string.sub(unit,5)) -- raid1..40 return returns 1 for raid1, 13 for raid13 
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

	local groupTableToHeal = {}
	local groupToHeal = 0
	local groupVal = 2
	local groupTable = { gr1, gr2, gr3, gr4, gr5, gr6, gr7, gr8 }

	for i=1,#groupTable do
		if groupTable[i] > groupVal then -- HEAL >= 3 JOUEURS
			groupVal = groupTable[i]
			groupToHeal = i
			table.insert(groupTableToHeal,i)
		end
	end
return groupToHeal, groupTableToHeal
end

-- FIND THE TARGET IN SUBGROUP TO HEAL WITH POH IN RAID
function jps.FindSubGroupTarget(low_health_def)
	if low_health_def == nil then low_health_def = 0.80 end
	local groupToHeal, groupTableToHeal = jps.FindSubGroup()
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

	if IsInRaid() then
		group_type = "raid"
		nps = 1
		npe = GetNumGroupMembers()
	else
		group_type = "party"
		nps = 0
		npe = GetNumSubgroupMembers()
	end

	for i=nps,npe do
		if i==0 then
		unit = "player"
		else
		unit = group_type..i
		end
		
		local subgroup = select(3,GetRaidRosterInfo(i))
		local unitname = select(1,UnitName(unit))  -- to avoid that party1, focus and target are added all refering to the same player
		local hpct_friend = jps.hp(unit)
		-- if jps.canHeal(unit) then -- and jps.hpInc(unit,"abs") > 0
		
			jps.RaidStatus[unitname] = {
				["unit"] = unit, -- RAID INDEX player, party..n, raid..n
				["hpct"] = hpct_friend,
				["subgroup"] = subgroup,
			}
	end
end

-----------------------
-- RAID TEST 
-----------------------

function jps_RaidTest()

	print("|cff0070dd","HighestDMG","|cffffffff"..jps.LowestTimetoDie())
	print("|cff0070dd","LowestFriendly","|cffffffff"..jps.LowestInRaidStatus())
	print("|cff0070dd","AggroTank","|cffffffff"..jps.findMeATank())

	for unit,index in pairs(jps.RaidStatus) do 
		print("|cffa335eeJPS",unit," - ",index.unit,"Hpct: ",index.hpct,"|cffa335eesubGroup: ",index.subgroup) -- color violet 
	end

	for unit,index in pairs(jps.RaidTarget) do
		print("|cffe5cc80JPS",unit," - ",index.enemy,"|cffa335ee"," - ", index.hpct)
	end
	
	local enemycount,targetcount = jps.RaidEnemyCount()
	local enemytargeted = jps.RaidLowestEnemy() -- UNIT ENEMY TARGETED BY FRIENDS WITH LOWEST HEALTH
	local enemytargetMe = jps.IstargetMe() -- UNIT ENEMY TARGETING THE PLAYER
	print("|cFFFF0000","EnemyCount_","|cffffffff",enemycount,"|cFFFF0000","TargetCount_","|cffffffff",targetcount)
	print("|cFFFF0000","EnemyTarget_","|cffffffff",enemytargeted,"|cFFFF0000","EnemyTargetMe_","|cffffffff",enemytargetMe)

end




