function paladin_holy(self)
	-- INFO
	-- 3 holy power + right mouse button to use Ligh of Dawn
	-- CDs: Lay on Hands, Divine Shield, Divine Protection, Avenging Wrath, Divine Favor
	
	--healer
	local holyPower = UnitPower("player",9)
	
	local tank = nil
	local judgeTarget = nil
    local crusaderTarget = nil
	local me = "player"

	-- Tank is focus.
	tank = jps.findMeATank()

	-- Find a target to judge.
    if UnitExists("focustarget") and UnitIsEnemy(me, "focustarget") and IsSpellInRange("judgement", "focustarget")  then
		judgeTarget = "focustarget"
    elseif UnitExists("target") and UnitIsEnemy(me, "target")  and IsSpellInRange("judgement", "target") then
		judgeTarget = "target"
	elseif UnitExists("targettarget") and UnitIsEnemy(me, "targettarget")  and IsSpellInRange("judgement", "targettarget") then
		judgeTarget = "targettarget"
	end

    -- Find a target for crusader strike.
	if UnitExists("focustarget") and UnitIsEnemy(me, "focustarget") and IsSpellInRange("crusader strike", "focustarget") then
		crusaderTarget = "focustarget"
    elseif UnitExists("target") and UnitIsEnemy(me, "target") and IsSpellInRange("crusader strike", "target") then
		crusaderTarget = "target"
	elseif UnitExists("targettarget") and UnitIsEnemy(me, "targettarget") and IsSpellInRange("crusader strike", "targettarget") then
		crusaderTarget = "targettarget"
    end

    -- Check if we should cleanse
    local cleanseTarget = nil
    local hasSacredCleansingTalent = 0
    _,_,_,_,hasSacredCleansingTalent =  GetTalentInfo(1,14)
    if hasSacredCleansingTalent == 1 then
      cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Disease"},{"Magic"})
    else
      cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Disease"})
    end

	--Default to healing lowest partymember
	local defaultTarget = jps.lowestInRaidStatus()
--	local defaultTarget = jps.lowestFriendly()

	--Check that the tank isn't going critical, and that I'm not about to die
    if jps.canHeal(tank) and jps.hpInc(tank) <= 0.5 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	local defaultHP = jps.hpInc(defaultTarget)
	
	local spellTable =
	{
		{ "lay on hands",		defaultHP < 0.05 and jps.UseCDs, defaultTarget },
--		{ "hand of protection",	defaultHP < 0.15 and jps.UseCDs, defaultTarget }, -- Not sure it is a good to have, since if the tank gets it, he will loose aggro
        { "divine shield",	    jps.hp() < 0.30 and jps.UseCDs and not jps.buff("Forbearance", me), me }, --can be optimized by using on specific boss mechanics
        { "divine protection",	jps.hp() < 0.50 and jps.UseCDs, me },
        { "seal of insight",	not jps.buff("seal of insight") }, 
        { "beacon of light",	jps.buffDuration("beacon of light",tank) < 30, tank },
--        { "cleanse",			cleanseTarget~=nil, cleanseTarget },
        { "rebuke",			    jps.shouldKick("target") and IsSpellInRange("Rebuke", "target"), "target" },
        { "judgement",			not jps.buff("Judgements of the Pure"), judgeTarget }, -- No need to judge all the time, only once per min for hast buff 
--        { "crusader strike",	UnitExists(crusaderTarget) and holyPower < 3, crusaderTarget }, -- More for PvP use
        { "light of dawn",		holyPower == 3 and IsMouseButtonDown(2) ~= nil },  -- only when right mouse button is pressed
        { "word of glory",		defaultHP < 0.8 and holyPower == 3, defaultTarget },
        { "avenging wrath",	    jps.UseCDs },
        { "holy shock",			defaultHP < 0.94 and holyPower < 3, defaultTarget },
        { "divine favor",	    jps.UseCDs },
        { "holy radiance",		defaultHP < 0.95 and jps.MultiTarget, defaultTarget },
-- { "guardian of ancient kings", 	}, -- TODO
        { "flash of light",		defaultHP < 0.3, defaultTarget },
        { "divine light",		defaultHP < 0.75, defaultTarget },
        { "holy light",			defaultHP < 0.95, defaultTarget },
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
	
end
