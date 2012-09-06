function shaman_enhancement(self)
	-- vipersnake
    --jpganis +simcraft
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

    local spellTable =
    {
        { "fire elemental totem", jps.UseCDs },
        { "wind shear", jps.shouldKick("target") },
        { "wind shear", jps.shouldKick("focus"), "focus" },
        { "Windfury Weapon",         not mh},
        { "Flametongue Weapon",         not oh and mh},
        { "searing totem", GetTotemTimeLeft(1) < 2 },
        { "lightning shield", not jps.buff("lightning shield") },
        { "Stormstrike", "onCD"},
        { "lava lash", "onCD"},
        { "unleash elements", "onCD"},
        { "flame shock", not jps.myDebuff("flame shock") or jps.buff("unleash flame") },
        { "lightning bolt", maelstromStacks > 4 and (not jps.MultiTarget or chainCD > 0)},
        { "chain lightning", maelstromStacks > 4 and jps.MultiTarget and chainCD == 0},
        { "earth shock" },
        { "feral spirit" },
        --{ "earth elemental totem" }, 
        { "spiritwalker's grace", jps.Moving },
        { "lightning bolt", maelstromStacks > 4 and "onCD"},
    }

    return parseSpellTable( spellTable )
end