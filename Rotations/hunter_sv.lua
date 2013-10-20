--[[[
@rotation Default
@class HUNTER
@spec SURVIVAL
@author tropic
@talents Yb!001100!dfgkmM
@description
Features:[br]
[*] auto misdirect to pet if soloing, misdirect to "focus" e.g. in party/raid[br]
[*] Auto use "Healthstone" at 50% hp
[*] mend pet when hp is less than 90%[br]
[*] interrupt spellcasting with Counter Shot[br]
[*] Use CDs: Blows all cooldowns: trinkets, eng. gloves pots (if boss) etc.
[br]
[br]
Trap Keys:[br]
[*][code]SHIFT:[/code] Explosive Trap[br]
[*][code]ALT:[/code] Freezing Trap[br]
[*][code]CONTROL:[/code] Snake Trap[br]
[*][code]SHIFT-CONTROL:[/code] Ice Trap[br]
]]--

jps.registerStaticTable("HUNTER", "SURVIVAL", {
    -- Revive pet
    { hunter.spells.heartOfThePhoenix, 'UnitIsDead("pet") ~= nil and HasPetUI() ~= nil' }, -- Instant revive pet (only some pets, Ferocity)
    { hunter.spells.revivePet, '((UnitIsDead("pet") ~= nil and HasPetUI() ~= nil) or HasPetUI() == nil) and not jps.Moving' },

    -- Heal pet
    { hunter.spells.mendPet, 'jps.hp("pet") < 0.90 and not jps.buff(hunter.spells.mendPet, "pet")' },

    -- Set pet to passive (IMPORTANT!)
    { {"macro", "/script PetPassiveMode()"},    'hunter.petIsPassive() == nil' },
    { {"macro", "/petattack"}, 'hunter.petShouldAttackMyTarget()' },

    -- Aspects
    { hunter.spells.aspectOfTheIronHawk, 'not jps.buff(hunter.spells.aspectOfTheHawk) and not jps.buff(hunter.spells.aspectOfTheIronHawk)' },

    -- Misdirection
    { hunter.spells.misdirection, 'not jps.buff(hunter.spells.misdirection) and UnitExists("focus") == nil and not IsInGroup() and UnitExists("pet") ~= nil', 'pet' }, -- IsInGroup() returns true/false. Works for any party/raid
    { hunter.spells.misdirection, 'not jps.buff(hunter.spells.misdirection) and UnitExists("focus") ~= nil', 'focus' },

    -- Interrupt
    { hunter.spells.counterShot, 'jps.shouldKick() and jps.CastTimeLeft("target") < 1.4' },

    -- Healthstone
    { jps.useBagItem(5512), 'jps.hp("player") < 0.50' },

    -- Trinkets and stuff
    { jps.useTrinket(0), 'jps.UseCDs' },
    { jps.useTrinket(1), 'jps.UseCDs' },
    { jps.useSynapseSprings, 'jps.useSynapseSprings() ~= "" and jps.UseCDs' },
    { jps.DPSRacial, 'jps.UseCDs' },
    { hunter.spells.lifeblood, 'jps.UseCDs' },

    -- CDs
    { hunter.spells.aMurderOfCrows, 'jps.UseCDs and not jps.mydebuff(hunter.spells.aMurderOfCrows)' },
    { hunter.spells.direBeast },
    { hunter.spells.rabid, 'jps.UseCDs' },
    { hunter.spells.rapidFire, 'jps.UseCDs and not jps.buff(hunter.spells.rapidFire) and not jps.bloodlusting()' },
    { hunter.spells.stampede, 'jps.UseCDs' },

    -- Traps
    { hunter.spells.trapLauncher, 'not jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.explosiveTrap, '(hunter.trapKey() == 1 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.freezingTrap, '(hunter.trapKey() == 2 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.snakeTrap, '(hunter.trapKey() == 4 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },
    { hunter.spells.iceTrap, '(hunter.trapKey() == 5 or hunter.trapKey() == 6) and jps.buff(hunter.spells.trapLauncher)' },

    -- Rotation
    { hunter.spells.explosiveShot, 'jps.buff(hunter.buffs.lockAndLoad)' },
    { hunter.spells.glaiveToss },
    { hunter.spells.multiShot, 'jps.MultiTarget' },
    { hunter.spells.cobraShot, 'jps.MultiTarget' },
    { hunter.spells.killShot },
    { hunter.spells.serpentSting, 'jps.myDebuffDuration(hunter.spells.serpentSting, "target") < 0.30' },
    { hunter.spells.explosiveShot },
    { hunter.spells.blackArrow, 'not jps.mydebuff(hunter.spells.blackArrow) and not jps.MultiTarget' },
    { hunter.spells.cobraShot, 'jps.myDebuffDuration(hunter.spells.serpentSting) < 6' },
    { hunter.spells.arcaneShot, 'jps.focus() >= 70 and not jps.buff(hunter.buffs.lockAndLoad) and not jps.MultiTarget' },
    { hunter.spells.cobraShot },
}, "SV Hunter 5.4")
