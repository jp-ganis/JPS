function priest_disc(self)
	local tank = jps.findMeATank()
	local me = "player"

	-- Find a tank.

	local defaultTarget = jps.lowestFriendly()

	if UnitExists(tank) and jps.hpInc(tank) < 0.4 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end
	
	local spellTable =
	{
		{ "penance",			defaultHP < 0.9, defaultTarget },
		{ "power word: shield",	defaultHP < 0.85 and not jps.debuff("weakened soul"), defaultTarget },
		{ "greater heal",		defaultHP < 0.65, defaultTarget },
		{ "heal",				defaultHP < 0.75, defaultTarget },
		{ "prayer of mending",	"onCD" },
		{ "prayer of healing",	jps.MultiTarget },
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
	
end
