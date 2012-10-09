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
	local tfUp = jps.buff("tiger's fury")
	local ps = jps.buff("predatory swiftness")
	local cenarionStacks = jps.buffStacksID(108381) --Dream of Cenarius
	local spellTable = {}

	if jps.MultiTarget then
	    spellTable =
		{
		    { nil,					not jps.buff("Cat Form") },
            -- approximate aoe range
            { nil,					IsSpellInRange("skull bash","target") == 0 },
            { "savage roar",		srDuration == 0 },
			{ "tiger's fury", 		energy <= 35 and not clearcasting and gcdLocked },
            --
		    { "thrash",				jps.debuffDuration("thrash") < 2 },
		    { "swipe",				energy > 51 },
		}
	else
		spellTable =
		{
			{ nil,					not jps.buff("Cat Form") },
			{ nil,					IsSpellInRange("shred","target") == 0 },
			--
			{ "savage roar",		srDuration == 0 },
			--
			{ "healing touch",		jps.buff("predatory swiftness") and cp >= 4 and cenarionStacks < 2 },
			-- don't waste a predatory swiftness if you are below shred energy and don't have cenarionStacks
			{ "healing touch",  	jps.buff("predatory swiftness") and not clearcasting and energy < 45 and cenarionStacks < 2 and cp < 4 and jps.buffDuration("predatory swiftness") <= 1 },
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
			{ "thrash",				clearcasting and jps.debuffDuration("thrash") < 3 and cenarionStacks == 0 },
			{ "savage roar",		srDuration <= 1 or (srDuration <= 3 and cp > 0) and executePhase },
			--
			{ "nature's swiftness",	cenarionStacks == 0 and not ps and cp >= 5 and executePhase },
			--
			{ "rip",				cp >= 5 and cenarionStacks > 0 and executePhase and not jps.RipBuffed }, -- stronger rip detection
			{ "ferocious bite",		executePhase and cp == 5 and ripDuration > 0 },
			--
			{ "rip",				cp >= 5 and ripDuration < 2 and cenarionStacks > 0 },
			{ "savage roar",		srDuration <= 1 or (srDuration <= 3 and cp > 0) },
			{ "nature's swiftness",	cenarionStacks == 0 and not ps and cp >= 5 and ripDuration < 3 and (berserking or ripDuration <= tfCD) and not executePhase },		
			{ "rip",				cp >= 5 and ripDuration < 2 and (berserking or ripDuration < tfCD) },
			{ "thrash",				clearcasting and jps.debuffDuration("thrash") < 3 },
			{ "savage roar",		srDuration <= 6 and cp >= 5 and ripDuration > 4 },
			{ "ferocious bite",		cp >= 5 and ripDuration > 4 },
			--
			{ "rake",				cenarionStacks > 0 and not jps.RakeBuffed },
			{ "rake",				rakeDuration < 3 and (berserking or tfCD+0.8 >= rakeDuration) },
			--
			{ "shred",				clearcasting },
			{ "shred",				jps.buffDuration("predatory swiftness") > 1 and not (energy + (energyPerSec * (jps.buffDuration("predatory swiftness")-1)) < (4 - cp)*20) },
			{ "shred",				((cp < 5 and ripDuration < 3) or (cp == 0 and srDuration < 2 )) },
			--
			{ "thrash",				cp >= 5 and jps.debuffDuration("thrash") < 6 and (tfUp or berserking) },
			{ "thrash",				cp >= 5 and jps.debuffDuration("thrash") < 6 and tfCD <= 3 },
			{ "thrash",				cp >= 5 and jps.debuffDuration("thrash") < 6 and energy >= 100 - energyPerSec },
			--
			{ "shred", 				berserking or jps.buff("tiger's fury") },
			{ "shred",				tfCD <= 3 },
			{ "shred",				energy >= 100 - (energyPerSec*2) },
			--
			{ "force of nature" }, -- treants lol

		}
	end

	return parseSpellTable(spellTable)
end
