function new_dk_blood(self)
    -- Talents:
    -- Tier 1: Roiling Blood
    -- Tier 2: Anti-Magic Zone
    -- Tier 3: Death's Advance
    -- Tier 4: Death Pact
    -- Tier 5: Runic Corruption
    -- Tier 6: Remorseless Winter
    -- Major Glyphs: Icebound Fortitude, Anti-Magic Shell
    
    -- Usage info:
    -- Shift to DnD at mouse
    -- Cooldowns: trinkets, raise dead, dancing rune weapon

    -- Todo:
    -- Left Ctrl to use Army of the Dead

    -- Change: add UnitExists("pet") == nil for raise dead. In some rare situations the cooldown gets reset and it can try to cast it again (last boss in End of Time)

    local targetThreatStatus = UnitThreatSituation("player","target")
    if not targetThreatStatus then targetThreatStatus = 0 end

    local rp = UnitPower("player") 

    local ffDuration = jps.debuffDuration("frost fever")
    local bpDuration = jps.debuffDuration("blood plague")
    local bcStacks = jps.buffStacks("blood charge") --Blood Stacks
    
    local haveGhoul, _, _, _, _ = GetTotemInfo(1) --Information about Ghoul pet

    local dr1 = select(3,GetRuneCooldown(1))
    local dr2 = select(3,GetRuneCooldown(2))
    local ur1 = select(3,GetRuneCooldown(3))
    local ur2 = select(3,GetRuneCooldown(4))
    local fr1 = select(3,GetRuneCooldown(5))
    local fr2 = select(3,GetRuneCooldown(6))
    local one_dr = dr1 or dr2
    local two_dr = dr1 and dr2
    local one_fr = fr1 or fr2
    local two_fr = fr1 and fr2
    local one_ur = ur1 or ur2
    local two_ur = ur1 and ur2

    -- Intelligent trinkets
    local trinket1ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket0Slot"))
    local canUseTrinket1,_ = GetItemSpell(trinket1ID)
    local _,Trinket1ready,_ = GetItemCooldown(trinket1ID)

    local trinket2ID = GetInventoryItemID("player", GetInventorySlotInfo("Trinket1Slot"))
    local canUseTrinket2,_ = GetItemSpell(trinket2ID)
    local _,Trinket2ready,_ = GetItemCooldown(trinket2ID)
    
    local possibleSpells = {
        -- Make sure we're in Blood Presence.
        { "Blood Presence", not jps.buff("Blood Presence") },
    
        -- Death and Decay when shift is down.
        { "Death and Decay", IsShiftKeyDown() ~= nil  and GetCurrentKeyBoardFocus() == nil },
    
        -- Army of the Dead when control is down.
        { "Army of the Dead", IsLeftControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },

        -- Interrupts
        jpsext.interruptSpellTable("Strangulate",2),
        jpsext.interruptSpellTable("Asphyxiate",2),
        jpsext.interruptSpellTable("Mind Freeze",2),

        -- Defensive cooldowns
        jpsext.healthstone(.5),
        { "Raise Dead", jps.UseCDs and UnitExists("pet") == nil },
        { "Dancing Rune Weapon", jps.UseCDs },
        { "Death Pact", jps.UseCDs and jps.hp() < .5 and haveGhoul },
        { "Icebound Fortitude", jps.UseCDs and jps.hp() < .3 },
        { "Vampiric Blood", jps.UseCDs and jps.hp() < .5 },
        { "Rune Tap", jps.UseCDs and jps.hp() < .8 },
        { "Death Siphon",jps.UseCDs and jps.hp() < .8 },
        { "Bone Shield",jps.UseCDs and not jps.buff("Bone Shield") },
        
        { jps.useSlot(13), jps.UseCDs },
        { jps.useSlot(14), jps.UseCDs },
        { jps.useSynapseSprings(), jps.UseCDs },
        { "Lifeblood", jps.UseCDs },
    
        -- Single target
        { "Outbreak", ffDuration <= 2  or bpDuration <= 2 },
        { "Blood Boil", jps.buff("Crimson Scourge") or jps.MultiTarget },
        { "Soul Reaper", jps.hp("target") <= .35 },
        { "Plague Strike", not jps.debuff("Blood Plague") },
        { "Icy Touch",  not jps.debuff("Frost Fever") },
        { "Death Strike" },
        { "Heart Strike", jps.debuff("Blood Plague") and jps.debuff("Frost Fever") },
        { "Rune Strike", rp >= 40 },
        { "Horn of Winter" },
        { "Empower Rune Weapon", not two_dr and not two_fr and not two_ur },
    }

    spell = parseSpellTable(possibleSpells)
    if spell == "Death and Decay" then jps.groundClick() end

    return spell
end
