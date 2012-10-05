--Ty to MEW Feral Sim
-- jpganis
function druid_feral(self)
	local energy = UnitMana("player")
	local cp = GetComboPoints("player")
	local tfCD = jps.cooldown("tiger's fury")
	local ripDuration = jps.debuffDuration("rip")
	local rakeDuration = jps.debuffDuration("rake")
	local srDuration = jps.buffDuration("savage roar")
	local srRipSyncTimer = abs(ripDuration - srDuration)
	local executePhase = jps.hp("target") <= 0.25
	local gcdLocked = true -- they changed this :( jps.cooldown("shred") == 0
	local energyPerSec = 10.59
	local clearcasting = jps.buff("clearcasting")
	local berserking = jps.buff("berserk")
	local tf_up = jps.buff("tiger's fury")
	local ps = jps.buff("predatory swiftness")
	local cenarion_stacks = jps.buffStacks("Dream of Cenarius")

	local spellTable =
	{
		{ nil,				not jps.buff("Cat Form") },
		{ nil,				IsSpellInRange("shred","target") == 0 },
		--
		{ "savage roar",		srDuration == 0 },
		--
		{ "healing touch",		jps.buff("predatory swiftness") and cp >= 4 and cenarion_stacks < 2 },
		{ "healing touch",		jps.buff("nature's swiftness") },
		-- 
		{ "tiger's fury", 		energy <= 35 and not clearcasting and gcdLocked },
		--
		{ "berserk", 			jps.UseCDs and jps.buff("tiger's fury") },
		{ "nature's vigil",		jps.UseCDs and jps.buff("berserk") },
		{ "incarnation",		jps.UseCDs and jps.buff("berserk") },
		{ jps.DPSRacial,		jps.UseCDs and jps.buff("berserk") },
		--
		{ "skull bash",			jps.shouldKick() and jps.Interrupts },
		--
		{ "ferocious bite",		executePhase and cp > 0 and ripDuration <= 2 and ripDuration > 0 },
		{ "thrash",			clearcasting and jps.debuffDuration("thrash") < 3 and cenarion_stacks == 0 },
		{ "savage roar",		sr_duration <= 1 or (sr_duration <= 3 and cp > 0) and execute_phase },
		--
		{ "nature's swiftness",		cenarion_stacks == 0 and not ps and cp >= 5 and execute_phase },
		--
		--{ "rip",			cp >= 5 and cenarion_stacks > 0 and execute_phase }, -- stronger rip detection
		{ "ferocious bite",		executePhase and cp == 5 and ripDuration > 0 },
		--
		{ "rip",			cp >= 5 and rip_duration < 2 and cenarion_stacks > 0 },
		{ "savage roar",		sr_duration <= 1 or (sr_duration <= 3 and cp > 0) },
		{ "nature's swiftness",		cenarion_stacks == 0 and not ps and cp >= 5 and rip_duration < 3 and (berserking or rip_duration <= tf_cd) and not execute_phase },		
		{ "rip",			cp >= 5 and rip_duration < 2 and (berserking or rip_duration < tf_cd) },
		{ "thrash",			clearcasting and jps.debuffDuration("thrash") < 3 },
		{ "savage roar",		sr_duration <= 6 and cp >= 5 and rip_duration > 4 },
		{ "ferocious bite",		cp >= 5 and rip_duration > 4 },
		--
		{ "shred", 			berserking or jps.buff("tiger's fury") },
		{ "shred",			(cp < 5 and ripDuration <= 3) or (cp == 0 and srDuration <= 2) },
		{ "shred",			tfCD <= 3 },
		{ "shred",			energy >= 100 - (energyPerSec*2) },

	}

	return parseSpellTable(spellTable)
end
