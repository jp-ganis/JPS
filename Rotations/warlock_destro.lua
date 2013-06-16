function isCotEBlacklisted(unit) -- stop spam curse of the elements at invalid targets @ mop
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

function canUseItemInBags(itemID)
    local itemID = itemID
    if GetItemCount(itemID, false, false) > 0 and select(2,GetItemCooldown(itemID)) == 0 then return true end
    return false
end

function isCastingInterruptSpell(unit)
    if unit == nil then
        local tI,tF = isCastingInterruptSpell("target") 
        local fI,fF = isCastingInterruptSpell("focus") 
        local mI,mF = isCastingInterruptSpell("mouseover") 
        
        return tI or fI or mI, math.min(tF and tI or 10, fF and fI or 10, mF and mI or 10)
    end
    local interruptSpells = {
        "Interrupting Jolt",
    }
    local spell, _, _, _, _, endTime = UnitCastingInfo(unit)
    local finish = endtime and (endTime/1000 - GetTime()) or 0
    for i,j in pairs(interruptSpells) do
        if spell == j then return true, finish end
    end
    return false, finish
end


function hasKilJaedensCunning()
    local selected, talentIndex = GetTalentRowSelectionInfo(6)
    return talentIndex == 17
end


function warlock_destro()
    local currentSpeed, _, _, _, _ = GetUnitSpeed("player")
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
    local timeToBurst = jpsext and jpsext.timeToDie("target", 0.2) or 0
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

    local avoidInterrupts = IsAltKeyDown()
    local enemyCastLeft = 0
    --local avoidInterrupts, enemyCastLeft = isCastingInterruptSpell() 
    if avoidInterrupts and jps.castTimeLeft("player") >= enemyCastLeft then
        SpellStopCasting()
    end
    local maxIntCast = 2.8
    
    local spellTable = {}
    

    spellTable[1] = {
    ["ToolTip"] = "Warlock Lx",
        -- Interrupts
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCast, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCast, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCast, "mouseover"},

        --{ {"macro","/focus [target=mouseover,exists,nodead]"}, IsControlKeyDown() ~= nil },
        
        -- Def CD's
        { "mortal coil", jps.Defensive and jps.hp() <= 0.80 },
        { {"macro","/use Healthstone"},  jps.hp("player") < 0.65 and canUseItemInBags(5512) },
        { "ember tap", jps.Defensive and jps.hp() <= 0.30 and burningEmbers > 0 },

        -- Rain of Fire
        { "rain of fire", jps.Moving and rainOfFireDuration < 1 and UnitExists("target") and UnitGUID("target") == UnitGUID("mouseover") },
        { "rain of fire", IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire") },
        { "rain of fire", IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil and IsSpellInRange("Soulstone", "rain of fire")},
        -- COE Debuff
        { "curse of the elements", not jps.debuff("curse of the elements") and not isCotEBlacklisted("target") },
        { "curse of the elements", attackFocus and not jps.debuff("curse of the elements", "focus") and not isCotEBlacklisted("focus"), "focus" },
        
        -- On the move
        { "fel flame", currentSpeed > 0 and not hasKilJaedensCunning() },
        
        -- CD's
        { {"macro","/cast Dark Soul: Instability"}, jps.cooldown("Dark Soul: Instability") == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { "Lifeblood", jps.UseCDs },
        { {"macro","/use 10"}, jps.glovesCooldown() == 0 and jps.UseCDs },
        { jps.useTrinket(0),       jps.UseCDs },
        { jps.useTrinket(1),       jps.UseCDs },
        
        {"nested", not jps.MultiTarget, {
            { "fire and brimstone", fireAndBrimstoneBuffed },
            { "havoc", attackFocus, "focus" },
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "chaos bolt", not avoidInterrupts and burningEmbers >= 1 and  havocStacks>=3},
            { "immolate", not avoidInterrupts and immolateTarget},
            { "immolate", not avoidInterrupts and immolateFocus, "focus"},
            { "conflagrate", "onCD" },
            { "chaos bolt", not avoidInterrupts and darkSoulActive and emberShards >= 19 },
            { "chaos bolt", not avoidInterrupts and timeToBurst > 5.0 and burningEmbers >= 3 and backdraftStacks < 3},
            { "chaos bolt", not avoidInterrupts and emberShards >= 35},
            { "incinerate", not avoidInterrupts },
            { "fel flame"},
        }},        
        {"nested", jps.MultiTarget, {
            { "shadowburn", burnPhase and burningEmbers > 0  },
            { "fire and brimstone", burningEmbers == 0 and fireAndBrimstoneBuffed },
            { "fire and brimstone", burningEmbers > 0 and not fireAndBrimstoneBuffed },
            { "immolate", not avoidInterrupts and fireAndBrimstoneBuffed and immolateTarget},
            { "incinerate", not avoidInterrupts },
            { "conflagrate"},
            { "fel flame"},
        }},
    }
    spellTable[2] = {
    ["ToolTip"] = "Interrupt Only",
        {"Optical blast", jps.Interrupts and jps.shouldKick("target") and jps.castTimeLeft("target") < maxIntCast, "target" },
        {"Optical blast", jps.Interrupts and jps.shouldKick("focus") and jps.castTimeLeft("focus") < maxIntCast, "focus"},
        {"Optical blast", jps.Interrupts and jps.shouldKick("mouseover") and jps.castTimeLeft("mouseover") < maxIntCast, "mouseover"},

        { {"macro","/focus [target=mouseover,exists,nodead]"}, IsControlKeyDown() ~= nil },
    }


	local spellTableActive = jps.RotationActive(spellTable)
	local spell,target = parseSpellTable(spellTableActive)
	
    if spell == "rain of fire" and jps.CastTimeLeft("player") == 0 then 
        jps.Cast( spell ) 
        jps.groundClick() 
        spell = nil 
    end
    
	return spell,target
end