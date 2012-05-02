-- jpganis
-- simcrafty
--TODO: add tab-dotting everything.
-- thanks to balance power tracker for making this SO much better
function druid_balance(self)
	if BalancePowerTracker_SharedInfo == nil then return druid_balance_fail()
	else return druid_balance_bpt() end
end

--bpt
function druid_balance_bpt(self)
	-- bpt virtual trackers
	local bptTable = BalancePowerTracker_SharedInfo
	local vEnergy = bptTable.virtualEnergy
	local vDirection = bptTable.virtualDirection
	local vEclipse = bptTable.virtualEclipse -- Returns S for Solar, L for Lunar, false for Neither

	if vDirection == "none" then vDirection = "sun" end

	-- Insect Swarm and Moonfire /fastest/ tick times.
	local isTick = 1.3
	local mfTick = 1.3

	-- Eclipse Buffs
	local sEclipse = jps.buff("eclipse (solar)")
	local lEclipse = jps.buff("eclipse (lunar)")

	-- Mushrooms
	local m1, _, _, _, _ = GetTotemInfo(1)
	local m2, _, _, _, _ = GetTotemInfo(2)
	local m3, _, _, _, _ = GetTotemInfo(3)
	
	-- Dot Durations
	local isDuration = jps.debuffDuration("insect swarm") - jps.castTimeLeft()
	local mfDuration = jps.debuffDuration("moonfire") - jps.castTimeLeft()
	local sfDuration = jps.debuffDuration("sunfire") - jps.castTimeLeft()
	
	-- Focus dots
	local focusDotting, focusIS, focusMF, focusSF
	if UnitExists("focus") then focusDotting = true
	else focusDotting = false end

	if focusDotting then
		focusIS = jps.debuffDuration("insect swarm","focus")
		focusMF = jps.debuffDuration("moonfire","focus")
		focusSF = jps.debuffDuration("sunfire","focus")
	end

	local spellTable =
	{
		-- Opening
		--{ "wild mushroom: detonate", m1 and m2 and m3 },
		{ "moonfire", jps.Opening and jps.debuff("insect swarm") }, -- try and fix double IS bug
		{ "insect swarm", jps.Opening and not jps.debuff("insect swarm") },
		-- Dodge Eclipse lag by casting one spell before dots/shooting star proc
		{ "starsurge", vEclipse ~= false and not jps.buff("shooting stars") },
		{ "wrath", vEclipse == "S" },
		{ "starfire", vEclipse == "L" },
		-- Insect Swarm
		{ "insect swarm", sEclipse and isDuration < isTick },
		{ "insect swarm", sEclipse and vEnergy < 15 and isDuration < 10 },
		{ "insect swarm", lEclipse and isDuration < isTick },
		-- Moonfire
		{ "moonfire", sEclipse and sfDuration < mfTick and mfDuration < mfTick },
		{ "moonfire", sEclipse and sfDuration < 10 and vEnergy < 15 },
		{ "moonfire", lEclipse and mfDuration < mfTick and sfDuration < mfTick },
		{ "moonfire", lEclipse and mfDuration < 10 and vEnergy >= -20 },
		-- Moving
		--{ "typhoon", jps.Moving },
		{ "starfall", lEclipse },
		{ "starsurge", jps.Moving and jps.buff("shooting stars") },
		{ "insect swarm", jps.Moving and isDuration < isTick },
		{ "moonfire", jps.Moving },
		-- Starsurge
		{ "starsurge", vDirection == "moon" and vEnergy > -85 },
		{ "starsurge", vDirection == "sun" and vEnergy < 85 },
		-- Lolboomkincds
		{ "innervate", jps.mana() < 0.5 },
		{ "force of nature", jps.UseCDs },
		-- Baseline
		{ "wrath", vDirection == "moon" },
		{ "starfire", vDirection == "sun" },
	}

	spell = parseSpellTable( spellTable )

	if isDuration > 0 and (mfDuration > 0 or sfDuration > 0) then jps.Opening = false end

	if spell == "force of nature" or spell == "wild mushroom" then
		jps.groundClick()
	--	Petattack("target")
	end

	return spell
