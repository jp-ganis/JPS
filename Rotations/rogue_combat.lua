--jpganis
-- Ty to SIMCRAFT for this rotation
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
		-- Blade Flurry
		{ BFMacro,		ub("player","Blade Flurry") and not jps.MultiTarget },
		{ "Blade Flurry",	jps.MultiTarget and not ub("player","Blade Flurry") },
		-- SnD
		{ "slice and dice",		cp > 0 and snd_duration < 2 },
		-- CDs
		{ "killing spree",		energy < 35 and snd_duration > 4 and not jps.buff("adrenaline rush") },
		{ "adrenaline rush",	energy < 35 },
		-- SINGLE TARGET
		{ "eviscerate",			cp == 5 and jps.buff("deep insight") },
		{ "rupture",			bleeding and cp == 5 and not rupture_duration <= 2 },
		{ "eviscerate",			cp == 5 },
		{ "revealing strike",	cp == 4 },
		{ "sinister strike",	cp < 4 },
	}

	return parseSpellTable(spellTable)

end


