if not paladin then paladin = {} end
function toSpellName(id) local name = GetSpellInfo(id); return name end
paladin.spells = {}
paladin.spells["avengingWrath"] = toSpellName(31884)
paladin.spells["blessingOfKings"] = toSpellName(20217)
paladin.spells["blessingOfMight"] = toSpellName(19740)
paladin.spells["blazingContempt"] = toSpellName(166831)
paladin.spells["cleanse"] = toSpellName(4987)
paladin.spells["crusaderStrike"] = toSpellName(35395)
paladin.spells["divineCrusader"] = toSpellName(144595)
paladin.spells["divineProtection"] = toSpellName(498)
paladin.spells["divinePurpose"] = toSpellName(86172)
paladin.spells["divineShield"] = toSpellName(642)
paladin.spells["divineStorm"] = toSpellName(53385)
paladin.spells["emancipate"] = toSpellName(121783)
paladin.spells["exorcism"] = toSpellName(879)
paladin.spells["empoweredSeals"] = toSpellName(152263)
paladin.spells["executionSentence"] = toSpellName(114157)
paladin.spells["finalVerdict"] = toSpellName(157048)
paladin.spells["paladin.spells.exorcism"] = toSpellName(879)
paladin.spells["empoweredDivineStorm"] = toSpellName(144595)
paladin.spells["fistOfJustice"] = toSpellName(105593)
paladin.spells["flashOfLight"] = toSpellName(19750)
paladin.spells["hammerOfTheRighteous"] = toSpellName(53595)
paladin.spells["hammerOfWrath"] = toSpellName(24275)
paladin.spells["handOfFreedom"] = toSpellName(1044)
paladin.spells["handOfProtection"] = toSpellName(1022)
paladin.spells["handOfPurity"] = toSpellName(114039)
paladin.spells["handOfSacrifice"] = toSpellName(6940)
paladin.spells["holyAvenger"] = toSpellName(105809)
paladin.spells["judgement"] = toSpellName(20271)
paladin.spells["layOnHands"] = toSpellName(633)
paladin.spells["maraadsTruth"] = toSpellName(156990)
paladin.spells["rebuke"] = toSpellName(96231)
paladin.spells["reckoning"] = toSpellName(62124)
paladin.spells["sealOfInsight"] = toSpellName(20164)
paladin.spells["sealOfRighteousness"] = toSpellName(20154)
paladin.spells["sealOfTruth"] = toSpellName(31801)
paladin.spells["seraphim"] = toSpellName(152262)
paladin.spells["selflessHealer"] = toSpellName(85804)
paladin.spells["templarsVerdict"] = toSpellName(85256)
paladin.spells["wordOfGlory"] = toSpellName(85673)
paladin.spells["arcaneTorrent"] = toSpellName(155145)

paladin.cp = function()
   return UnitPower("player",9)
end

function paladin.healTarget()
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

