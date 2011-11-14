function rogue_sub(self)
   local cp = GetComboPoints("player")
   local energy = UnitMana("player")
   local spell = nil
   if cp < 5 and ((jps.cd("shadow dance")==0 and energy < 85) or (jps.cd("vanish")==0) and energy < 60) then
	   jps.write("Pooling energy")
	   return nil
   end

	local spellTable = 
	{
		{"shadow dance",	energy > 85 and cp < 5 and not jps.buff("stealth") },
		{"vanish",			energy > 60 and cp <= 1 and jps.cd("shadowstep")==0 and not jps.buff("shadow dance") and not jps.buff("master of subtlety")},
		{"shadowstep",		jps.buff("stealth") or jps.buff("shadowdance") },
		{"premeditation",	cp <= 2 },
		{"ambush",			cp <= 4 },
		{"preparation",		jps.cd("vanish") > 60 },
		{"slice and dice",	jps.buffDuration("Slice and dice") < 3 and cp == 5 },
		{"rupture",			cp == 5 and not jps.debuff("rupture") },
		{"recuperate",		cp == 5 and jps.buffDuration("recuperate") < 3 },
		{"eviscerate",		cp == 5 and jps.debuffDuration("rupture") > 1 },
		{"hemorrhage",		cp < 4 and energy > 40 and jps.debuffDuration("hemorrhage") < 4 },
		{"hemorrhage",		cp < 5 and energy > 80 and jps.debuffDuration("hemorrhage") < 4 },
		{"backstab",		cp < 4 and energy > 40 },
		{"backstab",		cp < 5 and energy > 80 },
	}

   return parseSpellTable( spellTable )
end
