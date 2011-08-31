function hydraBear(self)
	--Gocargo <3
	-- Threat-Vars
	local myTargetThreatStatus = UnitThreatSituation("player","target")
	local myFocusThreatStatus = nil
	local targetTargetTanking = ub("targettarget","bear form") or ub("targettarget","defensive stance") or ub("targettarget","blood presence") or ub("targettarget","righteous fury")

	if UnitIsFriendly("focus") then
		myFocusThreatStatus = UnitThreatSituation("focus") end

	-- Other stuff
	local rage = UnitMana("player")
	local lacCount = jps.debuffStacks("lacerate")
	local lacDuration = jps.debuffDuration("lacerate")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100
	local onCD = "onCD"

	-- Moves
	local spellTable =
	{
		{nil,						not jps.buff("bear form") },
		{"skull bash(bear form)",	jps.Interrupts and jps.shouldKick() },
		{"bash",					jps.Interrupts and jps.shouldKick() },
		{"maul",					rage > 40 },
		-- Defense
		{"barkskin",				hp < 75 },
		{"survival instincts",		hp < 40 },
		{"frenzied regeneration",	hp < 25 },
		-- Offense
		{"berserk",					jps.UseCDs },
		-- Taunts
		{"growl",					myTargetThreatStatus < 2 and not targetTargetTanking },
		{"challenging roar",		focusThreatStatus > 1 },
		-- Multi-Target
		{"mangle(bear form)",		jps.buff("berserk") and jps.MultiTarget },
		{"swipe(bear form)",		jps.MultiTarget },
		{"thrash",					jps.MultiTarget },
		-- Single Target
		{"mangle(bear form)",		rage >= 20 or ub("player","berserk") },
		{"pulverize",				lacCount == 3 },
		{"lacerate",				lacCount < 3 or lacDuration < 1 },
		{"faerie fire (feral)",		onCD },
		{"demoralizing roar",		not jps.debuff("demoralizing roar" },
	}


	return parseSpellTable(spellTable)
end
