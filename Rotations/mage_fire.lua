function mage_fire(self)
	--jpganis + SIMCRAFT

	local spellTable = 
	{
		{ "scorch", not jps.debuff("critical mass") },
		{ "combustion", jps.debuff("living bomb") and jps.debuff("ignite") and jps.debuff("pyroblast") and jps.UseCDs },
		{ "mirror image" },
		{ "living bomb", not jps.debuff("living bomb") },
		{ "pyroblast", jps.buff("hot streak") },
		{ "flame orb" },
		{ "fireball" },
		{ "scorch" },
	}

	return parseSpellTable(spellTable)
end
