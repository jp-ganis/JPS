function paladin_protadin(self)
    
    -- New format by Gocargo.
    local myHealthPercent = UnitHealth("player")/UnitHealthMax("player") * 100
    local myManaPercent = UnitMana("player")/UnitManaMax("player") * 100
    local hPower = UnitPower("player","9")

    local spellTable =
   {
		{ "Lay on Hands",            myHealthPercent < 10 },
       --{ "Ardent Defender",         myHealthPercent < 22 and jps.Defensive },
	   --{ "Guardian of Ancient Kings", myHealthPercent < 38 and jps.Defensive },
		{ "Divine Protection",       myHealthPercent < 65 },
		{ "Holy Shield",             myHealthPercent < 80 },
		{ "Righteous Fury",          not jps.buff("Righteous Fury") },
		{ "Seal of Truth",           not jps.buff("Seal of Truth") },
		{ "Rebuke",                  jps.Interrupts and jps.shouldKick() },
		{ "Arcane Torrent",          jps.Interrupts and jps.shouldKick()},
		{ "Avenging Wrath",          jps.UseCDs },
		{ "Hammer of the Righteous", hPower < 3 and jps.MultiTarget },
		{ "Crusader Strike",         hPower < 3 },
		{ "Judgement",               not jps.buff("judgements of the pure") },
		{ "Word of Glory",           myHealthPercent < 35 and hPower == 3 },
		{ "Inquisition",             hPower == 3 and jps.MultiTarget and not jps.buff("Inquisition") },
		{ "Shield of the Righteous", hPower == 3 },
		{ "Avenger's Shield",        },
		{ "Divine Plea",             myManaPercent < 35 },
		{ "holy wrath",              jps.MultiTarget },
		{ "hammer of wrath",         },
        { "judgement",               },
		{ "holy wrath",              },
		{ "Consecration",            myManaPercent > 40 and (IsSpellInRange("Crusader Strike","target") == 1) },

	}

	return parseSpellTable(spellTable)
end
