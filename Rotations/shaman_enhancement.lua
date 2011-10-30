function shaman_enhancement(self)
	if jps.PvP then return shaman_enhancement_pvp()
	else return new_shaman_enhancement()
	end
end
