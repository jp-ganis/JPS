--Ty to MEW Feral Sim
-- jpganis
function druid_cat(self)
	if not jps.PvP then return druid_cat_pve()
	else return druid_cat_pvp() end
end

function druid_cat_pve(self)
	local energy = UnitMana("player")
	local cp = GetComboPoints("player")
	local tfCD = jps.cooldown("tiger's fury")
	local ripDuration = jps.debuffDuration("rip")
	local rakeDuration = jps.debuffDuration("rake")
	local srDuration = jps.buffDuration("savage roar")
	local srRipSyncTimer = abs(ripDuration - srDuration)
	local mangleDuration = jps.notmyDebuffDuration("mangle")
	local executePhase = jps.hp("target") <= 0.6 --ADD TALENT DETECTION
	local gcdLocked = jps.cooldown("shred") > 0
	local energyPerSec = 10.59
	local clearcasting = jps.buff("clearcasting")
	local berserking = jps.buff("berserk")
	local tf_up = jps.buff("tiger's fury")

	local pseudoMangle = jps.debuff("hemorrhage") or jps.debuff("trauma") or jps.debuff("tendon rip") or jps.debuff("gore") or jps.debuff("stampede")

	if pseudoMangle==true then mangleDuration = 5 end

	local spellTable =
	{
		{ nil,					IsSpellInRange("shred","target") == 0 },
		-- 
		{ "mangle(cat form)",	jps.Opening and cp == 0 },
		{ "savage roar",		jps.Opening and cp > 0 and srDuration == 0 },
		{ "tiger's fury", 		jps.Opening and srDuration > 0 },
		--
		{ "tiger's fury", 		energy <= 35 and not clearcasting and gcdLocked },
		--
		{ "berserk", 			jps.UseCDs and jps.buff("tiger's fury") },
		{ jps.DPSRacial,			jps.LastCast == "berserk" },
		--
		{ "skull bash(cat form)",jps.shouldKick() and jps.Interrupts },
		{ "swipe",				jps.MultiTarget },
		--
		{ nil,					gcdLocked },
		--
		{ "faerie fire (feral)", not jps.debuff("faerie fire") and jps.debuffStacks("sunder armor")~=3 },
		--
		{ "mangle(cat form)", 	mangleDuration < 3 and not jps.debuff("trauma") and not jps.debuff("hemorrhage") },
		--
		{ {"macro","/cast ravage"}, 				jps.buff("stampede") and jps.buffDuration("stampede") < 4 },
		--
		{ "ferocious bite", 		executePhase and cp == 5 and ripDuration > 0 },
		{ "ferocious bite", 		executePhase and cp > 0 and ripDuration <= 2.1 and ripDuration > 0 },
		--
		{ "rip", 				cp == 5 and ripDuration < 2 and (berserking or ripDuration+2 <= tfCD) },
		--
		{ "ferocious bite",		berserking and cp == 5 and ripDuration > 5 and srDuration > 3 },
		--
		{ "rake", 				jps.buff("tiger's fury") and rakeDuration < 9 },
		{ "rake", 				rakeDuration < 3 and (berserking or rakeDuration-0.8 <= tfCD or energy >= 71) },
		--
		{ "shred",				jps.buff("clearcasting") },
		--
		{ "savage roar",			cp > 0 and srDuration < 1 and ripDuration > 6 },
		--
		{ "ferocious bite",		(not berserking or energy < 25) and cp == 5 and ripDuration >= 14 and srDuration >= 10 },
		--
		{ {"macro","/cast ravage"}, 				jps.buff("stampede") and not clearcasting and (energy <= 100-(energyPerSec*2)) },
		--
		{ "shred", 				berserking or jps.buff("tiger's fury") },
		{ "shred",				(cp < 5 and ripDuration <= 3) or (cp == 0 and srDuration <= 2) },
		{ "shred",				tfCD <= 3 },
		{ "shred",				energy >= 100 - (energyPerSec*2) },
	}

	if jps.buff("tiger's fury") then jps.Opening = false end

	return parseSpellTable(spellTable)
end

function druid_cat_pvp(self)
	local dpsSpell = druid_cat_pve()
	if jps.buff("bear form") then dpsSpell = druid_guardian() end
	local CCd = not HasFullControl()
	local rooted = jps.debuff("frost nova","player") or jps.debuff("entangling roots","player") or jps.debuff("freeze","player")

	if CCd then RunMacroText("/use 13") end
	if rooted then return parseSpellTable({{"dash"},{"stampeding roar(cat form)"}}) end
	--bear form at low hp
	if not jps.buff("bear form") and jps.hp() < 0.5 then 
		RunMacroText("/cancelform")
		return "bear form"
	end

	return dpsSpell
end
