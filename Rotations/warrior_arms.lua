--jpganis + simcraft
function warrior_arms(self)
	local rage = UnitPower("player")
	local stance = GetShapeshiftForm()
	local midGCD = jps.cd("hamstring") > 0

	local spellTable = {
		{ "berserker stance", not jps.buff("taste for blood") and rage < 75 and midGCD },
		{ "battle stance", (not jps.myDebuff("rend") or jps.buff("taste for blood")) and jps.cd("mortal strike") > 1 and midGCD },
		{ "recklessness", jps.hp("target") <= 0.2 and midGCD },
		{ "berserker rage", not jps.buff("deadly calm") and rage < 70 },
		{ "deadly calm", rage < 30 and midGCD },
		{ "sweeping strikes", jps.MultiTarget },
		{ "bladestorm", jps.MultiTarget and not jps.buff("deadly calm") and not jps.buff("sweeping strikes") },
		{ "cleave", jps.MultiTarget },
		{ "inner rage", not jps.buff("deadly calm") and rage > 70 and jps.cd("deadly calm") > 15 },
		{ "heroic strike", rage >= 85 and jps.hp("target") > 0.2 },
		{ "heroic strike", jps.buff("deadly calm") },
		{ "heroic strike", jps.buff("battle trance") },
		{ "heroic strike", (jps.buff("incite") or jps.myDebuff("colossus smash")) and (rage >= 50 or jps.hp("target") > 0.2) },
		{ "heroic strike", rage >= 75 and jps.hp("target") < 0.2 },
		{ "overpower", jps.buffDuration("taste for blood") <= 1.5 and jps.buff("taste for blood") },
		{ "mortal strike", jps.hp("target") > 0.2 or rage >= 30 },
		{ "execute", jps.buff("battle trance") },
		{ "rend", not jps.myDebuff("rend") },
		{ "colossus smash", not jps.myDebuff("colossus smash") },
		{ "execute", jps.buff("deadly calm") or jps.buff("recklessness") },
		{ "mortal strike" },
		{ "overpower" },
		{ "execute" },
		{ "colossus smash", jps.debuffDuration("colossus smash") < 1.5 },
		{ "slam", jps.cd("mortal strike") >= 1.5 and (rage >= 35 or jps.buff("deadly calm") or jps.myDebuff("colossus smash")) },
		{ "slam", jps.cd("mortal strike") >= 1.2 and jps.debuffDuration("colossus smash") > 0.5 and rage >= 35 },
		{ "battle shout", rage < 20 },
	}

	return parseSpellTable(spellTable)
end

	


--pvp
function warrior_arms_pvp(self)
	local rage = UnitPower("player")
	local hamstringDuration = jps.debuffDuration("hamstring")
	local lttsStacks = jps.buffStacks("slaughter")
	local slaughterStacked = lttsStacks == 3
	local executePhase = jps.hp("target") <= 0.2
	local targetClass = UnitClass("target")
	local stance = GetShapeshiftForm()
	local shouldDisarm = targetClass == "warrior" or targetClass == "rogue" or targetClass == "death knight"

	local roots = {"freeze","entangling roots","frost nova"}
	local rooted = false
	for _,root in pairs(roots) do 
		if jps.debuff("player","root") then
			rooted = true
		end
	end

	local spellTable = 
	{
		{ "charge"					},
		{ "bladestorm",				IsSpellInRange("mortal strike","target")==0 and rooted },
		{ "hamstring",				hamstringDuration < 0.75 and not jps.buff("hand of freedom","target") and not jps.debuff("crippling poison") and not jps.debuff("chains of ice")},
		{ "pummel",					jps.shouldKick() },
		{ "battle shout",			not jps.buff("battle shout") },
		{ nil,						jps.buff("bladestorm") },
		{ "victory rush",			jps.buff("victorious") and (jps.hp() <= 0.75 or jps.buffDuration("victorious") < 3) },
		{ "rend",					not jps.debuff("rend") },
		-- Offensive Cooldowns
		{ "nested",					jps.UseCDs and jps.hp() > 0.6,
			{
				{ "throwdown",		jps.debuff("colossus smash") and slaughterStacked },
				{ "recklessness",	jps.debuff("colossus smash") and slaughterStacked },
				{ "deadly calm",	jps.debuff("colossus smash") and slaughterStacked and rage < 20 }, 
				{ jps.DPSRacial,	(jps.buff("recklessness") or jps.buff("deadly calm")) and jps["DPS Racial"]},
				{ "Lifeblood",		jps.buff("recklessness") or jps.buff("deadly calm") },
			}
		},
		-- Defensive Cooldowns
		{ "berserker rage",			jps.hp() < 0.6 and jps.cooldown("enraged regeneration")==0},
		{ "enraged regeneration",	jps.buff("berserker rage") or jps.buff("enraged") and jps.hp() < 0.6 },
		{ "defensive stance",		stance ~= 2 and shouldDisarm and jps.cooldown("disarm")==0 },	
		{ "disarm",					stance ~= 2 and shouldDisarm },
		-- Normal moves
		{ "battle stance",			stance ~= 1 },
		{ warrior_arms() },
	}

	spell = parseSpellTable(spellTable)
	return spell
end
