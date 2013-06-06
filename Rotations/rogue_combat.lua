function rogue_combat()
	if jps.PvP then
		return rogue_combat_pvp() 
	else 
		return rogue_combat_pve()
	end
end


