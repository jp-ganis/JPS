
------------------------------
-- SPELLTABLE -- contains the average value of healing spells
------------------------------

function update_healtable(...)
	local healname = select(13, ...)
	local healVal = select(15, ...)
	if Healtable[healname] == nil then
		Healtable[healname] = { 	
									["healname"]= healname,
									["healtotal"]= healVal,
									["healcount"]= 1,
									["averageheal"]=healVal
								}
	else
		Healtable[healname]["healtotal"] = Healtable[healname]["healtotal"] + healVal
		Healtable[healname]["healcount"] = Healtable[healname]["healcount"] + 1
		Healtable[healname]["averageheal"] = Healtable[healname]["healtotal"] / Healtable[healname]["healcount"]
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
		print(k,"|cffff8000", Healtable[k]["healtotal"]," ", Healtable[k]["healcount"]," ", Healtable[k]["averageheal"])
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
function jps.CountInRaidStatus(lowHealthDef)
	if lowHealthDef == nil then lowHealthDef = 0.80 end
	local unitsBelowHealthDef = 0
		for unit, unitTable in pairs(jps.RaidStatus) do 
			if (unitTable["inrange"] == true) and unitTable["hpct"] < lowHealthDef then
				unitsBelowHealthDef = unitsBelowHealthDef + 1
			end
		end	
	return unitsBelowHealthDef
end

-- LOWEST PERCENTAGE in RaidStatus
function jps.LowestInRaidStatus()
	local lowestUnit = jpsName
	local lowestHP = 1
	for unit,unitTable in pairs(jps.RaidStatus) do
		if (unitTable["inrange"] == true) and unitTable["hpct"] < lowestHP then
			lowestHP = Ternary(jps.isHealer, unitTable["hpct"], jps.hp(unit)) -- if isHealer is disabled get health value from jps.hp() (some "non-healer" rotations uses LowestInRaidStatus)
			lowestUnit = unit
		end
	end
	return lowestUnit
end

-- LOWEST HPCT with IncHeal & Absorbs in RaidStatus
function jps.LowestFriendlyStatus()
	local lowestUnit = jpsName
	local lowestHP = 1
	for unit,unitTable in pairs(jps.RaidStatus) do
		local hpInc = UnitGetIncomingHeals(unit)
		if not hpInc then hpInc = 0 end
		local hpAbs = UnitGetTotalAbsorbs(unit)
		if not hpAbs then hpAbs = 0 end
        local thisHP = UnitHealth(unit) + hpInc + hpAbs
        local thisHPct = thisHP / UnitHealthMax(unit)
        if (unitTable["inrange"] == true) and thisHPct < lowestHP then
         	lowestHP = thisHPct
         	lowestUnit = unit
        end
	end
	return lowestUnit
end

-- LOWEST HP in RaidStatus
function jps.LowestFriendly()
	local lowestUnit = jpsName
	local lowestHP = 0
	for unit,unitTable in pairs(jps.RaidStatus) do
	local thisHP = UnitHealthMax(unit) - UnitHealth(unit) 
		if (unitTable["inrange"] == true) and thisHP > lowestHP then
			lowestHP = thisHP
			lowestUnit = unit
		end
	end
	return lowestUnit
end

-- AVG RAID PERCENTAGE in RaidStatus without aberrations
function jps.avgRaidHP(noFilter)
	local raidHP = 1
	local unitCount = 0
	local minUnit = 1
	local avgHP = 1
	if GetNumGroupMembers() == 0 then return 1 end
	for unit, unitTable in pairs(jps.RaidStatus) do
		if unitTable["inrange"] then
			unitHP = unitTable["hpct"]
			if unitHP then
				if unitHP < minUnit and unitHP > 0 then minUnit = unitHP end
				raidHP = raidHP + unitHP
				unitCount = unitCount + 1
			end
		end
	end
	avgHP = raidHP / unitCount
	if not avgHP then return 1 end
	if unitCount > 10 or noFilter == true then
		return avgHP
	end
	 -- remove aberrations in 10 man groups (they lower the avg raid hp too much) allow max 30% hp difference to avg hp
	for unit, unitTable in pairs(jps.RaidStatus) do
		if unitTable["inrange"] then
			unitHP = unitTable["hpct"]
			if unitHP then
				if unitHP < (avgHP / 1.3) then
					raidHP = raidHP - unitHP
					unitCount = unitCount - 1
				end
			end
		end
	end
	avgHP = raidHP / unitCount
	if not avgHP then return 1 end
	return avgHP
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
	if not IsInRaid() and IsInGroup() then return 1 end
	
	local gr1 = 0
	local gr2 = 0
	local gr3 = 0
	local gr4 = 0
	local gr5 = 0
	local gr6 = 0
	local gr7 = 0
	local gr8 = 0

	for unit,unitTable in pairs(jps.RaidStatus) do
		if (unitTable["inrange"] == true) then
			if unitTable["subgroup"] == 1 then gr1= gr1+1
			elseif unitTable["subgroup"] == 2 then gr2= gr2+1
			elseif unitTable["subgroup"] == 3 then gr3 = gr3+1
			elseif unitTable["subgroup"] == 4 then gr4 = gr4+1
			elseif unitTable["subgroup"] == 5 then gr5 = gr5+1
			elseif unitTable["subgroup"] == 6 then gr6 = gr6+1
			elseif unitTable["subgroup"] == 7 then gr7 = gr7+1
			elseif unitTable["subgroup"] == 8 then gr8 = gr8+1
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
return groupToHeal -- RETURN Group with at least 3 unit in range
end

