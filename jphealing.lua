------------------------------
-- EventHandler_priest_disc
------------------------------

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
-- eventtable[15] == amount if suffix is _DAMAGE or _HEAL
-- eventtable[15] == auraType if suffix is _AURA_APPLIED or _AURA_REMOVED e.g. BUFF , DEBUFF
-- eventtable[15] == failedType if suffix is _CAST_FAILED e.g. "Target not in line of sight" "You must be behind your target."
-- eventtable[15] == auraType if suffix is _AURA_APPLIED_DOSE or _AURA_REMOVED_DOSE
-- eventtable[16] == amount if suffix is _AURA_APPLIED_DOSE or _AURA_REMOVED_DOSE
-- eventtable[16] == overhealing if suffix is _HEAL
-- eventtable[16] == overkill if suffix is _DAMAGE
-- eventtable[17] == absorbed if suffix is _HEAL
-- eventtable[17] == school if suffix is _DAMAGE
-- eventtable[18] == critical  if suffix is _HEAL
-- eventtable[18] == resisted  if suffix is _DAMAGE
-- eventtable[19] == blocked  if suffix is _DAMAGE
-- eventtable[20] == absorbed  if suffix is _DAMAGE
-- eventtable[21] == critical (1 or nil)  if suffix is _DAMAGE

function EventHandler_player(...)
 
		local eventtable =  {...}
		local timestamp, event_type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2,	destGUID, destName,	destFlags, destFlags2 = select(1,...)
    	
    	-- Timer shield for disc priest
		if eventtable[2] == "SPELL_CAST_SUCCESS" and eventtable[5] == GetUnitName("player") and eventtable[12] == 17 then
    		jps.createTimer( "Shield", 12 )
    	end
--    	if event_type == "SPELL_CAST_SUCCESS" and sourceName == GetUnitName("player") then 
--    		local spellId, spellName, spellSchool = select(12, ...)
--    		if spellId == 17 then jps.createTimer( "Shield_2", 12) end
--    	end

--[[
		if eventtable[2] == "SPELL_HEAL" and eventtable[9] == GetUnitName("target") and eventtable[13] == "Greater Heal" then
    		print("|cff1eff00Heal:",eventtable[9],"-",eventtable[13],"Amount:",eventtable[15]) 
    	end
]]    	
    	if eventtable[2] == "SPELL_HEAL" and eventtable[5] == GetUnitName("player") then
    		--print("|cff1eff00Heal:",eventtable[12],"-",eventtable[13],"Amount:",eventtable[15],"Crit:",eventtable[18])  
    	end
    	if eventtable[2] == "SPELL_DAMAGE" and eventtable[5] == GetUnitName("player") then
    		--print("|cff0070ddDmg:",eventtable[12],"-",eventtable[13],"Amount:",eventtable[15],"Crit:",eventtable[21])
    	end
    	
--    	if event_type == "SPELL_HEAL" and sourceName == GetUnitName("player") then
--    		local spellId, spellName, spellSchool, amount, overheal, absorbed, critical = select(12, ...)
--    		print("|cff0070ddHeal",spellId,"-",spellName,"School",spellSchool,"Amount",amount) 
--    	end
--    	if event_type == "SPELL_DAMAGE" and sourceName == GetUnitName("player") then
--    		local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical  = select(12, ...)
--    		print("|cff1eff00Dmg",spellId,"-",spellName,"Targ",destName,"Amount",amount,"Crit",critical)
--    	end
    	
    	if eventtable[2] == "SPELL_AURA_APPLIED" and eventtable[5] == GetUnitName("player") then
    		--print("|cff1eff00aura:",eventtable[12],"-",eventtable[13],"auratype:",eventtable[15])
    		if eventtable[12]~=nil and eventtable[15] == "BUFF" then 
    			local duration = select(6, UnitBuff("player", eventtable[13]))
    			jps.createTimer(eventtable[12], duration)
    		end
    		if eventtable[12]~=nil and eventtable[15] == "DEBUFF" then 
    			local duration = select(6, UnitDebuff("target", eventtable[13]))
    			jps.createTimer(eventtable[12], duration)
    		end
    	end
    	if eventtable[2] == "SPELL_AURA_REMOVED" and eventtable[5] == GetUnitName("player") then
    		--print("|cFFFF0000aura:",eventtable[12],"-",eventtable[13],"auratype:",eventtable[15])
    		if eventtable[12]~=nil and eventtable[15] == "BUFF" then 
    			jps.resetTimer(eventtable[12])
    		end
    		if eventtable[12]~=nil and eventtable[15] == "DEBUFF" then 
    			jps.resetTimer(eventtable[12])
    		end
    	end
    	if eventtable[2] == "SPELL_AURA_APPLIED_DOSE" and eventtable[5] == GetUnitName("player") then
    		--print("|cffa335eedose:",eventtable[12],"-",eventtable[13],"auratype:",eventtable[15],"count:",eventtable[16])
    	end
    	
    	-- You can create any timer you want with the spellID e.g. print("timer",jps.checkTimer( 12968 )) -- Rafale
    	-- You can know the spellname with the spellID with local name = GetSpellInfo(12968) e.g. print("spellname",name)
    	
