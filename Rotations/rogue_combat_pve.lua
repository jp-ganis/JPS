function rogue_combat(self)
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("rupture")
	local snd_duration = jps.buffDuration("slice and dice")
	local BFMacroText = "/cancelaura Blade Flurry"
	local BFMacro = { "macro", BFMacroText, "Blade Flurry", defaultTarget }
	local energy = UnitPower("player")
	local bleeding = jps.debuff("hemorrhage") or jps.debuff("mangle") or jps.debuff("blood frenzy")

	
	local spellTable = 
	{
		{ nil,			ub("player","killing spree") },
		{ "Kick",		jps.Interrupts and jps.shouldKick("target") and cd("kick") == 0 },
		{ BFMacro,		ub("player","Blade Flurry") and not jps.MultiTarget },
		{ "Blade Flurry",	jps.MultiTarget and not ub("player","Blade Flurry") },
		-- CDs
		{ "killing spree",		jps.buff("deep insight") and energy < 50 and jps.buff("adrenaline rush") },
		{ "adrenaline rush",	energy < 15 },
		-- SINGLE TARGET
		{ "eviscerate",			cp == 5 and snd_duration > 0 },
		{ "slice and dice",		cp > 0 and snd_duration < 2 },
		{ "rupture",			bleeding and cp == 5 and not rupture_duration <= 2 },
		{ "revealing strike",	cp == 4 },
		{ "sinister strike",	cp < 4 },
	}

	return parseSpellTable(spellTable)

end


