function rogue_combat(self)
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("target","rupture")
	local snd_duration = jps.buffDuration("player","slice and dice")
	local BFMacroText = "/cancelaura Blade Flurry"
	local BFMacro = { "macro", BFMacroText, "Blade Flurry", defaultTarget }
	local energy = UnitPower("player")
	
	local spellTable = 
	{
		{ nil,			ub("player","killing spree") },
		{ "Kick",		jps.Interrupts and jps.shouldKick("target") and cd("kick") == 0 },
		{ BFMacro,		ub("player","Blade Flurry") and not jps.MultiTarget },
		{ "Blade Flurry",	jps.MultiTarget and not ub("player","Blade Flurry") },
		{ "Adrenaline Rush",	jps.UseCDs and energy < 20 },
		{ "Killing Spree",	not jps.buff("adrenaline rush") and jps.UseCDs and energy < 20 and cd("Adrenaline Rush") > 0 },
		{ "Slice and Dice",	not ub("player","slice and dice") and cp > 0 and not ud("target","revealing strike") },
		{ "Rupture",		(ud("target","Trauma") or ud("target","hemorrhage") or ud("target","mangle")) and cp > 3 and not ud("target","Rupture") and not jps.buff("blade flurry") and ud("target","revealing strike") },
		{ "Eviscerate",		ud("target","revealing strike") or cp == 5 },
		{ "Revealing Strike",	(cp == 3 or cp==4) and ub("player","slice and dice") },
		{ "Sinister Strike", 	cp < 3 },
		
	}

	return parseSpellTable(spellTable)

end


