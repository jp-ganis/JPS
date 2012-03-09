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
	if UnitExists(unit) and UnitIsPlayer(unit) then
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
	if UnitExists(unit) and UnitIsPlayer(unit) then
      playername = GetUnitName(unit)
    end
	if playername ~= nil then
      local playerexclude = {}
	  table.insert(playerexclude, playername)
	  table.insert(playerexclude, GetTime())
	  table.insert(jps.HealerBlacklist,playerexclude)
      if jps.Debug then print("Blacklisting ", playername) end
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
