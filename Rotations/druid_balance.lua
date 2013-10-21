--[[[
@rotation Default
@class DRUID
@spec BALANCE
@author jpganis
@description 
SimCraft[br]
[br]
TODO: Add tab-dotting everything
]]--
jps.registerRotation("DRUID","BALANCE", function()
	
	local spell = nil
	local target = nil
	
	-- bpt virtual trackers
	local Energy = jps.eclipsePower()
	local Direction = GetEclipseDirection()
	
	if Direction == "none" then Direction = "sun" end
	
	-- Eclipse Buffs
	local sEclipse = jps.buff("eclipse (solar)")
	local lEclipse = jps.buff("eclipse (lunar)")
	
	-- Dot Durations
	local mfDuration = jps.debuffDuration("moonfire") - jps.CastTimeLeft()
	local sfDuration = jps.debuffDuration("sunfire") - jps.CastTimeLeft()
	local datEclipse = sEclipse or lEclipse

	
	local spellTable =
	{
		-- rebirth Ctrl-key + mouseover
		{ "rebirth", IsControlKeyDown() ~= nil and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("rebirth", "mouseover"), "mouseover" },
		-- Buffs
		{ "mark of the wild", not jps.buff("mark of the wild") , "player" },
		-- Rotation
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

	spell,target = parseSpellTable(spellTable)
	return spell,target
end, "Default")
