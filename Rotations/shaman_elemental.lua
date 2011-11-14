function shaman_elemental(self)
	local spell = nil
	local lsStacks = jps.buffStacks("lightning shield")
	local mana = UnitMana("player")/UnitManaMax("player")

	local spellTable =
	{
		{ "elemental mastery",	"onCD" },
		{ "flame shock",		jps.debuffDuration("flame shock") < 2 },
		{ "lava burst",			"onCD" },
		{ "earth shock",		lsStacks == 9 },
		{ "earth shock",		lsStacks > 6 and jps.debuffDuration("flame shock") > 5 },
		{ "spiritwalker's grace",	jps.Moving },
		{ "chain lightning",	jps.MultiTarget },
		{ "lightning bolt",		"onCD" },
		{ "thunderstorm",		mana < .9 },
	}

	return parseSpellTable( spellTable )
end
