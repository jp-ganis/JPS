function druid_guardian(self)
	--attempted by jpganis, fixed by Attip, updated by peanutbird
	-- simcraft
	-- Threat-Vars
	local myTargetThreatStatus = UnitThreatSituation("player","target")
	if not myTargetThreatStatus then myTargetThreatStatus = 0 end
	local myFocusThreatStatus = 0

	if UnitExists("focus") and UnitIsFriend("focus") then
		myFocusThreatStatus = UnitThreatSituation("focus") end

	-- Other stuff
	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("lacerate")
	local lacDuration = jps.debuffDuration("lacerate")
	local thrashDuration = jps.debuffDuration("thrash")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local onCD = "onCD"

	-- Moves
	local spellTable =
	{
		{nil,				IsSpellInRange("lacerate","target") ~= 1 },
		{"skull bash",			jps.Interrupts and jps.shouldKick() },
		{"mighty bash",			jps.Interrupts and jps.shouldKick() },
		{"mangle",			rage > 60 },

		-- Defense
		{"barkskin",			hp < 65 and jps.UseCDs},
		{"survival instincts",		hp < 40 and jps.UseCDs},
		{"might of ursoc",		hp < 25 and jps.UseCDs},
		{"frenzied regeneration",	hp < 55 and jps.buff("savage defense")},
		{"enrage",			rage <= 10 and hp > 95},
		{"savage defense",		(hp < 85 and rage >= 60)},
		-- Trinkets
		{jps.useTrinket(1),    		hp < 65 and jps.UseCDs },
		{jps.useTrinket(2),    		hp < 65 and jps.UseCDs },
		-- Offense
		{"berserk",			jps.UseCDs and jps.debuff("thrash") and jps.debuff("faerie fire")},
		-- Taunts
		{"growl",			myTargetThreatStatus < 2 and not jps.targetTargetTank() },
		-- Multi-Target
		{"thrash",			jps.MultiTarget and not jps.debuff("thrash")},
		{"mangle",			jps.MultiTarget },
		{"swipe",			jps.MultiTarget },
		-- Single Target
		{"mangle",			onCD or ub("player","berserk") },
		{"maul",			rage > 90 and hp >= 85 },	
		{"faerie fire",			not jps.debuff("weakened armor") },
		{"thrash",			not jps.debuff("thrash") or thrashDuration < 3},
		{"lacerate",			lacCount < 3 or lacDuration < 1 },
		{"faerie fire",			onCD },
	}


	return parseSpellTable(spellTable)
end
