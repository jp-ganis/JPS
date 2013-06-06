-- jpganis
-- simcrafty
--TODO: add tab-dotting everything.

function druid_balance(self)
	-- Eclipse Stuff
	local Energy = UnitPower("player",SPELL_POWER_ECLIPSE)
	local Direction = GetEclipseDirection()
	if Direction == "none" then Direction = "sun" end
	local sEclipse = jps.buff("eclipse (solar)")
	local lEclipse = jps.buff("eclipse (lunar)")
	
	-- bpt override
	energy, direction, virtual_energy, virtual_direction, virtual_eclipse = LibBalancePowerTracker:GetEclipseEnergyInfo()
	if (energy ~= nil) then
		Energy = virtual_energy
		Direction = virtual_direction
		lEclipse = virtual_eclipse == "L"
		sEclipse = virtual_eclipse == "S"
	end

	local datEclipse = sEclipse or lEclipse
	
	-- Insect Swarm and Moonfire /fastest/ tick times.
	local isTick = 1.5
	local mfTick = 1.5

	-- Dot Durations
	local mfDuration = jps.debuffDuration("moonfire") - jps.castTimeLeft()
	local sfDuration = jps.debuffDuration("sunfire") - jps.castTimeLeft()

	local spellTable =
	{
		{ "starfall" },
		{ "force of nature", jps.buff("nature's grace") or jps.Moving },
		{ "moonfire", jps.Moving and lEclipse },
		{ "sunfire", jps.Moving },
		{ "starsurge", jps.Moving and jps.buff("shooting stars") },
		{ "incarnation", sEclipse or lEclipse },
		{ "celestial alignment", jps.UseCDs and ((Direction=="moon" and Energy <= 0) or (Direction=="sun" and Energy >= 0)) and (not select(5,GetTalentInfo(11,"player")) or jps.buff("Incarnation: Chosen of Elune")) },
		{ "wrath", Energy <= -70 and Direction == "moon" },
		{ "starfire", Energy >= 60 and Direction == "sun" },
		{ "moonfire", mfDuration <= 1.5 },
		{ "sunfire", sfDuration <= 1.5 },
		{ "starsurge", (Energy < 80 and Energy > -85) or datEclipse},
		{ "starfire", jps.buff("celestial alignment") },
		{ "starfire", Direction == "sun" },
		{ "wrath", Direction == "moon" },
		{ "moonfire", jps.Moving and sfDuration == 0 },
		{ "sunfire" , jps.Moving and mfDuration == 0 },
	}

	spell = parseSpellTable( spellTable )

	if spell == "wild mushroom" then
		jps.groundClick()
	end

	return spell
end
