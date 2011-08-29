function pvp_warrior_arms(self)
	local onCD = "onCD"
	local rage = UnitPower("player")
	local hamstringDuration = jps.debuffDuration("hamstring")
	local lttsStacks = jps.buffStacks("slaughter")
	local slaughterStacked = lttsStacks == 3
	local executePhase = jps.targetHP() <= 0.2

	local spellTable = 
	{
		{ "hamstring",				hamstringDuration < 2 },
		{ "pummel",					jps.shouldPvPKick() },
		{ "battle shout",			not jps.buff("battle shout") },
		{ "victory rush",			jps.buff("victorious") and (jps.hp() <= 0.75 or jps.buffDuration("victorious") < 3) },
		{ "rend",					not jps.debuff("rend") },
		-- Offensive Cooldowns
		{ "nested",					jps.UseCDs,
			{
				{ "throwdown",		jps.debuff("colossus smash") and slaughterStacked },
				{ "recklessness",	jps.debuff("colossus smash") and slaughterStacked },
				{ "deadly calm",	jps.debuff("colossus smash") and slaughterStacked and rage < 20 }, 
				{ jps.DPSRacial,	jps.buff("recklessness") or jps.buff("deadly calm") },
			}
		},
		-- Defensive Cooldowns
		{ "berserker rage",			jps.hp() < 0.6 },
		{ "enraged regeneration",	jps.buff("berserker rage") or jps.buff("enraged") and jps.hp() < 0.6 },
		-- Normal moves
		{ "colossus smash",			onCD },
		{ "execute",				onCD },
		{ "mortal strike",			onCD },
		{ "overpower",				onCD },
		{ "heroic strike",			rage > 70 or jps.buff("deadly calm") },
		{ "slam",					onCD }, 
	}

	local returnSpell = parseSpellTable(spellTable)

	if returnSpell == "recklessness" or returnSpell == "deadly calm" then
		RunMacroText("/use 14")
	end

	return returnSpell
end
