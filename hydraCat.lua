function hydraCat(self)
	--jpganis
	local energy = UnitMana("player")
	local cp = GetComboPoints("player")
	local tfCD = jps.getCooldown("tiger's fury")
	local ripDuration = jps.debuffDuration("rip")
	local rakeDuration = jps.debuffDuration("rake")
	local srDuration = jps.buffDuration("savage roar")
	local mangleDuration = jps.notmyDebuffDuration("mangle")
	local executePhase = UnitHealth("target")/UnitHealthMax("target") <= 0.25

	local spellTable =
	{
		--{"spell",				conditionOne and (conditionTwo or conditionThree) },

		{ nil,					not jps.buff("cat form") },

		{"berserk", 			tfCD > 25 and energy > 80 and jps.UseCDs },
		{"tiger's fury", 		IsSpellInRange("shred","target") and ((energy <= 35 and not jps.buff("clearcasting")) or energy <= 26) },
		{"skull bash(cat form)",jps.shouldKick() and jps.Interrupts },
		{"faerie fire (feral)", not jps.debuff("faerie fire") and (energy < 15 or not IsSpellInRange("shred","target")) },
		{"ravage", 				jps.buff("stampede") and (jps.buffDuration("stampede") < 2 or jps.buff("tiger's fury")) },
		{"mangle(cat form)", 	mangleDuration < 1 and not jps.debuff("trauma") and not jps.debuff("hemorrhage") },
		{"ferocious bite", 		executePhase and (cp == 5 or ripDuration < 2) and ripDuration > 0 },
		{"rip", 				cp == 5 and ripDuration < 2 },
		{"rake", 				(jps.buff("tiger's fury") and rakeDuration < 8.5) or (rakeDuration < 3) },
		{"shred",				jps.buff("clearcasting") },
		{"savage roar", 		cp > 4 and ripDuration > 12 and srDuration < 12 },
		{"savage roar", 		cp > 0 and ripDuration > 12 and abs(srDuration-ripDuration) <= 3 },
		{"savage roar", 		cp > 0 and srDuration < 2 and ripDuration >= 8 },
		{"ravage", 				jps.buff("stampede") and cp < 5 and ripDuration == 0 },
		{"shred", 				jps.buff("berserk") or energy > 80 or tfCD <= 3 or ripDuration == 0 or srDuration == 0 or cp < 5 },
	}

	return parseSpellTable(spellTable)
end
