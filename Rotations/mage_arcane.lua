--jpganis + SIMCRAFT
function mage_arcane()

local stacks = jps.buffStacks("arcane charge")
	
local spellTable =
{
	{ "arcane barrage", jps.Moving },
	{ "fire blast",		jps.Moving },
	{ "ice lance",		jps.Moving },
	{ "alter time", 	not jps.buff("alter time") and jps.buff("arcane power") and jps.buffStacks("arcane missiles") == 2 and stacks > 3 and jps.buffDuration("rune of power") > 6 },
	{ "arcane blast",	jps.buff("alter time") and jps.buff("presence of mind") },
	{ "arcane missiles",jps.buff("alter time") or jps.buffStacks("arcane missiles") == 2 },
	{ "rune of power",	not jps.buff("rune of power") and not jps.buff("alter time") },
	{ "mana gem",		jps.mana() < 0.84 and not jps.buff("alter time") },
	{ "mirror image" },
	{ "arcane power", 	not jps.buff("alter time") and stacks > 1 },
	{ "presence of mind", not jps.buff("alter time") },
	{ "nether tempest",	not jps.debuff("nether tempest") },
	{ "arcane blast",	jps.mana() > 0.92 },
	{ "arcane missiles",jps.buff("arcane missiles") and jps.cd("alter time") > 4 },
	{ "arcane barrage",	jps.buff("arcane charge") and not jps.buff("arcane power") and not jps.buff("alter time") and jps.cd("mana gem") > 10 },
	{ "arcane barrage",	stacks >= 4 and not jps.buff("arcane missiles") },
	{ "arcane blast" },
}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end
