function shaman_enhancement(self)
	--simcraft and more
	-- Talents:
	-- Tier 1: Astral Shift
	-- Tier 2: Windwalk Totem
	-- Tier 3: Call of the Elements
	-- Tier 4: Echo of the Elements
	-- Tier 5: Ancestral Guidance
	-- Tier 6: Unleashed Fury
	-- Major Glyphs: Glyph of Chain Lightning, Glyph of Flame Shock
	
	-- Usage info:
	-- Use CDs for trinkets, Feral Spirit and Fire Elemental Totem
	-- Use AoE for Magma Totem, Fire Nova and Chain Lightning on Maelstrom Stacks
	-- Searing and Magma Totem will not override Fire Elemental Totem
	
	-- Todo:
	-- Perhaps implement more survivability for soloing
	
	local maelstromStacks = jps.buffStacks("maelstrom weapon")
	local shockCD = jps.cooldown("earth shock")
	local chainCD = jps.cooldown("chain lightning")
	
	-- Weapon Enchants
	local mh, _, _, oh, _, _, _, _, _ = GetWeaponEnchantInfo()
	
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
		-- Weapons. 
		{ "Windfury Weapon", not mh },
		{ "Flametongue Weapon", mh and not oh },
		-- Oh shit button 
		{ "Astral Shift", jps.hp() < .35 },
		-- Healing Tide 
		{ "Healing Tide Totem", jps.hp() < .5 },
		-- Healing Surge 
		{ "Healing Surge", jps.hp() < .7 },
		-- Wolves 
		{ "Feral Spirit", jps.UseCDs },
		-- Big guy 
		{ "Fire Elemental Totem", jps.UseCDs },
		-- AoE 
		{ "Magma Totem", jps.MultiTarget and fireTotem ~= "Magma Totem" and fireTotem ~= "Fire Elemental Totem" },
		-- Searing 
		{ "Searing Totem", not fireTotemActive },
		-- Trinket CDs. 
		{ jps.useTrinket(0), jps.UseCDs },
		{ jps.useTrinket(1), jps.UseCDs },
		-- Synapse Springs CD. (engineering gloves) 
		{ jps.useSynapseSprings(), jps.UseCDs },
		-- Lifeblood CD. (herbalists) 
		{ "Lifeblood", jps.UseCDs },
		-- DPS Racial CD. 
		{ jps.DPSRacial, jps.UseCDs },
		-- Interrupts 
		{ "Wind Shear", jps.shouldKick() },
		-- AoE 
		{ "Fire Nova", jps.MultiTarget and jps.debuff("Flame Shock") },
		-- AoE 
		{ "Chain Lightning", jps.MultiTarget and maelstromStacks >= 3 },
		-- Ascendance 
		{ "Ascendance", jps.UseCDs and not jps.buff("Ascendance") },
		-- Unleash Elements 
		{ "Unleash Elements" },
		-- Elemental Blast 
		{ "Elemental Blast" },
		-- Lightning Bolt 
		{ "Lightning Bolt", maelstromStacks >= 5 },
		-- Stormsblast 
		{ "Stormsblast" },
		-- Stormstrike 
		{ "Stormstrike" },
		-- Flame Shock 
		{ "Flame Shock", jps.debuffDuration("Flame Shock") <= 1.5 or jps.buff("Unleash Flame") },
		-- Lava Lash 
		{ "Lava Lash" },
		-- Unleash Elements 
		{ "Unleash Elements" },
		-- Lightning Bolt 
		{ "Lightning Bolt", maelstromStacks >= 3 and jps.buff("Ascendance") },
		-- Ancestral Swiftness 
		{ "Ancestral Swiftness", maelstromStacks < 2 },
		-- Lightning Bolt 
		{ "Lightning Bolt", jps.buff("Ancestral Swiftness") },
		-- Earth Shock 
		{ "Earth Shock" },
		-- Spiritwalker's Grace 
		{ "Spiritwalker's Grace", jps.Moving },
		-- Lightning Bolt 
		{ "Lightning Bolt", maelstromStacks >= 4 and not jps.buff("Ascendance") and jps.mana() > .5 },
	}

	local spell,target = parseSpellTable(spellTable)
	return spell,target
end
