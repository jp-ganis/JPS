function shaman_enhancement(self)
	if jps.PvP then return shaman_enhancement_pvp()
	else return shaman_enhancement_pve()
	end
end
