function shaman_resto()
	if jps.PvP then
		return shaman_resto_pvp() 
	elseif isArena == 1 then
		return shaman_resto_arena()
	else 
		return shaman_resto_pve()
	end
end