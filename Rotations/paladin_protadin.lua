function paladin_protadin()
	if jps.PvP then
		return paladin_protadin_pvp() 
	else
		return paladin_protadin_pve()
	end
end