--Blacklistplayer functions
--These functions will blacklist a target for a set time.


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

-- find the subgroup of an unit in RaidStatus --
function jps.findSubGroupUnit(unit)
if GetNumRaidMembers()==0 then return 0 end
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

-- find the subgroup to heal with POH in RaidStatus --
function jps.findSubGroupToHeal(low_health_def)
if GetNumRaidMembers()==0 then return 0 end

	local gr1 = 0
	local gr2 = 0
	local gr3 = 0
	local gr4 = 0
	local gr5 = 0
	local gr6 = 0
	local gr7 = 0
	local gr8 = 0

	for unit,hp_table in pairs(jps.RaidStatus) do
		--local thisHP = UnitHealth(unit) / UnitHealthMax(unit)
        if jps.canHeal(unit) and hp_table["hpct"] < low_health_def then
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
	local groupVal = 2 -- Heal >= 3 joueurs
	local groupTable = { gr1, gr2, gr3, gr4, gr5, gr6, gr7, gr8 }

	for i=1,#groupTable  do
		--print(i,"|cffff8000"..groupTable[i])
		if groupTable[i] > groupVal then -- Heal >= 3 joueurs
		groupVal = groupTable[i]
		groupToHeal = i
		--print(groupToHeal,"gr",groupVal)
		end
	end
--for i, j in pairs(groupTable) do
--	print(i,"|cffffffff"..j,"|cffff8000"..groupTable[i])
--end

local tt = nil
for unit,hp_table in pairs(jps.RaidStatus) do	
	if hp_table["subgroup"] == groupToHeal and (hp_table["hpct"] < low_health_def) then
		tt = unit
	break end
end

return groupToHeal, tt
end

----------------------
-- RAID TABLE HEALTH
----------------------

function jps.SortRaidStatus()


	table.wipe(jps.RaidStatus)
	-- table.wipe(jps.TT)
	-- for k,v in pairs(jps.RaidStatus) do jps.RaidStatus[k]=nil end
	-- collectgarbage("collect")
	
	local group_type, unit, subgroup 
	
	group_type="raid"
	nps=1
	npe=GetNumRaidMembers()
	if npe==0 then
	group_type="party"
	nps=0
	npe=GetNumPartyMembers()
	end

	for i=nps,npe do
		if i==0 then
		unit="player"
		else
		unit = group_type..i
		end
		
		if GetNumRaidMembers() > 0 then subgroup = select(3,GetRaidRosterInfo(i)) else subgroup = 0 end
		local hpInc = UnitGetIncomingHeals(unit)
		if not hpInc then hpInc = 0 end
		
		if jps.canHeal(unit) and (UnitHealth(unit) + hpInc < UnitHealthMax(unit)) then
			local hpct = jps.hpInc(unit) 
			unit = select(1,UnitName(unit))  -- to avoid that party1, focus and target are added all refering to the same player
			
			jps.RaidStatus[unit] = {
				["hp"] = UnitHealthMax(unit) - UnitHealth(unit),
				["hpct"] = hpct,
				["subgroup"] = subgroup
			}
			
		end
	end
--[[	
	local function sortMyTable(a,b) return jps.RaidStatus[a]["hp"] > jps.RaidStatus[b]["hp"] end 
	for k,v in pairs(jps.RaidStatus) do table.insert(jps.TT, k) end
	table.sort(jps.TT, sortMyTable)
]]
end
