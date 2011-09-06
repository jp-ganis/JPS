function shaman_enhancement_pvp(self)
	local maelstromStacks = jps.buffStacks("maelstrom weapon")
	local buffsToPurge = {"power word: shield","ice barrier","mana shield","avenging wrath","predator's swifness"}
	local shouldPurge = false
	local targetClass = UnitClass("target")

	for _,v in pairs(buffsToPurge) do
		if jps.buff(v,"target") then shouldPurge = true end

	local spellTable =
	{
		{ "wind shear", jps.shouldKick() },
		{ "wind shear", jps.shouldKick("focus"), "focus" },
		{ "hex", "onCD", "focus" },
		{ "purge", shouldPurge },
		{ "shamanistic rage", jps.hp() < 0.61 },
		{ "feral spirit", jps.hp("target") > 0.5 or jps.hp() < 0.59 },
		{ "earthbind totem", targetClass == "mage" or targetClass == "hunter" },
		{ "searing totem", GetTotemTimeLeft(1) < 2 },
		{ "lava lash", "onCD" },
		{ "frost shock", "onCD" },
		{ "flame shock", not jps.debuff("flame shock") },
		{ "greater healing wave", maelstromStacks == 5 and jps.hp() < 0.78},
		{ "lightning bolt", maelstromStacks == 5 },
		{ "unleash elements", "onCD" },
		{ "stormstrike", "onCD" },
	}

	return parseSpellTable( spellTable )
end