end

function druid_balance_fail(self)
	local power = UnitPower("player",SPELL_POWER_ECLIPSE)
	local eclipse = GetEclipseDirection()
	if eclipse == "none" then eclipse = "sun" end

	local isTick = 1.2
	local mfTick = 1.2

	local sEclipse = jps.buff("eclipse (solar)")
	local lEclipse = jps.buff("eclipse (lunar)")

	local m1, _, _, _, _ = GetTotemInfo(1)
	local m2, _, _, _, _ = GetTotemInfo(2)
	local m3, _, _, _, _ = GetTotemInfo(3)
	
	local isDuration = jps.debuffDuration("insect swarm")
	local mfDuration = jps.debuffDuration("moonfire")
	local sfDuration = jps.debuffDuration("sunfire")
	
	local focusDotting, focusIS, focusMF, focusSF
	focusDotting = UnitExists("focus")

	if focusDotting then
		focusIS = jps.debuffDuration("insect swarm","focus")
		focusMF = jps.debuffDuration("moonfire","focus")
		focusSF = jps.debuffDuration("sunfire","focus")
	end

	local spellTable =
	{
		{ "wild mushroom: detonate", m1 and m2 and m3 },
		{ "insect swarm", jps.Opening and not jps.debuff("insect swarm") },
		{ "moonfire", jps.Opening },
		-- Insect Swarm
		{ "insect swarm", sEclipse and isDuration < isTick },
		{ "insect swarm", sEclipse and power < 15 and isDuration < 10 },
		{ "inesct swarm", lEclipse and isDuration < isTick },
		-- Moonfire
		{ "moonfire", sEclipse and sfDuration < mfTick and mfDuration == 0 },
		{ "moonfire", sEclipse and sfDuration < 7 and power < 15 },
		{ "moonfire", lEclipse and mfDuration < mfTick and sfDuration == 0 },
		{ "moonfire", lEclipse and mfDuration < 10 and power >= -20 },
		--
		{ "wild mushroom: detonate", (m1 or m2 or m3) and sEclipse },
		{ "typhoon", jps.Moving },
		{ "starfall", lEclipse },
		{ "moonfire", sEclipse and ((sfDuration < mfTick and mfDuration == 0) or (power < 15 and sfDuration < 7)) and jps.LastCast ~= "moonfire" },
		{ "moonfire", lEclipse and ((mfDuration < mfTick and sfDuration == 0) or (power > -20 and mfDuration < 7)) and jps.LastCast ~= "moonfire" },
		--moving
		{ "starsurge", jps.Moving and jps.buff("shooting stars") },
		{ "moonfire", jps.Moving },
		{ "sunfire", jps.Moving },
		--
		{ "starsurge", eclipse == "moon" and power > -80 },
		{ "starsurge", lEclipse and jps.buff("shooting stars") },
		{ "innervate", jps.mana() < 0.5 },
		{ "force of nature", jps.UseCDs },
		{ "starfire", eclipse == "sun" and power < 75 },
		{ "starfire", jps.LastCast == "wrath" and eclipse == "moon" and power < -84 },
		{ "wrath", eclipse == "moon" and power >= -84 },
		{ "wrath", jps.LastCast == "starfire" and eclipse == "sun" and power >= 75 },
		{ "starfire", eclipse == "sun" },
		{ "wrath", eclipse == "moon" },
		{ "starfire" },
	}

	spell = parseSpellTable( spellTable )

	if isDuration > 0 and (mfDuration > 0 or sfDuration > 0) then jps.Opening = false end

	if spell == "force of nature" or spell == "wild mushroom" then
		jps.groundClick()
	--	Petattack("target")
	end
	
	return spell
end