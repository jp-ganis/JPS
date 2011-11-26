function shaman_enhancement(self)
	local maelstromStacks = jps.buffStacks("maelstrom weapon")

	local spellTable =
	{
		{ "wind shear", jps.shouldKick() },
		{ "wind shear", jps.shouldKick("focus"), "focus" },
		{ "shamanistic rage", jps.mana() < 0.2 },
		{ "searing totem", GetTotemTimeLeft(1) < 2 },
		{ "lava lash", "onCD" },
		{ "flame shock", jps.buff("unleash flame") },
		{ "lightning bolt", maelstromStacks == 5 },
		{ "unleash elements", "onCD" },
		{ "stormstrike", "onCD" },
		{ "earth shock", "onCD" },
		{ "feral spirit", "onCD" },
	}

	return parseSpellTable( spellTable )
end
