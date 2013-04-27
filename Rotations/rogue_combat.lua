--jpganis
-- Ty to SIMCRAFT for this rotation
lastGUID = ""
targetChanged = true


function rogue_combat(self)
    local comboPoints = GetComboPoints("player")
    local ruptureDuration = jps.debuffDuration("rupture")
    local sliceAndDiceDuration = jps.buffDuration("slice and dice")
    local energy = UnitPower("player")
    local inRaid = GetNumGroupMembers() > 5
    local targetGUID = UnitGUID("target")
    
    if targetChanged and comboPoints >= 1 then
        targetChanged = false
    end
    
    if targetGUID ~= nil and targetGUID ~= lastGUID and comboPoints == 0  then
        lastGUID = targetGUID
        targetChanged = true
    end
    
    local spellTable =  {
        -- Interrupts
        jpsext.interruptSpellTable("kick",2),
        -- Poisons
        { "deadly poison", not jps.buff("deadly poison")},
        { "leeching poison", not jps.buff("leeching poison")},
        -- Cooldowns
        --{ "redirect", targetChanged }, -- NOT GOOD...check if redirect can be cast...
        { "marked for death", comboPoints == 0 },
        { "shadow blades", sliceAndDiceDuration >= jps.buffDuration("shadow blades") },
        { "adrenaline rush", energy < 35 or jps.buff("shadow's blade") },
        { "preparation", not jps.buff("vanish") and jps.cd("vanish") > 60 },
        { "tricks of the trade", "onCD", "focus"},
        { "killing spree", energy < 35 and sliceAndDiceDuration > 4 and not jps.buff("adrenaline rush") },
        { "vanish", inRaid and not jps.buff("shadow blades") and not jps.buff("adrenaline rush") and energy < 20 and ((jps.buff("deep insight") and cp < 4)) },
        -- Rotation
        { "ambush" },
        { "slice and dice", sliceAndDiceDuration < 2 or (sliceAndDiceDuration < 15 and jps.buffStacks("bandit's guile") == 11 and comboPoints >= 4) },
        { "rupture", ruptureDuration < 4 and comboPoints == 5 },
        { "eviscerate", comboPoints == 5 },
        { "revealing strike", jps.debuffDuration("revealing strike") < 2 },
        { "sinister strike", comboPoints < 5 },
    }
    
    local aoeSpellTable = {
        -- Interrupts
        jpsext.interruptSpellTable("kick",2),
        -- Poisons
        { "deadly poison", not jps.buff("deadly poison")},
        { "leeching poison", not jps.buff("leeching poison")},
        -- Cooldowns
        { "marked for death", comboPoints == 0 },
        { "shadow blades", "onCD" },
        { "adrenaline rush", energy < 35 or jps.buff("shadow's blade") },
        { "tricks of the trade", "onCD", "focus"},
        { "killing spree", energy < 35 and not jps.buff("adrenaline rush") },
        { "sinister strike", targetChanged },
        { "crimson tempest", comboPoints > 4 },
        { "Fan of Knives", comboPoints < 5 },
    }

    if not jps.MultiTarget then
        return parseSpellTable( spellTable )
    else
        return parseSpellTable( aoeSpellTable )
    end
end


