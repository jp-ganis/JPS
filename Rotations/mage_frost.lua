--jpganis + SIMCRAFT
-- no pet freeze on simcraft, is this right? (??)
function mage_frost(self)
	local spellTable =
	{
		{ "evocation", jps.mana() < 0.4 and (jps.buff("icy veins") or jps.bloodlusting()) },
		{ "cold snap", jps.cd("deep freeze") > 15 and jps.cd("flame orb") > 30 and jps.cd("icy veins") > 30 },
		{ "flame orb", not jps.debuff("frostfire orb") },
		{ "mirror image" },
		{ "icy veins", not jps.buff("icy veins") and not jps.bloodlusting() },
		{ "deep freeze", jps.buff("fingers of frost") },
		{ "frostfire bolt", jps.buff("brain freeze") },
		{ "ice lance", jps.buffStacks("fingers of frost") > 1 },
		{ "ice lance", jps.buff("fingers of frost") and jps.petCooldown("5") < 1.5 },
		{ {"macro","/cast freeze\n/run jps.groundClick()"}, jps.petCooldown("5")==0 },
		{ "frostbolt" },
		{ "ice lance", jps.Moving },
	}

	return parseSpellTable(spellTable)
end
