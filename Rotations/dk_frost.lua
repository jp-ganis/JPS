function dk_frost(self,initOnly)
    
    if(initOnly == nil and (UnitCanAttack("player","target")~=1 or UnitIsDeadOrGhost("target")==1)) then return end    

    local rp = UnitPower("player",1)
    local ff_dur = jps.debuffDuration("frost fever")
    local bp_dur = jps.debuffDuration("blood plague")
    local wholeRuneCount = 0

    function getRunes()
        wholeRuneCount = 0
        local runes = {}
        local runeNames = {"dr","dr","fr","fr","ur","ur"}
        for i = 1, 6,1 do 
            local oldVal = runes[runeNames[i]] or 0
            wholeRuneCount = sif((select(3,GetRuneCooldown(i)) == true),wholeRuneCount+1,wholeRuneCount)
            runes[runeNames[i]] = (oldVal + sif((select(3,GetRuneCooldown(i)) == true),1,0))
        end

        return runes
    end
    
    function canCastObliterate()
        local runes = getRunes()
        if (runes["fr"] >= 1 and runes["ur"] >= 1) then return true end
        if (runes["dr"] >= 1 and runes["ur"] >= 1) then return true end
        if (runes["fr"] >= 1 and runes["dr"] >= 1) then return true end
        return false
    end
        
    spellTable = {}
    
    spellTable[1] ={
       ["name"] =  "DK Main Table",
       ["tooltip"] = 'hold shift for Death and Decay',
       ["rotation"] = {
                           -- Kicks
                        { "mind freeze",        jps.shouldKick() },
                        { "mind freeze",        jps.shouldKick("focus"), "focus" },
                        { "Strangulate",        jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
                        { "Strangulate",        jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
                
                        -- Buffs
                        { "horn of winter",      "onCD" },
                
                        -- Cooldowns
                        { "Pillar of Frost",    jps.UseCDs },
                        {jps.useTrinket(1),     jps.UseCds },
                        {jps.useTrinket(2),     jps.UseCds },
                        { "Unholy Blight",      jps.UseCds and (ff_dur <= 2 or bp_dur <= 2) and CheckInteractDistance("target",3) },  --only if skilled!!!!
                        { "outbreak",           ff_dur <= 2 or bp_dur <= 2 },    
                        { jps.DPSRacial,        jps.UseCDs and jps["DPS Racial"]},
                        { "raise dead",         jps.UseCDs and jps["Raise Dead (DPS)"] },
                        
                        -- AoE
                        { "death and decay",    jps.MultiTarget and IsShiftKeyDown() ~= nil },
                        {"Pestilence",          jps.MultiTarget and (ff_dur > 10 and bp_dur > 10)},
                
                        -- Mofes
                        { "howling blast",      ff_dur <= 2 },
                        { "plague strike",      bp_dur <= 2 },
                        { "obliterate",         canCastObliterate() },
                        { "frost strike",       rp > 110 },
                        { "howling blast",      jps.buff("Freezing Fog") },
                        { "obliterate",         canCastObliterate() },
                        { "frost strike",       rp > 100 },
                        { "obliterate",         "onCD" },
                        { "frost strike",       "onCD" },
                        { "howling blast",      "onCD" },
                        { "plague strike",      "onCD" },
                        { "Empower Rune Weapon" ,jps.UseCDs},
                }
    };
    spellTable[2] ={
       ["name"] = "DK DW optimized",
       ["tooltip"] = "for Double Wield equipped DK's, hold shift for Death and Decay.",
       ["rotation"] = {
                        -- Kicks
                        { "mind freeze",        jps.shouldKick() },
                        { "mind freeze",        jps.shouldKick("focus"), "focus" },
                        { "Strangulate",        jps.shouldKick() and jps.UseCDs and IsSpellInRange("mind freeze","target")==0 and jps.LastCast ~= "mind freeze" },
                        { "Strangulate",        jps.shouldKick("focus") and jps.UseCDs and IsSpellInRange("mind freeze","focus")==0 and jps.LastCast ~= "mind freeze" , "focus" },
                
                        -- Buffs
                        { "frost presence",       not jps.buff("frost presence") },
                        { "horn of winter",     "onCD" },
                
                        -- Cooldowns
                        { "Pillar of Frost",    jps.UseCDs },
                        {jps.useTrinket(1),     jps.UseCds },
                        {jps.useTrinket(2),     jps.UseCds },
                        { "Unholy Blight",      jps.UseCds and (ff_dur <= 2 or bp_dur <= 2) and CheckInteractDistance("target",3) },  --only if skilled!!!!
                        { "outbreak",           ff_dur <= 2 or bp_dur <= 2 },    
                        { jps.DPSRacial,        jps.UseCDs and jps["DPS Racial"]},
                        { "raise dead",         jps.UseCDs and jps["Raise Dead (DPS)"] },
                        { "Empower Rune Weapon",jps.UseCDs and  wholeRuneCount < 4 },
                        -- AoE
                        {"death and decay",     jps.MultiTarget and IsShiftKeyDown() ~= nil },
                        {"Pestilence",          jps.MultiTarget and (ff_dur > 10 and bp_dur > 10)},
                
                        -- Mofes
                        { "frost strike",       jps.buff("Killing Machine") and rp >= 20 },
                        { "soul reaper",       jps.hp("target") <= 0.35 and UnitLevel("player") >= 87 },
                        { "plague strike",      bp_dur <= 2 },
                        { "howling blast",      ff_dur <= 2 or jps.buff("Freezing Fog")},
                        { "obliterate",         canCastObliterate()},
                        { "frost strike",       rp >= 40 },
                        { "obliterate",         canCastObliterate()},
                        { "frost strike",       "onCD" },
                        { "howling blast",      "onCD" },
                        { "plague strike",      "onCD" },
                        { "Empower Rune Weapon" ,jps.UseCDs},
                        
                  }
    };

    if(initOnly == "init") then
        return spellTable 
    end

    local spell = parseSpellTable(spellTable)
    
    if spell == "death and decay" then
        jps.Cast( spell )
        jps.groundClick()
        spell = nil
    end

    return spell
end