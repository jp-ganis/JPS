function shaman_elemental(self)
	-- Updated for MoP
	-- Tier 1: Astral Shift
	-- Tier 2: Windwalk Totem
	-- Tier 3: Call of the Elements
	-- Tier 4: Echo of the Elements
	-- Tier 5: Healing Tide Totem
	-- Major Glyphs: Flame Shock (required), Spiritwalker's Grace (recommended),
	--    Telluric Currents (recommended)
	-- Minor Glyphs: Thunderstorm (required)
	
	local lsStacks = jps.buffStacks("lightning shield")
	local focus = "focus"
	local me = "player"
	local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()
	local engineering ="/use 10"
	local r = RunMacroText
	
	-- Totems
	local _, fireTotem, _, _, _ = GetTotemInfo(1)
	local _, earthTotem, _, _, _ = GetTotemInfo(2)
	local _, waterName, _, _, _ = GetTotemInfo(3)
	local _, airTotem, _, _, _ = GetTotemInfo(4)
	
	local fireTotemActive = fireTotem ~= ""
	local earthTotemActive = earthTotem ~= ""
	local waterTotemActive = waterName ~= ""
	local airTotemActive = airTotem ~= ""
	
	-- Fear
	local feared = jps.debuff("Fear") or jps.debuff("Intimidating Shout") or jps.debuff("Howl of Terror") or jps.debuff("Psychic Scream")
	
	local spellTable = {
		{ "Lightning Shield", not jps.buff("Lightning Shield") },
		{ "Flametongue Weapon", not mh },
		{ "Astral Shift", jps.hp() < .35 },
		{ "Healing Tide Totem", jps.hp() < .5 },
		{ "Healing Surge", jps.hp() < .7 },
		{ "Fire Elemental Totem", jps.UseCDs },
		{ "Searing Totem", not fireTotemActive },
		{ "Earth Elemental Totem", jps.UseCDs and jps.bloodlusting() },
		{ "Stormlash Totem", jps.UseCDs and jps.bloodlusting() },
		-- Trinket CDs. 
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		-- Synapse Springs CD. (engineering gloves) 
		{ jps.useSynapseSprings(), jps.UseCDs },
		-- Lifeblood CD. (herbalists) 
		{ "Lifeblood", jps.UseCDs },
		-- DPS Racial CD. 
		{ jps.DPSRacial, jps.UseCDs },
		{ "Wind Shear", jps.shouldKick() },
		{ "Unleash Elements", jps.debuffDuration("Flame Shock") < 2 },
		{ "Flame Shock", jps.buff("Unleash Flame") },
		{ "Lava Burst", jps.debuff("Flame Shock") },
		{ "Earth Shock", lsStacks > 5 and jps.debuffDuration("Flame Shock") > 5 },
		{ "Spiritwalker's Grace", jps.Moving },
		{ "Chain Lightning", jps.MultiTarget },
		{ "Thunderstorm", jps.mana() < .6 and jps.UseCDs },
		{ "Lightning Bolt" },
	}
	
	local spell,target = parseSpellTable(spellTable)
	return spell,target
end