jps.registerStaticTable("PALADIN","RETRIBUTION",{

-- Healthstone
{jps.useBagItem(5512),                   'jps.hp("player") < 0.65' },
-- Interrupt
{ paladin.spells.rebuke,                'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.5', "target"},
-- CD's
--{ jps.DPSRacial, 'jps.UseCDs' },

{"nested",'jps.Defensive',{
   { paladin.spells.layOnHands,         'jps.hp("player") < 0.05' },
   { paladin.spells.divineShield,         'jps.hp("player") < 0.10' },   
   --{ paladin.spells.handOfPurity,      'jps.hp(paladin.healTarget()) < 0.75', paladin.healTarget() },
   { paladin.spells.wordOfGlory,         'paladin.cp() > 3 and jps.hp(paladin.healTarget()) < 0.50', paladin.healTarget() },
   --{ paladin.spells.handOfSacrifice,      'jps.hp("player") > 0.90 and jps.hp(paladin.healTarget()) < 0.50', paladin.healTarget() },
   }},

{"nested", 'not jps.MultiTarget', {
   { paladin.spells.flashOfLight,         'jps.buffStacks(paladin.spells.selflessHealer) = 3 and jps.hp(paladin.healTarget()) < 0.96', paladin.healTarget() },
   { paladin.spells.divineStorm,          'paladin.cp() == 5 and jps.buff(paladin.spells.empoweredDivineStorm) and jps.buff(paladin.spells.finalVerdict)' },
   { paladin.spells.templarsVerdict,       'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and paladin.cp() >= 3' },
   { paladin.spells.hammerOfWrath },
   { paladin.spells.exorcism,            'jps.buff(paladin.spells.blazingContempt)' },
   { paladin.spells.crusaderStrike,      'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1' },
   { paladin.spells.seraphim,            'paladin.cp() > 4' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.empoweredDivineStorm)' },
   { paladin.spells.templarsVerdict,       'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and paladin.cp() == 3' },
   { paladin.spells.executionSentence,      'jps.TimeToDie("target") > 12' },
   { paladin.spells.sealOfTruth,          'GetShapeshiftForm() ~= 1' },
   { paladin.spells.judgement },
   { paladin.spells.avengingWrath,         'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and jps.UseCDs' },   
   { paladin.spells.holyAvenger,         'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and jps.UseCDs' },
   { paladin.spells.exorcism },
}},

{"nested", 'jps.MultiTarget', {
   { paladin.spells.flashOfLight,         'jps.buffStacks(paladin.spells.selflessHealer) = 3 and jps.hp(paladin.healTarget()) < 0.99', paladin.healTarget() },
   { paladin.spells.hammerOfWrath },
   { paladin.spells.sealOfRighteousness,    'GetShapeshiftForm() ~= 2' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.empoweredDivineStorm)' },
   { paladin.spells.avengingWrath,         'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and jps.UseCDs' },
   { paladin.spells.executionSentence,      'jps.TimeToDie("target") > 12' },
   { paladin.spells.holyAvenger,         'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and jps.UseCDs' },
   { paladin.spells.divineStorm,          'paladin.cp() >= 3' },   
   { paladin.spells.hammerOfTheRighteous,   'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1' },
   { paladin.spells.exorcism },
   { paladin.spells.judgement },
}},
   
}, "Noxxic")

