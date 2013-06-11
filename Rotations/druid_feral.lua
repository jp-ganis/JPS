function druid_feral()
local isArena, isRegistered = IsActiveBattlefieldArena()
	if jps.PvP then
		return druid_feral_pvp() 
	elseif isArena == 1 then
		return druid_feral_pvp()
	else
		return druid_feral_pve()
	end
end

