function click()
    jps.groundClick()
end

function warlock_destro(self)
    --latitude
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
    local immolateTarget = false
    local immolateFocus = false
    local fireAndBrimstoneBuffed = jps.buff("Fire and Brimstone", "player")
    local timeToBurst = jpsext.timeToLive("target", 0.2) or 0
    --local potionCount = GetItemCount("Potion of the Jade Serpent",0,1) 

    -- If focus exists and is not the same as target, consider attacking focus too
    if UnitExists("focus") ~= nil and UnitGUID("target") ~= UnitGUID("focus") and not UnitIsFriend("player", "focus") then
        attackFocus = true
    end
    
    -- Immolate target, if duration is low, avoid double cast (necessary?)
    if immolateDuration < 2 then
        if jps.LastCast == "immolate" and jps.LastTarget ~= "target" or jps.LastCast ~= "immolate" then
            immolateTarget = true
        end
    end
    
    -- Immolate focus, if duration is low, avoid double cast (necessary?)
    if focusImmolateDuration < 2 then
        if jps.LastCast == "immolate" and jps.LastTarget ~= "focus" or jps.LastCast ~= "immolate" then
            immolateFocus = true
        end
    end
    
    -- Banish Mouseover if elemental and less than 1.2 seconds left on banish
    banishMouseover = false
    if IsControlKeyDown() ~= nil  and not UnitIsFriend("player", "mouseover") ~= nil and IsSpellInRange("banish", "mouseover") and UnitCreatureType("mouseover") == "Elemental" then
        local banishDuration = jps.debuffDuration("banish", "mouseover")
        if banishDuration < 1.2 then
            banishMouseover = true
        end
    end
    
    -- Pet Summon?
    --[[
    local selected, talentIndex = GetTalentRowSelectionInfo(5)
    local summonPet = false
    local summonSpell = ""
    if UnitCreatureFamily("pet")==nil and talentIndex == 13 then
        summonSpell = "Summon Observer"
        summonPet = jps.LastCast ~= summonSpell
    end
    ]]

    -- Interrupt based on Pet
    
    --[[
    local interruptCondition = false
    local interruptTable = nil
    if UnitCreatureFamily("pet") == "Observer" then
        _, interruptCondition, interruptTable = jpsext.interruptSpellTable("Optical blast",20)
    elseif UnitCreatureFamily("pet") == "Felhunter" then
        _, interruptCondition, interruptTable = jpsext.interruptSpellTable("Spell Lock",20)
    end
    ]]
    
    local avoidInterrupts = IsAltKeyDown() ~= nil
    if avoidInterrupts and jps.castTimeLeft("player") > 0 then
        SpellStopCasting()
    end
    
    local maxIntCast = 2.8
    local singleTargetSpellTable = {
        -- Interrupts
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.castTimeLeft("target") < maxIntCast, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.castTimeLeft("focus") < maxIntCast, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.castTimeLeft("mouseover") < maxIntCast, "mouseover"},
        -- Resurrect Pet
        --{ summonSpell, summonPet},
        { "fire and brimstone", fireAndBrimstoneBuffed },
        -- Soulstone Mouseover
        { "soulstone", IsControlKeyDown() ~= nil  and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("soulstone", "mouseover"), "mouseover" },
        -- Banish Mouseover
        { "banish", banishMouseover, "mouseover" },
        -- Rain of Fire
        { "rain of fire", jps.Moving and rainOfFireDuration < 1 and UnitExists("target") and UnitGUID("target") == UnitGUID("mouseover") },
        { "rain of fire", IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire") },
        { "rain of fire", IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire")},
        -- COE Debuff
        { "curse of the elements", not jps.debuff("curse of the elements") },
        { "curse of the elements", attackFocus and not jps.debuff("curse of the elements", "focus"), "focus" },
        -- CD's
        { {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
        { jps.useTrinket(1),       jps.UseCDs },
        { jps.useTrinket(2),       jps.UseCDs },
        { "havoc", attackFocus, "focus" },
        { "shadowburn", burnPhase and burningEmbers > 0  },
        { "chaos bolt", not avoidInterrupts and burningEmbers >= 1 and  havocStacks>=3},
        { "immolate", not avoidInterrupts and immolateTarget},
        { "immolate", not avoidInterrupts and immolateFocus, "focus"},
        { "conflagrate", "onCD" },
        { "chaos bolt", not avoidInterrupts and darkSoulActive },
        { "chaos bolt", not avoidInterrupts and timeToBurst > 5.0 and burningEmbers >= 3 and backdraftStacks < 3},
        { "chaos bolt", not avoidInterrupts and emberShards >= 35},
        { "incinerate", not avoidInterrupts },
        { "fel flame"},
    }   

    local areaOfEffectSpellTable = {
        -- Kick Target,Focus or Mouseover
        {"nested", interruptCondition, interruptTable},
        -- Resurrect Pet
        --{ summonSpell, summonPet},
        -- Soulstone Mouseover
        { "soulstone", IsControlKeyDown() ~= nil  and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("soulstone", "mouseover"), "mouseover" },
        -- Banish Mouseover
        { "banish", banishMouseover, "mouseover" },
        -- Rain of Fire
        { "rain of fire", IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil },
        { "rain of fire", IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
        -- COE Debuff
        { "curse of the elements", fireAndBrimstoneBuffed and not jps.debuff("curse of the elements") },
        { "curse of the elements", attackFocus and not jps.debuff("curse of the elements", "focus"), "focus" },
        -- CD's
        { {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
        { jps.useTrinket(1), jps.UseCDs },
        { jps.useTrinket(2), jps.UseCDs },
        { "havoc", attackFocus, "focus" },
        { "shadowburn", burnPhase and burningEmbers > 0  },
        { "fire and brimstone", burningEmbers > 0 and not fireAndBrimstoneBuffed },
        { "immolate", fireAndBrimstoneBuffed and immolateTarget},
        { "incinerate" },
        { "conflagrate"},
    }   

    if jps.MultiTarget then
        spell = parseSpellTable( areaOfEffectSpellTable );
    else
        spell = parseSpellTable( singleTargetSpellTable );
    end
    if spell == "rain of fire" and jps.castTimeLeft("player") == 0 then 
        jps.Cast( spell ) 
        jps.groundClick() 
        spell = nil 
    end

    return spell
end