end

------------------------------
-- SPELLTABLE -- contains the average value of healing spells
------------------------------

function update_healtable(...)
	local eventtable =  {...}
    if healtable[eventtable[13]] == nil then
		healtable[eventtable[13]] = { 	["healname"]= eventtable[13],
										["healtotal"]= eventtable[15],
										["healcount"]= 1,
										["averageheal"]=eventtable[15]
									}
    else
		healtable[eventtable[13]]["healtotal"] = healtable[eventtable[13]]["healtotal"] + eventtable[15]
		healtable[eventtable[13]]["healcount"] = healtable[eventtable[13]]["healcount"] + 1
		healtable[eventtable[13]]["averageheal"] = healtable[eventtable[13]]["healtotal"] / healtable[eventtable[13]]["healcount"]
    end
	--print(eventtable[13],"  ",healtable[eventtable[13]]["healtotal"],"  ",healtable[eventtable[13]]["healcount"],"  ",healtable[eventtable[13]]["averageheal"])
end

-- Resets the count of each healing spell to 1 makes sure that the average takes continuously into account changes in stats due to buffs etc
function reset_healtable(self)
  for k,v in pairs(healtable) do
    healtable[k]["healtotal"] = healtable[k]["averageheal"]
    healtable[k]["healcount"] = 1
  end
end

-- Displays the different health values - mainly for tweaking/debugging
function print_healtable(self)
  for k,v in pairs(healtable) do
    print(k,"|cffff8000", healtable[k]["healtotal"],"  ", healtable[k]["healcount"],"  ", healtable[k]["averageheal"])
  end
-- print("renew",getaverage_heal("Renew"))
-- print("flash",getaverage_heal("Flash Heal"))
-- print("penance",getaverage_heal("Penance"))
end

-- Returns the average heal value of given spell. 
-- Needs to be extended for other classes, but takes into account Echo of Light (1+ GetMastery()* 0.0125) for holy priests
function getaverage_heal(spellname)
  local multiplier 

  	if spellname == "Renew" then
    	if GetRangedHaste() < 12.5 then
     		multiplier = 4
      	else 
      		multiplier = 5
    	end
  	else
  		multiplier = 1
  	end

  	if healtable[spellname] == nil then
    	return 0
  	else
    	return (healtable[spellname]["averageheal"]) * (1+GetMastery()* 0.0125) * multiplier
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
    local playername
	if UnitExists(unit)==1 then
      playername = GetUnitName(unit)
    end
  for i = 1, #jps.HealerBlacklist do
		if jps.HealerBlacklist[i][1] == playername then
			return true
		end
	end
	return false
end

function jps.BlacklistPlayer(unit)
    local playername
	if UnitExists(unit)==1 then
      playername = GetUnitName(unit)
    end
	if playername ~= nil then
      local playerexclude = {}
	  table.insert(playerexclude, playername)
	  table.insert(playerexclude, GetTime())
	  table.insert(jps.HealerBlacklist,playerexclude)
      if jps.Debug then print("|cffa335eeBlacklisting", playername) end
    end

end


---------------------------
-- GROUP Functions in RAID
---------------------------

function jps.canHeal(unit)
	if not unit then unit = "target" end
	if UnitExists(unit)~=1 then return false end
	if UnitIsVisible(unit)~=1 then return false end
	if UnitIsPlayer(unit)~=1 then return false end
	if UnitIsFriend("player",unit)~=1 then return false end
	if not UnitInRange(unit) then return false end
	if UnitIsDeadOrGhost(unit)==1 then return false end
	if jps.PlayerIsBlacklisted(unit) then return false end
	
	return true
end

-- counts the number of party members having a significant health pct loss --
function jps.countInRaidStatus(low_health_def)
	local units_needing_heals = 0
			for unit, unitTable in pairs(jps.RaidStatus) do 
				if jps.canHeal(unit) and unitTable["hpct"] < low_health_def then
				units_needing_heals = units_needing_heals + 1
				end
			end	
	return units_needing_heals
end

-- Lowest HP in RaidStatus
function jps.lowestFriendly()
	local lowestUnit = "player"
	local lowestHP = 0
	for unit, unitTable in pairs(jps.RaidStatus) do
	--local thisHP = UnitHealthMax(unit) - UnitHealth(unit) 
		if jps.canHeal(unit) and unitTable["hp"] > lowestHP then -- if thisHP > lowestHP 
			lowestHP = unitTable["hp"] -- thisHP
			lowestUnit = unit
		end
	end
	return lowestUnit
end

-- Lowest percentage in RaidStatus
function jps.lowestInRaidStatus() 
	local lowestUnit = "player"
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

