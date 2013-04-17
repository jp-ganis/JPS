function warlock_destro(self)
    --latitude
    local burningEmbers = UnitPower("player",14);   
    local immolateDuration = jps.debuffDuration("immolate");
    local focusImmolateDuration = jps.debuffDuration("immolate", "focus");
    local rainOfFireDuration = jps.buffDuration("rain of fire");
    local backdraftStacks = jps.buffStacks("backdraft");
    local havocStacks = jps.buffStacks("Havoc");
    local burnPhase = jps.hp("target") <= 0.20;
    local attackFocus = false;
    local spell = nil;
    local immolateTarget = false;
    local immolateFocus = false;
    local fireAndBrimstoneBuffed = jps.buff("Fire and Brimstone", "player")
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

    local singleTargetSpellTable = {
        -- Rain of Fire
        { "rain of fire", IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil },
        { "rain of fire", IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
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
        { "chaos bolt", burningEmbers >= 1 and  havocStacks>=3},
        { "immolate", immolateTarget},
        { "immolate", immolateFocus, "focus"},
        { "conflagrate", "onCD" },
        { "chaos bolt", burningEmbers >= 2 and backdraftStacks < 3 or burningEmbers == 4},
        { "incinerate" },
    }   

    local areaOfEffectSpellTable = {
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
        { "conflagrate", fireAndBrimstoneBuffed },
        { "incinerate" },
    }   

    if jps.MultiTarget then
        spell = parseSpellTable( areaOfEffectSpellTable );
    else
        spell = parseSpellTable( singleTargetSpellTable );
    end
    if spell == "rain of fire" then jps.groundClick() end

    return spell
end
