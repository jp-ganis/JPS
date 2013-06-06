function warrior_arms()
	if jps.PvP then
		return warrior_arms_pvp() 
	else 
		return warrior_arms_pve()
	end
end

