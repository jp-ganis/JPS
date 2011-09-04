function new_dk_unholy(self)
	-- jpganis, converted from kylextag's
	local power = UnitPower("player",6)
	local ffDuration = jps.debuffDuration("frost fever")
	local bpDuration = jps.debuffDuration("blood plague")
	local siStacks = jps.buffStacks("shadow infusion","pet")
	local superPet = jps.buff("dark transformation","pet")

	local spellTable =
	{
		-- interrupts
		{ "mind freeze", jps.shouldKick() },
		{ "strangulate", jps.shouldKick() and jps.LastCast ~= "mind freeze" },
		-- cooldowns
		{ "unholy frenzy", jps.UseCDs },
		{ "summon gargoyle", jps.UseCDs },
		-- buffs
		{ "horn of winter", not jps.buff("horn of winter") },
		{ "Icebound Fortitude", jps.hp() < 0.2 and jps.UseCDs },
		-- mofes
		{ {"macro","/petattack"}, not IsPetAttackActive() },
		{ "dark transformation", "onCD" },
		{ "outbreak", ffDuration < 2 and bpDuration < 2 },
		{ "plague strike", bpDuration < 2 },
		{ "icy touch", ffDuration < 2 },
		{ "death coil", jps.buff("sudden doom") },
		{ "death and decay", IsShiftKeyDown() },
		{ "scourge strike", siStacks < 5 },
		{ "blood boil", jps.MultiTarget },
		{ "festering strike", "onCD" },
		{ "death coil", not superPet and power >= 40 },
		{ "death coil", power >= 100 },
		{ "death coil", power >= 40 and superPet and jps.cd("Summon Gargoyle") > 0 },
		{ "blood tap", "onCD" },
		{ "horn of winter", "onCD" },
	}

	spell = parseSpellTable( spellTable )
	if spell == "death and decay" then jps.groundClick() end
	return spell
end
