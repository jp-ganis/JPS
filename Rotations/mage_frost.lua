function mage_frost()
	if jps.PvP then
		return mage_frost_pvp() 
	else 
		return mage_frost_pve()
	end
end