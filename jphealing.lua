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


---More to come...