-- find the subgroup of an unit in RaidStatus --
function jps.findSubGroupUnit(unit)
if GetNumGroupMembers()==0 then return 0 end
local groupUnit = 0
local raidIndex = UnitInRaid(unit) + 0.1 
-- UnitInRaid("unit") returns 0 for raid1, 12 for raid13
-- 0-4 > grp1
-- 5-9 > grp2
-- 10-14 > grp3
-- 15-19 > grp4
-- 20-24 > grp5
	
	if raidIndex == nil then groupUnit = 0 -- Pet return nil with UnitInRaid
	else groupUnit = math.ceil(raidIndex / 5) -- math.floor(0.5) > 0 math.ceil(0.5) > 1
	end      
return groupUnit
end	

-- find the target in subgroup to heal with POH in Raid
function jps.findSubGroupToHeal(low_health_def)

-- GetNumGroupMembers() number of players in your raid group, including yourself or 0 if you are not in a raid group
-- GetNumSubgroupMembers() number of party members, excluding the player (0 to 4)
-- While in a raid, you are also in a party. You might be the only person in your raidparty, so this function could still return 0

if GetNumGroupMembers()==0 then return nil end
if low_health_def == nil then low_health_def = 0.80 end
	local gr1 = 0
	local gr2 = 0
	local gr3 = 0
	local gr4 = 0
	local gr5 = 0
	local gr6 = 0
	local gr7 = 0
	local gr8 = 0

	for unit,hp_table in pairs(jps.RaidStatus) do
        if hp_table["hpct"] < low_health_def then -- jps.canHeal(unit) and
            if  hp_table["subgroup"] == 1 then gr1= gr1+1
            elseif  hp_table["subgroup"] == 2 then gr2= gr2+1
            elseif  hp_table["subgroup"] == 3 then gr3= gr3+1
            elseif  hp_table["subgroup"] == 4 then gr4= gr4+1
            elseif  hp_table["subgroup"] == 5 then gr5= gr5+1
            elseif  hp_table["subgroup"] == 6 then gr6= gr6+1
            elseif  hp_table["subgroup"] == 7 then gr7= gr7+1
            elseif  hp_table["subgroup"] == 8 then gr8= gr8+1
            end
         end
	end
	
	local groupToHeal = 0
	local groupVal = 2
	local groupTable = { gr1, gr2, gr3, gr4, gr5, gr6, gr7, gr8 }

	for i=1,#groupTable  do
		--print(i,"|cffff8000"..groupTable[i])
		if groupTable[i] > groupVal then -- Heal >= 3 joueurs
		groupVal = groupTable[i]
		groupToHeal = i
		--print("GrptoHeal "..groupToHeal,"GrpVal "..groupVal)
		end
	end

	local tt = nil -- jps.RaidStatus[tt].subgroup
	local lowestHP = low_health_def
	for unit,hp_table in pairs(jps.RaidStatus) do
		if hp_table["subgroup"] == groupToHeal and (hp_table["hpct"] < low_health_def) then
			tt = unit
			lowestHP = hp_table["hpct"]
		end
	end
	--print("tt",tt)
	return tt

end

----------------------
-- RAID TABLE HEALTH
----------------------

function jps.SortRaidStatus()

	table.wipe(jps.RaidStatus)
	
	local group_type, unit, subgroup 
	
	group_type="raid"
	nps=1
	npe=GetNumGroupMembers()
	if npe<=5 then
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
		
		if GetNumGroupMembers() > 0 then subgroup = select(3,GetRaidRosterInfo(i)) else subgroup = 0 end
		local hpInc = UnitGetIncomingHeals(unit)
		if not hpInc then hpInc = 0 end
		
		--why not return all units in the group?
		--the problem is that we may want to do other things 
		if jps.canHeal(unit) then -- and (UnitHealth(unit) + hpInc < UnitHealthMax(unit)) then
			local hpct = jps.hpInc(unit) 
			unit = select(1,UnitName(unit))  -- to avoid that party1, focus and target are added all refering to the same player
			
			jps.RaidStatus[unit] = {
				["name"] = unit,
				["hp"] = UnitHealthMax(unit) - UnitHealth(unit),
				["hpct"] = hpct,
				["subgroup"] = subgroup
			}
			
		end
	end
end

-----------------------
-- RAID TEST 
-----------------------

function jps_RaidTest()
print("findmeTank", jps.findMeATank())
print("AggroTank", jps.findMeAggroTank())
print("LowestFriendly: "..jps.lowestFriendly())
	for k,v in pairs(jps.RaidStatus) do 
		print("|cffa335ee",k,v["hp"]," - ",v["hpct"],"- subGroup: ",v.subgroup) -- color violet 
		-- print("|cffa335ee",jps.RaidStatus[k].name,jps.RaidStatus[k]["hp"]," - ",jps.RaidStatus[k]["hpct"],"- subGroup: ",jps.RaidStatus[k].subgroup) -- color violet 
	end
end
