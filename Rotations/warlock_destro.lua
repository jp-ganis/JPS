--[[
Warlock Destruction Rotations:

Warlock PvE Rotation:
 * SHIFT: Cast Rain of Fire @ Mouse - ONLY if RoF Duration is less than 1 seconds
 * CTRL-SHIFT: Cast Rain of Fire @ Mouse - ignoring the current RoF duration
 * ALT: Stop all casts and only use instants (useful for Dark Animus Interrupting Jolt)
 * jps.Interrupts - Casts from target, focus or mouseover will be interrupted (with FelHunter or Observer only!)
 * jps.Defensive - Create Healthstone if necessary, cast mortal coil and use ember tap
 * jps.UseCDs - use short CD's - NO Virmen's Bite, NO Doomguard/Terrorguard etc. - those SHOULDN'T be automated!

Interrupt Only:
 * Interrupt target, focus or mouseover with FelHunter or Observer only (you still need to check jps.Interrupt!)

Known Bugs:
 * [ADDON_ACTION_FORBIDDEN] AddOn "JPS" tried to call the protected function "CameraOrSelectOrMoveStop()".
    This will occur regulary if you cast Rain of Fire while moving...still works so it's just annoying


]]--

-- stop spam curse of the elements at invalid targets @ mop
function isCotEBlacklisted(unit) 
    local table_noSpamCotE = {
        "Twilight Sapper", 
        "Burning Tendons",
        "Corrupted Blood",
        "Energy Charge",
        "Celestial Protector",
    }
    for i,j in pairs(table_noSpamCotE) do
        if UnitName(unit) == j then return true end
    end
    return false
end

function hasKilJaedensCunning()
    local selected, talentIndex = GetTalentRowSelectionInfo(6)
    return talentIndex == 17
end


function warlock_destro()
    local burningEmbers = UnitPower("player",14)
    local emberShards = UnitPower("player", 14, true)
    local immolateDuration = jps.debuffDuration("immolate")
    local focusImmolateDuration = jps.debuffDuration("immolate", "focus")
    local rainOfFireDuration = jps.buffDuration("rain of fire")
    local backdraftStacks = jps.buffStacks("backdraft")
    local darkSoulActive = jps.buff("Dark Soul: Instability")
    local havocStacks = jps.buffStacks("Havoc")
    local burnPhase = jps.hp("target") <= 0.20
    local attackFocus = false
    local spell = nil
    local fireAndBrimstoneBuffed = jps.buff("Fire and Brimstone", "player")
    local timeToBurst = jps.TimeToDie("target", 0.2) or 0
    local avoidInterrupts = IsAltKeyDown()
    local maxIntCastLength = 2.8

    -- If focus exists and is not the same as target, consider attacking focus too
    if UnitExists("focus") ~= nil and UnitGUID("target") ~= UnitGUID("focus") and not UnitIsFriend("player", "focus") then
        attackFocus = true
    end
    

    if avoidInterrupts and jps.CastTimeLeft("player") >= 0 then
        SpellStopCasting()
        jps.NextSpell = {}
    end
    
    local spellTable = {}
    
    --- JPS doesn't seem to react fast enough so you might get stuck with fire and brimstone and no embers...
    if (fireAndBrimstoneBuffed and not jps.MultiTarget) or
       (burningEmbers == 0 and fireAndBrimstoneBuffed) or
       (burningEmbers > 1 and not fireAndBrimstoneBuffed and jps.MultiTarget) then 
        jps.Cast( "fire and brimstone" ) 
    end
    
    spellTable[1] = {
    ["ToolTip"] = "Warlock PvE",
        -- Interrupts
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Spell lock", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},

        -- Def CD's
        { "mortal coil", jps.Defensive and jps.hp() <= 0.80 },
        { "create healthstone", jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= "create healthstone"},

        { jps.useBagItem("Healthstone"), jps.hp("player") < 0.65 },
        { "ember tap", jps.Defensive and jps.hp() <= 0.30 and burningEmbers > 0 },

        -- Rain of Fire
        { "rain of fire", IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire") },
        { "rain of fire", IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire")},
        -- COE Debuff
        { "curse of the elements", not jps.debuff("curse of the elements") and not isCotEBlacklisted("target") },
        { "curse of the elements", attackFocus and not jps.debuff("curse of the elements", "focus") and not isCotEBlacklisted("focus"), "focus" },
        
        -- On the move
        { "fel flame", jps.Moving and not hasKilJaedensCunning() },
        
        -- CD's
        { {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { "Lifeblood", jps.UseCDs },
        { jps.useSynapseSprings(), jps.UseCDs },
        { jps.useTrinket(0),       jps.UseCDs },
        { jps.useTrinket(1),       jps.UseCDs },
        
        {"nested", not jps.MultiTarget and not avoidInterrupts, {
            { "havoc", attackFocus, "focus" },
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "chaos bolt", burningEmbers >= 1 and  havocStacks>=3},
            jps.dotTracker().castTable("immolate"),
            { "conflagrate", "onCD" },
            { "chaos bolt", darkSoulActive and emberShards >= 19 },
            { "chaos bolt", timeToBurst > 5.0 and burningEmbers >= 3 and backdraftStacks < 3},
            { "chaos bolt", emberShards >= 35},
            { "incinerate",},
        }},
        {"nested", not jps.MultiTarget and avoidInterrupts, {
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "conflagrate", "onCD" },
            { "fel flame"},
        }},
        {"nested", jps.MultiTarget, {
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "immolate", fireAndBrimstoneBuffed and jps.debuffDuration("immolate") and jps.LastCast ~= "immolate"},
            { "incinerate", },
            { "conflagrate"},
            { "fel flame"},
        }},
    }
    spellTable[2] = {
    ["ToolTip"] = "Interrupt Only",
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {"Spell lock", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {"Spell lock", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
    }


    local spellTableActive = jps.RotationActive(spellTable)
    local spell,target = parseSpellTable(spellTableActive)

    return spell,target
end