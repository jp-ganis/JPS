function druid_resto(self)
	--healer
	local tank = nil
	local me = "player"

	-- Tank is focus.
	tank = jps.findMeATank()

    -- Check if we should cleanse
    local cleanseTarget = nil
    local hasSacredCleansingTalent = 0
    _,_,_,_,hasSacredCleansingTalent = 1 -- GetTalentInfo(1,14) JPTODO: find the resto talent
    if hasSacredCleansingTalent == 1 then
      cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"},{"Magic"})
    else
      cleanseTarget = jps.FindMeADispelTarget({"Poison"},{"Curse"})
    end

	--Default to healing lowest partymember
	local defaultTarget = jps.lowestFriendly()

	--Check that the tank isn't going critical, and that I'm not about to die
    if UnitExists(tank) and jps.hpInc(tank) <= 0.5 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	--Get the health of our decided target
	local defaultHP = jps.hpInc(defaultTarget)

	--JPTODO tranquility detection
	
	local spellTable =
	{
    { "barkskin",			jps.hp() < 0.50 },
		{ "tree of life",		defaultHP < 0.45 and not jps.buff("tree of life") },
    { "remove corruption",	cleanseTarget~=nil, cleanseTarget },
    { "wild growth",		jps.MultiTarget and defaultHP < 0.85 },
		{ "regrowth",			defaultHP < 0.55 or jps.buff("clearcasting"), defaultTarget },
    { "rejuvenation",		defaultHP < 0.85 and not jps.buff("rejuvenation",defaultTarget), defaultTarget },
		{ "swiftmend",			defaultHP < 0.75, defaultTarget },
		{ "nourish",			defaultHP < 0.8, defaultTarget },
    { "lifebloom",			jps.buffDuration("lifebloom",tank) < 3 or jps.buffStacks("lifebloom",tank) < 3, tank },
    { "rejuvenation",		jps.buffDuration("rejuvenation",tank) < 3, tank },
		{ "nourish",			jps.hpInc(tank) < 0.9 or jps.buffDuration("lifebloom",tank) < 5, tank },
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
	
end