jps.registerStaticTable("PALADIN","RETRIBUTION",{

-- Healthstone
{jps.useBagItem(5512),                   'jps.hp("player") < 0.65' },
-- Interrupt
{ paladin.spells.rebuke,                'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.5', "target"},
-- CD's
--{ jps.DPSRacial, 'jps.UseCDs' },

{"nested",'jps.Defensive',{
   { paladin.spells.layOnHands,         'jps.buff("forbearance") and jps.hp("player") < 0.05' },
   { paladin.spells.divineShield,         'jps.hp("player") < 0.10' },
   { paladin.spells.flashOfLight,         'jps.buffStacks(paladin.spells.selflessHealer) = 3 and jps.hp(paladin.healTarget()) < 0.95', paladin.healTarget() },
   --{ paladin.spells.handOfPurity,         'jps.hp(paladin.healTarget()) < 0.75', paladin.healTarget() },
   { paladin.spells.wordOfGlory,         'paladin.cp() > 3 and jps.hp(paladin.healTarget()) < 0.50', paladin.healTarget() },
   --{ paladin.spells.handOfSacrifice,      'jps.hp("player") > 0.90 and jps.hp(paladin.healTarget()) < 0.50', paladin.healTarget() },
   }},

   {"nested", 'not jps.MultiTarget', {
   { paladin.spells.flashOfLight,         'jps.buffStacks(paladin.spells.selflessHealer) = 3 and jps.hp(paladin.healTarget()) < 0.99', paladin.healTarget() },
   { paladin.spells.executionSentence,      'jps.TimeToDie("target") > 12' },
   { paladin.spells.holyAvenger,          'jps.buff(paladin.spells.seraphim) and jps.UseCDs' },
   { paladin.spells.holyAvenger,           'paladin.cp() <= 2 and jps.talentInfo(paladin.spells.seraphim) and jps.UseCDs' },
   { paladin.spells.avengingWrath,       'jps.buff(paladin.spells.seraphim) and jps.UseCDs' },
   { paladin.spells.avengingWrath,       'jps.talentInfo(paladin.spells.seraphim) and jps.UseCDs' },
   { paladin.spells.seraphim },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and paladin.cp() > 4 and jps.buff(paladin.spells.finalVerdict)' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and paladin.cp() > 4 and jps.talentInfo(paladin.spells.finalVerdict)' }, 
   { paladin.spells.divineStorm,          'paladin.cp() > 4 and jps.buff(paladin.spells.finalVerdict)' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and paladin.cp() > 4 and (jps.talentInfo(paladin.spells.seraphim) and jps.cooldown(paladin.spells.seraphim) <=4)' },
   { paladin.spells.templarsVerdict,       'paladin.cp() > 4 or (jps.buff("Holy Avenger") and paladin.cp() >= 3) and (jps.talentInfo(paladin.spells.seraphim) and jps.cooldown(paladin.spells.seraphim) <=4)' },
   { paladin.spells.templarsVerdict,       'jps.buff(paladin.spells.divinePurpose) and jps.buffDuration(paladin.spells.divinePurpose) < 4' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and jps.buffDuration(paladin.spells.divineCrusader) < 4 and jps.talentInfo(paladin.spells.finalVerdict)' }, 
   { paladin.spells.finalVerdict,         'paladin.cp() > 4 or (jps.buff("Holy Avenger") and paladin.cp() >= 3)' },
   { paladin.spells.finalVerdict,         'jps.buff(paladin.spells.divinePurpose) and jps.buffDuration(paladin.spells.divinePurpose) < 4' },
   { paladin.spells.hammerOfWrath }, 
   { paladin.spells.judgement,            'jps.talentInfo(paladin.spells.empoweredSeals) and jps.buff(paladin.spells.maraadsTruth)' },   
   { paladin.spells.exorcism,            'jps.buff("Blazing Contempt") and paladin.cp() <=2 and not jps.buff("Holy Avenger")' },
   { paladin.spells.sealOfTruth,         'jps.talentInfo(paladin.spells.empoweredSeals) and jps.buff(paladin.spells.maraadsTruth) and jps.buffDuration(paladin.spells.maraadsTruth) <=3' },      
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and jps.buff(paladin.spells.finalVerdict) and (jps.buff("Avenging Wrath") and jps.hp("Target") < 0.35)' },
   { paladin.spells.finalVerdict,         'jps.buff(paladin.spells.divinePurpose) and jps.hp("Target") < 0.35' },
   { paladin.spells.templarsVerdict,       'jps.buff(paladin.spells.divinePurpose) and jps.hp("Target") < 0.35 and (jps.talentInfo(paladin.spells.seraphim) and jps.cooldown(paladin.spells.seraphim) <=4)' },
   { paladin.spells.crusaderStrike },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and (jps.buff("Avenging Wrath") or jps.hp("Target") < 0.35) and jps.talentInfo(paladin.spells.finalVerdict)' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and jps.buff(paladin.spells.finalVerdict)' },
   { paladin.spells.finalVerdict },
   { paladin.spells.sealOfRighteousness,   'jps.talentInfo(paladin.spells.empoweredSeals) and jps.buff(paladin.spells.maraadsTruth) and jps.buffDuration(paladin.spells.maraadsTruth) <=3' },
   { paladin.spells.judgement },
   { paladin.spells.templarsVerdict,       'jps.buff(paladin.spells.divinePurpose)' },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.divineCrusader) and jps.talentInfo(paladin.spells.finalVerdict)' },
   { paladin.spells.templarsVerdict,       'paladin.cp() >= 4 and (jps.talentInfo(paladin.spells.seraphim) and jps.cooldown(paladin.spells.seraphim) <=4)' },
   { paladin.spells.exorcism },
   { paladin.spells.templarsVerdict,       'paladin.cp() >= 3 and (jps.talentInfo(paladin.spells.seraphim) and jps.cooldown(paladin.spells.seraphim) <=4)' },
   { paladin.spells.holyPrism },
}},

{"nested", 'jps.MultiTarget', {
   { paladin.spells.flashOfLight,         'jps.buffStacks(paladin.spells.selflessHealer) = 3 and jps.hp(paladin.healTarget()) < 0.99', paladin.healTarget() },
   { paladin.spells.sealOfRighteousness,    'GetShapeshiftForm() ~= 2' },
   { paladin.spells.avengingWrath,         'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and jps.UseCDs' },
   { paladin.spells.executionSentence,      'jps.TimeToDie("target") > 12' },
   { paladin.spells.holyAvenger,         'IsSpellInRange(paladin.spells.crusaderStrike,"target") == 1 and jps.UseCDs' },
   { paladin.spells.divineStorm,          'paladin.cp() > 4' },
   { paladin.spells.hammerOfWrath },
   { paladin.spells.hammerOfTheRighteous },
   { paladin.spells.judgement },
   { paladin.spells.exorcism },
   { paladin.spells.divineStorm,          'jps.buff(paladin.spells.empoweredDivineStorm)' },
}},
   
}, "SimCraft")
