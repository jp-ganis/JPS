--TO DO : tranquility detection

druid = {}


local function toSpellName(id) name = GetSpellInfo(id); return name end
druid.spells = {}
druid.spells["removeCorruption"] = toSpellName(2782)
druid.spells["naturesCure"] = toSpellName(88423)
druid.spells["rebirth"] = toSpellName(20484)
druid.spells["markOfTheWild"] = toSpellName(1126)
druid.spells["barkskin"] = toSpellName(22812)
druid.spells["incarnation"] = toSpellName(106731)
druid.spells["lifebloom"] = toSpellName(33763)
druid.spells["swiftmend"] = toSpellName(81269)
druid.spells["wildGrowth"] = toSpellName(48438)
druid.spells["rejuvination"] = toSpellName(774)
druid.spells["regrowth"] = toSpellName(8936)
druid.spells["naturesSwiftness"] = toSpellName(132158)
druid.spells["healingTouch"] = toSpellName(5185)
druid.spells["nourish"] = toSpellName(50464)
druid.spells["clearcasting"] = toSpellName(16870)
druid.spells["harmony"] = toSpellName(100977)
druid.spells["innervate"] = toSpellName(29166)
druid.spells["soulOfTheForrest"] = toSpellName(48504)
druid.spells["ironbark"] = toSpellName(102342)
druid.spells["wildMushroom"] = toSpellName(88747)
druid.spells["wildMushroomBloom"] = toSpellName(102791)


druid.groupHealTable = {"NoSpell", false, "player"}
function druid.groupHealTarget()
    local tank = jps.findMeATank()
    local healTarget = jps.LowestInRaidStatus()
    if jps.canHeal(tank) and jps.hp(tank) <= 0.5 then healTarget = tank end
    if jps.hpInc("player") < 0.2 then healTarget = "player" end
    return healTarget
end

function druid.hastSotF()
    local selected, talentIndex = GetTalentRowSelectionInfo(4)
    return talentIndex == 10
end

function groupHeal()
    local healTarget = druid.groupHealTarget()
    local healSpell = nil
    if jps.canCast(druid.spells.wildGrowth, healTarget) then
        healSpell = druid.spells.wildGrowth
    elseif jps.canCast(druid.spells.swiftmend, healTarget) and jps.buff(druid.spells.rejuvination,healTarget) or jps.buff(druid.spells.regrowth,healTarget) then
        healSpell = druid.spells.swiftmend
    elseif not jps.buff(druid.spells.rejuvination,healTarget) then
        healSpell = druid.spells.rejuvination
    end
    druid.groupHealTable[1] = healSpell
    druid.groupHealTable[2] = healSpell ~= nil
    druid.groupHealTable[3] = healTarget
    return druid.groupHealTable
end

druid.focusHealTable = {"NoSpell", false, "player"}
druid.focusHealTargets = {"target", "targettarget", "focus", "focustarget"}
function druid.focusHealTarget()
    if jps.hpInc("player") < 0.2 then return "player" end
    -- First Check for low targets
    for _,healTarget in pairs(druid.focusHealTargets) do
        if jps.hpInc(healTarget) < .5 and jps.canHeal(healTarget) then return healTarget end
    end
    -- All above 50% -> take first possible target
    for _,healTarget in pairs(druid.focusHealTargets) do
        if jps.canHeal(healTarget) then return healTarget end
    end
    return nil
end



local dispelTable = {druid.spells.naturesCure}
function druid.dispel()
    local cleanseTarget = nil -- jps.FindMeDispelTarget({"Poison"},{"Curse"},{"Magic"})
    if jps.DispelMagicTarget() then
    	cleanseTarget = jps.DispelMagicTarget()
    elseif jps.DispelDiseaseTarget() then
    	cleanseTarget = jps.DispelDiseaseTarget()
    elseif jps.DispelPoisonTarget() then
    	cleanseTarget = jps.DispelPoisonTarget()
    end
    dispelTable[2] = cleanseTarget ~= nil
    dispelTable[3] = cleanseTarget
    return dispelTable
end



