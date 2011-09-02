function paladin_holy(self)
	local holyPower = UnitPower("player",9)
	
	local tank = nil
	local judgeTarget = nil
	local me = "player"

	-- Tank is focus.
	tank = jps.findMeATank()

	-- Find a target to judge.
	if UnitIsEnemy(me, "focustarget") then
		judgeTarget = "focustarget"	
	elseif UnitIsEnemy(me, "targettarget") then
		judgeTarget = "targettarget"
	elseif UnitIsEnemy(me, "target") then
		judgeTarget = "target"
	end

	local defaultTarget = jps.lowestFriendly()

	if UnitExists(tank) and jps.hpInc(tank) < 0.4 then defaultTarget = tank end
	if jps.hpInc(me) < 0.2 then	defaultTarget = me end

	local defaultHP = jps.hpInc(defaultTarget)
	
	local spellTable =
	{
		{ "seal of insight",	"refresh" },
		{ "beacon of light",	not jps.buff("beacon of light",tank), tank },
		{ "judgement",			UnitExists(judgeTarget) },	
		{ "holy shock",			defaultHP < 0.9, defaultTarget },
		{ "word of glory",		defaultHP < 0.85 and holyPower > 2, defaultTarget },
		{ "divine light",		defaultHP < 0.55, defaultTarget },
		{ "holy light",			defaultHP < 0.7, defaultTarget },
		{ "lay on hands",		defaultHP < 0.03 and jps.UseCDs, defaultTarget },
		{ "divine protection",	jps.hp() < 0.15 and jps.UseCDs, me },
		{ "hand of protection",	defaultHP < 0.15 and jps.UseCDs, defaultTarget },
		{ "holy radiance",		jps.MultiTarget and jps.UseCDs },
	}



	local spell,target = parseSpellTable(spellTable)
	jps.Target = target
	return spell
	
end
