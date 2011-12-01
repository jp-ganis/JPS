-- jpganis
-- simcrafty
function druid_balance(self)
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
		{ "force of nature",	jps.UseCDs and jps.buff("eclipse (solar)") },
		{ "solar beam", 		jps.shouldKick() },
		{ "solar beam", 		jps.shouldKick("focus"), "focus" },
		{ "innervate", 			jps.mana() < 0.5, "player" },
		--{ {"item","Fiery Quintessence"},  "onCD" },
		{ "starsurge", 			"onCD" },
		{ "starfire", 			power <= -87 and (jps.LastCast == "wrath" or jps.LastCast == "starsurge") and not jps.buff("eclipse (lunar)") },
		{ "starfall", 			"onCD" },
		{ "wrath", 				power >= 80 and (jps.LastCast == "starfire" or jps.LastCast == "starsurge") and not jps.buff("eclipse (solar)") },
		{ "wrath", 				power <= -87 and not jps.buff("eclipse (lunar)") },
		{ "starfire", 			power >= 80 and not jps.buff("eclipse (solar)") },
		{ "insect swarm", 		isDuration < 1 },
		{ "moonfire", 			mfDuration < 1 and sfDuration < 1 },
		{ "moonfire", 			mfDuration < 3 and sfDuration < 3  and jps.buff("eclipse (lunar)") },
		{ "insect swarm", 		isDuration < 3 and jps.buff("eclipse (solar)") },
		{ "insect swarm", 		focusDotting and focusIS < 1, "focus" },
		{ "insect swarm", 		focusDotting and focusIS < 3 and jps.buff("eclipse (solar)"), "focus" },
		{ "moonfire", 			focusDotting and focusMF < 1 and focusSF < 1, "focus" },
		{ "moonfire", 			focusDotting and focusMF < 3 and focusSF < 3  and jps.buff("eclipse (lunar)"), "focus" },
		{ "moonfire", 			jps.Moving },
		{ "wrath", 				eclipse == "moon" },
		{ "starfire", 			eclipse == "sun" },
	}

	spell = parseSpellTable( spellTable )

	if spell == "force of nature" then
		jps.groundClick()
	--	Petattack("target")
	end
	
	return spell
end