-- FIND THE TARGET IN SUBGROUP TO HEAL WITH POH IN RAID
function jps.FindSubGroupTarget(lowHealthDef)
	if lowHealthDef == nil then lowHealthDef = 0.80 end
	local groupToHeal = jps.FindSubGroup()
	local tt = nil
	local tt_count = 0
	local lowestHP = lowHealthDef
	
	for unit,unitTable in pairs(jps.RaidStatus) do
		if (unitTable["inrange"] == true) and (unitTable["subgroup"] == groupToHeal) and (unitTable["hpct"] < lowHealthDef) then
			tt = unit
			lowestHP = unitTable["hpct"]
			tt_count = tt_count + 1
		end
	end
	if tt_count > 2 then return tt end
	return nil
end

-----------------------
-- UPDATE RAIDSTATUS
-----------------------

function jps.UpdateRaidStatus(unit)	-- partypet1 to partypet4 -- party1 to party4 -- raid1 to raid40 -- raidpet1 to raidpet40 -- arena1 to arena5
	local unitname = select(1,UnitName(unit))
	if jps.RaidStatus[unitname] then
		jps.RaidStatus[unitname]["unit"] = unit -- RAID INDEX player, party..n, raid..n
		jps.RaidStatus[unitname]["hpct"] = jps.hp(unitname)
		jps.RaidStatus[unitname]["subgroup"] = jps.RaidStatus[unitname].subgroup
		jps.RaidStatus[unitname]["target"] = unit.."target"
		jps.RaidStatus[unitname]["inrange"] = jps.canHeal(unit)
	end
end

----------------------
-- RAID TABLE HEALTH
----------------------

function jps.UnitInRaid(unit)
	local layout = nil
	if not UnitInRaid(unit) then layout = unit return layout end

	if IsInRaid() then
		layout = "raid"
	else
		layout = "party"
		if (UnitIsUnit(unit,"player")==1) then layout = "player" end
	end
	return layout..UnitInRaid(unit)
end

function jps.SortRaidStatus()
	
-- GetNumSubgroupMembers() -- Number of players in the player's sub-group, excluding the player. remplace GetNumPartyMembers patch 5.0.4
-- GetNumGroupMembers() -- returns Number of players in the group (either party or raid), 0 if not in a group. remplace GetNumRaidMembers patch 5.0.4
-- IsInRaid() Boolean - returns true if the player is currently in a raid group, false otherwise
-- IsInGroup() Boolean - returns true if the player is in a some kind of group, otherwise false
-- UnitInParty returns 1 or nil
-- UnitInRaid Layout position for raid members: integer ascending from 0 (which is the first member of the first group)
-- UnitInRaid Returns a number if the unit is in your raid group, nil otherwise
-- name, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(raidIndex)
-- raidIndex of raid member between 1 and MAX_RAID_MEMBERS (40). If you specify an index that is out of bounds, the function returns nil

	table.wipe(jps.RaidStatus)
			
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
		local unitname = select(1,UnitName(unit)) -- to avoid that party1, focus and target are added all refering to the same player
		local unit_hpct = jps.hp(unit)
		local unittarget = unit.."target"
		local inrange_friend = jps.canHeal(unit)

		jps.RaidStatus[unitname] = {
			["unit"] = unit, -- RAID INDEX player, party..n, raid..n
			["hpct"] = unit_hpct,
			["subgroup"] = subgroup,
			["target"] = unittarget,
			["inrange"] = inrange_friend
		}
	end
end

-----------------------
-- RAID TEST 
-----------------------

function jps_RaidTest()

	for unit,index in pairs(jps.RaidStatus) do 
		print("|cffa335eeJPS",unit,"Unit:",index.unit,"Hpct: ",index.hpct,"|cffa335eesubGroup: ",index.subgroup,"Target: ",index.target,"Range",index.inrange) -- color violet 
	end

	for unit,index in pairs(jps.RaidTarget) do
		print("|cffe5cc80JPS",unit,"|cffa335ee","Unit: ",index.unit,"Hpct: ",index.hpct,"Count: ",index.count)
	end

	local enemycount,targetcount = jps.RaidEnemyCount()
	local enemytargeted = jps.LowestInRaidTarget() -- UNIT ENEMY TARGETED BY FRIENDS WITH LOWEST HEALTH
	local enemytargetMe = jps.IstargetMe() -- UNIT ENEMY TARGETING THE PLAYER
	print("|cFFFF0000","EnemyCount_","|cffffffff",enemycount,"|cFFFF0000","TargetCount_","|cffffffff",targetcount)
	print("|cFFFF0000","EnemyTarget_","|cffffffff",enemytargeted,"|cFFFF0000","EnemyTargetMe_","|cffffffff",enemytargetMe)

end