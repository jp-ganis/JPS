function warrior_arms_pvp(self)
	local onCD = "onCD"
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
		{ "charge",					onCD },
		{ "bladestorm",				IsSpellInRange("mortal strike","target")==0 and rooted },
		{ "hamstring",				hamstringDuration < 2 and not jps.buff("hand of freedom","target") },
		{ "pummel",					jps.shouldKick() },
		{ nil,						jps.buff("bladestorm") },
		{ "battle shout",			not jps.buff("battle shout") },
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
		{ "colossus smash",			onCD },
		{ "execute",				onCD },
		{ "mortal strike",			onCD },
		{ "overpower",				onCD },
		{ "heroic strike",			rage > 70 or jps.buff("deadly calm") },
		{ "slam",					rage > 35 }, 
	}

	spell = parseSpellTable(spellTable)
	return spell
end
