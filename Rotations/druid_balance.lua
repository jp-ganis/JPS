function new_druid_balance(self)
	local power = UnitPower("player",SPELL_POWER_ECLIPSE)
	local eclipse = GetEclipseDirection()
	if eclipse == "none" then eclipse = "sun" end
	
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
		{ "force of nature", jps.UseCDs and jps.buff("eclipse (solar)") },
		{ "solar beam", jps.shouldKick() },
		{ "solar beam", jps.shouldKick("focus"), "focus" },
		{ "starsurge", "onCD" },
		{ "innervate", jps.mana() < 0.5, "player" },
		{ "starfire", power <= -87 and (jps.LastCast == "wrath" or jps.LastCast == "starsurge") and not jps.buff("eclipse (lunar)") },
		{ "starfall", "onCD" },
		{ "wrath", power >= 80 and (jps.LastCast == "starfire" or jps.LastCast == "starsurge") and not jps.buff("eclipse (solar)") },
		{ "wrath", power <= -87 and not jps.buff("eclipse (lunar)") },
		{ "starfire", power >= 80 and not jps.buff("eclipse (solar)") },
		{ "insect swarm", isDuration < 1.5 },
		{ "moonfire", mfDuration < 1.5 and sfDuration < 1.5 },
		{ "insect swarm", focusDotting and focusIS < 1.5, "focus" },
		{ "moonfire", focusDotting and focusMF < 1.5 and focusSF < 1.5, "focus" },
		{ "moonfire", jps.Moving },
		{ "wrath", eclipse == "moon" },
		{ "starfire", eclipse == "sun" },
	}

	spell = parseSpellTable( spellTable )

	if spell == "force of nature" then
		jps.groundClick()
		Petattack("target")
	end

	return spell
end
