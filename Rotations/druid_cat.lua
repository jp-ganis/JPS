--Ty to MEW Feral Sim
-- jpganis

-- NO LONGER USED
function druid_cat(self)
	local energy = UnitMana("player")
	local cp = GetComboPoints("player")
	local tfCD = jps.cooldown("tiger's fury")
	local ripDuration = jps.debuffDuration("rip")
	local rakeDuration = jps.debuffDuration("rake")
	local srDuration = jps.buffDuration("savage roar")
	local srRipSyncTimer = abs(ripDuration - srDuration)
	local executePhase = jps.hp("target") <= 0.25 --ADD TALENT DETECTION
	local gcdLocked = jps.cooldown("shred") == 0
	local energyPerSec = 10.59
	local clearcasting = jps.buff("clearcasting")
	local berserking = jps.buff("berserk")
	local tf_up = jps.buff("tiger's fury")

	local spellTable =
	{
		{ nil,					IsSpellInRange("shred","target") == 0 },
		-- 
		{ "tiger's fury", 		energy <= 35 and not clearcasting and gcdLocked },
		--
		{ "berserk", 			jps.UseCDs and jps.buff("tiger's fury") },
		{ "nature's vigil",		jps.UseCDs and jps.buff("berserk") },
		{ "incarnation",		jps.UseCDs and jps.buff("berserk") },
		{ jps.DPSRacial,		jps.UseCDs and jps.buff("berserk") },
		--
		{ "skull bash",jps.shouldKick() and jps.Interrupts },
		--
		{ nil,					gcdLocked },
		--
		{ "savage roar",		srDuration <= 1 or (srDuration <= 3 and cp > 0 and (cp < 5 or jps.buff("Dream of Cenarius"))) },
		{ "faerie fire", 		jps.debuffStacks("weakened armor")~=3 },
		--
		{ "ferocious bite",		executePhase and cp == 5 and ripDuration > 0 },
		{ "ferocious bite",		executePhase and cp > 0 and ripDuration <= 2 and ripDuration > 0 },
		--
		{ "rip", 				cp == 5 and ripDuration < 2 and (berserking or ripDuration+2 <= tfCD) },
		--
		{ "ferocious bite",		berserking and cp == 5 and ripDuration > 5 and srDuration > 1 },
		--
		{ "savage roar",		cp == 5 and ripDuration <= 12 and srDuration <= (ripDuration+4) },
		--
		{ "rake", 				jps.buff("tiger's fury") and rakeDuration < 9 },
		{ "rake", 				rakeDuration < 3 and (berserking or rakeDuration-0.8 <= tfCD or energy >= 71) },
		--
		{ "shred",				jps.buff("clearcasting") },
		--
		{ "savage roar",		cp > 0 and srDuration < 1 and ripDuration > 6 },
		--
		{ "ferocious bite",		(not berserking or energy < 25) and cp == 5 and ripDuration >= 14 and srDuration >= 10 },
		--
		{ "shred", 				berserking or jps.buff("tiger's fury") },
		{ "shred",				(cp < 5 and ripDuration <= 3) or (cp == 0 and srDuration <= 2) },
		{ "shred",				tfCD <= 3 },
		{ "shred",				energy >= 100 - (energyPerSec*2) },
	}

	return parseSpellTable(spellTable)
end
