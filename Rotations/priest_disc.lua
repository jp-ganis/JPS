function priest_disc(self)
	local tank = jps.findMeATank()
	local me = "player"
	local defaultTarget = jps.lowestFriendly()

	if UnitExists(tank) and jps.hpInc(tank) < 0.4 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	-- Check for Prayer of Mending
	local pomUp = false
	for unit,_ in jps.RaidStatus do
		if jps.buffDuration("prayer of mending",unit) > 0 then
			pomUp = true end
	end

	-- Don't kick penance
	if UnitChannelInfo(me) then return nil end
	
	local spellTable =
	{
		{ "penance",			defaultHP < 0.9, defaultTarget },
		{ "power word: shield",	defaultHP < 0.85 and not jps.debuff("weakened soul",defaultTarget), defaultTarget },
		{ "greater heal",		defaultHP < 0.65, defaultTarget },
		{ "heal",				defaultHP < 0.75, defaultTarget },
		{ "prayer of mending",	not pomUp },
		{ "prayer of healing",	jps.MultiTarget },
		{ "shadowfiend",		jps.mana(me) < 0.6 },
	}

	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
	
end
