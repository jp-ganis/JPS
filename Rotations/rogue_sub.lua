--jpganis
-- Ty to SIMCRAFT for this rotation
function rogue_sub(self)
   local cp = GetComboPoints("player")
   local energy = UnitMana("player")
   local spell = nil

	local spellTable = 
	{
		{ "preparation", not jps.buff("vanish") and jps.cd("vanish") > 60 },
		{ "shadow blades" },
		{ nil, energy < 75 },
		{ "shadow dance", energy > 75 and not jps.buff("stealth") and not jps.debuff("find weakness") },
		{ nil, energy < 30 },
		{ "vanish", energy >= 45 and energy <= 75 and cp <= 3 and not jps.buff("Shadow Dance") and not jps.buff("Master of Subtlety") and not jps.debuff("find weakness") },
		{ "premeditation", cp <= 2 },
		{ "ambush", cp <= 5 },
		{ "slice and dice", snd_duration < 3 and cp == 5 },
		{ "rupture", rupture_duration < 5 and cp == 5 },
		{ "ambush", jps.buffDuration("shadow dance") <= 2 },
		{ "eviscerate", cp == 5 },
		{ "hemorrhage", cp < 4 } ,
		{ "tricks of the trade" },
		{ "backstab", cp < 5 and energy > 80 and jps.cd("shadow dance") >= 2 },
	}

   return parseSpellTable( spellTable )
end
