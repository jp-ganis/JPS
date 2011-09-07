function rogue_combat(self)
	if jps.PvP then return rogue_combat_pvp()
	else return rogue_combat_pve() end
end
