function hunter_bm()
	if jps.PvP then
		return hunter_bm_pvp() 
	else
		return hunter_bm_pve()
	end
end