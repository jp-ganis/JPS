function druid_guardian(self)
	--attempted by jpganis, fixed by Attip!
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
	local demoDuration = jps.debuffDuration("demoralizing roar")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local onCD = "onCD"

	-- Moves
	local spellTable =
	{
		{nil,						not jps.buff("bear form") },
		{"skull bash(bear form)",	jps.Interrupts and jps.shouldKick() },
		-- {"bash",					jps.Interrupts and jps.shouldKick() },
		{"maul",					rage > 60 },
		-- Defense
		{"barkskin",				hp < 75 and jps.UseCDs},
		{"survival instincts",		hp < 40 and jps.UseCDs},
		{"frenzied regeneration",	hp < 25 and jps.UseCDs},
		{"demoralizing roar",		not jps.debuff("demoralizing roar") or demoDuration < 3},
		{"enrage",			rage <= 80},
		-- Offense
		{"berserk",					jps.UseCDs and jps.debuff("demoralizing roar") and jps.debuff("faerie fire")},
		-- Taunts
		{"growl",					myTargetThreatStatus < 2 and not jps.targetTargetTank() },
		{"challenging roar",		myFocusThreatStatus > 1 },
		-- Multi-Target
		{"mangle(bear form)",		jps.buff("berserk") and jps.MultiTarget },
		{"swipe(bear form)",		jps.MultiTarget },
		{"thrash",					jps.MultiTarget },
		-- Single Target
		{"mangle(bear form)",		onCD or ub("player","berserk") },
		{"faerie fire (feral)",		not jps.debuff("faerie fire") },
		{"thrash",					rage >= 25 },
		{"pulverize",				lacCount == 3 },
		{"lacerate",				lacCount < 3 or lacDuration < 1 },
		{"faerie fire (feral)",		onCD },
	}


	return parseSpellTable(spellTable)
end
