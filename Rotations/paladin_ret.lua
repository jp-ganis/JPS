function paladin_ret(self)
	--jpganis + SIMCRAFT
	local hPower = UnitPower("player","9")

	local spellTable =
	{
		{ "rebuke", jps.Interrupts and jps.shouldKick() },
		{ "judgement", not jps.buff("judgements of the pure") },
		{ "zealotry" },
		{ "guardian of ancient kings", (jps.buffDuration("zealotry") < 31 and jps.buff("zealotry")) or jps.cd("zealotry")>60 },
		{ "avenging wrath", jps.buffDuration("zealotry") < 21 and jps.buff("zealotry") },
		{ "inquisition", jps.buffDuration("inquisition") < 5 and (hPower == 3 or jps.buff("divine purpose")) },
		{ "crusader strike", hPower < 3 },
		{ "templar's verdict", jps.buff("divine purpose") },
		{ "templar's verdict", hPower==3 },
		{ "hammer of wrath" },
		{ "exorcism", jps.buff("the art of war") },
		{ "judgement" },
		{ "holy wrath" },
		{ "consecration", jps.mana("abs") > 17000 },
		{ "divine plea" },
	}
	

	return parseSpellTable(spellTable)
end
