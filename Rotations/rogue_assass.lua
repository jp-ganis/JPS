function rogue_assass(self)
	--jpganis+simcraft
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("rupture")
	local snd_duration = jps.buffDuration("slice and dice")

	local spellTable =
	{
		{ "envenom", jps.LastCast == "cold blood" },
		{ "garrote" },
		{ "slice and dice", not jps.buff("slice and dice") },
		{ "rupture", rupture_duration <  2 },
		{ "vendetta" },
		{ "cold blood", cp == 5 },
		{ "envenom", cp >= 4 and not jps.buff("envenom") },
		{ "envenom", cp >= 4 and energy >= 90 },
		{ "envenom", cp >= 2 and snd_duration < 3 },
		{ "backstab", cp < 5 and jps.hp("target") < 0.35 },
		{ "mutilate", cp < 4 and jps.hp("target") > 0.35 },
		{ "vanish", energy > 50 and not jps.buff("overkill") },
	}

	return parseSpellTable( spellTable )
end
