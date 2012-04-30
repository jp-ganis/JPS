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
	local vEclipse = bptTable.virtualEclipse

	if vDirection == "none" then vDirection = "sun" end

	-- Insect Swarm and Moonfire /fastest/ tick times.
	local isTick = 1.3
	local mfTick = 1.3

	-- Eclipse Buffs
	local sEclipse = jps.buff("eclipse (solar)") or vEclipse == "S"
	local lEclipse = jps.buff("eclipse (lunar)") or vEclipse == "L"

	-- Mushrooms
	local m1, _, _, _, _ = GetTotemInfo(1)
	local m2, _, _, _, _ = GetTotemInfo(2)
	local m3, _, _, _, _ = GetTotemInfo(3)
	
	local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
	local sunfireMacro = "/cast sunfire"
	local sunfireKill = {"macro", sunfireMacro}
	-- Dot Durations
	local isDuration = jps.debuffDuration("insect swarm") - jps.castTimeLeft()
	local mfDuration = jps.debuffDuration("moonfire") - jps.castTimeLeft()
	local sfDuration = jps.debuffDuration("sunfire") - jps.castTimeLeft()
	
	local focusDotting = UnitExists("focus")
	local focusIS = jps.debuffDuration("insect swarm","focus")
	local focusMF = jps.debuffDuration("moonfire","focus")
	local focusSF = jps.debuffDuration("sunfire","focus")

	local spellTable =
	{
		{"wild mushroom: detonate", 	m3 },
		{"wild mushroom",		IsShiftKeyDown() ~= nil and not m3 and not (jps.LastCast == "wild mushroom" and jps.ThisCast == "wild mushroom" and jps.NextCast == "wild mushroom") },
		{"insect swarm",		(isDuration < 2.6 or (isDuration < 10 and sEclipse and vEnergy < 15)) and (sEclipse or lEclipse) },
		{"wild mushroom: detonate", 	(m1 or m2 or m3) and currentSpeed == 0 and not jps.MultiTarget },
		{"typhoon",			currentSpeed > 0 },
		{"starfall",			vEnergy < -80 or jps.MultiTarget and currentSpeed == 0 },
		{sunfireKill,			sEclipse and ((sfDuration < 2.6 and not jps.myDebuff("moon fire")) or (vEnergy < 15 and sfDuration < 10 and sfDuration > 0)) },
		{"moonfire",			lEclipse and ((mfDuration < 2.6 and not jps.myDebuff("sunfire")) or (vEnergy > -20 and mfDuration < 10 and mfDuration > 0)) },
		{{"macro","/cast [@focus] moonfire"}, 	lEclipse and focusDotting ~= nil and ((focusMF < 2.6 and not jps.myDebuff("sunfire","focus")) or (vEnergy > -20 and focusMF < 10 and focusMF > 0)) },
		{{"macro","/cast [@focus] sunfire"},	sEclipse and focusDotting ~= nil and ((focusSF < 2.6 and not jps.myDebuff("moon fire","focus")) or (vEnergy < 15 and focusSF < 10 and focusSF > 0)) },
		{{"macro","/cast [@focus] insect swarm"}, focusDotting ~= nil and (focusIS < 2.6 or (focusIS < 10 and sEclipse and vEnergy < 15)) and (sEclipse or lEclipse) },
		{"starsurge",			(currentSpeed == 0 and (sEclipse or lEclipse)) or (jps.buff("shooting stars") and (vEnergy > -50 or vEnergy < 50)) },
		{"innervate", 			jps.mana() < 0.5 },	
		{"force of nature",		jps.UseCDs },
		{{"macro","/use 13"}, 		jps.itemCooldown("58183") == 0 and jps.UseCDs },
		{{"macro","/use 14"},		jps.itemCooldown("72448") == 0 and jps.UseCDs },
		{"lifeblood", 			jps.UseCDs },
		{"starfire",			currentSpeed == 0 and vDirection == "sun" and vEnergy <= 80 },
		{"starfire",			currentSpeed == 0 and jps.LastCast == "wrath" and vDirection == "moon" and vEnergy < -87 },
		{"wrath",			currentSpeed == 0 and vDirection == "moon" and vEnergy >= -87 },
		{"wrath",			currentSpeed == 0 and jps.LastCast == "starfire" and vDirection == "sun" and vEnergy >= 80 },
		{"starfire",			currentSpeed == 0 and vDirection == "sun" },
		{"wrath",			currentSpeed == 0 and vDirection == "moon" },
		{"starfire",			currentSpeed == 0 and "onCD" },
		{"wild mushroom",		currentSpeed > 0 and not m3 },
		{"starsurge",			currentSpeed > 0 and jps.buff("shooting stars") },
		{"moonfire",			currentSpeed > 0 },
		{sunfireKill,			currentSpeed > 0 },
		
	}

	spell = parseSpellTable( spellTable )

	if spell == "force of nature" or spell == "wild mushroom" then jps.groundClick()
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
