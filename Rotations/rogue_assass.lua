rogue = {}

local function toSpellName(id) local name = GetSpellInfo(id); return name end
rogue.spells = {}
rogue.spells["kick"] = toSpellName(1766)
rogue.spells["shadowBlades"] = toSpellName(121471)
rogue.spells["preparation"] = toSpellName(14185)
rogue.spells["vanish"] = toSpellName(1856)
rogue.spells["ambush"] = toSpellName(8676)
rogue.spells["sliceAndDice"] = toSpellName(5171)
rogue.spells["dispatch"] = toSpellName(111240)
rogue.spells["mutilate"] = toSpellName(1329)
rogue.spells["rupture"] = toSpellName(1943)
rogue.spells["vendetta"] = toSpellName(79140)
rogue.spells["tricksOfTheTrade"] = toSpellName(57934)
rogue.spells["envenom"] = toSpellName(32645)
rogue.spells["crimsonTempest"] = toSpellName(121411)
rogue.spells["fanOfKnives"] = toSpellName(51723)
rogue.spells["stealth"] = toSpellName(1784)
rogue.spells["deadlyPoison"] = toSpellName(2823)
rogue.spells["leechingPoison"] = toSpellName(108211)

jps.registerStaticTable("ROGUE","ASSASSINATION",{
    -- Poisons
    { rogue.spells.deadlyPoison, 'not jps.buff(rogue.spells.deadlyPoison)' },
    { rogue.spells.leechingPoison, 'not jps.buff(rogue.spells.leechingPoison)' },

    -- Healthstone
    {jps.useBagItem(5512), 'jps.hp("player") < 0.65' },

    -- Interrupt
    { rogue.spells.kick, 'jps.Interrupts and jps.shouldKick("target") and jps.CastTimeLeft("target") < 1.5', "target"},

    -- CD's
    { rogue.spells.shadowBlaes, 'jps.bloodlusting() and jps.buffDuration(rogue.spells.sliceAndDice) >= jps.buffDuration(rogue.spells.shadowBlades) and jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },
    { jps.useSynapseSprings() , 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
    { jps.useTrinket(0),       'jps.UseCDs' },
    { jps.useTrinket(1),       'jps.UseCDs' },

    {"nested", not jps.MultiTarget, {
        { rogue.spells.preparation, 'not jps.buff(rogue.spells.vanish) and jps.cooldown(rogue.spells.vanish) > 60' },
        { rogue.spells.vanish, 'IsInGroup() and not jps.buff(rogue.spells.stealth) and not jps.buff(rogue.spells.shadowBlades)' },
        { rogue.spells.ambush },
        { rogue.spells.sliceAndDice, 'jps.buffDuration(rogue.spells.sliceAndDice) <= 2' },
        { rogue.spells.dispatch,    'UnitMana("player") > 90 and jps.debuffDuration(rogue.spells.rupture) < 4' },
        { rogue.spells.mutilate,     'UnitMana("player") > 90 and jps.debuffDuration(rogue.spells.rupture) < 4' },
        { rogue.spells.rupture,    'jps.debuffDuration(rogue.spells.rupture) < 2 or (GetComboPoints("player") == 5 and jps.debuffDuration(rogue.spells.rupture) < 3)' },
        { rogue.spells.vendetta },
        { rogue.spells.tricksOfTheTrade, 'UnitExists("focus") and UnitIsFriend("focus", "player")', "focus" },
        { rogue.spells.tricksOfTheTrade, 'jps.findMeAggroTank() ~= "player"', jps.findMeAggroTank },
        { rogue.spells.envenom, 'GetComboPoints("player") >= 2 and jps.buffDuration(rogue.spells.sliceAndDice) < 3' },
        { rogue.spells.envenom, 'GetComboPoints("player") >= 4 and jps.buffDuration(rogue.spells.envenom) < 1' },
        { rogue.spells.envenom, 'GetComboPoints("player") > 4' },
        { rogue.spells.dispatch, 'GetComboPoints("player") < 5' },
        { rogue.spells.mutilate },
    }},
    {"nested", jps.MultiTarget, {
        { rogue.spells.sliceAndDice, 'jps.buffDuration(rogue.spells.sliceAndDice) <= 2' },
        { rogue.spells.rupture, 'jps.debuffDuration("rupture") < 2 or (GetComboPoints("player") == 5 and jps.debuffDuration("rupture") < 3)' },
        { rogue.spells.crimsonTempest, 'GetComboPoints("player") > 4'},
        { rogue.spells.fanOfKnives },
    }},
}, "Default")

