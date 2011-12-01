-- jpganis
-- Ty to SIMCRAFT for this rotation
function new_dk_unholy(self)
	local power = UnitPower("player",6)
	local ffDuration = jps.debuffDuration("frost fever")
	local bpDuration = jps.debuffDuration("blood plague")
	local siStacks = jps.buffStacks("shadow infusion","pet")
	local superPet = jps.buff("dark transformation","pet")

	local dr1 = select(3,GetRuneCooldown(1))
	local dr2 = select(3,GetRuneCooldown(2))
	local fr1 = select(3,GetRuneCooldown(3))
	local fr2 = select(3,GetRuneCooldown(4))
	local ur1 = select(3,GetRuneCooldown(5))
	local ur2 = select(3,GetRuneCooldown(6))
	local one_dr = dr1 or dr2
	local two_dr = dr1 and dr2
	local one_fr = fr1 or fr2
	local two_fr = fr1 and fr2
	local one_ur = ur1 or ur2
	local two_ur = ur1 and ur2

	local spellTable =
	{
		-- interrupts
		{ "mind freeze", jps.shouldKick() },
		{ "strangulate", jps.shouldKick() and jps.LastCast ~= "mind freeze" },
		-- cooldowns
		{ "unholy frenzy", jps.UseCDs and not jps.buff("bloodlust") and not jps.buff("heroism") and not jps.buff("time warp")},
		-- mofes
		{ {"macro","/petattack"}, not IsPetAttackActive() },
		{ "outbreak", ffDuration < 2 and bpDuration < 2 },
		{ "icy touch", ffDuration < 2 },
		{ "plague strike", bpDuration < 2 },
		{ "dark transformation", "onCD" },
		{ "summon gargoyle",	jps.buff("unholy frenzy") },
		{ "death and decay", two_ur and rp < 110 },
		{ "scourge strike", two_ur and rp < 110 },
		{ "festering strike", two_dr and two_fr and rp < 110 },
		{ "blood boil", jps.MultiTarget },
		{ "death coil", rp > 90 },
		{ "death coil", jps.buff("sudden doom") },
		{ "death and decay", "onCD" },
		{ "scourge strike", "onCD"},
		{ "festering strike", "onCD"},
		{ "death coil", "onCD" },
		{ "blood tap", "onCD" },
		{ "empower rune weapon", "onCD" },
		{ "horn of winter", "onCD" },
	}

	spell = parseSpellTable( spellTable )
	if spell == "death and decay" then jps.groundClick() end
	return spell
end
