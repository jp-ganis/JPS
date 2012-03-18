--jpganis
-- Ty to SIMCRAFT for this rotation
function priest_shadow(self)
	local swpDuration = jps.debuffDuration("shadow word: pain")
	local plagueDuration = jps.debuffDuration("devouring plague")
	local vtDuration = jps.debuffDuration("vampiric touch")
	local gcd = 1.5
	

	local spellTable =
	{
		-- Movement/trash
		{ "shadow word death",	jps.Moving };
		{ "devouring plague",	jps.Moving and jps.mana() > 0.1 },
		{ "mind sear",			jps.MultiTarget },

		-- Highest priority
		{ "vampiric touch",		vtDuration < gcd + 2.5 and jps.LastCast ~= "vampiric touch"},
		{ "devouring plague",	plagueDuration < gcd + 1.0 },
		{ "shadow word: pain",	swpDuration < gcd + .5 and jps.LastCast ~= "shadow word: pain"},
		
		-- Situational
		{ "shadowfiend",		"onCD" },
		{ "archangel",			jps.buffStacks("dark evangelism") >= 5 and vtDuration > 5 and
								plagueDuration > 5 },
		
		-- Medium Priority
		-- SW:D before mind-blast only if you have tier 13 2-piece
		{ "shadow word: death",	jps.hp("target") <= 0.25 },
		{ "mind blast",			"onCD" },

		-- Filler
		{ "mind flay",			"onCD" }
	}

	return parseSpellTable( spellTable )
end
