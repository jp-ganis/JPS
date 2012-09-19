--jpganis
-- Ty to SIMCRAFT for this rotation
function rogue_combat(self)
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("rupture")
	local snd_duration = jps.buffDuration("slice and dice")
	local energy = UnitPower("player")
	
	local spellTable = 
	{
		{ "preparation", not jps.buff("vanish") and jps.cd("vanish") > 60 },
		{ "vanish", not jps.buff("shadow blades") and not jps.buff("adrenaline rush") and energy < 20 and ((jps.buff("deep insight") and cp < 4)) },
		{ "ambush" },
		{ "slice and dice", snd_duration < 2 or (snd_duration < 15 and jps.buffStacks("bandit's guile") == 11 and cp >= 4) },
		{ "shadow blades", jps.bloodlusting() and snd_duration >= jps.buffDuration("shadow blades") },
		{ "killing spree", energy < 35 and snd_duration > 4 and not jps.buff("adrenaline rush") },
		{ "adrenaline rush", energy < 35 or jps.buff("shadow's blade") },
		{ "rupture", rupture_duration < 4 and cp == 5 and jps.buff("deep insight") },
		{ "eviscerate", cp == 5 and jps.buff("deep insight") },
		{ "rupture", rupture_duration < 4 and cp == 5 },
		{ "revealing strike", jps.buff("deep insight") and cp < 5 },
		{ "tricks of the trade" },
		{ "sinister strike", cp < 5 },
	}

	return parseSpellTable(spellTable)

end


