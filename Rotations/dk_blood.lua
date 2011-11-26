function new_dk_blood(self)
	-- jpganis, converted from Kiwi's
	-- not SIMCRAFT, but SIMCRAFT status
	local power = UnitPower("player",6)
	local targetThreatStatus = UnitThreatSituation("player","target")
	if not targetThreatStatus then targetThreatStatus = 0 end

	local spellTable =
	{
		-- taunt
		{ "dark command", targetThreatStatus ~= 3 and not jps.targetTargetTank() },
		-- kick
		{ "mind freeze", jps.shouldKick() },
		{ "Strangulate", jps.shouldKick() and jps.LastCast ~= "mind freeze" },
		-- aggro cooldowns
		{ "Raise Dead", jps.UseCDs },
		{ "Dancing Rune Weapon", jps.UseCDs },
		-- defensive cooldowns
		{ "Icebound Fortitude", jps.hp() < 0.3 },
		{ "Vampiric Blood", jps.hp() < 0.5 },
		{ "Rune Tap", jps.hp() < 0.8 },
		-- buffs
		{ "horn of winter", not jps.buff("horn of winter") },
		{ "Blood Presence", not jps.buff("blood presence") },
		{ "Bone Shield", not jps.buff("bone shield") },
		-- multitarget
		{ "death and decay", IsShiftKeyDown() and jps.MultiTarget },
		{ "pestilence", UnitExists("focus") and not jps.debuff("blood plague","focus") and jps.MultiTarget },
		-- singletarget
		{ "Death Grip", IsSpellInRange("plague strike","target") == 0 },
		{ "death strike", "onCD" },
		{ "rune strike", power >= 100 },
		{ "outbreak", not jps.debuff("blood plague") },
		{ "plague strike", not jps.debuff("blood plague") },
		{ "icy touch", not jps.debuff("frost fever") },
		{ "heart strike", jps.debuff("blood plague") and jps.debuff("frost fever") },
		{ "horn of winter", "onCD" },
	}


	spell = parseSpellTable(spellTable)
	if spell == "death and decay" then jps.groundClick() end

	return spell
end

