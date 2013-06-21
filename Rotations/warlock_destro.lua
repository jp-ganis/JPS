--[[
Warlock Destruction Rotations:

Warlock PvE Rotation:
 * SHIFT: Cast Rain of Fire @ Mouse - ONLY if RoF Duration is less than 1 seconds
 * CTRL-SHIFT: Cast Rain of Fire @ Mouse - ignoring the current RoF duration
 * CTRL: Havoc @ Mouse
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

local function toSpellName(id) name = GetSpellInfo(id); return name end
local spells = {}
spells["immolate"] = toSpellName(348)
spells["felFlame"] = toSpellName(77799)
spells["backdraft"] = toSpellName(117896)
spells["rainOfFire"] = toSpellName(5740)
spells["darkSoulInstability"] = toSpellName(113858)
spells["havoc"] = toSpellName(80240)
spells["fireAndBrimstone"] = toSpellName(108683)
spells["opticalBlast"] = toSpellName(119911)
spells["spellLock"] = toSpellName(19647)
spells["mortalCoil"] = toSpellName(6789)
spells["createHealthstone"] = toSpellName(6201)
spells["emberTap"] = toSpellName(114635)
spells["curseOfTheElements"] = toSpellName(1490)
spells["felFlame"] = toSpellName(77799)
spells["shadowburn"] = toSpellName(17877)
spells["chaosBolt"] = toSpellName(116858)
spells["incinerate"] = toSpellName(29722)
spells["conflagrate"] = toSpellName(17962)

spells["lifeblood"] = toSpellName(121279)


local function hasKilJaedensCunning()
    local selected, talentIndex = GetTalentRowSelectionInfo(6)
    return talentIndex == 17
end

function warlock_destro()
    local burningEmbers = UnitPower("player",14)
    local emberShards = UnitPower("player", 14, true)
    local rainOfFireDuration = jps.buffDuration(spells.rainOfFire)
    local backdraftStacks = jps.buffStacks(spells.backdraft)
    local darkSoulActive = jps.buff(spells.darkSoulInstability)
    local havocStacks = jps.buffStacks(spells.havoc)
    local burnPhase = jps.hp("target") <= 0.20
    local attackFocus = false
    local spell = nil
    local fireAndBrimstoneBuffed = jps.buff(spells.fireAndBrimstone, "player")
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
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.spellLock, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},

        -- Def CD's
        {spells.mortalCoil, jps.Defensive and jps.hp() <= 0.80 },
        {spells.createHealthstone, jps.Defensive and GetItemCount(5512, false, false) == 0 and jps.LastCast ~= "create healthstone"},

        { jps.useBagItem(5512), jps.hp("player") < 0.65 }, -- Healthstone
        { spells.emberTap, jps.Defensive and jps.hp() <= 0.30 and burningEmbers > 0 },

        -- Rain of Fire
        { spells.rainOfFire, IsShiftKeyDown() ~= nil and rainOfFireDuration < 1 and GetCurrentKeyBoardFocus() == nil  },
        { spells.rainOfFire, IsShiftKeyDown() ~= nil and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil },
        -- COE Debuff
        { spells.curseOfTheElements, not jps.debuff(spells.curseOfTheElements) },
        { spells.curseOfTheElements, attackFocus and not jps.debuff(spells.curseOfTheElements, "focus"), "focus" },
        
        -- On the move
        { spells.felFlame, jps.Moving and not hasKilJaedensCunning() },
        
        -- CD's
        { {"macro","/cast " .. spells.darkSoulInstability}, jps.cooldown(spells.darkSoulInstability) == 0 and jps.UseCDs },
        { jps.DPSRacial, jps.UseCDs },
        { spells.lifeblood, jps.UseCDs },
        { jps.useSynapseSprings(), jps.UseCDs },
        { jps.useTrinket(0),       jps.UseCDs },
        { jps.useTrinket(1),       jps.UseCDs },
        
        {"nested", not jps.MultiTarget and not avoidInterrupts, {
            { spells.havoc, not IsShiftKeyDown() and IsControlKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil, "mouseover" },
            { spells.havoc, attackFocus, "focus" },
            { spells.shadowburn, burnPhase and burningEmbers > 0  },
            { spells.chaosBolt, burningEmbers >= 1 and  havocStacks>=3},
            jps.dotTracker().castTable("immolate"),
            { spells.conflagrate, "onCD" },
            { spells.chaosBolt, darkSoulActive and emberShards >= 19 },
            { spells.chaosBolt, timeToBurst > 5.0 and burningEmbers >= 3 and backdraftStacks < 3},
            { spells.chaosBolt, emberShards >= 35},
            { spells.incinerate },
        }},
        {"nested", not jps.MultiTarget and avoidInterrupts, {
            { spells.shadowburn, burnPhase and burningEmbers > 0  },
            { spells.conflagrate, "onCD" },
            { "fel flame"},
        }},
        {"nested", jps.MultiTarget, {
            { spells.shadowburn, burnPhase and burningEmbers > 0  },
            { spells.immolate , fireAndBrimstoneBuffed and jps.myDebuffDuration(spells.immolate) <= 2.0 and jps.LastCast ~= spells.immolate},
            { spells.conflagrate, fireAndBrimstoneBuffed },
            { spells.incinerate },
        }},
    }
    spellTable[2] = {
    ["ToolTip"] = "Interrupt Only",
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.opticalBlast, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < maxIntCastLength, "target" },
        {spells.spellLock, jps.Interrupts and jps.shouldKick("focus") and jps.CastTimeLeft("focus") < maxIntCastLength, "focus"},
        {spells.spellLock, jps.Interrupts and jps.shouldKick("mouseover") and jps.CastTimeLeft("mouseover") < maxIntCastLength, "mouseover"},
    }


    local spellTableActive = jps.RotationActive(spellTable)
    local spell,target = parseSpellTable(spellTableActive)

    return spell,target
end