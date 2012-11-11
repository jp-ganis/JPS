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
    local shockCD = jps.cd("earth shock")
    local chainCD = jps.cd("chain lightning")

    -- Totems
    local _, fireName, _, _, _ = GetTotemInfo(1)
    local _, earthName, _, _, _ = GetTotemInfo(2)
    local _, waterName, _, _, _ = GetTotemInfo(3)
    local _, airName, _, _, _ = GetTotemInfo(4)

    local mh, _, _, oh, _, _, _, _, _ =GetWeaponEnchantInfo()

    local haveFireTotem = fireName ~= ""
    local haveEarthTotem = earthName ~= ""
    local haveWaterTotem = waterName ~= ""
    local haveAirTotem = airName ~= ""

	-- Intelligent trinkets
	local trinket1ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket0Slot"))
	local canUseTrinket1,_ = GetItemSpell(trinket1ID)
	local _,Trinket1ready,_ = GetItemCooldown(trinket1ID)

	local trinket2ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket1Slot"))
	local canUseTrinket2,_ = GetItemSpell(trinket2ID)
	local _,Trinket2ready,_ = GetItemCooldown(trinket2ID)

    local spellTable =
    {
		-- Trinkets
		{ {"macro","/use 13"}, 		jps.UseCDs and canUseTrinket1 ~= nil and Trinket1ready == 0 },  
		{ {"macro","/use 14"}, 		jps.UseCDs and canUseTrinket2 ~= nil and Trinket2ready == 0 }, 	
		-- Cooldowns
		{ "fire elemental totem", 	jps.UseCDs },
        { "feral spirit", 			jps.UseCDs },
        -- Kicks
        { "wind shear", 			jps.shouldKick("target") },
        { "wind shear", 			jps.shouldKick("focus"), "focus" },
		-- Weapon buffs/enchants
        { "Windfury Weapon", 		not mh},
        { "Flametongue Weapon", 	not oh and mh},
        { "lightning shield", 		not jps.buff("lightning shield") },
		-- AoE
        { "magma totem", 			jps.MultiTarget and fireName ~= "Magma Totem" and fireName ~= "Fire Elemental Totem" },
        { "Fire Nova", 				jps.MultiTarget and jps.debuff("flame shock") },
		{ "chain lightning", 		jps.MultiTarget and maelstromStacks >= 3 },
		
		-- Rotation
        { "Ascendance", 			jps.UseCDs and not jps.buff("Ascendance") }, -- jps.cd("strike") >= 3
        { "searing totem", 			not jps.MultiTarget and fireName ~= "Searing Totem" and fireName ~= "Fire Elemental Totem" }, -- GetTotemTimeLeft(1) < 1
        { "Unleash Elements", 		"onCD"}, -- If talent in tier 6
        { "Elemental Blast", 		"onCD"}, -- Talent in tier 6
        { "Lightning Bolt", 		maelstromStacks >= 5 },
        { "Stormsblast", 			"onCD"},
        { "Stormstrike", 			"onCD"},
        { "flame shock", 			jps.debuffDuration("flame shock") <= 1.5 or jps.buff("unleash flame") },
        { "lava lash", 				"onCD"},
        { "Unleash Elements", 		"onCD"}, 
        { "lightning bolt", 		maelstromStacks >= 3 and jps.buff("Ascendance") },
        { "Ancestral Swiftness", 	maelstromStacks < 2 }, -- Talent tier 4
        { "Lightning Bolt", 		jps.buff("Ancestral Swiftness") },
        { "flame shock", 			jps.buff("unleash flame") and jps.debuffDuration("Flame Shock") <= 3 },
        { "earth shock", 			"onCD" },
        { "spiritwalker's grace", 	jps.Moving },
        { "lightning bolt", 		maelstromStacks > 1 and not jps.buff("Ascendance") },
    }

    return parseSpellTable( spellTable )
end