function druid.legacyDefaultTarget()
    --healer
    local tank = nil
    local me = "player"
    
    -- Tank is focus.
    tank = jps.findMeATank()
    
    --Default to healing lowest partymember
    local defaultTarget = jps.LowestInRaidStatus()
    
    --Check that the tank isn't going critical, and that I'm not about to die
    if jps.canHeal(tank) and jps.hp(tank) <= 0.5 then defaultTarget = tank end
    if jps.hpInc(me) < 0.2 then    defaultTarget = me end
    
    return defaultTarget
end

function druid.legacyDefaultHP()
    return jps.hpInc(druid.legacyDefaultTarget())
end

--[[[
@rotation Legacy Rotation
@class DRUID
@spec RESTORATION
@description 
Makes you Top Healer...until you run out of mana. You have to use Innervate and Tranquility manually![br]
]]--


jps.registerStaticTable("DRUID","RESTORATION",{
["ToolTip"] = "Legacy Rotation",
    -- rebirth Ctrl-key + mouseover
    { druid.spells.rebirth, 'IsControlKeyDown() ~= nil and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("rebirth", "mouseover")', "mouseover" },
    
    -- Buffs
    { druid.spells.markOfTheWild, 'not jps.buff(druid.spells.markOfTheWild)', player },
    
    -- CDs
    { druid.spells.barkskin, 'jps.hp() < 0.50' },
    { druid.spells.incarnation, 'IsShiftKeyDown() ~= nil and GetCurrentKeyBoardFocus() == nil' },
    
    druid.dispel,
    { druid.spells.lifebloom, 'jps.buffDuration(druid.spells.lifebloom,jps.findMeATank()) < 3 or jps.buffStacks(druid.spells.lifebloom,jps.findMeATank()) < 3', jps.findMeATank },
    { druid.spells.swiftmend, 'druid.legacyDefaultHP() < 0.85 and (jps.buff(druid.spells.rejuvination,druid.legacyDefaultTarget()) or jps.buff(druid.spells.regrowth,druid.legacyDefaultTarget()))', druid.legacyDefaultTarget },
    { druid.spells.wildGrowth, 'druid.legacyDefaultHP() < 0.95 and jps.MultiTarget', druid.legacyDefaultTarget },
    { druid.spells.rejuvination, 'druid.legacyDefaultHP() < 0.95 and not jps.buff(druid.spells.rejuvination,druid.legacyDefaultTarget())', druid.legacyDefaultTarget },
    { druid.spells.rejuvination, 'jps.buffDuration(druid.spells.rejuvination,jps.findMeATank()) < 3', jps.findMeATank },
    { druid.spells.regrowth, 'druid.legacyDefaultHP() < 0.55 or jps.buff(druid.spells.clearcasting)', druid.legacyDefaultTarget },
    { druid.spells.naturesSwiftness, 'druid.legacyDefaultHP() < 0.40' },
    { druid.spells.healingTouch, '(jps.buff(druid.spells.naturesSwiftness) or not jps.Moving) and druid.legacyDefaultHP() < 0.55', druid.legacyDefaultTarget },    
    { druid.spells.nourish, 'druid.legacyDefaultHP() < 0.85', druid.legacyDefaultTarget },
    --    { "nourish",            jps.hp(tank) < 0.9 or jps.buffDuration("lifebloom",tank) < 5, tank },
}, "Legacy Rotation")


--[[[
@rotation Advanced Rotation
@class DRUID
@spec RESTORATION
@talents UY!002010!gUTSPF
@author Kirk24788
@description 
This is a Raid-Rotation, don't use it for PvP!. It's focus is mana conserve and minimum overheal. You might not end up as top healer but you shouldn't
run out of mana. Don't worry, if there is something to heal, it will heal! Use Tranquility manually.
[br]
Modifiers:[br]
[*] [code]SHIFT[/code]: Place Wild Mushroom[br]
[*] [code]CTRL-SHIFT[/code]: Cast Wild Mushroom: Bloom[br]
]]--

jps.registerStaticTable("DRUID","RESTORATION",{
    -- rebirth Ctrl-key + mouseover
    { druid.spells.rebirth, 'IsControlKeyDown() ~= nil and UnitIsDeadOrGhost("target") ~= nil and IsSpellInRange("rebirth", "target")', "target" },
    { druid.spells.rebirth, 'IsControlKeyDown() ~= nil and UnitIsDeadOrGhost("mouseover") ~= nil and IsSpellInRange("rebirth", "mouseover")', "mouseover" },
    
    -- Buffs
    { druid.spells.markOfTheWild, 'not jps.buff(druid.spells.markOfTheWild)', player },
    
    -- CDs
    { druid.spells.barkskin, 'jps.hp() < 0.50' },

    -- Dispel
    druid.dispel,

    -- Wild Mushrooms
    {druid.spells.wildMushroomBloom, 'IsShiftKeyDown() and IsControlKeyDown() and not GetCurrentKeyBoardFocus()' },
    {druid.spells.wildMushroom, 'IsShiftKeyDown() and druid.activeMushrooms() < 3 and not GetCurrentKeyBoardFocus()'  },
    
    -- Innervate
    {druid.spells.innervate, 'jps.mana("player") < 0.75', "player"},
    
    -- Group Heal
    {"nested", 'not jps.Defensive', {
        -- Lifebloom on tank
        { druid.spells.lifebloom, 'jps.buffDuration(druid.spells.lifebloom,jps.findMeATank()) < 3 or jps.buffStacks(druid.spells.lifebloom,jps.findMeATank()) < 3', jps.findMeATank },
        -- Harmony!
        { druid.spells.nourish, 'jps.buffDuration(druid.spells.harmony) < 3', jps.findMeATank },
        -- Group Heal
        { druid.spells.rejuvination, 'jps.hpInc(druid.groupHealTarget()) < 0.80 and not jps.buff(druid.spells.rejuvination,druid.groupHealTarget())', druid.groupHealTarget },
        { druid.spells.swiftmend, 'jps.buff(druid.spells.rejuvination,druid.groupHealTarget()) or jps.buff(druid.spells.regrowth,druid.groupHealTarget())', druid.groupHealTarget },
        { druid.spells.wildGrowth, 'druid.hastSotF() and jps.buff(druid.spells.soulOfTheForrest) or not druid.hastSotF()', druid.groupHealTarget },
    }},

    -- Focus Heal
    {"nested", 'jps.Defensive and druid.focusHealTarget() ~= nil', {
        { druid.spells.regrowth, 'jps.buffDuration(druid.spells.harmony) < 2 and not jps.buff(druid.spells.regrowth, druid.focusHealTarget())', druid.focusHealTarget },
        { druid.spells.nourish, 'jps.buffDuration(druid.spells.harmony) < 3 and jps.buff(druid.spells.regrowth, druid.focusHealTarget())', druid.focusHealTarget },
        { druid.spells.ironbark, 'jps.hp(jps.findMeATank())', jps.findMeATank },
        { druid.spells.lifebloom, 'jps.buffDuration(druid.spells.lifebloom,jps.findMeATank()) < 3 or jps.buffStacks(druid.spells.lifebloom,jps.findMeATank()) < 3', jps.findMeATank },
        { druid.spells.rejuvination, 'jps.buffDuration(druid.spells.rejuvination,druid.focusHealTarget()) < 2', druid.focusHealTarget },
        { druid.spells.swiftmend, 'jps.buff(druid.spells.rejuvination,druid.focusHealTarget()) or jps.buff(druid.spells.regrowth,druid.focusHealTarget())', druid.focusHealTarget },
        { druid.spells.naturesSwiftness, 'jps.hpInc(druid.focusHealTarget()) < 0.40' },
        { druid.spells.healingTouch, 'jps.buff(druid.spells.naturesSwiftness) and jps.hpInc(druid.focusHealTarget()) < 0.55', druid.focusHealTarget },
        { druid.spells.regrowth, 'jps.hpInc(druid.focusHealTarget()) < 0.75 and jps.buff(druid.spells.clearcasting)', druid.focusHealTarget },
        { druid.spells.regrowth, 'jps.hpInc(druid.focusHealTarget()) < 0.55 and not jps.buff(druid.spells.regrowth, druid.focusHealTarget())', druid.focusHealTarget },
        { druid.spells.nourish, 'jps.hpInc(druid.focusHealTarget()) < 0.85', druid.focusHealTarget },
    }},
},"Advanced Rotation")
