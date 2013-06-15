function priest_disc()
local isArena, isRegistered = IsActiveBattlefieldArena()
	if jps.PvP then
		return priest_disc_pvp() 
	elseif isArena == 1 then
		return priest_disc_pvp()
	else
		return priest_disc_pve()
end
end
