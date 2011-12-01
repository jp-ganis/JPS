function rogue_combat_pvp(self)
	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("target","rupture")
	local snd_duration = jps.buffDuration("player","slice and dice")
	local BFMacroText = "/cancelaura Blade Flurry"
	local BFMacro = { "macro", BFMacroText, "Blade Flurry", defaultTarget }
	local energy = UnitPower("player")
	local targetClass = UnitClass("target")
	local shouldDisarm = targetClass == "warrior" or targetClass == "rogue" or targetClass == "death knight"

	
	local spellTable = 
	{
		{ nil,			ub("player","killing spree") },
		{ "Cheap Shot",		ub("player","stealth") and IsUsableSpell("cheap shot") },
		{ "Kick",		jps.Interrupts and jps.shouldKick("target") and cd("kick") == 0 },
		{ BFMacro,		ub("player","Blade Flurry") and not jps.MultiTarget },
		{ "Blade Flurry",	jps.MultiTarget and not ub("player","Blade Flurry") },
		{ "Evasion",		jps.hp() < 0.6 and not ub("player","evasion") },
		{ "Dismantle",		shouldDisarm and cd("dismantle") == 0 },
		{ "Adrenaline Rush",	jps.UseCDs and energy < 20 },
		{ "Killing Spree",	not jps.buff("adrenaline rush") and jps.UseCDs and energy < 20 and cd("Adrenaline Rush") > 0 },
		{ "Recuperate",		IsUsableSpell("Recuperate") and jps.hp() < 0.8 and not ub("player","recuperate") },
		{ "Slice and Dice",	not ub("player","slice and dice") and cp > 0 and not ud("target","revealing strike") },
		{ "Rupture",		(ud("target","Trauma") or ud("target","hemorrhage") or ud("target","mangle")) and cp > 3 and not ud("target","Rupture") and not jps.buff("blade flurry") and ud("target","revealing strike") },
		{ "Eviscerate",		ud("target","revealing strike") or cp == 5 },
		{ "Revealing Strike",	(cp == 3 or cp==4) and ub("player","slice and dice") },
		{ "Sinister Strike", 	cp < 3 },
		
	}

	return parseSpellTable(spellTable)

end


