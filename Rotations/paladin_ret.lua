function paladin_ret(self)
	--jpganis + SIMCRAFT
	local hPower = UnitPower("player","9")
	local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
	local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100

	local spellTable =
	{
		{ "rebuke", jps.Interrupts and jps.shouldKick() },
		{ "arcane torrent", jps.Interrupts and jps.shouldKick() },
		{ "word of glory", myHealthPercent < 15 },
	--	{{"macro","/use 14"},	jps.itemCooldown(72899) == 0 and jps.UseCDs },
		{ "judgement", not jps.buff("judgements of the pure") },
		{ "zealotry" },
		{ "guardian of ancient kings", (jps.buffDuration("zealotry") < 31 and jps.buff("zealotry")) or jps.cd("zealotry")>60 and jps.UseCDs },
		{ "avenging wrath", jps.buffDuration("zealotry") < 21 and jps.buff("zealotry") and (IsSpellInRange("Crusader Strike","target") == 1) and jps.UseCDs },
		{ "inquisition", jps.buffDuration("inquisition") < 5 and (hPower == 3 or jps.buff("divine purpose")) },
		{ "divine storm", hPower < 3 and jps.MultiTarget },
        	{ "crusader strike", hPower < 3 },
		{ "templar's verdict", jps.buff("divine purpose") },
		{ "templar's verdict", hPower==3 },
		{ "divine plea", myManaPercent < 45 },
		{ "hammer of wrath" },
		{ "exorcism", jps.buff("the art of war") },
		{ "judgement" },
		{ "holy wrath" },
		{ "consecration", jps.mana("abs") > 17000 and (IsSpellInRange("Crusader Strike","target") == 1) },
		{ "divine plea" },
	}

	return parseSpellTable(spellTable)
end

