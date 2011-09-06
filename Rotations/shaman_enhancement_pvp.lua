function shaman_enhancement_pvp(self)
	local maelstromStacks = jps.buffStacks("maelstrom weapon")
	local buffsToPurge = {"power word: shield","ice barrier","mana shield","avenging wrath","predator's swifness","blessing of protection"}
	local shouldPurge = false
	local couldPurge = false
	local feared = jps.debuff("fear","player") or jps.debuff("intimidating shout","player") or jps    .debuff("howl of terror","player") or jps.debuff("psychic scream","player")

	local targetClass = UnitClass("target")

	for _,v in pairs(buffsToPurge) do
		if jps.buff(v,"target") then shouldPurge = true end end
	

	local spellTable =
	{
		{ nil, jps.buff("ghost wolf") },
		{ "tremor totem", feared },
		{ "wind shear", jps.shouldKick() },
		{ "wind shear", jps.shouldKick("focus"), "focus" },
		{ "greater healing wave", maelstromStacks == 5 and jps.hp() < 0.78},
		{ "hex", "onCD", "focus" },
		{ "purge", shouldPurge },
		{ "shamanistic rage", jps.hp() < 0.61 },
		{ "feral spirit", jps.hp("target") > 0.5 or jps.hp() < 0.59 },
		{ "earthbind totem", targetClass == "mage" or targetClass == "hunter" },
		{ "stoneclaw totem", jps.hp() < 0.7 },
		{ "searing totem", GetTotemTimeLeft(1) < 2 },
		{ "lava lash", "onCD" },
		{ "frost shock", "onCD" },
		{ "flame shock", not jps.debuff("flame shock") },
		{ "lightning bolt", maelstromStacks == 5 },
		{ "unleash elements", "onCD" },
		{ "stormstrike", "onCD" },
		{ "lightning shield", "refresh" },
		{ "purge", jps.mana() > 0.2 },
	}

	return parseSpellTable( spellTable )
end
