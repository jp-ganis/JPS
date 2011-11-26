--jpganis
--Ty to SIMCRAFT for this rotation
function priest_shadow(self)
	local swpDuration = jps.debuffDuration("shadow word: pain")
	local plagueDuration = jps.debuffDuration("devouring plague")
	local vtDuration = jps.debuffDuration("vampiric touch")
	local gcd = 1.5
	
	local spellTable = 
	{
		{ "mind sear",			jps.MultiTarget },
		{ "mind blast",			"onCD" },
		{ jps.DPSRacial,		"onCD" },
		{ "shadow word: pain",	swpDuration < gcd + .5 and jps.LastCast ~= "shadow word: pain"},
		{ "devouring plague",	plagueDuration < gcd + 1.0 },
		--actions+=/stop_moving,health_percentage<=25,if=cooldown.shadow_word_death.remains>=0.2|dot.vampiric_touch.remains<cast_time+2.5
		{ "vampiric touch",		vtDuration < gcd + 2.5 and jps.LastCast ~= "vampiric touch"},
		{ "archangel",			jps.buffStacks("dark evangelism") >= 5 and vtDuration > 5 and plagueDuration > 5 },
		--actions+=/start_moving,health_percentage<=25,if=cooldown.shadow_word_death.remains<=0.1
		{ "shadow word: death",	jps.hp("target") <= 0.25 },
		{ "shadowfiend",		"onCD" },
		{ "shadow word: death",	jps.mana() < 0.1 },
		{ "mind flay",			"onCD" },
		--actions+=/shadow_word_death,moving=1
		--actions+=/devouring_plague,moving=1,if=mana_pct>10
	}

	return parseSpellTable( spellTable )
end
