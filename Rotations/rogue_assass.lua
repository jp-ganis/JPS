function rogue_assass(self)
	--jpganis+simcraft
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("rupture")
	local snd_duration = jps.buffDuration("slice and dice")
	local energy = UnitMana("player")

	local spellTable =
	{
		{ "preparation", not jps.buff("vanish") and jps.cd("vanish") > 60 },
		{ "vanish", not jps.buff("stealth") and not jps.buff("shadow blades") },
		{ "ambush" },
		{ "shadow blades", jps.bloodlusting() and snd_duration >= jps.buffDuration("shadow blades") },
		{ "slice and dice", snd_duration <= 2 },
		{ "dispatch",	energy > 90 and rupture_duration < 4 },
		{ "mutilate", 	energy > 90 and rupture_duration < 4 },
		{ "rupture",	rupture_duration < 2 or (cp == 5 and rupture_duration < 3) },
		{ "vendetta" },
		{ "envenom", cp >= 4 and jps.buffDuration("envenom") < 1 },
		{ "envenom", cp > 4 },
		{ "envenom", cp >= 2 and snd_duration < 3 },
		{ "dispatch", cp < 5 },
		{ "tricks of the trade" },
		{ "mutilate" },
	}

	return parseSpellTable( spellTable )
end
