function paladin_holy(self)
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

	local defaultTarget = jps.lowestFriendly()

    if UnitExists(tank) and jps.hpInc(tank) < 0.4 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	local defaultHP = jps.hpInc(defaultTarget)
	
	local spellTable =
	{
		{ "lay on hands",		defaultHP < 0.05 and jps.UseCDs, defaultTarget, true },
		{ "hand of protection",	defaultHP < 0.15 and jps.UseCDs, defaultTarget, true },
        { "divine shield",	    jps.hp() < 0.30 and jps.UseCDs and not jps.buff("Forbearance", me), me }, --can be optimized by using on specific boss mechanics
        { "divine protection",	jps.hp() < 0.50 and jps.UseCDs, me },
        { "seal of insight",	"refresh" },
        { "beacon of light",	jps.buffDuration("beacon of light",tank) < 30, tank },
        { "cleanse",			cleanseTarget~=nil, cleanseTarget },
        { "rebuke",			    jps.shouldKick("target") and IsSpellInRange("Rebuke", "target"), "target" },
        { "judgement",			UnitExists(judgeTarget), judgeTarget },
        { "crusader strike",	UnitExists(crusaderTarget) and holyPower < 3, crusaderTarget },
        { "divine favor",	    UnitExists(focus) and jps.Combat and jps.hp("focus") < 0.9 and UnitClassification("focustarget")=="worldboss", me },
        { "avenging wrath",	    UnitExists(focus) and jps.Combat and jps.hp("focus") < 0.9 and UnitClassification("focustarget")=="worldboss", me },
        { "flash of light",		defaultHP < 0.35, defaultTarget },
        { "light of dawn",		holyPower == 3 and IsMouseButtonDown(2) },  -- only when right mouse button is pressed
        { "holy shock",			defaultHP < 0.8 and holyPower < 3, defaultTarget },
        { "word of glory",		defaultHP < 0.8 and holyPower == 3, defaultTarget },
        { "divine light",		defaultHP < 0.5, defaultTarget },
        { "holy light",			defaultHP < 0.7, defaultTarget },
        { "holy radiance",		jps.MultiTarget and jps.UseCDs },
	}

	local spell,target = parseSpellTable(spellTable)

	return spell
	
end
