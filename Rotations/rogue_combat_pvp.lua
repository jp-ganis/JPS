jps.registerRotation("ROGUE","COMBAT",function()

	local cp = GetComboPoints("player")
	local rupture_duration = jps.debuffDuration("target","rupture")
	local snd_duration = jps.buffDuration("player","slice and dice")
	local BFMacroText = "/cancelaura Blade Flurry"
	local BFMacro = { "macro", BFMacroText, defaultTarget }
	local energy = UnitPower("player")
	local targetClass = UnitClass("target")
	local shouldDisarm = targetClass == "warrior" or targetClass == "rogue" or targetClass == "death knight"

	local spellTable = 
	{
		{ nil,			jps.buff("killing spree") },
		{ "Cheap Shot",		jps.buff("stealth") and IsUsableSpell("cheap shot") },
		{ "Kick",		jps.Interrupts and jps.shouldKick("target") and jps.cooldown("kick") == 0 },
		{ BFMacro,		jps.buff("Blade Flurry") and not jps.MultiTarget },
		{ "Blade Flurry",	jps.MultiTarget and not jps.buff("Blade Flurry") },
		{ "Evasion",		jps.hp() < 0.6 and not jps.buff("evasion") },
		{ "Dismantle",		shouldDisarm and jps.cooldown("dismantle") == 0 },
		{ "Adrenaline Rush",	jps.UseCDs and energy < 20 },
		{ "Killing Spree",	not jps.buff("adrenaline rush") and jps.UseCDs and energy < 20 and jps.cooldown("Adrenaline Rush") > 0 },
		{ "Recuperate",		IsUsableSpell("Recuperate") and jps.hp() < 0.8 and not jps.buff("Recuperate") },
		{ "Slice and Dice",	not jps.buff("slice and dice") and cp > 0 and not jps.debuff("target","revealing strike") },
		{ "Rupture",		(jps.debuff("Trauma","target") or jps.debuff("hemorrhage","target") or jps.debuff("mangle","target")) and cp > 3 and not jps.debuff("Rupture","target") and not jps.buff("blade flurry") and jps.debuff("revealing strike","target") },
		{ "Eviscerate",		jps.debuff("revealing strike","target") or cp == 5 },
		{ "Revealing Strike",	(cp == 3 or cp==4) and jps.buff("slice and dice") },
		{ "Sinister Strike", 	cp < 3 },

	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default", false, true)