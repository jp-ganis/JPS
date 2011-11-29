function warlock_affliction(self)
	local mana = UnitMana("player")/UnitManaMax("player")
	local shards = UnitPower("player",7)
	local spell = nil

	local bod_duration = jps.debuffDuration("bane of doom")
	local cpn_duration = jps.debuffDuration("corruption")
	local ua_duration = jps.debuffDuration("unstable affliction")

	-- focus dotting
	local focus_dotting, focus_corruption, focus_ua, focus_bane
	if UnitExists("focus") then
		focus_dotting = true
		focus_corruption = jps.debuffDuration("corruption","focus")
		focus_ua = jps.debuffDuration("unstable affliction","focus")
		focus_bane = jps.debuffDuration("bane of agony","focus")
	end

	local spellTable =
	{
		{ "demon soul" },
		{ "corruption", cpn_duration < 3 },
		{ "unstable affliction", ua_duration < 4.5 },
		{ "bane of doom", bod_duration == 0 },
		{ "haunt" },
		{ "summon doomguard" },
		{ "drain soul", jps.hp("target") <= 0.25 },
		{ "shadowflame", IsShiftKeyDown() },
		{ "life tap", jps.mana() <= 0.35 },
		{ "soulburn", not jps.buff("demon soul: felhunter") },
		{ "soulfire", jps.buff("soulburn") },
		{ "shadow bolt" },
		{ "life tap", jps.Moving and jps.mana() < 0.8 and jps.mana() < jps.hp("target") },
		{ "fel flame", jps.Moving },
		{ "life tap" },
	}

	return parseSpellTable(spellTable)
end
