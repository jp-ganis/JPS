-- jpganis
-- simcrafty
--TODO: add tab-dotting everything.
-- thanks to balance power tracker for making this SO much better
--function druid_balance(self)
--	if BalancePowerTracker_SharedInfo == nil then return druid_balance_fail()
--	else return druid_balance_bpt() end
--end

--bpt
function druid_balance(self)
	-- bpt virtual trackers
	local tEnergy = UnitPower("player",SPELL_POWER_ECLIPSE)
	local vDirection = GetEclipseDirection()

	if vDirection == "none" then vDirection = "sun" end

	-- Insect Swarm and Moonfire /fastest/ tick times.
	local isTick = 1.3
	local mfTick = 1.3

	-- Eclipse Buffs
	local sEclipse = jps.buff("eclipse (solar)")
	local lEclipse = jps.buff("eclipse (lunar)")

	-- Dot Durations
	local mfDuration = jps.debuffDuration("moonfire") - jps.castTimeLeft()
	local sfDuration = jps.debuffDuration("sunfire") - jps.castTimeLeft()
	
	-- Focus dots
	local focusDotting, focusIS, focusMF, focusSF
	if UnitExists("focus") then focusDotting = true
	else focusDotting = false end

	if focusDotting then
		focusMF = jps.debuffDuration("moonfire","focus")
		focusSF = jps.debuffDuration("sunfire","focus")
	end

	local spellTable =
	{
		{ "starfall" },
		{ "force of nature" },
		{ "moonfire", jps.Moving and sfDuration == 0 },
		{ "sunfire" , jps.Moving and mfDuration == 0 },
		{ "moonfire", jps.Moving and lEclipse },
		{ "sunfire", jps.Moving },
		{ "starsurge", jps.Moving and jps.buff("shooting stars") },
		{ "incarnation", sEclipse or lEclipse },
		{ "celestial alignment", ((vDirection=="moon" and tEnergy <= 0) or (vDirection=="sun" and tEnergy >= 0)) and (not select(5,GetTalentInfo(11,"player")) or jps.buff("Incarnation: Chosen of Elune")) },
		{ "wrath", tEnergy <= -70 and vDirection == "moon" },
		{ "starfire", tEnergy >= 60 and vDirection == "sun" },
		{ "moonfire", mfDuration == 0 and not jps.buff("celestial alignment") },
		{ "sunfire", sfDuration == 0 and not jps.buff("celestial alignment") },
		{ "starsurge" },
		{ "starfire", jps.buff("celestial alignment") },
		{ "starfire", vDirection == "sun" },
		{ "wrath", vDirection == "moon" },
	}

	spell = parseSpellTable( spellTable )


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

	local mfDuration = jps.debuffDuration("moonfire")
	local sfDuration = jps.debuffDuration("sunfire")
	
	local focusDotting, focusIS, focusMF, focusSF
	focusDotting = UnitExists("focus")

	if focusDotting then
		focusMF = jps.debuffDuration("moonfire","focus")
		focusSF = jps.debuffDuration("sunfire","focus")
	end

	local spellTable =
	{
		{ "moonfire", jps.Opening },
		-- Moonfire
		{ "moonfire", sEclipse and sfDuration < mfTick and mfDuration == 0 },
		{ "moonfire", sEclipse and sfDuration < 7 and power < 15 },
		{ "moonfire", lEclipse and mfDuration < mfTick and sfDuration == 0 },
		{ "moonfire", lEclipse and mfDuration < 10 and power >= -20 },
		--
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


	if spell == "force of nature" or spell == "wild mushroom" then
		jps.groundClick()
	--	Petattack("target")
	end

	if spell == "starfall" and jps.glovesCooldown() == 0 then
		RunMacroText("/use 10")
	end
	
	return spell
end
