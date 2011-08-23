function hydraBear(self)
	--Gocargo <3
	-- Threat-Vars
	local uTS = UnitThreatSituation
	local focusShouldBeSaved = false
	local focusThreatDuration = 0
	local targetShouldBeTaunted = false
	local targetThreatDuration = 0
	local targetTargetTanking = ub("targettarget","bear form") or ub("targettarget","defensive stance") or ub("targettarget","blood presence") or ub("targettarget","righteous fury")

	-- Other stuff
	local rage = UnitMana("player")
	local lacCount = jps.getDebuffStacks("lacerate")
	local lacDuration = jps.getDebuffDuration("lacerate")
	local hp = UnitHealth("player")/UnitHealthMax("player") * 100

    --Taunt if not attacking me and if my focus target pulls agro
    if UnitExists("focus") and UnitIsFriend("focus","player") then
        if uTS("focus") ~= nil and uTS("focus") == 3 then
            if focusThreatDuration == 0 then
                focusThreatDuration = GetTime()
            elseif GetTime()-focusThreatDuration > 2 and not focusShouldBeSaved then
                focusShouldBeSaved = true
                print("focus will be saved")
            end 
        elseif focusShouldBeSaved or focusThreatDuration > 0 then
            focusShouldBeSaved = false
            focusThreatDuration = 0 
        end 
    end 
   
	--Target Checks
    if UnitExists("target") and UnitCanAttack("target","player") then
        if uTS("player","target") and uTS("player","target") < 3 and not targetTargetTanking then
            if targetThreatDuration == 0 then
                targetThreatDuration = GetTime()
            elseif GetTime()-targetThreatDuration > 0.5 and not targetShouldBeTaunted then
                targetShouldBeTaunted = true
                print("Taunting Target")
            end 
        elseif targetShouldBeTaunted or targetThreatDuration > 0 then
            targetShouldBeTaunted = false
            targetThreatDuration = 0 
        end 
    end 


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
		{"demoralizing roar",		"refresh" },
		-- Offense
		{"berserk",					jps.UseCDs },
		-- Taunts
		{"growl",					targetShouldBeTaunted },
		{"challenging roar",		focusShouldBeSaved },
		-- Multi-Target
		{"mangle(bear form)",		jps.buff("berserk") and jps.MultiTarget },
		{"swipe(bear form)",		jps.MultiTarget },
		{"thrash",					jps.MultiTarget },
		-- Single Target
		{"mangle(bear form)",		rage >= 20 or ub("player","berserk") },
		{"thrash",					"onCD" },
		{"faerie fire (feral)",		not jps.debuff("faerie fire") },
		{"pulverize",				lacCount == 3 },
		{"lacerate",				lacCount < 3 or lacDuration < 1 },
		{"faerie fire (feral)",		"onCD" },
	}


	return parseSpellTable(spellTable)
