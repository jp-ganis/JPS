function shaman_enhancement(self)
	--jpganis +simcraft
	local maelstromStacks = jps.buffStacks("maelstrom weapon")
	local shockCD = jps.cd("earth shock")

	local spellTable =
	{
		{ "wind shear", jps.shouldKick() },
		{ "wind shear", jps.shouldKick("focus"), "focus" },
		{ "searing totem", GetTotemTimeLeft(1) < 2 },
		{ "lightning shield", not jps.buff("lightning shield") },
		{ "stormstrike" },
		{ "lava lash" },
		{ "lightning bolt", maelstromStacks > 4 },
		{ "unleash elements" },
		{ "lava burst", shockCD < 2 and jps.debuffDuration("flame shock") > 2.5 and jps.buffDuration("unleash flame") > 2.5 },
		{ "flame shock", not jps.myDebuff("flame shock") or jps.buff("unleash flame") },
		{ "earth shock" },
		{ "feral spirit" },
		{ "earth elemental totem" }, 
		{ "spiritwalker's grace", jps.Moving },
		{ "lightning bolt", maelstromStacks > 1 },
	}

	return parseSpellTable( spellTable )
end
